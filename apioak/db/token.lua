local pdk = require("apioak.pdk")

local _M = {}

local table_name = "oak_tokens"

function _M.query_by_uid(user_id)
    local sql = pdk.string.format("SELECT * FROM %s WHERE user_id = %s", table_name, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.query_by_token(token)
    local sql = pdk.string.format("SELECT * FROM %s WHERE token = '%s'", table_name, token)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

function _M.create_by_uid(user_id)
    local token = pdk.string.md5(pdk.time.time())
    local expired = pdk.time.date("%Y-%m-%d %H:%M:%S", pdk.time.time() + 86400)

    local sql = pdk.string.format("INSERT INTO %s (token, user_id, expired_at) VALUES ('%s', '%s', '%s')",
            table_name, token, user_id, expired)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    res.token   = token
    res.expired = expired
    return res, nil
end

function _M.update_by_uid(user_id)
    local token = pdk.string.md5(pdk.time.time())
    local expired = pdk.time.date("%Y-%m-%d %H:%M:%S", pdk.time.time() + 86400)

    local sql = pdk.string.format("UPDATE %s SET token = '%s', expired_at = '%s' WHERE user_id = %s",
            table_name, token, expired, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    res.token   = token
    res.expired = expired
    return res, nil
end

function _M.continue_by_uid(user_id)
    local expired = pdk.time.date("%Y-%m-%d %H:%M:%S", pdk.time.time() + 86400)

    local sql = pdk.string.format("UPDATE %s SET expired_at = '%s' WHERE user_id = %s",
            table_name, expired, user_id)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    res.expired = expired
    return res, nil
end

function _M.continue_by_token(token)
    local expired = pdk.time.date("%Y-%m-%d %H:%M:%S", pdk.time.time() + 86400)

    local sql = pdk.string.format("UPDATE %s SET expired_at = '%s' WHERE token = '%s'",
            table_name, expired, token)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    res.expired = expired
    return res, nil
end

function _M.expire_by_token(token)
    local sql = pdk.string.format("UPDATE %s SET expired_at = NULL WHERE token = '%s'", table_name, token)
    local res, err = pdk.database.execute(sql)

    if err then
        return nil, err
    end
    return res, nil
end

return _M
