local nginx_signals = require "apioak/cmd/utils/nginx_signals"

local lapp = [[
Usage: apioak quit
]]

local function execute(args)
    nginx_signals.quit()
end

return {
    lapp = lapp,
    execute = execute
}