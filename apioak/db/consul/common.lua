local pdk = require("apioak.pdk")

local _M = {}

local DEFAULT_SERVICE_PREFIX = "service/"
local DEFAULT_ROUTER_PREFIX  = "router/"
local DEFAULT_PLUGIN_PREFIX  = "plugin/"
local DEFAULT_UPSTREAM_PREFIX = "upstream/"


function _M.lists(prefix)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local keys, err = consul:list_keys(prefix)

    if err ~= nil then
        return nil, err
    end

    local res = {}

    if not keys or not keys.body then
        return {list = res}, nil
    end

    for _, v in ipairs(keys.body) do

        local d, err = pdk.consul.get_key(v)

        if err ~= nil or d == nil then
           goto continue
        end

       table.insert(res, pdk.json.decode(d))

       ::continue::
     end

    return {list = res}, nil
end

function _M.detail(key)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local d, err = pdk.consul.get_key(key)

    if err ~= nil or d == nil or d.status ~= 200 then
        return nil, "get Key-Value:[" .. key .. "] detail FAIL [".. err .. "]"
    end

    return d, nil

end

function _M.deleted(key)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local g, err = pdk.consul.get_key(key)

    if err ~= nil or g == nil then
        return nil, "Key-Value:[" .. key .. "] does not exists]"
    end

    local d, err = consul:delete_key(key)

    if err ~= nil or d == nil or d.status ~= 200 then
        return nil, "delete Key-Value:[".. key .."] FAIL [".. err .. "]"
    end

    return {}, nil

end

function _M.batch_check_kv_exists_by_id(params, prefix)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return false
    end

    if params.len == 0 then
        return true
    end

    for _, value in ipairs(params) do

        local id = value.id or ""

        if id == "" then
            goto continue
        end

        local key = prefix .. id

        local p, err = consul:get_key(key)

        if err ~= nil or p == nil or p.body == "" then
            return false
        end

        ::continue::
    end

    return true
end

function _M.check_kv_exists_by_id(param, prefix)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return false
    end

    local id = param.id or ""

    if not id then
        return true
    end

    local key = prefix .. id

    local p, err = consul:get_key(key)
    if err ~= nil or p == nil or p.body == "" then
        return false
    end

    return true
end

return _M