local pdk = require("apioak.pdk")
local role = require("apioak.db.role")

local _M = {}

local table_name = "oak_users"

_M.table_name = table_name

function _M.all(is_enable)
    local sql
    if is_enable then
        sql = pdk.string.format("SELECT id, name, email FROM %s WHERE is_enable = 1", table_name)
    else
        sql = pdk.string.format("SELECT id, name, email, is_enable, is_owner FROM %s", table_name)
    end
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end
    return res, nil
end

function _M.create(params)
    local sql = pdk.string.format(
            "INSERT INTO %s (name, password, email, is_owner, is_enable) VALUES ('%s', '%s', '%s', '%s', '%s')",
            table_name, params.name, pdk.string.md5(params.password), params.email,
            params.is_owner or 0, params.is_enable or 0)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.update(user_id, params)
    local sql = pdk.string.format("UPDATE %s SET name = '%s', password = '%s', email = '%s', is_enable = %s WHERE id = %s",
            table_name, params.name, pdk.string.md5(params.password), params.email, params.is_enable, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.delete(user_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s",
            table_name, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.update_password(user_id, password)
    local sql = pdk.string.format("UPDATE %s SET password = '%s' WHERE id = %s",
            table_name, pdk.string.md5(password), user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.update_status(user_id, status)
    local sql = pdk.string.format("UPDATE %s SET is_enable = %s WHERE id = %s",
            table_name, status, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_by_email(email)
    local sql = pdk.string.format("SELECT * FROM %s WHERE email = '%s'", table_name, email)
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end
    return res, err
end

function _M.query_by_id(uid)
    local sql = pdk.string.format("SELECT id, name, email, is_enable, is_owner FROM %s WHERE id = %s",
            table_name, uid)
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end
    return res, err
end

function _M.query_by_pid(gid)
   local sql = pdk.string.format(
           "SELECT users.id, users.name, users.email, roles.is_admin FROM %s AS roles LEFT JOIN %s AS users ON roles.user_id = users.id WHERE roles.project_id = %s",
           role.table_name, table_name, gid)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, err
end

return _M
