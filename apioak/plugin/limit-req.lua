local pdk = require("apioak.pdk")
local sys = require("apioak.sys")
local limit_req  = require("resty.limit.req")
local ngx_var    = ngx.var
local ngx_sleep  = ngx.sleep

local plugin_name = "limit-req"

local _M = {
    name        = "limit-req",
    type        = "Traffic Control",
    description = "Lua module for limiting request rate.",
    config = {
        rate = {
            type        = "number",
            minimum     = 1,
            maximum     = 100000,
            default     = 200,
            description = "the specified request rate (number per second) threshold."
        },
        burst = {
            type        = "number",
            minimum     = 0,
            maximum     = 5000,
            default     = 100,
            description = "the number of excessive requests per second allowed to be delayed."
        }
    }
}

local config_schema = {
    type = "object",
    properties = {
        rate = {
            type      = "integer",
            minLength = 1,
            minimum   = 1,
            maximum   = 100000,
        },
        burst = {
            type    = "integer",
            minimum = 0,
            maximum = 5000,
        }
    },
    required = { "rate", "burst" }
}

local function create_limit_object(router_id, config)
    local cache_key = pdk.string.format("%s:ROUTER:%s", plugin_name, router_id)

    local limit = sys.cache.get(cache_key)
    if not limit then
        local err
        limit, err = limit_req.new("plugin_limit_req", config.rate, config.burst)
        if not limit then
            pdk.log.error("[Limit-Req] failed to instantiate a resty.limit.req object: ", err)
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
        pdk.log.error("[Limit-Req] Authorization FAIL, backend config error, " .. err_message)
        pdk.response.exit(500)
    end

    local limit = create_limit_object(router.id, plugin_config)
    if not limit then
        pdk.response.exit(500, { err_message = "[Limit-Req] Failed to instantiate a Limit-Req object" })
    end

    local unique_key = ngx_var.remote_addr
    local delay, err = limit:incoming(unique_key, true)
    if not delay then
        if err == "rejected" then
            pdk.response.exit(503, { err_message = "[Limit-Req] Access denied" })
        end
        pdk.response.exit(500, { err_message = "[Limit-Req] Failed to limit request, " .. err })
    end

    if delay >= 0.001 then
        ngx_sleep(delay)
    end
end

return _M
