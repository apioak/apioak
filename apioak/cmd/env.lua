local common = require "apioak/cmd/utils/common"

local lapp = [[
Usage: apioak env
]]


local function get_config()
    local res, err = io.open(common.apioak_home .. "/conf/apioak.yaml", "r")
    if not res then
        print("Config Loading         ...FAIL(" .. err ..")")
        os.exit(1)
    else
        print("Config Loading         ...OK")
    end

    local config_content = res:read("*a")
    res:close()

    local yaml = require("tinyyaml")
    local config_table = yaml.parse(config_content)
    if not config_table or type(config_table) ~= "table" then
        print("Config Parse           ...FAIL")
        os.exit(1)
    else
        print("Config Parse           ...OK")
    end

    return config_table, nil
end


local function validate_database()
    local res, err = get_config()
    if not res.database then
        print("Config Database        ...FAIL(Undefined)")
        os.exit(1)
    else
        print("Config Database        ...OK")
    end

    local db_config = res.database

    local mysql  = require("resty.mysql")
    res, err = mysql:new()
    if not res then
        print("Database Init          ...FAIL(".. err ..")")
        os.exit(1)
    else
        print("Database Init          ...OK")
    end
    local db = res

    res, err = db:connect({
        host     = db_config.host     or "127.0.0.1",
        port     = db_config.port     or 3306,
        database = db_config.db_name  or "apioak",
        user     = db_config.user     or "apioak",
        password = db_config.password or ""
    })

    if not res then
        print("Database Connect       ...FAIL(".. err ..")")
        os.exit(1)
    else
        print("Database Connect       ...OK")
    end

    res, err = db:query("SELECT version() AS version")
    if not res then
        print("Database Query Version ...FAIL(".. err ..")")
        os.exit(1)
    else
        print("Database Query Version ...OK")
    end

    local db_version = res[1].version
    local db_version_num = tonumber(string.match(db_version, "^%d+%.%d+"))
    if string.find(db_version, "MariaDB") then
        if db_version_num < 10.2 then
            print("Database Version       ...FAIL(MariaDB version be greater than 10.2)")
            os.exit(1)
        else
            print("Database Version       ...OK")
        end
    else
        if db_version_num < 5.7 then
            print("Database Version       ...FAIL(MySQL version be greater than 5.7)")
            os.exit(1)
        else
            print("Database Version       ...OK")
        end
    end

    res, err = db:query("SHOW tables")
    if not res then
        print("Database Query Tables  ...FAIL(".. err ..")")
        os.exit(1)
    else
        print("Database Query Tables  ...OK")
    end

    local db_tables = {}
    local conf_tables = db_config.tables
    local table_field = 'Tables_in_' .. db_config.db_name
    for i = 1, #res do
        table.insert(db_tables, res[i][table_field])
    end
    if table.sort(db_tables) == table.sort(conf_tables) then
        print("Database Tables        ...OK")
    else
        print("Database Tables        ...FAIL")
    end
end

local function execute(args)
    local nginx_path = common.trim(common.execute_cmd("which openresty"))
    if not nginx_path then
        print("OpenResty PATH         ...FAIL(OpenResty not found in system PATH)")
        os.exit(1)
    else
        print("OpenResty PATH         ...OK")
    end


    if ngx.config.nginx_version < 1015008 then
        print("OpenResty Version      ...FAIL(OpenResty version must be greater than 1.15.8)")
        os.exit(1)
    else

        print("OpenResty Version      ...OK")
    end

    validate_database()
end

return {
    lapp = lapp,
    execute = execute
}