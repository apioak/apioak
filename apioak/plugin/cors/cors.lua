local pdk = require("apioak.pdk")

local plugin_common = require("apioak.plugin.plugin_common")

local plugin_name = "cors"

local _M = {}

function _M.schema_config(config)

    local plugin_schema_err = plugin_common.plugin_config_schema(plugin_name, config)

    if plugin_schema_err then
        return plugin_schema_err
    end

    if config.allow_methods and (#config.allow_methods > 0) then

        local allow_methods_arr = pdk.string.split(config.allow_methods, ",")

        local allow_methods_num = #allow_methods_arr

        local new_methods = {}

        local plugin_schema = require("apioak.plugin." .. plugin_name .. ".schema-" .. plugin_name)

        for i = 1, #allow_methods_arr do

            local method_upper = pdk.string.upper(pdk.string.trim(allow_methods_arr[i]))

            repeat

                if not method_upper or (method_upper == "") then
                    break
                end

                local _, err = pdk.schema.check(plugin_schema.schema_methods_enum, {
                    method = method_upper
                })

                if err then
                    return err
                end

                if allow_methods_num == 1 then
                    pdk.table.insert(new_methods, method_upper)
                else
                    if allow_methods_arr[i] ~= "*" then
                        pdk.table.insert(new_methods, method_upper)
                    end
                end

            until true
        end

        config.allow_methods = pdk.table.concat(new_methods, ",")

    end

    return nil
end

function _M.http_header_filter(oak_ctx, plugin_config)

    if plugin_config.allow_methods and (#plugin_config.allow_methods > 0) then
        pdk.response.set_header("Access-Control-Allow-Methods", plugin_config.allow_methods)
    end

    if plugin_config.allow_origins and (#plugin_config.allow_origins > 0) then
        pdk.response.set_header("Access-Control-Allow-Origin", plugin_config.allow_origins)
    end

    if plugin_config.allow_headers and (#plugin_config.allow_headers > 0) then
        pdk.response.set_header("Access-Control-Expose-Headers", plugin_config.allow_headers)
    end

    if plugin_config.allow_credential then
        pdk.response.set_header("Access-Control-Allow-Credentials", plugin_config.allow_credential)
    end

    if plugin_config.max_age and (plugin_config.max_age > 0) then
        pdk.response.set_header("Access-Control-Max-Age", plugin_config.max_age)
    end

end

return _M