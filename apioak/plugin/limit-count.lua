local pdk = require("apioak.pdk")
local sys = require("apioak.sys")
local limit_count = require("resty.limit.count")
local ngx_var     = ngx.var


local plugin_name = "limit-count"

local _M = {
    name        = plugin_name,
    type        = "Traffic Control",
    description = "Lua module for limiting request counts.",
    config = {
        count = {
            type        = "number",
            minimum     = 1,
            maximum     = 100000000,
            default     = 5000,
            description = "the specified number of requests threshold.",
        },
        time_window = {
            type        = "number",
            minimum     = 1,
            maximum     = 86400,
            default     = 3600,
            description = "the time window in seconds before the request count is reset.",
        }
    }
}

local config_schema = {
    type = "object",
    properties = {
        count = {
            type    = "integer",
            minimum = 1,
            maximum = 100000000,
        },
        time_window = {
            type    = "integer",
            minimum = 1,
            maximum = 86400,
        }
    },
    required = { "count", "time_window" }
}

local function create_limit_object(router_id, config)
    local cache_key = pdk.string.format("%s:ROUTER:%s", plugin_name, router_id)

    local limit = sys.cache.get(cache_key)
    if not limit then
        local err
        limit, err = limit_count.new("plugin_limit_count", config.count, config.time_window)
        if not limit then
            pdk.log.error("[Limit-Count] failed to instantiate a resty.limit.count object: ", err)
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
        pdk.log.error("[Limit-Count] Authorization FAIL, backend config error, " .. err_message)
        pdk.response.exit(500)
    end

    local limit = create_limit_object(router.id, plugin_config)
    if not limit then
        pdk.response.exit(500, { err_message = "[Limit-Count] Failed to instantiate a Limit-Count object" })
    end

    local unique_key = ngx_var.remote_addr
    local delay, err = limit:incoming(unique_key, true)
    if not delay then
        if err == "rejected" then
            pdk.response.set_header("X-RateLimit-Limit", router_plugin.config.count)
            pdk.response.set_header("X-RateLimit-Remaining", 0)
            pdk.response.exit(503, { err_message = "[Limit-Count] Access denied" })
        end
        pdk.response.exit(500, { err_message = "[Limit-Count] Failed to limit request, " .. err })
    end

    local remaining = err
    pdk.response.set_header("X-RateLimit-Limit", router_plugin.config.count)
    pdk.response.set_header("X-RateLimit-Remaining", remaining)
end

return _M
