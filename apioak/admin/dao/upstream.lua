local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

_M.DEFAULT_ALGORITHM = "round-robin"
_M.DEFAULT_TIMEOUT   = 6000


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


function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.upstreams)

    if err then
        return nil, "get upstream list FAIL [".. err .."]"
    end

    return res, nil
end


function _M.updated(params, detail)

    local old_name = detail.name

    if params.name then
        detail.name = params.name
    end
    if params.algorithm then
        detail.algorithm = params.algorithm
    end
    if params.nodes then
        detail.nodes = params.nodes
    end
    if params.connect_timeout then
        detail.connect_timeout = params.connect_timeout
    end
    if params.write_timeout then
        detail.write_timeout = params.write_timeout
    end
    if params.read_timeout then
        detail.read_timeout = params.read_timeout
    end

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.upstreams .. old_name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.upstreams .. detail.id,
                Value = detail.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.upstreams .. detail.name,
                Value = pdk.json.encode(detail),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update upstream FAIL, err[".. tostring(err) .."]"
    end

    return { id = detail.id }, nil
end


function _M.detail(key)
    if uuid.is_valid(key) then

        local name, err = common.get_key(common.SYSTEM_PREFIX_MAP.upstreams .. key)

        if err or not name then
            return nil, "upstream key:[".. key .. "] does not exist"
        end

        key = name
    end

    local detail, err = common.get_key(common.PREFIX_MAP.upstreams .. key)

    if err or not detail then
        return nil, "upstream detail:[".. key .."] does not exist"
    end

    return  pdk.json.decode(detail), nil
end


function _M.deleted(detail)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.upstreams .. detail.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.upstreams .. detail.name,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete upstream FAIL, err[".. tostring(err) .."]"
    end

    return {}, nil
end


return _M