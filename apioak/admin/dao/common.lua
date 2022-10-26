local pdk  = require("apioak.pdk")
local config  = require("apioak.sys.config")

local _M = {}

_M.APIOAK_PREFIX = function ()

    local conf, err = config.query("consul")

    if err or not conf then
        return "apioak/"
    end

    return conf.prefix .. "/"
end

_M.SYSTEM_PREFIX = _M.APIOAK_PREFIX() .. "system/mapping/"

_M.SYSTEM_PREFIX_MAP = {
    services  = _M.SYSTEM_PREFIX .. "services/",
    routers   = _M.SYSTEM_PREFIX .. "routers/",
    plugins   = _M.SYSTEM_PREFIX .. "plugins/",
    upstreams = _M.SYSTEM_PREFIX .. "upstreams/",
}

_M.PREFIX_MAP = {
    services  = _M.APIOAK_PREFIX() .. "services/",
    routers   = _M.APIOAK_PREFIX() .. "routers/",
    plugins   = _M.APIOAK_PREFIX() .. "plugins/",
    upstreams = _M.APIOAK_PREFIX() .. "upstreams/",
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

function _M.list_keys(prefix)

    local keys, err = pdk.consul.instance:list_keys(prefix)

    if err then
        return nil, err
    end

    local res = {}

    if not keys or not keys.body then
        return {list = res}, nil
    end

    if type(keys.body) ~= "table" then
        return {list = res}, nil
    end

    for i = 1, #keys.body do

        local d, err = _M.get_key(keys.body[i])

        if err == nil and d then
            table.insert(res, pdk.json.decode(d))
        end
     end

    return {list = res}, nil
end

function _M.detail_key(key)

    local d, err = _M.get_key(key)

    if err then
        return nil, "failed to get Key-Value detail with key [" .. key .. "], err[".. tostring(err) .. "]"
    end

    if not d then
        return nil, "failed to get Key-Value detail with key [" .. key .. "]"
    end

    return d, nil

end

function _M.delete_key(key)

    local g, err = _M.get_key(key)

    if err then
        return nil, "Key-Value:[" .. key .. "] does not exists], err:[".. tostring(err) .."]"
    end

    if not g then
        return nil, "Key-Value:[" .. key .. "] does not exists]"
    end

    local d, err = pdk.consul.instance:delete_key(key)

    if err then
        return nil, "failed to delete Key-Value with key [" .. key .. "], err[".. tostring(err) .. "]"
    end

    if not d then
        return nil, "failed to delete Key-Value with key [" .. key .. "]"
    end

    return {}, nil

end

function _M.txn(payload)

    local res, err = pdk.consul.instance:txn(payload)

    if err then
        return nil, "exec txn error, payload:[".. pdk.json.encode(payload) .."], err:[".. tostring(err) .."]"
    end

    if not res then
        return nil, "exec txn error, payload:[".. pdk.json.encode(payload) .."]"
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
        return false, "params format error, err:[table expected, got ".. type(params) .."]"
    end

    if params.len == 0 then
        return true, nil
    end

    for _, value in ipairs(params) do

        local id   = value.id or nil
        local name = value.name or nil

        repeat
            if not id and not name then
                break
            end

            local res, err = _M.check_kv_exists(value, prefix)

            if err then
                return false, err
            end

            if not res then
                return false, nil
            end

        until true
    end

    return true, nil
end

function _M.check_kv_exists(params, prefix)

    if type(params) ~= "table" then
        return false, "params format error, err:[table expected, got ".. type(params) .."]"
    end

    local id   = params.id or nil
    local name = params.name or nil

    if not id and not name then
        return true, nil
    end

    local id_res, id_err = nil, nil

    local name_res, name_err = nil, nil

    if id then

        local id_key = _M.SYSTEM_PREFIX_MAP[prefix] .. id

        id_res, id_err = _M.get_key(id_key)

        if id_err then
            return false, "failed to get ".. prefix ..
                    " with id [".. params.id .."], err:[".. tostring(id_err) .."]"
        end

        if not id_res then
            return false, "failed to get ".. prefix .. " with id [".. params.id .."]"
        end
    end

    if name then

        local name_key = _M.PREFIX_MAP[prefix] .. name

        name_res, name_err = _M.get_key(name_key)

        if name_err then
            return false, "failed to get ".. prefix ..
                    " with name [".. params.name .."], err:[".. tostring(name_err) .."]"
        end

        if not name_res then
            return false, "failed to get ".. prefix .. " with name [".. params.name .."]"
        end
    end

    if id and name and not id_err and not name_err then
        if id_res and name_res then
            if id_res ~= name then
                return false, "params.id:[".. id .."] and params.name:[".. name .."] resources do not match"
            end
        end
    end

    return true, nil
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

return _M