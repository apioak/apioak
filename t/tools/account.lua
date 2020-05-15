local json        = require("cjson.safe")
local pdk         = require("apioak.pdk")
local user_table  = "oak_users"
local token_table = "oak_tokens"
local roles_table = "oak_roles"

local _M = {}

function _M.get_token(user_id)
    local token_sql = pdk.string.format("SELECT token FROM %s WHERE user_id = %s",
            token_table, ngx.quote_sql_str(user_id))
    local user_token, token_err = pdk.database.execute(token_sql)

    if token_err then
        return 500, nil, token_err
    end

    return 200, user_token[1].token, nil
end


function _M.set_admin(user_id)
    local set_admin_sql = pdk.string.format("UPDATE %s SET is_owner = 1 WHERE id = %s",
            user_table, ngx.quote_sql_str(user_id))
    local set_admin, set_err = pdk.database.execute(set_admin_sql)
    if set_err then
        return 500, nil, set_err
    end

    ngx.log(ngx.INFO, json.encode(set_admin))

    return 200, "OK", nil
end


function _M.user_delete(user_id)
    local delete_user_sql = pdk.string.format("DELETE FROM %s WHERE id = %s",
            user_table, ngx.quote_sql_str(user_id))
    local del_user_res, del_user_err = pdk.database.execute(delete_user_sql)
    if del_user_err then
        return 500, nil, del_user_res
    end

    local delete_roles_sql = pdk.string.format("DELETE FROM %s WHERE user_id = %s",
            roles_table, ngx.quote_sql_str(user_id))
    local del_roles_res, del_roles_err = pdk.database.execute(delete_roles_sql)
    ngx.log(ngx.INFO, del_roles_err, json.encode(del_roles_res))

    local delete_token_sql = pdk.string.format("DELETE FROM %s WHERE user_id = %s",
            token_table, ngx.quote_sql_str(user_id))
    local del_token_res, del_token_err = pdk.database.execute(delete_token_sql)
    ngx.log(ngx.INFO, del_token_err, json.encode(del_token_res))

    return 200, del_user_res.affected_rows, nil
end


function _M.user_info(email)
    local user_sql = pdk.string.format("SELECT * FROM %s WHERE email = %s",
            user_table, ngx.quote_sql_str(email))
    local user_id, user_err = pdk.database.execute(user_sql)
    if user_err then
        return 401, nil, user_err
    end

    return 200, user_id[1], nil
end

return _M
