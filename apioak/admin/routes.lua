local pdk = require("apioak.pdk")

local _M = {}

function _M.get(id)
    local key = "/routes"
    if id then
        key = string.format("%s/%s", key, id)
    end
    local res, err = pdk.etcd.get(key)
    if err then
        return 500, err
    end
    return res.status, res.body
end

function _M.put(id, conf)
    local key = "routes"
    if id then
        key = string.format("%s/%s", key, id)
    end
    local res, err = pdk.etcd.set(key, conf)
    if err then
        return 500, err
    end
    return res.status, res.body
end

function _M.post(conf)
    local key = "routes"
    local res, err = pdk.etcd.push(key, conf)
    if err then
        return 500, err
    end
    return res.status, res.body
end

function _M.delete(id)
    local key = "/routes"
    if id then
        key = string.format("%s/%s", key, id)
    end
    local res, err = pdk.etcd.del(key)
    if err then
        return 500, err
    end
    return res.status, res.body
end

return _M
