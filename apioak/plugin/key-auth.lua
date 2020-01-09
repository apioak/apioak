local pdk      = require("apioak.pdk")

local _M = {
    type  = 'Authentication',
    name  = "Key Auth",
    desc  = "Add a key authentication to your APIs.",
    key   = "key-auth",
    order = 1201
}

local schema = {
    type = "object",
    properties = {
        secret = {type = "string"},
    },
    required = { "secret" }
}

local function key_verify(header_key, secret)
    if (not header_key) or (not secret) then
        return false
    end

    if header_key == secret then
        return true
    end

    return false
end


function _M.http_access(oak_ctx)
    if not oak_ctx['plugins'] then
        return false, nil
    end

    if not oak_ctx.plugins[_M.key] then
        return false, nil
    end

    local plugin_conf = oak_ctx.plugins[_M.key]

    ngx.say(pdk.json.encode(plugin_conf));

    local _, err = pdk.schema.check(schema, plugin_conf)
    if err then
        return false, nil
    end

    local header_key = pdk.request.header('apikey')
    if not header_key then
        pdk.response.exit(401, { err_message = "Missing API key found in request" })
    end

    local verify = key_verify(header_key, plugin_conf.secret)
    if not verify then
        pdk.response.exit(401, { err_message = "Invalid API key in request" })
    end

    return verify
end

return _M



