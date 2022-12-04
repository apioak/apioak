local pcall   = pcall
local config  = require("apioak.sys.config")
local stringx = require("apioak.pdk.string")
local tablex  = require("apioak.pdk.table")
local logx    = require("apioak.pdk.log")

local _M = {}

function _M.loading()

    local res, err = config.query("plugins")

    if err then
        return nil, err
    end

    local plugins = {}

    for i = 1, #res do

        local plugin_path = stringx.format("apioak.plugin.%s.%s", res[i], res[i])

        local ok, plugin = pcall(require, plugin_path)

        if ok then
            tablex.insert(plugins, plugin)
        end
    end

    return plugins, nil
end


function _M.plugins_loading()

    local plugins, err = config.query("plugins")

    if err then
        logx.error("[pdk.plugin] get plugin data error: [" .. tostring(err) .. "]")
        return nil
    end

    local plugin_data_list = {}

    for i = 1, #plugins do

        local plugin_path = stringx.format("apioak.plugin.%s.%s", plugins[i], plugins[i])

        local ok, plugin_handlers = pcall(require, plugin_path)

        if ok and plugin_handlers ~= true then
            tablex.insert(plugin_data_list, {
                key     = plugins[i],
                handler = plugin_handlers
            })
        end
    end

    if next(plugin_data_list) then
        return plugin_data_list
    end

    return nil
end

return _M
