local pdk          = require("apioak.pdk")
local yaml         = require("tinyyaml")
local io_open      = io.open
local ngx_timer_at      = ngx.timer.at
local ngx_config_prefix = ngx.config.prefix

local config_objects

local _M = {}

local function loading_configs(premature)
    if premature then
        return
    end

    local file, err = io_open(ngx_config_prefix() .. "conf/apioak.yaml", "r")
    if err then
        pdk.log.error("[sys.config] failed to open configuration file, ", err)
        return
    end

    local content = file:read("*a")
    file:close()

    local config = yaml.parse(content)
    if not config then
        pdk.log.error("[sys.config] failed to parse configuration file")
        return
    end

    config_objects = config
end

function _M.init_worker()
    ngx_timer_at(0, loading_configs)
end

function _M.query(key)
    if not config_objects then
        loading_configs()
    end

    if not config_objects[key] then
        return nil, key .. " is not set in the configuration file"
    end

    return config_objects[key], nil
end

return _M
