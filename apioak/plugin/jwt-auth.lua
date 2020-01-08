local jwt      = require("resty.jwt")
local pdk      = require("apioak.pdk")

local _M = {
    type  = 'Authentication',
    name  = "Jwt Auth",
    desc  = "Add a jwt authentication to your APIs.",
    key   = "jwt-auth",
    order = 1301
}

local schema = {
    type = "object",
    properties = {
        secret = {
            type = "string",
        }
    },
    required = { "secret" }
}

local function is_credential_in_header(secret, header_credential)
    local res = jwt.verify(_M.key, secret, header_credential)
    return res.verified
end

local function is_credential_in_query(secret, query_credential)
    local res = jwt.verify(_M.key, secret, query_credential)
    return res.verified
end

local function is_authorized(secret, header_credential, query_credential)
    if not secret then return false end
    local authorized = false

    if is_credential_in_header(secret, header_credential) then
        authorized = true
    elseif is_credential_in_query(secret, query_credential) then
        authorized = true
    end
    return authorized
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

    local header_credential = pdk.request.header("Authorization")
    local query_credential = pdk.request.query('token')

    local is_success = is_authorized(plugin_conf.secret, header_credential, query_credential)

    if not is_success then
        pdk.response.exit(403, { err_message = "Authorization Required" })
    end
end



return _M



