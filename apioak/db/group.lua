local pdk  = require("apioak.pdk")
local role = require("apioak.db.role")

local table_name = "oak_groups"

local _M = {}

function _M.all(is_owner)
    local sql
    if is_owner then
        sql = pdk.string.format("SELECT *, 1 AS is_admin FROM %s", table_name)
    else
        sql = pdk.string.format("SELECT * FROM %s", table_name)
    end
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.create(params)
    local sql = pdk.string.format("INSERT INTO %s (name, description) VALUES ('%s', '%s')",
            table_name, params.name, params.description)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.update(group_id, params)
    local sql = pdk.string.format("UPDATE %s SET name = '%s', description = '%s' WHERE id = %s",
            table_name, params.name, params.description, group_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.delete(group_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s", table_name, group_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query(group_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE id = %s", table_name, group_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_by_name(name)
    local sql = pdk.string.format("SELECT * FROM %s WHERE name = '%s'",
            table_name, name)
    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_uid(user_id)
    local sql = pdk.string.format(
            "SELECT groups.*, roles.is_admin FROM %s as roles, %s as groups WHERE roles.group_id = groups.id AND roles.user_id = %s",
            role.table_name, table_name, user_id)

    local res, err = pdk.mysql.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

return _M
