local pdk = require("apioak.pdk")

local _M = {}

function _M.plugin_config_schema(plugin_name, plugin_config)

    local plugin_schema = require("apioak.plugin." .. plugin_name .. ".schema-" .. plugin_name)

    local _, err = pdk.schema.check(plugin_schema.schema, plugin_config)

    if err then
        return err
    end

    return nil
end

return _M