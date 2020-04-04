local pdk = require("apioak.pdk")
local sys = require("apioak.sys")
local limit_conn = require("resty.limit.conn")
local ngx_var    = ngx.var
local ngx_sleep  = ngx.sleep

local plugin_name = "limit-conn"

local _M = {
    name        = plugin_name,
    type        = "Traffic Control",
    description = "Lua module for limiting request concurrency (or concurrent connections).",
    config = {
        rate = {
            type        = "number",
            minimum     = 1,
            maximum     = 100000,
            default     = 200,
            description = "the maximum number of concurrent requests allowed."
        },
        burst = {
            type        = "number",
            minimum     = 0,
            maximum     = 50000,
            default     = 100,
            description = "the number of excessive concurrent requests (or connections) allowed to be delayed."
        },
        default_conn_delay = {
            type        = "number",
            minimum     = 0,
            maximum     = 60,
            default     = 1,
            description = "the default processing latency of a typical connection (or request)."
        }
    }
}

local config_schema = {
    type = "object",
    properties = {
        rate = {
            type    = "number",
            minimum = 1,
            maximum = 100000,
        },
        burst = {
            type    = "number",
            minimum = 1,
            maximum = 50000,
        },
        default_conn_delay = {
            type    = "number",
            minimum = 1,
            maximum = 60,
        }
    },
    required = { "rate", "burst", "default_conn_delay" }
}

local function create_limit_object(router_id, config)
    local cache_key = pdk.string.format("%s:ROUTER:%s", plugin_name, router_id)

    local limit = sys.cache.get(cache_key)
    if not limit then
        local err
        limit, err = limit_conn.new("plugin_limit_conn", config.rate, config.burst, config.default_conn_delay)
        if not limit then
            pdk.log.error("[Limit-Conn] failed to instantiate a resty.limit.conn object: ", err)
        else
            sys.cache.set(cache_key, limit, 86400)
        end
    end

    return limit
end

function _M.http_access(oak_ctx)
    local router  = oak_ctx.router or {}
    local plugins = router.plugins

    if not plugins then
        return
    end

    local router_plugin = plugins[plugin_name]
    if not router_plugin then
        return
    end

    local plugin_config = router_plugin.config or {}
    local _, err_message = pdk.schema.check(config_schema, plugin_config)
    if err_message then
        pdk.log.error("[Limit-Conn] Authorization FAIL, backend config error, " .. err_message)
        pdk.response.exit(500)
    end

    local limit = create_limit_object(router.id, plugin_config)
    if not limit then
        pdk.response.exit(500, { err_message = "[Limit-Conn] Failed to instantiate a Limit-Conn object" })
    end

    local unique_key = ngx_var.remote_addr
    local delay, err = limit:incoming(unique_key, true)
    if not delay then
        if err == "rejected" then
            pdk.response.exit(503, { err_message = "[Limit-Conn] Access denied" })
        end
        pdk.response.exit(500, { err_message = "[Limit-Conn] Failed to limit request, " .. err })
    end

    if limit:is_committed() then
        router_plugin.res = pdk.table.new(0, 3)
        router_plugin.res.limit = limit
        router_plugin.res.key   = unique_key
        router_plugin.res.delay = delay
    end

    if delay >= 0.001 then
        ngx_sleep(delay)
    end

    plugins[plugin_name]   = router_plugin
    oak_ctx.router.plugins = plugins
end

function _M.http_log(oak_ctx)
    local router  = oak_ctx.router or {}
    local plugins = router.plugins

    if not plugins then
        return
    end

    local router_plugin = plugins[plugin_name]
    if not router_plugin then
        return
    end

    local limit_conn_res = router_plugin.res
    if not limit_conn_res then
        return
    end

    local key   = limit_conn_res.key
    local limit = limit_conn_res.limit
    local delay = limit_conn_res.delay

    local request_time = ngx_var.request_time
    local latency      = pdk.string.tonumber(request_time) - delay
    local conn, err = limit:leaving(key, latency)
    if not conn then
        pdk.log.error("failed to record the connection leaving request: ", err)
    end
end

return _M
