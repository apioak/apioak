local limit_req_new = require("resty.limit.req").new
local ngx_var = ngx.var
local pdk = require("apioak.pdk")

local _M = {
    type = "Traffic Control",
    name = "Limit Req",
    desc = "Add a limit req to your APIs.",
    key = "limit-req",
    order = 1103,
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
        }
    },
    required = { "rate", "burst", "key" }
}

local function create_limit_obj(conf)
    local limit, err = pdk.shared.get(_M.key)
    if not err then
        return limit, nil
    end

    limit, err = limit_req_new("plugin_limit_req", conf.rate, conf.burst)
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
        pdk.response.exit(500,
                { err_message =  "failed to instantiate a resty.limit.req object: " .. err })
    end

    local key = ngx_var[plugin_conf.key] or "0.0.0.0"
    local delay, err = limit:incoming(key, true)
    if not delay then
        if err == "rejected" then
            pdk.response.exit(503, { err_message = err })
        else
            pdk.response.exit(500, { err_message = err })
        end
    end

    if delay >= 0.001 then
        ngx.sleep(delay)
    end
end

return _M
