local pdk = require("apioak.pdk")

local _M = {}

function _M.loading()
    local config_all     = pdk.config.all()
    local config_plugins = config_all.plugins
    local plugins = {}
    for _, config_plugin in ipairs(config_plugins) do
        local plugin_path = pdk.string.format("apioak.plugin.%s", config_plugin)
        local ok, plugin = pcall(require, plugin_path)
        if ok then
            pdk.table.insert(plugins, plugin)
        end
    end
    return plugins
end

function _M.init_worker()

end

return _M
