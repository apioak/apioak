local common  = require "apioak/cmd/utils/common"
local io_open = io.open

local lapp = [[
Usage: apioak env
]]

local config

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

local function validate_consul()
    local res, err = get_config()
    if not res.database then
        print("Config Consul          ...FAIL (".. err ..")")
        os.exit(1)
    else
        print("Config Consul          ...OK")
    end

    local conf = res.consul

    local resty_consul = require("resty.consul")
    local consul = resty_consul:new({
        host            = conf.host or '127.0.0.1',
        port            = conf.port or 8500,
        connect_timeout = conf.connect_timeout or 60*1000, -- 60s
        read_timeout    = conf.read_timeout or 60*1000, -- 60s
        default_args    = {},
        ssl             = conf.ssl or false,
        ssl_verify      = conf.ssl_verify or true,
        sni_host        = conf.sni_host or nil,
    })

    local agent_config, err = consul:get('/agent/self')

    if not agent_config then
        print("Consul Connect         ...FAIL (".. err ..")")
        os.exit(1)
    else
        print("Consul Connect         ...OK")
    end

    if agent_config.status ~= 200 then
        print("Consul Config          ...FAIL(" .. agent_config.status ..
                ": " .. string.gsub(agent_config.body, "\n", "") ..")")
        os.exit(1)
    end

    local consul_version_num = tonumber(string.match(agent_config.body.Config.Version, "^%d+%.%d+"))
    if consul_version_num < 1.13 then
        print("Consul Version         ...FAIL (consul version be greater than 1.13)")
        os.exit(1)
    else
        print("Consul Version         ...OK")
    end

    config = res
end

local function validate_plugin()

    local plugins = config.plugins

    local err_plugins = {}

    for i = 1, #plugins do

        local file_path = common.apioak_home .. "/apioak/plugin/" .. plugins[i] .. "/" .. plugins[i] .. ".lua"

        local _, err = io_open(file_path, "r")

        if err then
            table.insert(err_plugins, plugins[i])
        end

    end

    if next(err_plugins) then
        print("Plugin Check           ...FAIL (Plugin not found: " .. table.concat(err_plugins, ', ') .. ")")
        os.exit(1)
    else
        print("Plugin Check           ...OK")
    end
end

local function execute()
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

    validate_consul()

    validate_plugin()
end

return {
    lapp = lapp,
    execute = execute
}