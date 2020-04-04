local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local project_controller = controller.new("project")

function project_controller.created()

    local body = project_controller.get_body()

    project_controller.check_schema(schema.project.created, body)

    project_controller.user_authenticate()

    local  res, err = db.project.created(body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    local project_id = res.insert_id
    if project_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    end

    for i = 1, #body.upstreams do
        local upstream      = body.upstreams[i]
        upstream.project_id = project_id
        res, err = db.upstream.create(upstream)
        if err then
            db.project.delete(project_id)

            db.upstream.delete_by_pid(project_id)

            pdk.response.exit(500, { err_message = err })
        end
    end

    res, err = db.role.create(project_id, project_controller.uid, 1)
    if err then

        db.project.delete(project_id)

        db.upstream.delete_by_pid(project_id)

        pdk.response.exit(500, { err_message = err })
    end

    if res.insert_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.updated(params)

    local body      = project_controller.get_body()
    body.project_id = params.project_id

    project_controller.check_schema(schema.project.updated, body)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    local  res, err = db.project.updated(params.project_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    for i = 1, #body.upstreams do
        local upstream = body.upstreams[i]
        res, err = db.upstream.update_by_pid(params.project_id, upstream)
        if err then
            pdk.response.exit(500, { err_message = err })
        end
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.selected(params)

    project_controller.check_schema(schema.project.query, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        project_controller.project_authenticate(params.project_id, project_controller.uid)
    end

    local res, err = db.project.query(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res == 0 then
        pdk.response.exit(501, { err_message = "project not exists" })
    end
    local project = res[1]

    res, err = db.upstream.query_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end
    project.upstreams = res

    pdk.response.exit(200, { err_message = "OK", project = project })
end

function project_controller.deleted(params)

    project_controller.check_schema(schema.project.deleted, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    local res, err = db.router.query_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res > 0 then
        pdk.response.exit(501, { err_message = "routers in project were not deleted" })
    end

    res, err = db.plugin.delete_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.upstream.delete_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.role.delete_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.project.delete(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.members(params)

    project_controller.check_schema(schema.project.members, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        project_controller.project_authenticate(params.project_id, project_controller.uid)
    end

    local res, err = db.user.query_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", members = res })
end

function project_controller.member_created(params)

    local body      = project_controller.get_body()
    body.project_id = params.project_id

    project_controller.check_schema(schema.project.member_created, body)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    if pdk.string.tonumber(body.user_id) == project_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.role.create(body.project_id, body.user_id, body.is_admin)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.insert_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.member_deleted(params)

    project_controller.check_schema(schema.project.member_deleted, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local user_group = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    if pdk.string.tonumber(params.user_id) == project_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.role.delete(params.project_id, params.user_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.member_updated(params)

    local body      = project_controller.get_body()
    body.user_id    = params.user_id
    body.project_id = params.project_id

    project_controller.check_schema(schema.project.member_updated, body)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    if pdk.string.tonumber(params.user_id) == project_controller.uid then
        pdk.response.exit(501, { err_message = "no permissions" })
    end

    local res, err = db.role.update(params.project_id, params.user_id, body.is_admin)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.plugins(params)

    project_controller.check_schema(schema.project.plugins, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        project_controller.project_authenticate(params.project_id, project_controller.uid)
    end

    local res, err = db.plugin.query_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", plugins = res })
end

function project_controller.plugin_created(params)

    local body      = project_controller.get_body()
    body.project_id = params.project_id

    project_controller.check_schema(schema.project.plugin_created, body)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    local res, err = db.plugin.create_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.insert_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.plugin_updated(params)

    local body      = project_controller.get_body()
    body.project_id = params.project_id
    body.plugin_id  = params.plugin_id

    project_controller.check_schema(schema.project.plugin_updated, body)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    local res, err = db.plugin.update_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id, params.plugin_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.plugin_deleted(params)

    project_controller.check_schema(schema.project.plugin_deleted, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local role = project_controller.project_authenticate(params.project_id, project_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(501, { err_message = "no permissions" })
        end
    end

    local res, err = db.plugin.delete_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id, params.plugin_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function project_controller.routers(params)

    project_controller.check_schema(schema.project.routers, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        project_controller.project_authenticate(params.project_id, project_controller.uid)
    end

    local res, err = db.router.query_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", routers = res })
end

return project_controller
