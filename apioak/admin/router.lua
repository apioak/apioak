local pdk = require("apioak.pdk")

local _M = {}

_M.cached_key = "/routers"

function _M.list()

end

function _M.query(params)

    ngx.say("this is get query")
    ngx.say("query: ", params.id)
end

function _M.create(params)
    ngx.say("create: ", params.id)
end

function _M.update(params)
    ngx.say("update: ", params.id)
end

function _M.delete(params)
    ngx.say("delete: ", params.id)
end

function _M.get(id)
    local key = "routes"
    if id then
        key = string.format("%s/%s", key, id)
    end
    local etcd_cli = pdk.etcd.new()
    local res, err = etcd_cli.get(key)
    if err then
        return 500, err
    end
    return res.status, res.body
end

function _M.put(id, conf)
    if not id then
        return 500, { error_msg = " route id undefined" }
    end
    if not conf then
        return 500, { error_msg = " route conf undefined" }
    end

    local res, err = pdk.schema.check(pdk.schema.routes, conf)
    if not res then
        return 500, { error_msg = err }
    end

    local key = pdk.string.format("%s/%s", _M.cached_key, id)
    local etcd_cli = pdk.etcd.new()
    res, err = etcd_cli.set(key, conf)
    if err then
        return 500, err
    end
    return res.status, res.body
end

function _M.post(conf)
    local key = "routes"
    local etcd_cli = pdk.etcd.new()
    local res, err = etcd_cli.push(key, conf)
    if err then
        return 500, err
    end
    return res.status, res.body
end

function _M.del(id)
    local key = "routes"
    if id then
        key = string.format("%s/%s", key, id)
    end
    local etcd_cli = pdk.etcd.new()
    local res, err = etcd_cli.del(key)
    if err then
        return 500, err
    end
    return res.status, res.body
end

return _M
