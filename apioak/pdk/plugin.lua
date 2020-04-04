local pcall   = pcall
local config  = require("apioak.sys.config")
local stringx = require("apioak.pdk.string")
local tablex  = require("apioak.pdk.table")

local _M = {}

function _M.loading()
    local res, err = config.query("plugins")
    if err then
        return nil, err
    end

    local plugins = {}
    for i = 1, #res do
        local plugin_path = stringx.format("apioak.plugin.%s", res[i])
        local ok, plugin = pcall(require, plugin_path)
        if ok then
            tablex.insert(plugins, plugin)
        end
    end

    return plugins, nil
end

return _M
