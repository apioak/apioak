local pdk = require("apioak.pdk")

local table_name = "oak_upstreams"

local _M = {}

_M.table_name = table_name

function _M.all()
    local sql = pdk.string.format("SELECT * FROM %s", table_name)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].nodes    = pdk.json.decode(res[i].nodes)
        res[i].timeouts = pdk.json.decode(res[i].timeouts)
    end

    return res, nil
end

function _M.create(params)
    local sql = pdk.string.format([[
        INSERT INTO %s (
            env,
            host,
            type,
            project_id,
            timeouts,
            nodes
        )
        VALUES ('%s', '%s', '%s', '%s', '%s', '%s')
    ]], table_name,
        params.env,
        params.host,
        params.type,
        params.project_id,
        pdk.json.encode(params.timeouts),
        pdk.json.encode(params.nodes))
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.update_by_pid(pid, upstream)
    local sql = pdk.string.format([[
        UPDATE
            %s
        SET
            host = '%s', type = '%s', timeouts = '%s', nodes = '%s'
        WHERE
            id = %s AND project_id = %s
    ]], table_name, upstream.host, upstream.type,
            pdk.json.encode(upstream.timeouts),
            pdk.json.encode(upstream.nodes), upstream.id, pid)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query(upstream_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE id = %s", table_name, upstream_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_by_pid(project_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE project_id = %s", table_name, project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].nodes    = pdk.json.decode(res[i].nodes)
        res[i].timeouts = pdk.json.decode(res[i].timeouts)
    end

    return res, nil
end

function _M.delete_by_pid(project_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE project_id = %s", table_name, project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_last_updated_hid()
    local sql = pdk.string.format(
            "SELECT MD5(updated_at) AS hash_id FROM %s ORDER BY updated_at DESC LIMIT 1", table_name)
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
