local pdk  = require("apioak.pdk")

local table_name = "oak_plugins"

local _M = {}

_M.table_name = table_name

_M.RESOURCES_TYPE_ROUTER = "ROUTER"

_M.RESOURCES_TYPE_PROJECT = "PROJECT"

function _M.query_by_res(res_type, res_id)
    local sql = pdk.string.format("SELECT id, name, type, description, config  FROM %s WHERE res_type = '%s' AND res_id = %s",
            table_name, res_type, res_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].config = pdk.json.decode(res[i].config)
    end

    return res, nil
end

function _M.create_by_res(res_type, res_id, params)
    local sql = pdk.string.format("INSERT INTO %s (name, type, description, config, res_type, res_id) VALUES ('%s', '%s', '%s', '%s', '%s', '%s')",
            table_name, params.name, params.type, params.description, pdk.json.encode(params.config), res_type, res_id)
    local res, err = pdk.mysql.execute(sql)

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
                id = %s AND res_id = %s AND res_type = '%s'
        ]], table_name, plugin_id, res_id, res_type)
    else
        sql = pdk.string.format([[
            DELETE
            FROM
                %s
            WHERE
                res_id = %s AND res_type = '%s'
        ]], table_name, res_id, res_type)
    end

    local res, err = pdk.mysql.execute(sql)
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
            name= '%s',
            type = '%s',
            description = '%s',
            config = '%s'
        WHERE
            id = %s AND res_id = %s AND res_type = '%s'
    ]], table_name,
        params.name,
        params.type,
        params.description,
        pdk.json.encode(params.config),
        plugin_id,
        res_id,
        res_type)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

return _M
