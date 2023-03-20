local ngx         = ngx
local rand        = math.random
local pdk         = require("apioak.pdk")
local config      = require("apioak.sys.config")

local _M = {}

_M.APIOAK_PREFIX = function()

    local conf, err = config.query("consul")

    if err or not conf then
        return "apioak/"
    end

    return conf.prefix .. "/"
end

_M.SYSTEM_PREFIX = _M.APIOAK_PREFIX() .. "system/mapping/"
_M.DATA_PREFIX   = _M.APIOAK_PREFIX() .. "data/"
_M.HASH_PREFIX   = _M.APIOAK_PREFIX() .. "system/hash/"

_M.SYSTEM_PREFIX_MAP = {
    services       = _M.SYSTEM_PREFIX .. pdk.const.CONSUL_PRFX_SERVICES .. "/",
    routers        = _M.SYSTEM_PREFIX .. pdk.const.CONSUL_PRFX_ROUTERS .. "/",
    plugins        = _M.SYSTEM_PREFIX .. pdk.const.CONSUL_PRFX_PLUGINS .. "/",
    upstreams      = _M.SYSTEM_PREFIX .. pdk.const.CONSUL_PRFX_UPSTREAMS .. "/",
    certificates   = _M.SYSTEM_PREFIX .. pdk.const.CONSUL_PRFX_CERTIFICATES .. "/",
    upstream_nodes = _M.SYSTEM_PREFIX .. pdk.const.CONSUL_PRFX_UPSTREAM_NODES .. "/",
}

_M.PREFIX_MAP = {
    services       = _M.DATA_PREFIX .. pdk.const.CONSUL_PRFX_SERVICES .. "/",
    routers        = _M.DATA_PREFIX .. pdk.const.CONSUL_PRFX_ROUTERS .. "/",
    plugins        = _M.DATA_PREFIX .. pdk.const.CONSUL_PRFX_PLUGINS .. "/",
    upstreams      = _M.DATA_PREFIX .. pdk.const.CONSUL_PRFX_UPSTREAMS .. "/",
    certificates   = _M.DATA_PREFIX .. pdk.const.CONSUL_PRFX_CERTIFICATES .. "/",
    upstream_nodes = _M.DATA_PREFIX .. pdk.const.CONSUL_PRFX_UPSTREAM_NODES .. "/",
}

_M.HASH_PREFIX_MAP = {
    sync_update = _M.HASH_PREFIX .. "sync/update",
}

function _M.get_key(key)

    local d, err = pdk.consul.instance:get_key(key)

    if err then
        return nil, err
    end

    if type(d.body) ~= "table" then
        return nil, nil
    end

    if not d.body[1].Value then
        return nil, nil
    end

    return d.body[1].Value, nil
end

function _M.put_key(key, value, args)

    local d, err = pdk.consul.instance:put_key(key, value, args)

    if err then
        return false, err
    end

    if d and (d.status == 200) then
        return d.body, nil
    end

    return false, ("[" .. d.status .. "]" .. d.reason)
end

function _M.list_keys(prefix)

    local keys, err = pdk.consul.instance:list_keys(prefix)

    if err then
        return nil, err
    end

    local res = {}

    if not keys or not keys.body then
        return { list = res }, nil
    end

    if type(keys.body) ~= "table" then
        return { list = res }, nil
    end

    for i = 1, #keys.body do

        local d, err = _M.get_key(keys.body[i])

        if err == nil and d then
            table.insert(res, pdk.json.decode(d))
        end
    end

    return { list = res }, nil
end

function _M.detail_key(key)

    local d, err = _M.get_key(key)

    if err then
        return nil, "failed to get Key-Value detail with key [" .. key .. "], err[" .. tostring(err) .. "]"
    end

    if not d then
        return nil, nil
    end

    return d, nil

end

function _M.delete_key(key)

    local g, err = _M.get_key(key)

    if err then
        return nil, "Key-Value:[" .. key .. "] does not exists], err:[" .. tostring(err) .. "]"
    end

    if not g then
        return nil, "Key-Value:[" .. key .. "] does not exists]"
    end

    local d, err = pdk.consul.instance:delete_key(key)

    if err then
        return nil, "failed to delete Key-Value with key [" .. key .. "], err[" .. tostring(err) .. "]"
    end

    if not d then
        return nil, "failed to delete Key-Value with key [" .. key .. "]"
    end

    return {}, nil

end

function _M.txn(payload)

    local res, err = pdk.consul.instance:txn(payload)

    if err then
        return nil, "exec txn error, payload:[" .. pdk.json.encode(payload) .. "], err:[" .. tostring(err) .. "]"
    end

    if not res then
        return nil, "exec txn error, payload:[" .. pdk.json.encode(payload) .. "]"
    end

    local ret = {}

    if type(res.body) ~= "table" or type(res.body.Results) ~= "table" then
        return ret, "exec txn error"
    end

    for i = 1, #res.body.Results do
        ret[i] = res.body.Results[i]
    end

    return ret, nil
end

function _M.batch_check_kv_exists(params, prefix)

    if type(params) ~= "table" then
        return nil, "params format error, err:[table expected, got " .. type(params) .. "]"
    end

    if #params == 0 then
        return nil, "parameter cannot be empty:[" .. pdk.json.encode(params, true) .. "]"
    end

    local exists_data, exists_id_map = {}, {}

    for _, item in ipairs(params) do

        repeat
            if not item.id and not item.name then
                break
            end

            local res, err = _M.check_kv_exists(item, prefix)

            if err then
                return nil, err
            end

            if not res then
                break
            end

            if exists_id_map[res.id] then
                break
            end

            table.insert(exists_data, res)
            exists_id_map[res.id] = 0

        until true
    end

    if next(exists_data) ~= nil then
        return exists_data, nil
    end

    return nil, nil
end

function _M.check_kv_exists(params, prefix)

    if type(params) ~= "table" then
        return nil, "the parameter must be a table:[" .. type(params) .. "][" .. pdk.json.encode(params) .. "]"
    end

    if next(params) == nil then
        return nil, "parameter cannot be empty:[" .. pdk.json.encode(params, true) .. "]"
    end

    if not params.id and not params.name then
        return nil, "the parameter must be one or both of the id and name passed:["
                .. pdk.json.encode(params, true) .. "]"
    end

    if params.id and not params.name then

        local id_key = _M.SYSTEM_PREFIX_MAP[prefix] .. params.id

        local id_res, id_err = _M.get_key(id_key)

        if id_err then
            return nil, "params-id failed to get with id [" .. id_key .. "], err:[" .. tostring(id_err) .. "]"
        end

        if not id_res then
            return nil, nil
        end

        local name_key = _M.PREFIX_MAP[prefix] .. id_res

        local name_res, name_err = _M.get_key(name_key)

        if name_err then
            return nil, " params-id failed to get with name [ "
                    .. id_key .. "|" .. name_key .. "], err:[" .. tostring(name_err) .. "]"
        end

        if not name_res then
            return nil, nil
        end

        return pdk.json.decode(name_res), nil
    end

    if not params.id and params.name then

        local name_key = _M.PREFIX_MAP[prefix] .. params.name

        local name_res, name_err = _M.get_key(name_key)

        if name_err then
            return nil, "params-name failed to get with name [" .. name_key .. "], err:[" .. tostring(name_err) .. "]"
        end

        if not name_res then
            return nil, nil
        end

        return pdk.json.decode(name_res), nil
    end

    if params.id and params.name then

        local id_key = _M.SYSTEM_PREFIX_MAP[prefix] .. params.id

        local name_key = _M.PREFIX_MAP[prefix] .. params.name

        local id_res, id_err = _M.get_key(id_key)

        if id_err then
            return nil, "params-id-name failed to get with id ["
                    .. id_key .. "|" .. name_key .. "], err:[" .. tostring(id_err) .. "]"
        end

        local name_res, name_err = _M.get_key(name_key)

        if name_err then
            return nil, "params-id-name failed to get with name [ "
                    .. id_key .. "|" .. name_key .. "], err:[" .. tostring(name_err) .. "]"
        end

        if (id_res and not name_res) or (not id_res and name_res) or (id_res ~= params.name) then
            return nil, nil
        end

        return pdk.json.decode(name_res), nil
    end

    return nil, nil
end

function _M.check_key_exists(name, prefix)

    local key = _M.PREFIX_MAP[prefix] .. name

    local p, err = _M.get_key(key)

    if err then
        return false
    end

    if not p then
        return false
    end

    return true
end

function _M.check_mapping_exists(id, prefix)

    local key = _M.SYSTEM_PREFIX_MAP[prefix] .. id

    local p, err = _M.get_key(key)

    if err then
        return false
    end

    if not p then
        return false
    end

    return true
end

function _M.update_sync_data_hash(init)

    local hash_data, err = _M.get_sync_data()

    if err then
        return false, err
    end

    if not hash_data then
        hash_data = {}
    end

    local key = _M.HASH_PREFIX_MAP[pdk.const.CONSUL_SYNC_UPDATE]
    local millisecond = ngx.now()
    local hash_key = key .. ":" .. millisecond .. rand()
    local hash = pdk.string.md5(hash_key)

    hash_data.new = hash

    if init == true then
        hash_data.old = hash
    end

    local res, err = _M.put_key(key, hash_data)

    if err then
        return false, err
    end

    return res, nil
end

function _M.get_sync_data()

    local key = _M.HASH_PREFIX_MAP[pdk.const.CONSUL_SYNC_UPDATE]

    local hash_data, err = _M.get_key(key)

    if err then
        return nil, err
    end

    if hash_data and (type(hash_data) == "string") then
        return pdk.json.decode(hash_data), nil
    end

    return nil, nil
end

function _M.clear_sync_data()

    local key = _M.HASH_PREFIX_MAP[pdk.const.CONSUL_SYNC_UPDATE]

    local delete, err = _M.delete_key(key)

    if err then
        return nil, err
    end

    return delete, nil
end


return _M