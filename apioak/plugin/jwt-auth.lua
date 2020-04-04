local jwt = require("resty.jwt")
local pdk = require("apioak.pdk")

local plugin_name = "jwt-auth"

local _M = {
    name         = plugin_name,
    type         = "Authentication",
    description  = "Lua module for JWT Authentication.",
    config = {
        secret = {
            type        = "string",
            default     = "A65001FB250D8F2E87E3B5821B2C48C7",
            minLength   = 10,
            maxLength   = 32,
            description = "signature secret key",
        }
    },
}

local config_schema = {
    type = "object",
    properties = {
        secret = {
            type      = "string",
            minLength = 10,
            maxLength = 32,
        }
    },
    required = { "secret" }
}

function _M.http_access(oak_ctx)
    local router  = oak_ctx.router or {}
    local plugins = router.plugins

    if not plugins then
        return
    end

    local router_plugin = plugins[plugin_name]
    if not router_plugin then
        return
    end

    local plugin_config = router_plugin.config or {}
    local _, err = pdk.schema.check(config_schema, plugin_config)
    if err then
        pdk.log.error("[Jwt-Auth] Authorization FAIL, backend config error, " .. err)
        pdk.response.exit(500)
    end

    local certificate = pdk.request.header("APIOAK-JWT-AUTH")
    if not certificate then
        pdk.response.exit(401,
                { err_message = "[Jwt-Auth] Authorization FAIL, property header \"APIOAK-JWT-AUTH\" is required" })
    end

    local res = jwt:verify(plugin_config.secret, certificate)
    if not res.verified then
        pdk.response.exit(401, { err_message = "[Jwt-Auth] Authorization FAIL" })
    end
end

return _M
