local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local account_controller = controller.new("account")

function account_controller.register()

    local body = account_controller.get_body()

    account_controller.check_schema(schema.account.register, body)

    local res, err = db.user.all()
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res == 0 then
        body.is_owner  = 1
    end
    body.is_enable = 1

    if body.password ~= body.valid_password then
        pdk.response.exit(501, { err_message = "inconsistent password entry" })
    end

    res, err = db.user.create(body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.insert_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function account_controller.login()

    local body = account_controller.get_body()

    account_controller.check_schema(schema.account.login, body)

    local res, err = db.user.query_by_email(body.email)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res == 0 then
        pdk.response.exit(501, { err_message = "account not exists" })
    end

    local user = res[1]
    if pdk.string.md5(body.password) ~= user.password then
        pdk.response.exit(501, { err_message = "password validation failure" })
    end

    if user.is_enable == 0 then
        pdk.response.exit(501, { err_message = "account is disabled" })
    end

    res, err = db.token.query_by_uid(user.id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res == 0 then
        res, err = db.token.create_by_uid(user.id)
    else
        res, err = db.token.update_by_uid(user.id)
    end

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        user = pdk.table.del(user, "password")
        user.token = res.token

        pdk.response.exit(200, { err_message = "OK", user = user })
    end
end

function account_controller.logout()

    account_controller.user_authenticate()

    local res, err = db.token.expire_by_token(account_controller.token)

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function account_controller.status()

    local user = account_controller.user_authenticate()

    user = pdk.table.del(user, "password")

    pdk.response.exit(200, { err_message = "OK" , user = user})
end

return account_controller
