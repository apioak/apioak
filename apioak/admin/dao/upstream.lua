local common = require("apioak.admin.dao.common")
local uuid   = require("resty.jit-uuid")
local pdk    = require("apioak.pdk")

local _M = {}

_M.DEFAULT_ALGORITHM = "round-robin"
_M.DEFAULT_TIMEOUT   = 6000

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.upstreams)

    if err then
        return nil, "get upstream list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.created(params)
    local id = uuid.generate_v4()

    local data = {
        id              = id,
        name            = params.name,
        algorithm       = params.algorithm or _M.DEFAULT_ALGORITHM,
        nodes           = params.nodes or {},
        connect_timeout = params.connect_timeout or _M.DEFAULT_TIMEOUT,
        write_timeout   = params.write_timeout or _M.DEFAULT_TIMEOUT,
        read_timeout    = params.read_timeout or _M.DEFAULT_TIMEOUT
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.upstreams .. id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.upstreams .. params.name,
                Value = pdk.json.encode(data),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create upstream FAIL [".. err .."]"
    end

    return { id = id }, nil
end


return _M