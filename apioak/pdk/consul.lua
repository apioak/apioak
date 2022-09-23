local config = require("apioak.sys.config")
local resty_consul = require('resty.consul')

local _M = {
    _VERSION = '0.6.0',
}

local DEFAULT_HOST            = "127.0.0.1"
local DEFAULT_PORT            = 8500
local DEFAULT_COONECT_TIMEOUT = 60*1000 -- 60s default timeout
local DEFAULT_READ_TIMEOUT    = 60*1000 -- 60s default timeout

function _M.new()

    local conf, err = config.query("consul")

    if err or conf == nil then
        return nil, err
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

    return consul, nil

end

function _M.get_key(key)
    local consul, err = _M.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local d, err = consul:get_key(key)

    if err ~= nil or not d or d == nil then
        return nil, err
    end

    if d.status ~= 200 then
        return nil, "get key FAIL"
    end

    return d.body[1].Value, nil

end

return _M