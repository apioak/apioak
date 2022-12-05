local pdk = require("apioak.pdk")

local plugin_name = "key-auth"

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
        pdk.log.error("[key-Auth] oak_ctx format err!")
    end

    local header_key = matched.header["APIOAK-KEY-AUTH"]

    if not header_key then
        pdk.response.exit(
                401, { message = "[key-auth] Authorization FAIL, header \"APIOAK-KEY-AUTH\" is required" })
    end

    if header_key ~= plugin_config.secret then
        pdk.response.exit(401, { message = "[key-auth] Authorization FAIL" })
    end

end

return _M