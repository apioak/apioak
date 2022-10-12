local stop  = require("apioak.cmd.stop")
local start = require("apioak.cmd.start")

local lapp = [[
Usage: apioak restart
]]

local function execute()

    pcall(stop.execute)

    pcall(start.execute)
end

return {
    lapp = lapp,
    execute = execute
}