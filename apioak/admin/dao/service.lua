local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

local DEFAULT_PROTOCOLS = {"http"}
local DEFAULT_PORT = {"80"}

function _M.created(params)

    local check_service_name = common.check_key_exists(params.name, "services")

    if check_service_name then
        return nil, "the service name[".. params.name .."] already exists"
    end

    local check_plugin, err = common.batch_check_kv_exists(params.plugins, "plugins")

    if err or not check_plugin then
        return nil, err
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

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.services .. service_id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.services .. params.name,
                Value = pdk.json.encode(service_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create service FAIL [".. err .."]"
    end

    return { id = service_id }, nil
end

function _M.updated(service_key, params)

    if uuid.is_valid(service_key) then
        local tmp, err = common.get_key(common.SYSTEM_PREFIX_MAP.services .. service_key)

        if err or not tmp then
            return nil, "service:[".. service_key .. "] does not exists, err [".. tostring(err) .."]"
        end

        service_key = tmp
    end

    local prefix = common.PREFIX_MAP.services

    local old, err = common.get_key(prefix .. service_key)

    if err or not old then
        return nil, "service[".. service_key .."] does not exist"
    end
    old = pdk.json.decode(old)

    local new, err = common.get_key( prefix .. params.name)

    if err then
        return nil, "check service name error"
    end

    if new then
        return nil, "the service name[".. params.name .."] already exists"
    end

    local check_plugin, err = common.batch_check_kv_exists(params.plugins, "plugins")

    if err or not check_plugin then
        return nil, err
    end

    local service_body = {
        id        = old.id,
        name      = params.name,
        protocols = params.protocols or DEFAULT_PROTOCOLS,
        hosts     = params.hosts,
        ports     = params.ports or DEFAULT_PORT,
        plugins   = params.plugins or {},
        enabled   = params.enabled or true
    }

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.services .. old.name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.services .. old.id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.services .. params.name,
                Value = pdk.json.encode(service_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update service FAIL, err[".. tostring(err) .."]"
    end

    return { id = old.id }, nil
end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.services)

    if err then
        return nil, "get service list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local name = params.service_key

    if uuid.is_valid(params.service_key) then
        local tmp, err = common.get_key(common.SYSTEM_PREFIX_MAP.services .. params.service_key)

        if err or not tmp then
            return nil, "service:[".. params.service_key .. "] does not exists, err [".. tostring(err) .."]"
        end

        name = tmp
    end

    local key = common.PREFIX_MAP.services .. name

    local res, err = common.detail_key(key)

    if err or not res then
        return nil, "service:[".. params.service_key .. "] does not exists, err [".. tostring(err) .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local name = params.service_key

    if uuid.is_valid(params.service_key) then
        local tmp, err = common.get_key(common.SYSTEM_PREFIX_MAP.services .. params.service_key)

        if err or not tmp then
            return nil, "service:[".. params.service_key .. "] does not exists, err [".. tostring(err) .."]"
        end

        name = tmp
    end

    local key = common.PREFIX_MAP.services .. name

    local g, err = common.get_key(key)

    if err or not g then
        return nil, "Key-Value:[" .. params.service_key .. "] does not exists], err:[".. tostring(err) .."]"
    end

    g = pdk.json.decode(g)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.services .. g.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.services .. name,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete service FAIL, err[".. tostring(err) .."]"
    end

    return {}, nil
end

return _M