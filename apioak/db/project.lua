local pdk  = require("apioak.pdk")

local table_name = "oak_projects"

local _M = {}

_M.table_name = table_name

function _M.query_by_gid(group_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE group_id = %s", table_name, group_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.create(params)
    local sql = pdk.string.format("INSERT INTO %s (name, description, path, group_id, user_id) VALUES ('%s', '%s', '%s', '%s', '%s')",
            table_name, params.name, params.description, params.path, params.group_id, params.user_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.update(project_id, params)
    local sql = pdk.string.format("UPDATE %s SET name = '%s', description = '%s', path = '%s' WHERE id = %s",
            table_name, params.name, params.description, params.path, project_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query(project_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE id = %s",
            table_name, project_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.delete(project_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s",
            table_name, project_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

return _M
