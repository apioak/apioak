local pdk  = require("apioak.pdk")

local table_name = "oak_roles"

local _M = {}

_M.table_name = table_name

function _M.create(group_id, user_id, is_admin)
    local sql = pdk.string.format("INSERT INTO %s (group_id, user_id, is_admin) VALUES ('%s', '%s', '%s')",
            table_name, group_id, user_id, is_admin)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.query(group_id, user_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE group_id = %s AND user_id = %s",
            table_name, group_id, user_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.delete(group_id, user_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE group_id = %s AND user_id = %s",
            table_name, group_id, user_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.update(group_id, user_id, is_admin)
    local sql = pdk.string.format("UPDATE %s SET is_admin = %s WHERE group_id = %s AND user_id = %s",
            table_name, is_admin, group_id, user_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_uid(user_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE user_id = %s", table_name, user_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_gid(group_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE group_id = %s", table_name, group_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.delete_by_gid(group_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE group_id = %s", table_name, group_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.delete_by_uid(user_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE user_id = %s", table_name, user_id)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

return _M
