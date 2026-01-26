local script_path = debug.getinfo(1).source:sub(2)

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function execute_cmd(cmd)
    local t = io.popen(cmd)
    local data = t:read("*all")
    t:close()
    return data
end

local apioak_home
if script_path:sub(1, 4) == '/usr' or script_path:sub(1, 4) == '/bin' then
    -- 系统安装模式：使用标准 LuaRocks tree 路径
    apioak_home = "/usr/local/apioak"
    package.cpath = "/usr/local/apioak/lib/lua/5.1/?.so;"
            .. package.cpath

    package.path = "/usr/local/apioak/share/lua/5.1/?.lua;"
            .. "/usr/local/apioak/share/lua/5.1/?/init.lua;"
            .. package.path
else
    -- 开发模式：使用 lua_modules
    apioak_home = trim(execute_cmd("pwd"))
    local lua_modules_path = apioak_home .. "/lua_modules"

    package.cpath = lua_modules_path .. "/lib/lua/5.1/?.so;"
            .. package.cpath

    package.path = lua_modules_path .. "/share/lua/5.1/?.lua;"
            .. lua_modules_path .. "/share/lua/5.1/?/init.lua;"
            .. package.path
end

local openresty_bin = trim(execute_cmd("which openresty"))
if not openresty_bin then
    error("can not find the openresty.")
end

local openresty_launch = openresty_bin .. [[  -p ]] .. apioak_home .. [[ -c ]]
        .. apioak_home .. [[/conf/nginx.conf]]

return {
    apioak_home = apioak_home,
    openresty_launch = openresty_launch,
    trim = trim,
    execute_cmd = execute_cmd,
}