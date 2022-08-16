local log = require("apioak.pdk.log")
local stop = require("apioak.cmd.stop")
local start = require("apioak.cmd.start")

local lapp = [[
Usage: apioak restart
]]

local function execute(args)

    pcall(stop.execute, args, {quiet = true})

    pcall(start.execute)
end

return {
    lapp = lapp,
    execute = execute
}