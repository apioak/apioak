local ngx = ngx
local config = require("apioak.sys.config")
local resty_consul = require('resty.consul')
local pdk        = require("apioak.pdk")

local _M = {
    _VERSION = '0.6.0',
}

local DEFAULT_HOST    = "127.0.0.1"
local DEFAULT_PORT    = 8500
local DEFAULT_TIMEOUT = 60*1000 -- 60s default timeout

function _M.new()

    local conf, err = config.query("consul")

    if err or conf == nil then
        return nil, err
    end

    local consul = resty_consul:new({
        host            = conf.host or "127.0.0.1",
        port            = conf.port or 8500,
        connect_timeout = conf.connect_timeout or (60*1000), -- 60s
        read_timeout    = conf.read_timeout or (60*1000), -- 60s
        default_args    = {},
        ssl             = conf.ssl or false,
        ssl_verify      = conf.ssl_verify or true,
        sni_host        = conf.sni_host or nil,
    })

    return consul, nil

end

return _M