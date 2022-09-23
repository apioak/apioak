local pdk    = require("apioak.pdk")
local common = require("apioak.db.consul.common")
local uuid   = require("resty.jit-uuid")

local _M = {}


local DEFAULT_METHODS = {"ALL"}

function _M.created(params)

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local check_service = common.check_kv_exists_by_id(params.service, params.service_prefix or common.DEFAULT_SERVICE_PREFIX)

    if not check_service then
        return nil, "service check FAIL"
    end

    local check_plugin = common.batch_check_kv_exists_by_id(params.plugins, params.plugin_prefix or common.DEFAULT_PLUGIN_PREFIX)

    if not check_plugin then
        return nil, "plugin check FAIL"
    end

    local check_upstream = common.check_kv_exists_by_id(params.upstream, params.upstream_prefix or common.DEFAULT_UPSTREAM_PREFIX)

    if not check_upstream then
        return nil, "upstream check FAIL"
    end

    local router_id = uuid.generate_v4()
    local router_body = {
        id        = router_id,
        name      = params.name,
        methods   = params.methods or DEFAULT_METHODS,
        paths     = params.paths,
        headers   = params.headers or {},
        service   = params.service,
        plugins   = params.plugins or {},
        upstream  = params.upstream or {},
        enabled   = params.enabled or true
    }

    local prefix = params.prefix or common.DEFAULT_ROUTER_PREFIX

    local res, err = consul:put_key( prefix .. router_id, router_body)

    if err ~= nil then
        return nil, "create router FAIL [".. err .."]"
    end

    if not res or res.status ~= 200 then
        return nil, "create router FAIL [".. err .."] [".. res.status .."]"
    end


    -- TODO 以prefix + router_id 或 prefix + name

    -- local txn_payload = {
    --     {
    --         KV = {
    --             Verb  = "set",
    --             Key   = key .. router_id,
    --             Value = router_body,
    --         }
    --     },
    --     {
    --         KV = {
    --             Verb  = "set",
    --             Key   = key .. router_body.name,
    --             Value = router_body,
    --         }
    --     },
    -- }

    -- local res, err = consul.txn(txn_payload)

    -- if err ~= nil then
    --     return nil, err
    -- end

    -- if not res then
    --     ngx.say(err)
    --     return
    -- end

    return { id = router_id }, nil
end

function _M.updated(router_id, params)

    local prefix = params.prefix or common.DEFAULT_ROUTER_PREFIX

    local consul, err = pdk.consul.new()

    if err ~= nil or not consul then
        return nil, err
    end

    local _, err = pdk.consul.get_key(prefix .. router_id)

    if err ~= nil then
        return nil, "router[".. router_id .."] does not exist"
    end

    local check_service = common.check_kv_exists_by_id(params.service, params.service_prefix or common.DEFAULT_SERVICE_PREFIX)

    if not check_service then
        return nil, "service check FAIL"
    end

    local check_plugin = common.batch_check_kv_exists_by_id(params.plugins, params.plugin_prefix or common.DEFAULT_PLUGIN_PREFIX)

    if not check_plugin then
        return nil, "plugin check FAIL"
    end

    local check_upstream = common.check_kv_exists_by_id(params.upstream, params.upstream_prefix or common.DEFAULT_UPSTREAM_PREFIX)

    if not check_upstream then
        return nil, "upstream check FAIL"
    end

    local router_body = {
        id        = router_id,
        name      = params.name,
        methods   = params.methods or DEFAULT_METHODS,
        paths     = params.paths,
        headers   = params.headers or {},
        service   = params.service,
        plugins   = params.plugins or {},
        upstream  = params.upstream or {},
        enabled   = params.enabled or true
    }

    local res, err = consul:put_key( prefix .. router_id, router_body)

    if err ~= nil then
        return nil, "update router FAIL [".. err .."]"
    end

    if not res or res.status ~= 200 then
        return nil, "update router FAIL [".. err .."] [".. res.status .."]"
    end

    return { id = router_id }, nil
end

function _M.lists(params)

    local prefix = params.prefix or common.DEFAULT_ROUTER_PREFIX
    local res, err = common.lists(prefix)

    if err ~= nil then
        return nil, "get router list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(params)

    local prefix = params.prefix or common.DEFAULT_ROUTER_PREFIX

    local key = prefix .. params.router_id

    local res, err = common.detail(key)

    if err ~= nil or res == nil then
        return nil, "router:[".. params.router_id .. "] does not exists, err [".. err .."]"
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(params)

    local prefix = params.prefix or common.DEFAULT_ROUTER_PREFIX

    local key = prefix .. params.router_id

    local res, err = common.deleted(key)

    if err ~= nil or res == nil then
        return nil, "router:[".. params.router_id .. "] delete FAIL, err:[".. err .."]"
    end

    return res, nil
end


-- ****************************************************************
local table_name = "oak_routers"

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
    ]], table_name, project.table_name, ngx.quote_sql_str(router_name))
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
    ]], table_name, project.table_name, pdk.table.concat(project_ids, ","), ngx.quote_sql_str(router_name))
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
    ]], table_name, project.table_name, ngx.quote_sql_str(project_id))
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
    ]], table_name, project.table_name, ngx.quote_sql_str(router_id))
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

function _M.created1(params)
    local sql = pdk.string.format([[
        INSERT INTO %s (
            name, enable_cors, description,
            request_path, request_method, request_params, backend_path,
            backend_method, backend_params, constant_params,
            response_type, response_success, response_failure, response_codes, response_schema,
            project_id
        )
        VALUES(
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
    ]], table_name,
            ngx.quote_sql_str(params.name),
            ngx.quote_sql_str(params.enable_cors),
            ngx.quote_sql_str(params.description),
            ngx.quote_sql_str(params.request_path),
            ngx.quote_sql_str(params.request_method),
            ngx.quote_sql_str(pdk.json.encode(params.request_params)),
            ngx.quote_sql_str(params.backend_path),
            ngx.quote_sql_str(params.backend_method),
            ngx.quote_sql_str(pdk.json.encode(params.backend_params)),
            ngx.quote_sql_str(pdk.json.encode(params.constant_params)),
            ngx.quote_sql_str(params.response_type),
            ngx.quote_sql_str(params.response_success),
            ngx.quote_sql_str(params.response_failure),
            ngx.quote_sql_str(pdk.json.encode(params.response_codes)),
            ngx.quote_sql_str(pdk.json.encode(params.response_schema)),
            ngx.quote_sql_str(params.project_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.updated1(router_id, params)
    local sql = pdk.string.format([[
        UPDATE %s
        SET
            name = %s, enable_cors = %s, description = %s,
            request_path = %s, request_method = %s, request_params = %s,
            backend_path = %s, backend_method = %s, backend_params = %s,
            constant_params = %s, response_type = %s, response_success = %s, response_failure = %s,
            response_codes = %s, response_schema = %s
        WHERE
            id = %s;
    ]], table_name,
            ngx.quote_sql_str(params.name),
            ngx.quote_sql_str(params.enable_cors),
            ngx.quote_sql_str(params.description),
            ngx.quote_sql_str(params.request_path),
            ngx.quote_sql_str(params.request_method),
            ngx.quote_sql_str(pdk.json.encode(params.request_params)),
            ngx.quote_sql_str(params.backend_path),
            ngx.quote_sql_str(params.backend_method),
            ngx.quote_sql_str(pdk.json.encode(params.backend_params)),
            ngx.quote_sql_str(pdk.json.encode(params.constant_params)),
            ngx.quote_sql_str(params.response_type),
            ngx.quote_sql_str(params.response_success),
            ngx.quote_sql_str(params.response_failure),
            ngx.quote_sql_str(pdk.json.encode(params.response_codes)),
            ngx.quote_sql_str(pdk.json.encode(params.response_schema)),
            ngx.quote_sql_str(router_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end

    return res, nil
end

function _M.deleted1(router_id)
    local sql = pdk.string.format("DELETE FROM %s WHERE id = %s", table_name, ngx.quote_sql_str(router_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.env_push(router_id, env, router_info)
    router_info = pdk.json.encode(router_info)
    local sql = pdk.string.format("UPDATE %s SET env_%s_config = %s WHERE id = %s",
            table_name,
            pdk.string.lower(env),
            ngx.quote_sql_str(router_info),
            ngx.quote_sql_str(router_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.env_pull(router_id, env)
    local sql = pdk.string.format("UPDATE %s SET env_%s_config = NULL WHERE id = %s",
            table_name,
            pdk.string.lower(env),
            ngx.quote_sql_str(router_id))
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_env_by_pid(project_id)
    local sql = "SELECT id, request_method, request_path, response_type, response_success, env_prod_config, " ..
            "env_beta_config, env_test_config FROM %s WHERE project_id = %s ORDER BY request_path DESC"
    sql = pdk.string.format(sql, table_name, ngx.quote_sql_str(project_id))
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