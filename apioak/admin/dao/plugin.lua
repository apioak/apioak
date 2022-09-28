local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")

local _M = {}

function _M.created(params)

    local check_plugin_name = common.check_key_exists(params.name, "plugins")

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

function _M.updated(plugin_key, params)

    if uuid.is_valid(plugin_key) then
        plugin_key, err = common.get_key(common.SYSTEM_PREFIX_MAP.plugins .. plugin_key)

        if err or not plugin_key then
            return nil, "plugin:[".. plugin_key .. "] does not exists, err [".. tostring(err) .."]"
        end
    end

    local prefix = common.PREFIX_MAP.plugins

    local old, err = common.get_key(prefix .. plugin_key)

    if err or not old then
        return nil, "plugin[".. plugin_key .."] does not exist"
    end

    old = pdk.json.decode(old)

    local v, err = common.get_key( prefix .. params.name)

    if err then
        return nil, "check plugin name error"
    end

    if v then
        return nil, "the plugin name[".. params.name .."] already exists"
    end

    local plugin_body = {
        id        = old.id,
        name      = params.name,
        key       = params.key,
        config    = params.config or {},
    }

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.plugins .. old.name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. old.id,
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
        return nil, "update plugin FAIL, err[".. tostring(err) .."]"
    end

    return { id = old.id }, nil

end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.plugins)

    if err then
        return nil, "get plugin list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local name = params.plugin_key

    if uuid.is_valid(params.plugin_key) then
        name, err = common.get_key(common.SYSTEM_PREFIX_MAP.plugins .. params.plugin_key)

        if err or not name then
            return nil, "plugin:[".. params.plugin_key .. "] does not exists, err [".. tostring(err) .."]"
        end
    end

    local key = common.PREFIX_MAP.plugins .. name

    local res, err = common.detail_key(key)

    if err or not res then
        return nil, "plugin:[".. params.plugin_key .. "] does not exists, err [".. tostring(err) .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local name = params.plugin_key

    if uuid.is_valid(params.plugin_key) then
        name, err = common.get_key(common.SYSTEM_PREFIX_MAP.plugins .. params.plugin_key)

        if err or not name then
            return nil, "plugin:[".. params.plugin_key .. "] does not exists, err [".. tostring(err) .."]"
        end
    end

    local key = common.PREFIX_MAP.plugins .. name

    local g, err = common.get_key(key)

    if err or not g then
        return nil, "plugin:[" .. params.plugin_key .. "] does not exists], err:[".. tostring(err) .."]"
    end

    g = pdk.json.decode(g)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.plugins .. g.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.plugins .. name,
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