local nginx_signals = require "apioak/cmd/utils/nginx_signals"

local lapp = [[
Usage: apioak start
]]

local function execute()
    nginx_signals.start()
end

return {
    lapp = lapp,
    execute = execute
}