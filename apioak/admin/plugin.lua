local ipairs = ipairs
local pdk    = require("apioak.pdk")

local _M = {}

_M.cached_key = "/plugins"

function _M.list()
    local responses = {}
    local plugins = pdk.plugin.loading()
    for _, plugin in ipairs(plugins) do
        pdk.table.insert(responses, {
            name  = plugin.name,
            type  = plugin.type,
            desc  = plugin.desc,
            key   = plugin.key,
            order = plugin.order,
        })
    end
    pdk.response.exit(200, responses)
end

return _M
