local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.db.consul.common")

local _M = {}

local DEFAULT_PROTOCOLS = {"http"}
local DEFAULT_PORT = {"80"}

function _M.created(params)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local prefix = params.prefix or common.DEFAULT_SERVICE_PREFIX

    local check_plugin = common.batch_check_kv_exists_by_id(params.plugins, prefix)

    if not check_plugin then
        return nil, "plugin check FAIL"
    end

    local service_id = uuid.generate_v4()
    local service_body = {
        id        = service_id,
        name      = params.name,
        protocols = params.protocols or DEFAULT_PROTOCOLS,
        hosts     = params.hosts,
        ports     = params.ports or DEFAULT_PORT,
        plugins   = params.plugins or {},
        enabled   = params.enabled or true
    }

    local res, err = consul:put_key( prefix .. service_id, service_body)

    if err ~= nil then
        return nil, "create service FAIL [".. err .."]"
    end

    if not res or res.status ~= 200 then
        return nil, "create service FAIL [".. err .."] [".. res.status .."]"
    end

    return { id = service_id }, nil
end

function _M.updated(service_id, params)
    
    local prefix = params.prefix or common.DEFAULT_SERVICE_PREFIX

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local _ , err = pdk.consul.get_key(prefix .. service_id)

    if err ~= nil then
        return nil, "service[".. service_id .."] does not exist"
    end

    local check_plugin = common.batch_check_kv_exists_by_id(params.plugins, prefix)

    if not check_plugin then
        return nil, "plugin check FAIL"
    end

    local service_body = {
        id        = service_id,
        name      = params.name,
        protocols = params.protocols or DEFAULT_PROTOCOLS,
        hosts     = params.hosts,
        ports     = params.ports or DEFAULT_PORT,
        plugins   = params.plugins or {},
        enabled   = params.enabled or true
    }

    local res, err = consul:put_key( prefix .. service_id, service_body)

    if err ~= nil then
        return nil, "update service FAIL [".. err .."]"
    end

    if not res or res.status ~= 200 then
        return nil, "update service FAIL [".. err .."] [".. res.status .."]"
    end

    return { id = service_id }, nil
end

function _M.lists(params)

    local prefix = params.prefix or common.DEFAULT_SERVICE_PREFIX
    local res, err = common.lists(prefix)

    if err ~= nil then
        return nil, "get service list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local prefix = params.prefix or common.DEFAULT_SERVICE_PREFIX

    local key = prefix .. params.service_id

    local res, err = common.detail(key)

    if err ~= nil or res == nil then
        return nil, "service:[".. params.service_id .. "] does not exists, err [".. err .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local prefix = params.prefix or common.DEFAULT_SERVICE_PREFIX

    local key = prefix .. params.service_id

    local res, err = common.deleted(key)

    if err ~= nil or res == nil then
        return nil, "service:[".. params.service_id .. "] delete FAIL, err:[".. err .."]"
    end

    return res, nil
end

return _M