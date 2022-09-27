local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

function _M.created(params)

    local check_plugin_name = common.check_mapping_exists(params.name, "plugins")

    if check_plugin_name then
        return nil, "the plugin name[".. params.name .."] already exists"
    end

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
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. params.name,
                Value = service_id,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.plugins .. plugin_id,
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

function _M.updated(plugin_id, params)

    local prefix = common.PREFIX_MAP.plugins

    local old , err = common.get_key(prefix .. plugin_id)

    if err or not old then
        return nil, "plugin[".. plugin_id .."] does not exist"
    end
    old = pdk.json.decode(old)

    local v, err = common.get_key( common.SYSTEM_PREFIX_MAP.plugins .. params.name)

    if err then
        return nil, "check plugin name error"
    end

    if v then
        if v ~= old.id then
            return nil, "the plugin name[".. params.name .."] already exists"
        end
    end

    local plugin_body = {
        id        = plugin_id,
        name      = params.name,
        key       = params.key,
        config    = params.config or {},
    }

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. old.name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. params.name,
                Value = plugin_id,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.plugins .. plugin_id,
                Value = pdk.json.encode(plugin_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update plugin FAIL, err[".. tostring(err) .."]"
    end

    return { id = plugin_id }, nil

end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.plugins)

    if err then
        return nil, "get plugin list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local key = common.PREFIX_MAP.plugins .. params.plugin_id

    local res, err = common.detail_key(key)

    if err then
        return nil, "plugin:[".. params.plugin_id .. "] does not exists, err [".. err .."]"
    end

    if not res then
        return nil, "plugin:[".. params.plugin_id .. "] does not exists"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local key = common.PREFIX_MAP.plugins .. params.plugin_id

    local g, err = common.get_key(key)

    if err or not g then
        return nil, "Key-Value:[" .. key .. "] does not exists], err:[".. tostring(err) .."]"
    end

    g = pdk.json.decode(g)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. g["name"],
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.plugins .. params.plugin_id,
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