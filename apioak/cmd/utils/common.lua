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
    apioak_home = "/usr/local/apioak"
    package.cpath = "/usr/local/apioak/deps/lib64/lua/5.1/?.so;"
            .. "/usr/local/apioak/deps/lib/lua/5.1/?.so;"
            .. package.cpath

    package.path = "/usr/local/apioak/deps/share/lua/5.1/apioak/lua/?.lua;"
            .. "/usr/local/apioak/deps/share/lua/5.1/?.lua;"
            .. "/usr/share/lua/5.1/apioak/lua/?.lua;"
            .. "/usr/local/share/lua/5.1/apioak/lua/?.lua;"
            .. package.path
else
    apioak_home = trim(execute_cmd("pwd"))
    package.cpath = apioak_home .. "/deps/lib64/lua/5.1/?.so;"
            .. package.cpath

    package.path = apioak_home .. "/apioak/?.lua;"
            .. apioak_home .. "/deps/share/lua/5.1/?.lua;"
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