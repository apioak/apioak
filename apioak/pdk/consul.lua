local config = require("apioak.sys.config")
local resty_consul = require('resty.consul')

local _M = {
    _VERSION = '0.6.0',
    instance = {},
}

local DEFAULT_HOST            = "127.0.0.1"
local DEFAULT_PORT            = 8500
local DEFAULT_COONECT_TIMEOUT = 60*1000 -- 60s default timeout
local DEFAULT_READ_TIMEOUT    = 60*1000 -- 60s default timeout

function _M.init()

    local conf, err = config.query("consul")

    if err or conf == nil then
        return
    end

    local consul = resty_consul:new({
        host            = conf.host or DEFAULT_HOST,
        port            = conf.port or DEFAULT_PORT,
        connect_timeout = conf.connect_timeout or DEFAULT_COONECT_TIMEOUT, -- 60s
        read_timeout    = conf.read_timeout or DEFAULT_READ_TIMEOUT, -- 60s
        default_args    = {},
        ssl             = conf.ssl or false,
        ssl_verify      = conf.ssl_verify or true,
        sni_host        = conf.sni_host or nil,
    })

    _M.instance = consul
end

return _M