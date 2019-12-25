local limit_count_new = require("resty.limit.count").new
local ngx_var = ngx.var
local pdk = require("apioak.pdk")

local _M = {
    type  = "Traffic Control",
    name  = "Limit Count",
    desc  = "Add a limit count to your APIs.",
    key   = "limit-count",
    order = 1102
}

local schema = {
    type = "object",
    properties = {
        rate = {
            type = "integer",
            minLength = 1
        },
        seconds = {
            type = "integer",
            minLength = 1
        },
        key = {
            type = "string",
        }
    },
    required = { "rate", "seconds", "key" }
}

local function create_limit_obj(conf)
    local limit, err = pdk.shared.get(_M.key)
    if not err then
        return limit, nil
    end

    limit, err = limit_count_new("plugin_limit_count", conf.rate, conf.seconds)
    if not limit then
        return nil, err
    end
    pdk.shared.set(_M.key, limit)
    return limit, nil
end

function _M.http_access(oak_ctx)
    if not oak_ctx['plugins'] then
        return 200, nil
    end

    if not oak_ctx.plugins[_M.key] then
        return 200, nil
    end
    local plugin_conf = oak_ctx.plugins[_M.key]
    local _, err = pdk.schema.check(schema, plugin_conf)
    if err then
        return 200, nil
    end

    local limit, err = create_limit_obj(plugin_conf)
    if not limit then
        return 500, "failed to instantiate a resty.limit.req object: ", err
    end

    local key = ngx_var[plugin_conf.key] or "0.0.0.0"
    local delay, err = limit:incoming(key, true)
    if not delay then
        if err == "rejected" then
            ngx.header["X-RateLimit-Limit"] = plugin_conf.rate
            ngx.header["X-RateLimit-Remaining"] = 0
            return 503, "rejected"
        end
        return 500, err
    end

    ngx.header["X-RateLimit-Limit"] = plugin_conf.rate
    ngx.header["X-RateLimit-Remaining"] = err
    return 200, nil;
end

return _M
