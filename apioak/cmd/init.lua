local pl_app = require("pl.lapp")
local log = require "apioak.pdk.log"

local cmds_arr = {}
local cmds = {
  start = true,
  stop = true,
  quit = true,
  restart = true,
  reload = true,
  help = true,
  test = true,
  env = true,
  version = true,
}

for k in pairs(cmds) do
    cmds_arr[#cmds_arr+1] = k
end

table.sort(cmds_arr)

local help = string.format([[
Usage: apioak COMMAND
The available commands are:
 %s]], table.concat(cmds_arr, "\n ") .. "\n ")

return function(args)
    local cmd_name = table.remove(args, 1)
    if not cmd_name then
        pl_app(help)
        pl_app.quit()
    elseif not cmds[cmd_name] then
        pl_app(help)
        pl_app.quit("No such command: " .. cmd_name)
    end

    local cmd = require("apioak.cmd." .. cmd_name)
    local cmd_lapp = cmd.lapp
    local cmd_exec = cmd.execute

    if cmd_lapp then
        args = pl_app(cmd_lapp)
    end

    -- check sub-commands
    if cmd.sub_commands then
        local sub_cmd = table.remove(args, 1)
        if not sub_cmd then
        pl_app.quit()
        elseif not cmd.sub_commands[sub_cmd] then
        pl_app.quit("No such command for " .. cmd_name .. ": " .. sub_cmd)
        else
        args.command = sub_cmd
        end
    end

    log.debug("ngx_lua: %s", ngx.config.ngx_lua_version)
    log.debug("nginx: %s", ngx.config.nginx_version)
    log.debug("Lua: %s", jit and jit.version or _VERSION)

    xpcall(function() cmd_exec(args) end, function(err)
        if not (args.v or args.vv) then
        err = err:match "^.-:.-:.(.*)$"
        io.stderr:write("Error: " .. err .. "\n")
        else
        local trace = debug.traceback(err, 2)
        io.stderr:write("Error: \n")
        io.stderr:write(trace .. "\n")
        end

        pl_app.quit(nil, true)
    end)
end