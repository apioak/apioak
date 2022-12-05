local pdk = require("apioak.pdk")
local jwt = require("resty.jwt")

local plugin_name = "jwt-auth"

local _M = {}

function _M.schema_config(config)

    local plugin_schema = require("apioak.plugin." .. plugin_name .. ".schema-" .. plugin_name)

    local _, err = pdk.schema.check(plugin_schema.schema, config)

    if err then
        return err
    end

    return nil
end

function _M.http_access(oak_ctx, plugin_config)

    local matched = oak_ctx.matched

    if not matched.header then
        pdk.log.error("[jwt-Auth] oak_ctx format err!")
    end

    local jwt_token = matched.header["APIOAK-JWT-AUTH"]

    if not jwt_token then
        pdk.response.exit(
                401, { message = "[jwt-auth] Authorization FAIL, header \"APIOAK-JWT-AUTH\" is required" })
    end

    local jwt_verify = jwt:verify(plugin_config.jwt_key, jwt_token)

    if not jwt_verify.verified then
        pdk.response.exit(401, { err_message = "[jwt-auth] Authorization FAIL" })
    end

end

return _M