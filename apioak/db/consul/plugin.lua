local ngx = ngx
local pdk = require("apioak.pdk")
local uuid = require("resty.jit-uuid")
local common = require("apioak.db.consul.common")

local _M = {}

function _M.created(params)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local plugin_id = uuid.generate_v4()
    local plugin_body = {
        id        = plugin_id,
        name      = params.name,
        key       = params.key,
        config    = params.config or {},
    }

    local prefix = params.prefix or common.DEFAULT_PLUGIN_PREFIX

    local res, err = consul:put_key( prefix .. plugin_id, plugin_body)

    if err ~= nil then
        return nil, "create plugin FAIL [".. err .."]"
    end

    if not res or res.status ~= 200 then
        return nil, "create plugin FAIL [".. err .."] [".. res.status .."]"
    end

    return { id = plugin_id }, nil
end

function _M.updated(plugin_id, params)

    local prefix = params.prefix or common.DEFAULT_PLUGIN_PREFIX

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local _, err = pdk.consul.get_key(prefix .. plugin_id)

    if err ~= nil then
        return nil, "plugin[".. plugin_id .."] does not exist"
    end

    local plugin_body = {
        id        = plugin_id,
        name      = params.name,
        key       = params.key,
        config    = params.config or {},
    }

    local res, err = consul:put_key( prefix .. plugin_id, plugin_body)

    if err ~= nil then
        return nil, "update plugin FAIL [".. err .."]"
    end

    if not res or res.status ~= 200 then
        return nil, "update plugin FAIL [".. err .."] [".. res.status .."]"
    end

    return { id = plugin_id }, nil

end

function _M.lists(params)

    local prefix = params.prefix or common.DEFAULT_PLUGIN_PREFIX
    local res, err = common.lists(prefix)

    if err ~= nil then
        return nil, "get plugin list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local prefix = params.prefix or common.DEFAULT_PLUGIN_PREFIX

    local key = prefix .. params.plugin_id

    local res, err = common.detail(key)

    if err ~= nil or res == nil then
        return nil, "plugin:[".. params.plugin_id .. "] does not exists, err [".. err .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local prefix = params.prefix or common.DEFAULT_PLUGIN_PREFIX

    local key = prefix .. params.plugin_id

    local res, err = common.deleted(key)

    if err ~= nil or res == nil then
        return nil, "plugin:[".. params.plugin_id .. "] delete FAIL, err:[".. err .."]"
    end

    return res, nil
end

-- ****************************************************************************
local table_name = "oak_plugins"

_M.table_name = table_name

_M.RESOURCES_TYPE_ROUTER = "ROUTER"

_M.RESOURCES_TYPE_PROJECT = "PROJECT"

function _M.query_by_res(res_type, res_id)
    local sql = pdk.string.format("SELECT id, name, type, description, config "
            .. "FROM %s WHERE res_type = %s AND res_id = %s",
            table_name,
            ngx.quote_sql_str(res_type),
            ngx.quote_sql_str(res_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].config = pdk.json.decode(res[i].config)
    end

    return res, nil
end

function _M.create_by_res(res_type, res_id, params)
    local sql = pdk.string.format("INSERT INTO %s (name, type, description, config, res_type, res_id) "
            .. "VALUES (%s, %s, %s, %s, %s, %s)",
            table_name,
            ngx.quote_sql_str(params.name),
            ngx.quote_sql_str(params.type),
            ngx.quote_sql_str(params.description),
            ngx.quote_sql_str(pdk.json.encode(params.config)),
            ngx.quote_sql_str(res_type),
            ngx.quote_sql_str(res_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.delete_by_res(res_type, res_id, plugin_id)
    local sql
    if plugin_id then
        sql = pdk.string.format([[
            DELETE
            FROM
                %s
            WHERE
                id = %s AND res_id = %s AND res_type = %s
        ]], table_name,
                ngx.quote_sql_str(plugin_id),
                ngx.quote_sql_str(res_id),
                ngx.quote_sql_str(res_type))
    else
        sql = pdk.string.format([[
            DELETE
            FROM
                %s
            WHERE
                res_id = %s AND res_type = %s
        ]], table_name,
                ngx.quote_sql_str(res_id),
                ngx.quote_sql_str(res_type))
    end

    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.update_by_res(res_type, res_id, plugin_id, params)
    local sql = pdk.string.format([[
        UPDATE
            %s
        SET
            name= %s,
            type = %s,
            description = %s,
            config = %s
        WHERE
            id = %s AND res_id = %s AND res_type = %s
    ]],
            table_name,
            ngx.quote_sql_str(params.name),
            ngx.quote_sql_str(params.type),
            ngx.quote_sql_str(params.description),
            ngx.quote_sql_str(pdk.json.encode(params.config)),
            ngx.quote_sql_str(plugin_id),
            ngx.quote_sql_str(res_id),
            ngx.quote_sql_str(res_type))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_project_last_updated_hid()
    local sql = pdk.string.format([[
        SELECT
            MD5(updated_at) AS hash_id
        FROM
            %s
        WHERE
            res_type = '%s'
        ORDER BY
            updated_at
        DESC
        LIMIT 1
    ]], table_name, _M.RESOURCES_TYPE_PROJECT)
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    if #res == 0 then
        return res, nil
    end

    return res[1], nil
end
return _M