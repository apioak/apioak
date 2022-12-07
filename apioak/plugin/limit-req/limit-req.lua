local ngx = ngx
local pdk = require("apioak.pdk")
local sys = require("apioak.sys")
local limit_req  = require("resty.limit.req")
local ngx_var    = ngx.var
local ngx_sleep  = ngx.sleep

local plugin_common = require("apioak.plugin.plugin_common")

local plugin_name = "limit-req"


local _M = {}

function _M.schema_config(config)

    local plugin_schema_err = plugin_common.plugin_config_schema(plugin_name, config)

    if plugin_schema_err then
        return plugin_schema_err
    end

    return nil
end

local function create_limit_object(matched, plugin_config)

    local cache_key = pdk.string.format("%s:ROUTER:%s:%s", plugin_name, matched.host, matched.uri)

    local limit = sys.cache.get(cache_key)

    if not limit then

        local limit_new, err = limit_req.new("plugin_limit_req", plugin_config.rate, plugin_config.burst)

        if not limit_new then
            pdk.log.error("[limit-req] failed to instantiate a resty.limit.req object: ", err)
        else
            sys.cache.set(cache_key, limit_new, 86400)
        end

        limit = limit_new
    end

    return limit

end

function _M.http_access(oak_ctx, plugin_config)

    local matched = oak_ctx.matched

    if not matched.host or not matched.uri then
        pdk.response.exit(500, { message = "[limit-conn] Configuration data format error" })
    end

    local limit = create_limit_object(matched, plugin_config)
    if not limit then
        pdk.response.exit(500, { message = "[limit-req] Failed to instantiate a Limit-Req object" })
    end

    local unique_key = ngx_var.remote_addr

    local delay, err = limit:incoming(unique_key, true)

    if not delay then

        if err == "rejected" then
            pdk.response.exit(503, { message = "[limit-req] Access denied" })
        end
        pdk.response.exit(500, { message = "[limit-req] Failed to limit request, " .. err })

    end

    if delay >= 0.001 then
        ngx_sleep(delay)
    end

end



return _M