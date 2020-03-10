local pdk = require("apioak.pdk")

local table_name = "oak_upstreams"

local _M = {}

_M.table_name = table_name

function _M.create(params)
    local sql = pdk.string.format("INSERT INTO %s (env, host, type, project_id, enable_retries, timeouts, nodes) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s')",
            table_name, params.env, params.host, params.type, params.project_id, params.enable_retries, pdk.json.encode(params.timeouts), pdk.json.encode(params.nodes))
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.update(upstream_id, params)
    local sql = pdk.string.format("UPDATE %s SET env = '%s', host = '%s', type = '%s', project_id = '%s', enable_retries = '%s', timeouts = '%s', nodes = '%s' WHERE id = %s",
            table_name, params.env, params.host, params.type, params.project_id, params.enable_retries, pdk.json.encode(params.timeouts), pdk.json.encode(params.nodes), upstream_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query(upstream_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE id = %s", table_name, upstream_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_by_pid(project_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE project_id = %s", table_name, project_id)
    local res, err = pdk.mysql.execute(sql)

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
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

return _M
