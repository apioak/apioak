local ngx = ngx
local pdk = require("apioak.pdk")
local sys = require("apioak.sys")
local limit_conn = require("resty.limit.conn")
local ngx_var    = ngx.var
local ngx_sleep  = ngx.sleep

local plugin_common = require("apioak.plugin.plugin_common")

local plugin_name = "limit-conn"

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

        local limit_new, err = limit_conn.new(
                "plugin_limit_conn", plugin_config.rate, plugin_config.burst, plugin_config.default_conn_delay)

        if not limit_new then
            pdk.log.error("[limit-conn] failed to instantiate a resty.limit.conn object: ", err)
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
        pdk.response.exit(500, { message = "[limit-conn] Failed to instantiate a Limit-Conn object" })
    end

    local unique_key = ngx_var.remote_addr

    local delay, err = limit:incoming(unique_key, true)

    if not delay then
        if err == "rejected" then
            pdk.response.exit(503, { message = "[limit-conn] Access denied" })
        end
        pdk.response.exit(500, { message = "[limit-conn] Failed to limit request, " .. err })
    end

    if limit:is_committed() then
        plugin_config.res = pdk.table.new(0, 3)
        plugin_config.res.limit = limit
        plugin_config.res.key   = unique_key
        plugin_config.res.delay = delay
    end

    if delay >= 0.001 then
        ngx_sleep(delay)
    end

end

function _M.http_log(oak_ctx, plugin_config)

    local limit_conn_res = plugin_config.res

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