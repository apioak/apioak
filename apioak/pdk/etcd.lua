local type       = type
local error      = error
local str_format = string.format
local etcd       = require("resty.etcd")
local config     = require("apioak.pdk.config")

local function new()
    local all_config  = config.all()
    local etcd_config = all_config.etcd

    local _ETCD = {
        prefix = nil,
    }


    function _ETCD._init()
        local cli, err = etcd.new({
            http_host = etcd_config.host or nil,
            timeout   = etcd_config.timeout or nil,
        })

        if err then
            error("[pdk.etcd] content failure")
        end

        if not etcd_config.prefix or type(etcd_config.prefix) ~= "string" then
            error("[pdk.etcd] prefix [" .. etcd_config.prefix "] invalid")
        end

        _ETCD.prefix = etcd_config.prefix

        return cli
    end


    function _ETCD._valid(key)
        if not key or type(key) ~= "string" then
            error("[pdk.etcd] key [" .. key .. "] invalid")
        end

        return str_format("/%s/%s", _ETCD.prefix, key)
    end


    function _ETCD.get(key)
        local  cli = _ETCD._init()
        key = _ETCD._valid(key)
        return cli:get(key)
    end


    function _ETCD.set(key, value)
        local  cli = _ETCD._init()
        key = _ETCD._valid(key)
        return cli:set(key, value)
    end


    function _ETCD.push(key, value)
        local  cli = _ETCD._init()
        key = _ETCD._valid(key)
        return cli:push(key, value)
    end


    function _ETCD.delete(key)
        local  cli = _ETCD._init()
        key = _ETCD._valid(key)
        return cli:delete(key)
    end


    return _ETCD
end

return {
    new = new
}
