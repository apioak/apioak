local nginx_signals = require("apioak/cmd/utils/nginx_signals")

local lapp = [[
Usage: apioak reload
]]

local function execute()
    nginx_signals.reload()
end

return {
    lapp = lapp,
    execute = execute
}