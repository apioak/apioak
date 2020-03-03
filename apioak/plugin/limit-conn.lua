local limit_conn_new = require("resty.limit.conn").new
local ngx_var = ngx.var
local pdk = require("apioak.pdk")

local _M = {
    name        = "limit-conn",
    type        = "Traffic Control",
    description = "Lua module for limiting request concurrency (or concurrent connections).",
    config = {
        rate = {
            type        = "number",
            minimum     = 1,
            maximum     = 0,
            default     = 200,
            description = "the maximum number of concurrent requests allowed."
        },
        burst = {
            type        = "number",
            minimum     = 1,
            maximum     = 0,
            default     = 100,
            description = "the number of excessive concurrent requests (or connections) allowed to be delayed."
        },
        default_conn_delay = {
            type        = "number",
            minimum     = 1,
            maximum     = 60,
            default     = 1,
            description = "the default processing latency of a typical connection (or request)."
        }
    },
    conf = {}
}

local schema = {
    type = "object",
    properties = {
        rate = {
            type = "integer",
            minLength = 1
        },
        burst = {
            type = "integer",
            minLength = 1
        },
        key = {
            type = "string",
        },
        default_conn_delay = {
            type = "number",
        }
    },
    required = { "rate", "burst", "key", "default_conn_delay" }
}

local function create_limit_obj(conf)
    local limit, err = pdk.shared.get(_M.key)
    if not err then
        return limit, nil
    end

    limit, err = limit_conn_new("plugin_limit_conn", conf.rate, conf.burst, conf.default_conn_delay)
    if not limit then
        return nil, err
    end
    pdk.shared.set(_M.key, limit)
    return limit, nil
end

function _M.http_access(oak_ctx)
    if not oak_ctx['plugins'] then
        return false, nil
    end

    if not oak_ctx.plugins[_M.key] then
        return false, nil
    end
    local plugin_conf = oak_ctx.plugins[_M.key]
    local _, err = pdk.schema.check(schema, plugin_conf)
    if err then
        return false, nil
    end

    local limit, err = create_limit_obj(plugin_conf)
    if not limit then
        pdk.response.exit(500, { err_message = "failed to instantiate a resty.limit.conn object: " .. err })
    end
    _M.conf = plugin_conf

    local key = ngx_var[plugin_conf.key] or "0.0.0.0"
    local delay, err = limit:incoming(key, true)
    if not delay then
        if err == "rejected" then
            pdk.response.exit(503, { err_message = err })
        else
            pdk.response.exit(500, { err_message = err })
        end
    end

    if limit:is_committed() then
        oak_ctx.limit_conn_key = key
        oak_ctx.limit_conn_delay = delay
    end

    if delay >= 0.001 then
        ngx.sleep(delay)
    end
end

function _M.http_log(oak_ctx)
    if next(_M.conf) == nil then
        return
    end
    local limit, err = create_limit_obj(_M.conf)
    if not limit then
        pdk.log.error("failed to instantiate a resty.limit.conn object: ", err)
    end
    local key = oak_ctx.limit_conn_key
    if key then
        local latency = tonumber(ngx_var.request_time) - oak_ctx.limit_conn_delay
        local conn, err = limit:leaving(key, latency)
        if not conn then
            pdk.log.error("failed to record the connection leaving ", "request: ", err)
        end
    end
end

return _M
