local nginx_signals = require "apioak/cmd/utils/nginx_signals"

local lapp = [[
Usage: apioak stop
]]

local function execute(args)
    nginx_signals.stop()
end

return {
    lapp = lapp,
    execute = execute
}