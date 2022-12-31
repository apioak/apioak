local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

_M.DEFAULT_PORT = 80
_M.DEFAULT_WEIGHT = 1
_M.DEFAULT_TIMEOUT = 1
_M.DEFAULT_INTERVAL = 5
_M.DEFAULT_ENABLED_TRUE = true
_M.DEFAULT_ENABLED_FALSE = false
_M.DEFAULT_HEALTH = "HEALTH"
_M.DEFAULT_UNHEALTH = "UNHEALTH"

function _M.created(params)
    local id = uuid.generate_v4()

    local data = {
        id      = id,
        name    = params.name,
        address = params.address or "",
        port    = params.port or _M.DEFAULT_PORT,
        health  = params.health or _M.DEFAULT_HEALTH,
        weight  = params.weight or _M.DEFAULT_WEIGHT,
        check   = {
            enabled  = params.check.enabled  or _M.DEFAULT_ENABLED_FALSE,
            tcp      = params.check.tcp      or _M.DEFAULT_ENABLED_TRUE,
            method   = params.check.method   or "",
            host     = params.check.host     or "",
            uri      = params.check.uri      or "",
            timeout  = params.check.timeout  or _M.DEFAULT_TIMEOUT,
            interval = params.check.interval or _M.DEFAULT_INTERVAL,
        }
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.upstream_nodes .. id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.upstream_nodes .. params.name,
                Value = pdk.json.encode(data),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create upstream_node FAIL [".. err .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-upstream-node-create update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return { id = id }, nil
end

function _M.lists()
    local res, err = common.list_keys(common.PREFIX_MAP.upstream_nodes)

    if err then
        return nil, "get upstream_node list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.updated(params, detail)

    local old_name = detail.name

    if params.name then
        detail.name = params.name
    end
    if params.address then
        detail.address = params.address
    end
    if params.port then
        detail.port = params.port
    end
    if params.weight then
        detail.weight = params.weight
    end
    if params.health then
        detail.health = params.health
    end
    if params.check.enabled then
        detail.check.enabled = params.check.enabled
    end
    if params.check.tcp then
        detail.check.tcp = params.check.tcp
    end
    if params.check.method then
        detail.check.method = params.check.method
    end
    if params.check.host then
        detail.check.host = params.check.host
    end
    if params.check.uri then
        detail.check.uri = params.check.uri
    end
    if params.check.interval then
        detail.check.interval = params.check.interval
    end
    if params.check.timeout then
        detail.check.timeout = params.check.timeout
    end

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.upstream_nodes .. old_name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.upstream_nodes .. detail.id,
                Value = detail.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.upstream_nodes .. detail.name,
                Value = pdk.json.encode(detail),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update upstream_node FAIL, err[".. tostring(err) .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-upstream-node-update update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return { id = detail.id }, nil
end

function _M.detail(key)

    if uuid.is_valid(key) then

        local name, err = common.get_key(common.SYSTEM_PREFIX_MAP.upstream_nodes .. key)

        if err then
            return nil, "upstream_node key:[".. key .. "] does not exist"
        end

        if not name then
            return nil, nil
        end

        key = name
    end

    local detail, err = common.get_key(common.PREFIX_MAP.upstream_nodes .. key)

    if err then
        return nil, "upstream_node detail:[".. key .."] does not exist[" .. tostring(err) .. "]"
    end

    if not detail then
        return nil
    end

    return  pdk.json.decode(detail), nil
end

function _M.deleted(detail)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.upstream_nodes .. detail.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.upstream_nodes .. detail.name,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete upstream_node FAIL, err[".. tostring(err) .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-upstream-node-delete update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return {}, nil
end

return _M