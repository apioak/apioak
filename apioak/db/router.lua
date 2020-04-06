local pdk     = require("apioak.pdk")
local role    = require("apioak.db.role")
local project = require("apioak.db.project")


local table_name = "oak_routers"

local _M = {}

_M.table_name = table_name

function _M.all(router_name)
    local sql
    if router_name and pdk.string.len(router_name) >= 1 then
        sql = pdk.string.format([[
            SELECT
                routers.id,
                routers.name,
                routers.description,
                routers.request_path,
                routers.request_method,
                projects.path AS project_path,
                projects.name AS project_name,
                projects.id AS project_id,
                !ISNULL(routers.env_prod_config) AS env_prod_publish,
                !ISNULL(routers.env_beta_config) AS env_beta_publish,
                !ISNULL(routers.env_test_config) AS env_test_publish
            FROM %s routers
                LEFT JOIN %s projects ON routers.project_id = projects.id
            WHERE
                routers.name LIKE '%%%s%%'
            ORDER BY
                routers.id
            DESC
    ]], table_name, project.table_name, router_name)
    else
        sql = pdk.string.format([[
            SELECT
                routers.id,
                routers.name,
                routers.description,
                routers.request_path,
                routers.request_method,
                projects.path AS project_path,
                projects.name AS project_name,
                projects.id AS project_id,
                !ISNULL(routers.env_prod_config) AS env_prod_publish,
                !ISNULL(routers.env_beta_config) AS env_beta_publish,
                !ISNULL(routers.env_test_config) AS env_test_publish
            FROM %s routers
                LEFT JOIN %s projects ON routers.project_id = projects.id
            ORDER BY
                routers.id
            DESC
    ]], table_name, project.table_name)
    end

    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_uid(user_id, router_name)
    local res, err = role.query_by_uid(user_id)
    if err then
        return nil, err
    end

    local project_ids = pdk.table.new(50, 0)
    for i = 1, #res do
        pdk.table.insert(project_ids, res[i].project_id)
    end

    if #project_ids == 0 then
        return pdk.table.new(0, 0), nil
    end

    local sql
    if router_name and pdk.string.len(router_name) >= 1 then
        sql = pdk.string.format([[
            SELECT
                routers.id,
                routers.name,
                routers.description,
                routers.request_path,
                routers.request_method,
                projects.path AS project_path,
                projects.name AS project_name,
                projects.id AS project_id,
                !ISNULL(routers.env_prod_config) AS env_prod_publish,
                !ISNULL(routers.env_beta_config) AS env_beta_publish,
                !ISNULL(routers.env_test_config) AS env_test_publish
            FROM
                %s AS routers
            LEFT JOIN
                %s AS projects
            ON
                routers.project_id = projects.id
            WHERE
                projects.id IN (%s) AND routers.name LIKE '%%%s%%'
            ORDER BY
                routers.id
            DESC
    ]], table_name, project.table_name, pdk.table.concat(project_ids, ","), router_name)
    else
        sql = pdk.string.format([[
            SELECT
                routers.id,
                routers.name,
                routers.description,
                routers.request_path,
                routers.request_method,
                projects.path AS project_path,
                projects.name AS project_name,
                projects.id AS project_id,
                !ISNULL(routers.env_prod_config) AS env_prod_publish,
                !ISNULL(routers.env_beta_config) AS env_beta_publish,
                !ISNULL(routers.env_test_config) AS env_test_publish
            FROM
                %s AS routers
            LEFT JOIN
                %s AS projects
            ON
                routers.project_id = projects.id
            WHERE
                projects.id IN (%s)
            ORDER BY
                routers.id
            DESC
    ]], table_name, project.table_name, pdk.table.concat(project_ids, ","))
    end

    res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.query_by_pid(project_id)
    local sql = pdk.string.format([[
        SELECT
            routers.id,
            routers.name,
            routers.description,
            routers.request_path,
            routers.request_method,
            projects.path AS project_path,
            projects.name AS project_name,
            projects.id AS project_id,
            !ISNULL(routers.env_prod_config) AS env_prod_publish,
	        !ISNULL(routers.env_beta_config) AS env_beta_publish,
	        !ISNULL(routers.env_test_config) AS env_test_publish
        FROM %s routers
	        LEFT JOIN %s projects ON routers.project_id = projects.id
	    WHERE
	        projects.id = %s
	    ORDER BY
	        routers.id
	    DESC
    ]], table_name, project.table_name, project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.query(router_id)
    local sql = pdk.string.format([[
        SELECT
            routers.id,
            routers.name,
            routers.enable_cors,
            routers.description,
            routers.constant_params,
            routers.request_path,
            routers.request_method,
            routers.request_params,
            routers.backend_path,
            routers.backend_method,
            routers.backend_params,
            routers.response_type,
            routers.response_success,
            routers.response_failure,
            routers.response_codes,
            routers.response_schema,
            !ISNULL(routers.env_prod_config) AS env_prod_publish,
            !ISNULL(routers.env_beta_config) AS env_beta_publish,
            !ISNULL(routers.env_test_config) AS env_test_publish,
            projects.id AS project_id,
            projects.name AS project_name,
            projects.path AS project_path
        FROM
            %s AS routers
        LEFT JOIN
            %s AS projects ON routers.project_id = projects.id
        WHERE
            routers.id = %s
    ]], table_name, project.table_name, router_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].request_params  = pdk.json.decode(res[i].request_params)
        res[i].backend_params  = pdk.json.decode(res[i].backend_params)
        res[i].constant_params = pdk.json.decode(res[i].constant_params)
        res[i].response_codes  = pdk.json.decode(res[i].response_codes)
        res[i].response_schema = pdk.json.decode(res[i].response_schema)
    end

    return res, nil
end

function _M.created(params)
    local sql = pdk.string.format([[
        INSERT INTO %s (
            name, enable_cors, description,
            request_path, request_method, request_params, backend_path,
            backend_method, backend_params, constant_params,
            response_type, response_success, response_failure, response_codes, response_schema,
            project_id
        )
        VALUES(
            '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s'
        )
    ]], table_name,
        params.name,
        params.enable_cors,
        params.description,
        params.request_path,
        params.request_method,
        pdk.json.encode(params.request_params),
        params.backend_path,
        params.backend_method,
        pdk.json.encode(params.backend_params),
        pdk.json.encode(params.constant_params),
        params.response_type,
        params.response_success,
        params.response_failure,
        pdk.json.encode(params.response_codes),
        pdk.json.encode(params.response_schema),
        params.project_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.updated(router_id, params)
    local sql = pdk.string.format([[
        UPDATE %s
        SET
            name = '%s', enable_cors = '%s', description = '%s',
            request_path = '%s', request_method = '%s', request_params = '%s',
            backend_path = '%s', backend_method = '%s', backend_params = '%s',
            constant_params = '%s', response_type = '%s', response_success = '%s', response_failure = '%s',
            response_codes = '%s', response_schema = '%s'
        WHERE
            id = %s;
    ]], table_name,
        params.name,
        params.enable_cors,
        params.description,
        params.request_path,
        params.request_method,
        pdk.json.encode(params.request_params),
        params.backend_path,
        params.backend_method,
        pdk.json.encode(params.backend_params),
        pdk.json.encode(params.constant_params),
        params.response_type,
        params.response_success,
        params.response_failure,
        pdk.json.encode(params.response_codes),
        pdk.json.encode(params.response_schema),
        router_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.deleted(router_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s", table_name, router_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.env_push(router_id, env, router_info)
    router_info = pdk.json.encode(router_info)
    local sql = pdk.string.format("UPDATE %s SET env_%s_config = '%s' WHERE id = %s",
            table_name, pdk.string.lower(env), router_info, router_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.env_pull(router_id, env)
    local sql = pdk.string.format("UPDATE %s SET env_%s_config = NULL WHERE id = %s",
            table_name, pdk.string.lower(env), router_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_env_by_pid(project_id)
    local sql = "SELECT id, request_method, request_path, response_type, response_success, env_prod_config, " ..
            "env_beta_config, env_test_config FROM %s WHERE project_id = %s"
    sql = pdk.string.format(sql, table_name, project_id)
    local res, err = pdk.database.execute(sql)
    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].env_prod_config = pdk.json.decode(res[i].env_prod_config)
        res[i].env_beta_config = pdk.json.decode(res[i].env_beta_config)
        res[i].env_test_config = pdk.json.decode(res[i].env_test_config)
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
