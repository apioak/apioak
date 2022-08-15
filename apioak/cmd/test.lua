
local nginx_signals = require "apioak/cmd/utils/nginx_signals"

local lapp = [[
Usage: apioak test

]]

local function execute()
    nginx_signals.test()
end
    
return {
    lapp = lapp,
    execute = execute
}