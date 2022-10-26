local nginx_signals = require "apioak/cmd/utils/nginx_signals"
local env           = require"apioak/cmd/env"

local lapp = [[
Usage: apioak start
]]

local function execute()
    env.execute()
    print("----------------------------")

    nginx_signals.start()

    print("Apioak started successfully!")
end

return {
    lapp = lapp,
    execute = execute
}