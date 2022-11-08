local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

_M.DEFAULT_HEALTH = "HEALTH"
_M.DEFAULT_UNHEALTH = "UNHEALTH"
_M.DEFAULT_ENABLED = false
_M.DEFAULT_WEIGHT = 1
_M.DEFAULT_PORT = 80
_M.DEFAULT_TIMEOUT = 1
_M.DEFAULT_INTERVAL = 5

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
            enabled  = params.check.enabled or _M.DEFAULT_ENABLED,
            tcp      = params.check.tcp or "",
            method   = params.check.method or "",
            http     = params.check.http or "",
            timeout  = params.check.timeout or _M.DEFAULT_TIMEOUT,
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

    return { id = id }, nil
end

function _M.lists()
    local res, err = common.list_keys(common.PREFIX_MAP.upstream_nodes)

    if err then
        return nil, "get upstream_node list FAIL [".. err .."]"
    end

    return res, nil
end

return _M