local meta = require "apioak.sys.meta"

local lapp = [[
Usage: apioak version [OPTIONS]

Print Apioak's version. With the -a option, will print
the version of all underlying dependencies.

Options:
 -a,--all         get version of all dependencies
]]

local str = [[
apioak: %s
ngx_lua: %s
nginx: %s
Lua: %s]]

local function execute()
  print(string.format(str,
                      meta.__VERSION,
                      ngx.config.ngx_lua_version,
                      ngx.config.nginx_version,
                      jit and jit.version or _VERSION
  ))
end

return {
  lapp = lapp,
  execute = execute
}
