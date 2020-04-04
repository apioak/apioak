local pdk      = require("apioak.pdk")
local role     = require("apioak.db.role")
local plugin   = require("apioak.db.plugin")
local upstream = require("apioak.db.upstream")

local table_name = "oak_projects"

local _M = {}

_M.table_name = table_name

function _M.all(project_name)
    local sql
    if project_name and pdk.string.len(project_name) >= 1 then
        sql = pdk.string.format([[
            SELECT
                id,
                name,
                path,
                description
            FROM
                %s
            WHERE
                name LIKE '%%%s%%'
            ORDER BY
                id
            DESC
        ]], table_name, project_name)
    else
        sql = pdk.string.format([[
            SELECT
                id,
                name,
                path,
                description
            FROM
                %s
            ORDER BY
                id
            DESC
        ]], table_name)
    end

    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_uid(user_id, project_name)
    local sql
    if project_name and pdk.string.len(project_name) >= 1 then
        sql = pdk.string.format([[
            SELECT
                projects.id,
                projects.name,
                projects.path,
                projects.description,
                roles.is_admin
            FROM
                %s AS projects
            LEFT JOIN
                %s AS roles
            ON
                projects.id = roles.project_id
            WHERE
                roles.user_id = %s AND projects.name LIKE '%%%s%%'
            ORDER BY
                projects.id
            DESC
        ]], table_name, role.table_name, user_id, project_name)
    else
        sql = pdk.string.format([[
            SELECT
                projects.id,
                projects.name,
                projects.path,
                projects.description,
                roles.is_admin
            FROM
                %s AS projects
            LEFT JOIN
                %s AS roles
            ON
                projects.id = roles.project_id
            WHERE
                roles.user_id = %s
            ORDER BY
                projects.id
            DESC
        ]], table_name, role.table_name, user_id)
    end

    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.created(params)
    local sql = pdk.string.format("INSERT INTO %s (name, description, path) VALUES ('%s', '%s', '%s')",
            table_name, params.name, params.description, params.path)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.updated(project_id, params)
    local sql = pdk.string.format("UPDATE %s SET name = '%s', description = '%s', path = '%s' WHERE id = %s",
            table_name, params.name, params.description, params.path, project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.query(project_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE id = %s",
            table_name, project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.delete(project_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s",
            table_name, project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_env_all()
    local sql      = pdk.string.format("SELECT id, path FROM %s", table_name)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    local projects = res
    for i = 1, #projects do
        local project = projects[i]
        res, err      = plugin.query_by_res(plugin.RESOURCES_TYPE_PROJECT, project.id)
        if err then
            return nil, err
        end

        local plugins = {}
        for p = 1, #res do
            plugins[res[p].name] = res[p]
        end
        projects[i].plugins = plugins

        res, err = upstream.query_by_pid(project.id)
        if err then
            return nil, err
        end

        local upstreams = {}
        for u = 1, #res do
            upstreams[res[u].env] = res[u]
        end
        projects[i].upstreams = upstreams
    end

    return projects, nil
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
