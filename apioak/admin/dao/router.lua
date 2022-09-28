local pdk    = require("apioak.pdk")
local common = require("apioak.admin.dao.common")
local uuid   = require("resty.jit-uuid")

local _M = {}


local DEFAULT_METHODS = {"ALL"}

function _M.created(params)

    local check_router_name = common.check_mapping_exists(params.name, "routers")

    if check_router_name then
        return nil, "the router name[".. params.name .."] already exists"
    end

    local check_service, err = common.check_kv_exists(params.service, "services")

    if err or not check_service then
        return nil, err
    end

    local check_plugin, err = common.batch_check_kv_exists(params.plugins, "plugins")

    if err or not check_plugin then
        return nil, err
    end

    --local check_upstream, err = common.check_kv_exists(params.upstream, "upstreams")
    --
    --if err or not check_upstream then
    --    return nil, err
    --end

    local router_id = uuid.generate_v4()

    local router_body = {
        id        = router_id,
        name      = params.name,
        methods   = params.methods or DEFAULT_METHODS,
        paths     = params.paths,
        headers   = params.headers or {},
        service   = params.service,
        plugins   = params.plugins or {},
        upstream  = params.upstream or {},
        enabled   = params.enabled or true
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. params.name,
                Value = router_id,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.routers .. router_id,
                Value = pdk.json.encode(router_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create service FAIL [".. tostring(err) .."]"
    end

    return { id = router_id }, nil
end

function _M.updated(router_id, params)

    local prefix = common.PREFIX_MAP.routers

    local old , err = common.get_key(prefix .. router_id)

    if err or not old then
        return nil, "router[".. router_id .."] does not exist"
    end
    old = pdk.json.decode(old)

    local v, err = common.get_key( common.SYSTEM_PREFIX_MAP.routers .. params.name)

    if err then
        return nil, "check router name error"
    end

    if v then
        if v ~= old.id then
            return nil, "the router name[".. params.name .."] already exists"
        end
    end

    local check_service, err = common.check_kv_exists(params.service, "services")

    if err or not check_service then
        return nil, err
    end

    local check_plugin, err = common.batch_check_kv_exists(params.plugins, "plugins")

    if err or not check_plugin then
        return nil, err
    end

    local check_upstream, err = common.check_kv_exists(params.upstream, "upstreams")

    if err or not check_upstream then
        return nil, err
    end

    local router_body = {
        id        = router_id,
        name      = params.name,
        methods   = params.methods or DEFAULT_METHODS,
        paths     = params.paths,
        headers   = params.headers or {},
        service   = params.service,
        plugins   = params.plugins or {},
        upstream  = params.upstream or {},
        enabled   = params.enabled or true
    }

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. old.name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. params.name,
                Value = router_id,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.routers .. router_id,
                Value = pdk.json.encode(router_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update service FAIL, err[".. tostring(err) .."]"
    end

    return { id = router_id }, nil
end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.routers)

    if err then
        return nil, "get router list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local key = common.PREFIX_MAP.routers .. params.router_id

    local res, err = common.detail_key(key)

    if err or not res then
        return nil, "router:[".. params.router_id .. "] does not exists, err [".. tostring(err) .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local key = common.PREFIX_MAP.routers .. params.router_id

    local g, err = common.get_key(key)

    if err or not g then
        return nil, "Key-Value:[" .. key .. "] does not exists], err:[".. tostring(err) .."]"
    end

    g = pdk.json.decode(g)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. g["name"],
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.routers .. params.router_id,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete router FAIL, err[".. tostring(err) .."]"
    end

    return {}, nil
end

return _M