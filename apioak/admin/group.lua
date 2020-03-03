local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local group_controller = controller.new("group")

function group_controller.list()

    group_controller.user_authenticate()

    local res, err
    if group_controller.is_owner then
        res, err = db.group.all(true)
    else
        res, err = db.group.query_by_uid(group_controller.uid)
    end

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", groups = res })
end

function group_controller.query(params)

    group_controller.check_schema(schema.group.query, params)

    group_controller.user_authenticate()

    local res, err = db.group.query(params.group_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res > 0 then
        res = res[1]
    end

    pdk.response.exit(200, { err_message = "OK", group = res })
end

function group_controller.created()

    group_controller.user_authenticate()

    if not group_controller.is_owner then
        pdk.response.exit(401, { err_message = "no permission to create group" })
    end

    local body = group_controller.get_body()
    group_controller.check_schema(schema.group.created, body)

    local _, err = db.group.create(body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end


function group_controller.updated(params)

    group_controller.user_authenticate()

    if not group_controller.is_owner then
        pdk.response.exit(401, { err_message = "no permission to update group" })
    end

    local body = group_controller.get_body()
    body.group_id = params.group_id

    group_controller.check_schema(schema.group.updated, body)

    local _, err = db.group.update(body.group_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function group_controller.deleted(params)

    group_controller.user_authenticate()

    if not group_controller.is_owner then
        pdk.response.exit(401, { err_message = "no permission to update group" })
    end

    group_controller.check_schema(schema.group.deleted, params)

    local res, err = db.project.query_by_gid(params.group_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res > 0 then
        pdk.response.exit(500, { err_message = "projects in group were not deleted" })
    end

    res, err = db.role.delete_by_gid(params.group_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.group.delete(params.group_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function group_controller.user_list(params)

    group_controller.user_authenticate()

    if not group_controller.is_owner then
        group_controller.group_authenticate(params.group_id, group_controller.uid)
    end

    group_controller.check_schema(schema.group.user_list, params)

    local res, err = db.user.query_by_gid(params.group_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", users = res })
end

function group_controller.user_create(params)

    group_controller.user_authenticate()

    local body    = group_controller.get_body()
    body.group_id = params.group_id

    group_controller.check_schema(schema.group.user_created, body)

    if not group_controller.is_owner then
        local user_group = group_controller.group_authenticate(params.group_id, group_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local _, err = db.role.create(body.group_id, body.user_id, body.is_admin)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function group_controller.user_update(params)

    group_controller.user_authenticate()

    local body    = group_controller.get_body()
    body.user_id  = params.user_id
    body.group_id = params.group_id

    group_controller.check_schema(schema.group.user_updated, body)

    if not group_controller.is_owner then
        local user_group = group_controller.group_authenticate(params.group_id, group_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to update group member" })
        end
    end

    local _, err = db.role.update(body.group_id, body.user_id, body.is_admin)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function group_controller.user_delete(params)

    group_controller.user_authenticate()

    group_controller.check_schema(schema.group.user_deleted, params)

    if not group_controller.is_owner then
        local user_group = group_controller.group_authenticate(params.group_id, group_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to delete group member" })
        end
    end

    if params.user_id == group_controller.uid then
        pdk.response.exit(401, { err_message = "no permission to delete this member" })
    end

    local _, err = db.role.delete(params.group_id, params.user_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

return group_controller
