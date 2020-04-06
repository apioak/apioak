local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local user_controller = controller.new("user")

function user_controller.created()

    user_controller.user_authenticate()

    local body = user_controller.get_body()

    user_controller.check_schema(schema.user.created, body)

    if body.password ~= body.valid_password then
        pdk.response.exit(501, { err_message = "inconsistent password entry" })
    end

    if not user_controller.is_owner then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.user.create(body)

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", res = res })
end

function user_controller.deleted(params)

    user_controller.check_schema(schema.user.deleted, params)

    user_controller.user_authenticate()

    if not user_controller.is_owner then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    if pdk.string.tonumber(params.user_id) == user_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.role.delete_by_uid(params.user_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.user.delete(params.user_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", res = res })
end

function user_controller.enable(params)

    user_controller.check_schema(schema.user.enable, params)

    user_controller.user_authenticate()

    if not user_controller.is_owner then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    if pdk.string.tonumber(params.user_id) == user_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.user.update_status(params.user_id, 1)

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", res = res })
end

function user_controller.disable(params)

    user_controller.check_schema(schema.user.disable, params)

    user_controller.user_authenticate()

    if not user_controller.is_owner then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    if pdk.string.tonumber(params.user_id) == user_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.user.update_status(params.user_id, 0)

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", res = res })
end

function user_controller.password(params)

    local body   = user_controller.get_body()
    body.user_id = params.user_id

    user_controller.check_schema(schema.user.password, body)

    user_controller.user_authenticate()

    if not user_controller.is_owner then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    if pdk.string.tonumber(params.user_id) == user_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    if body.password ~= body.valid_password then
        pdk.response.exit(501, { err_message = "inconsistent password entry" })
    end

    local res, err = db.user.update_password(params.user_id, body.password)

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", res = res })
end

return user_controller
