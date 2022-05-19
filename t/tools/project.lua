local ngx             = ngx
local pdk             = require("apioak.pdk")
local project_table   = "oak_projects"
local upstreams_table = "oak_upstreams"
local plugins_table   = "oak_plugins"
local routers_table   = "oak_routers"

local _M = {}

function _M.project_info(name, path)
    local sql = pdk.string.format("SELECT * FROM %s WHERE name = %s AND path = %s",
            project_table,
            ngx.quote_sql_str(name),
            ngx.quote_sql_str(path))
    local res, err = pdk.database.execute(sql)
    if err then
        return 500, nil, err
    end

    return 200, res[1], nil
end


function _M.project_upstream(project_id, env)
    local sql = pdk.string.format("SELECT * FROM %s WHERE project_id = %s AND env = %s",
            upstreams_table,
            ngx.quote_sql_str(project_id),
            ngx.quote_sql_str(env))
    local res, err = pdk.database.execute(sql)
    if err then
        return 500, nil, err
    end

    return 200, res[1], nil
end


function _M.plugins_info(res_type, res_id, name)
    local sql = pdk.string.format("SELECT * FROM %s WHERE res_type = %s AND res_id = %s AND name = %s",
            plugins_table,
            ngx.quote_sql_str(res_type),
            ngx.quote_sql_str(res_id),
            ngx.quote_sql_str(name))
    local res, err = pdk.database.execute(sql)
    if err then
        return 500, nil, err
    end

    return 200, res[1], nil
end


function _M.routers_info(project_id, request_path, request_method)
    local sql = pdk.string.format(
            "SELECT * FROM %s WHERE project_id = %s AND request_path = %s AND request_method = %s",
            routers_table,
            ngx.quote_sql_str(project_id),
            ngx.quote_sql_str(request_path),
            ngx.quote_sql_str(request_method))
    local res, err = pdk.database.execute(sql)
    if err then
        return 500, nil, err
    end

    return 200, res[1], nil
end


return _M
