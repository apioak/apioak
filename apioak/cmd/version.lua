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

local function execute(args)
  if args.all then
    print(string.format(str,
      meta.__VERSION,
      ngx.config.ngx_lua_version,
      ngx.config.nginx_version,
      jit and jit.version or _VERSION
    ))
  else
    print(meta.__VERSION)
  end
end

return {
  lapp = lapp,
  execute = execute
}
