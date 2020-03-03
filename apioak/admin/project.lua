local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local project_controller = controller.new("project")

function project_controller.list(params)

    project_controller.check_schema(schema.project.list, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        project_controller.group_authenticate(params.group_id, project_controller.uid)
    end

    local res, err = db.project.query_by_gid(params.group_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", projects = res })
end

function project_controller.create(params)

    local body = project_controller.get_body()
    body.group_id = params.group_id

    project_controller.check_schema(schema.project.created, body)

    project_controller.user_authenticate()
    body.user_id  = project_controller.uid

    if not project_controller.is_owner then
        local user_group = project_controller.group_authenticate(params.group_id, project_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local  res, err = db.project.create(body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end
    local project_id = res.insert_id

    for i = 1, #body.upstreams do
        local upstream = body.upstreams[i]
        upstream.project_id = project_id
        res, err = db.upstream.create(upstream)
        if err then
            pdk.response.exit(500, { err_message = err })
        end
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function project_controller.update(params)

    local body = project_controller.get_body()
    body.id = params.project_id

    project_controller.check_schema(schema.project.updated, body)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local user_group = project_controller.group_authenticate(params.group_id, project_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local  res, err = db.project.update(params.project_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    for i = 1, #body.upstreams do
        local upstream = body.upstreams[i]
        res, err = db.upstream.update(upstream.id, upstream)
        if err then
            pdk.response.exit(500, { err_message = err })
        end
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function project_controller.query(params)

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
        pdk.response.exit(500, { err_message = "project: " .. params.project_id .. "not exists" })
    end
    local project = res[1]

    res, err = db.upstream.query_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end
    project.upstreams = res

    pdk.response.exit(200, { err_message = "OK", project = project })
end

function project_controller.delete(params)

    project_controller.check_schema(schema.project.deleted, params)

    project_controller.user_authenticate()

    if not project_controller.is_owner then
        local user_group = project_controller.group_authenticate(params.group_id, project_controller.uid)
        if user_group.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local res, err = db.router.query_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res > 0 then
        pdk.response.exit(500, { err_message = "routers in project were not deleted" })
    end

    res, err = db.plugin.delete_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.upstream.delete_by_pid(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    res, err = db.project.delete(params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

return project_controller
