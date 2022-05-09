local pdk = require("apioak.pdk")
local config  = require("apioak.sys.config")
local stringx = require("apioak.pdk.string")
local _M = {}

function _M.init_worker()

    local res, err = config.query("plugins")
    if err then
        return
    end

    for i = 1, #res do
        local plugin_path = stringx.format("apioak.plugin.%s", res[i])
        local ok, plugin = pcall(require, plugin_path)
        if not ok then
            pdk.log.error("failed to load plugin err: " .. plugin)
            return
        end
        if plugin.init then
            plugin.init()
        end
    end

end

return _M
