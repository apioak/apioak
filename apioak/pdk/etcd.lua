local etcd = require("resty.etcd")
local config = require("apioak.pdk.config")

local function etcd_client()
    local all_config = config.all()
    local etcd_config = all_config.etcd
    local local_config = {
        http_host = etcd_config.host or nil,
        timeout = etcd_config.timeout or nil
    }
    local cli, err = etcd.new(local_config)
    if err then
        return nil, err
    end
    return {
        client = cli,
        prefix = etcd_config.prefix
    }, nil
end

local _ETCD = {}
_ETCD.new = etcd_client()

function _ETCD.get(key)
    local cli, err = etcd_client().client
    if err then
        return nil, err
    end
    key = string.format("%s/%s", etcd_client().prefix)
    return  cli:get(key)
end

function _ETCD.set(key, value)
    local cli, err = etcd_client().client
    if err then
        return nil, err
    end
    key = string.format("%s/%s", etcd_client().prefix)
    return cli:set(key, value)
end

function _ETCD.push(key, value)
    local cli, err = etcd_client().client
    if err then
        return nil, err
    end
    key = string.format("%s/%s", etcd_client().prefix)
    return cli:push(key, value)
end

function _ETCD.del(key)
    local cli, err = etcd_client().client
    if err then
        return nil, err
    end
    key = string.format("%s/%s", etcd_client().prefix)
    return cli:delete(key)
end

return _ETCD

