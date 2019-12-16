local pcall         = pcall
local ipairs        = ipairs
local config        = require("apioak.pdk.config")
local table_insert  = table.insert
local string_format = string.format

local _M = {}

function _M.loading()
    local config_all = config.all()
    local config_plugins = config_all.plugins
    local plugins = {}
    for _, config_plugin in ipairs(config_plugins) do
        local plugin_path = string_format("apioak.plugin.%s", config_plugin)
        local ok, plugin = pcall(require, plugin_path)
        if ok then
            table_insert(plugins, plugin)
        end
    end
    return plugins
end

return _M
