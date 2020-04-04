local pdk  = require("apioak.pdk")

local table_name = "oak_roles"

local _M = {}

_M.table_name = table_name

function _M.create(project_id, user_id, is_admin)
    local sql = pdk.string.format("INSERT INTO %s (project_id, user_id, is_admin) VALUES ('%s', '%s', '%s')",
            table_name, project_id, user_id, is_admin)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.query(project_id, user_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE project_id = %s AND user_id = %s",
            table_name, project_id, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.delete(project_id, user_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE project_id = %s AND user_id = %s",
            table_name, project_id, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.update(project_id, user_id, is_admin)
    local sql = pdk.string.format("UPDATE %s SET is_admin = %s WHERE project_id = %s AND user_id = %s",
            table_name, is_admin, project_id, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_uid(user_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE user_id = %s", table_name, user_id)
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

function _M.delete_by_uid(user_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE user_id = %s", table_name, user_id)
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

return _M
