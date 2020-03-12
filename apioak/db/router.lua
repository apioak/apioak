local pdk = require("apioak.pdk")

local table_name = "oak_routers"

local _M = {}

_M.table_name = table_name

function _M.query_by_pid(project_id)
    local sql = "SELECT id, name, enable_cors, description, request_path, request_method, env_prod_config, " ..
            "env_beta_config, env_test_config FROM %s WHERE project_id = %s"
    sql = pdk.string.format(sql, table_name, project_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        if res[i].env_prod_config == pdk.string.null then
            res[i].env_prod_publish = 0
        else
            res[i].env_prod_publish = 1
        end
        res[i].env_prod_config = nil

        if res[i].env_beta_config == pdk.string.null then
            res[i].env_beta_publish = 0
        else
            res[i].env_beta_publish = 1
        end
        res[i].env_beta_config = nil

        if res[i].env_test_config == pdk.string.null then
            res[i].env_test_publish = 0
        else
            res[i].env_test_publish = 1
        end
        res[i].env_test_config = nil
    end

    return res, nil
end

function _M.query(router_id)
    local sql = "SELECT id, name, enable_cors, description, request_path, request_method, request_params, " ..
            "backend_path, backend_method, backend_params, constant_params, response_type, " ..
            "response_success, response_failure, response_codes, response_schema, env_prod_config, env_beta_config, " ..
            "env_test_config, project_id FROM %s WHERE id = %s";
    sql = pdk.string.format(sql, table_name, router_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end

    for i = 1, #res do
        res[i].request_params  = pdk.json.decode(res[i].request_params)
        res[i].backend_params  = pdk.json.decode(res[i].backend_params)
        res[i].constant_params = pdk.json.decode(res[i].constant_params)
        res[i].response_codes  = pdk.json.decode(res[i].response_codes)
        res[i].response_schema = pdk.json.decode(res[i].response_schema)

        if res[i].env_prod_config == pdk.string.null then
            res[i].env_prod_publish = 0
        else
            res[i].env_prod_publish = 1
        end
        res[i].env_prod_config = nil

        if res[i].env_beta_config == pdk.string.null then
            res[i].env_beta_publish = 0
        else
            res[i].env_beta_publish = 1
        end
        res[i].env_beta_config = nil

        if res[i].env_test_config == pdk.string.null then
            res[i].env_test_publish = 0
        else
            res[i].env_test_publish = 1
        end
        res[i].env_test_config = nil
    end

    return res, nil
end

function _M.created(params)
    local sql = "INSERT INTO %s (name, enable_cors, description, request_path, request_method, request_params, " ..
            "backend_path, backend_method, backend_params, constant_params, response_type, " ..
            "response_success, response_failure, response_codes, response_schema, project_id) " ..
            "VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', " ..
            "'%s')"
    sql = pdk.string.format(sql, table_name, params.name, params.enable_cors, params.description, params.request_path,
            params.request_method, pdk.json.encode(params.request_params), params.backend_path, params.backend_method,
            pdk.json.encode(params.backend_params), pdk.json.encode(params.constant_params),
            params.response_type, params.response_success, params.response_failure, pdk.json.encode(params.response_codes),
            pdk.json.encode(params.response_schema), params.project_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.updated(router_id, params)
    local sql = "UPDATE %s SET name = '%s', enable_cors = '%s', description = '%s', request_path = '%s', " ..
            "request_method = '%s', request_params = '%s', backend_path = '%s', backend_method = '%s', " ..
            "backend_params = '%s', constant_params = '%s', response_type = '%s', " ..
            "response_success = '%s', response_failure = '%s', response_codes = '%s', response_schema = '%s' "..
            "WHERE id = '%s'"
    sql = pdk.string.format(sql, table_name, params.name, params.enable_cors, params.description, params.request_path,
            params.request_method, pdk.json.encode(params.request_params), params.backend_path, params.backend_method,
            pdk.json.encode(params.backend_params), pdk.json.encode(params.constant_params),
            params.response_type, params.response_success, params.response_failure, pdk.json.encode(params.response_codes),
            pdk.json.encode(params.response_schema), router_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.deleted(router_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s", table_name, router_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.online(router_id, env, router_info)
    router_info = pdk.json.encode(router_info)
    local sql = pdk.string.format("UPDATE %s SET env_%s_config = '%s' WHERE id = %s",
            table_name, pdk.string.lower(env), router_info, router_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.offline(router_id, env)
    local sql = pdk.string.format("UPDATE %s SET env_%s_config = NULL WHERE id = %s",
            table_name, pdk.string.lower(env), router_id)
    local res, err = pdk.mysql.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_env_by_pid(project_id)
    local sql = "SELECT id, request_method, request_path, response_type, response_success, env_prod_config, " ..
            "env_beta_config, env_test_config FROM %s WHERE project_id = %s"
    sql = pdk.string.format(sql, table_name, project_id)
    local res, err = pdk.mysql.execute(sql)
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

return _M
