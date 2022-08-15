local log = require("apioak.cmd.utils.log")
local stop = require("apioak.cmd.stop")
local start = require("apioak.cmd.start")
local kill = require("apioak.cmd.utils.kill")

local lapp = [[
Usage: apioak restart
]]

local function execute(args)

    pcall(stop.execute, args, {quiet = true})

    log.enable()

    pcall(start.execute)
end

return {
    lapp = lapp,
    execute = execute
}