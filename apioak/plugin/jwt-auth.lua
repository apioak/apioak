local jwt      = require("resty.jwt")
local pdk      = require("apioak.pdk")
local plstring = require("pl.stringx")

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
local function jwt_auth(secret, credential)
    local obj = jwt.verify(_M.key, secret, credential)
    if obj.verified then
        return true
    end
    return false
end

local function is_authorized(secret, header_credential, query_credential)
    if not secret then return false end
    local authorized = false
    if (not header_credential) and (not query_credential) then
        return authorized
    end
    if header_credential then
        authorized = jwt_auth(secret, plstring.split(header_credential, " ")[2])
    elseif query_credential then
        authorized = jwt_auth(secret, query_credential)
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



