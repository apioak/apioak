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

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.certificates)

    if err then
        return nil, "get certificate list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(key)

    if uuid.is_valid(key) then

        local name, err = common.get_key(common.SYSTEM_PREFIX_MAP.certificates .. key)

        if err or not name then
            return nil, "certificate key:[".. key .. "] does not exist"
        end

        key = name
    end

    local detail, err = common.get_key(common.PREFIX_MAP.certificates .. key)

    if err or not detail then
        return nil, "certificates detail:[".. key .."] does not exist"
    end

    return  pdk.json.decode(detail), nil
end

function _M.updated(params, detail)

    local old_name = detail.name

    if params.name then
        detail.name = params.name
    end
    if params.snis then
        detail.snis = params.snis
    end
    if params.cert then
        detail.cert = params.cert
    end
    if params.key then
        detail.key = params.key
    end

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.certificates .. old_name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.certificates .. detail.id,
                Value = detail.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.certificates .. detail.name,
                Value = pdk.json.encode(detail),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update certificate FAIL, err[".. tostring(err) .."]"
    end

    return { id = detail.id }, nil
end

return _M