local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

function _M.created(params)

    local plugin_id = uuid.generate_v4()

    local plugin_body = {
        id        = plugin_id,
        name      = params.name,
        key       = params.key,
        config    = params.config or {},
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. plugin_id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.plugins .. params.name,
                Value = pdk.json.encode(plugin_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create plugin FAIL, err:[".. tostring(err) .."]"
    end

    return { id = plugin_id }, nil
end

function _M.updated(params, detail)

    local old_name = detail.name

    if params.name then
        detail.name = params.name
    end
    if params.config then
        detail.config = params.config
    end

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.plugins .. old_name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. detail.id,
                Value = detail.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.plugins .. detail.name,
                Value = pdk.json.encode(detail),
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update plugin FAIL, err[".. tostring(err) .."]"
    end

    return { id = detail.id }, nil

end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.plugins)

    if err then
        return nil, "get plugin list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(key)

    if uuid.is_valid(key) then
        local tmp, err = common.get_key(common.SYSTEM_PREFIX_MAP.plugins .. key)

        if err or not tmp then
            return nil, "plugin:[".. key .. "] does not exists, err [".. tostring(err) .."]"
        end

        key = tmp
    end

    local res, err = common.detail_key(common.PREFIX_MAP.plugins .. key)

    if err or not res then
        return nil, "plugin:[".. key .. "] does not exists, err [".. tostring(err) .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(detail)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. detail.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.plugins .. detail.name,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete plugin FAIL, err[".. tostring(err) .."]"
    end

    return {}, nil
end

return _M