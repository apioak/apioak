local limit_count_new = require("resty.limit.count").new
local ngx_var = ngx.var
local pdk = require("apioak.pdk")

local _M = {
    name        = "limit-count",
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

local schema = {
    type = "object",
    properties = {
        count = {
            type = "integer",
            minLength = 1
        },
        time_window = {
            type = "integer",
            minLength = 1
        },
        key = {
            type = "string",
        }
    },
    required = { "count", "time_window", "key" }
}

local function create_limit_obj(conf)
    local limit, err = pdk.shared.get(_M.key)
    if not err then
        return limit, nil
    end

    limit, err = limit_count_new("plugin_limit_count", conf.count, conf.time_window)
    if not limit then
        return nil, err
    end
    pdk.shared.set(_M.key, limit)
    return limit, nil
end

function _M.http_access(oak_ctx)
    if not oak_ctx.plugins or not oak_ctx.plugins[_M.name] then
        return false, nil
    end

    local plugin_conf = oak_ctx.plugins[_M.name]
    local _, err = pdk.schema.check(schema, plugin_conf)
    if err then
        return false, nil
    end

    local limit, err = create_limit_obj(plugin_conf)
    if not limit then
        pdk.response.exit(500,
                { err_message = "failed to instantiate a resty.limit.count object: " ..  err })
    end

    local key = ngx_var[plugin_conf.key] or "0.0.0.0"
    local delay, err = limit:incoming(key, true)
    if not delay then
        if err == "rejected" then
            ngx.header["X-RateLimit-Limit"] = plugin_conf.rate
            ngx.header["X-RateLimit-Remaining"] = 0
            pdk.response.exit(503, { err_message =  err })
        else
            pdk.response.exit(500, { err_message =  err })
        end
    end

    ngx.header["X-RateLimit-Limit"] = plugin_conf.rate
    ngx.header["X-RateLimit-Remaining"] = err
end

return _M
