local pdk = require("apioak.pdk")

local plugin_common = require("apioak.plugin.plugin_common")

local plugin_name = "mock"

local _M = {}

function _M.schema_config(config)

    local plugin_schema_err = plugin_common.plugin_config_schema(plugin_name, config)

    if plugin_schema_err then
        return plugin_schema_err
    end

    return nil
end

function _M.http_access(oak_ctx, plugin_config)

    pdk.response.set_header(pdk.const.RESPONSE_MOCK_REQUEST_KEY, true)

    if plugin_config.http_headers and next(plugin_config.http_headers) then

        for h_key, h_value in pairs(plugin_config.http_headers) do
            pdk.response.set_header(h_key, h_value)
        end

    end

    local decode_body = pdk.json.decode(plugin_config.http_body)

    if decode_body then
        pdk.response.exit(plugin_config.http_code, decode_body, plugin_config.response_type)
    end

    pdk.response.exit(plugin_config.http_code, plugin_config.http_body, plugin_config.response_type)

end

return _M