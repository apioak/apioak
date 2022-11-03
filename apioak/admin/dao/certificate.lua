local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

function _M.created(params)
    local id = uuid.generate_v4()

    local data = {
        id   = id,
        name = params.name,
        snis = params.snis,
        cert = params.cert or "",
        key  = params.key or ""
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.certificates .. id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.certificates .. params.name,
                Value = pdk.json.encode(data),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create certificate FAIL [" .. err .. "]"
    end

    return { id = id }, nil
end

return _M