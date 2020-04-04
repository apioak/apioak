local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local common_controller = controller.new("common")

function common_controller.users()

    common_controller.user_authenticate()

    local res, err
    if common_controller.is_owner then
        res, err = db.user.all()
    else
        res, err = db.user.query_by_id(common_controller.uid)
    end
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", users = res })
end

function common_controller.members()

    common_controller.user_authenticate()

    local res, err = db.user.all(true)

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", members = res })
end

function common_controller.plugins()

    common_controller.user_authenticate()

    local plugins = pdk.plugin.loading()

    local res = {}
    for i = 1, #plugins do
        pdk.table.insert(res, {
            name        = plugins[i].name,
            type        = plugins[i].type,
            description = plugins[i].description,
            config      = plugins[i].config
        })
    end

    pdk.response.exit(200, { err_message = "OK", plugins = res })
end

function common_controller.projects()

    local query = pdk.request.query()

    common_controller.check_schema(schema.common.projects, query)

    common_controller.user_authenticate()

    local res, err
    if common_controller.is_owner then
        res, err = db.project.all(query.q)
    else
        res, err = db.project.query_by_uid(common_controller.uid, query.q)
    end

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if common_controller.is_owner then
        for i = 1, #res do
            res[i].is_admin = 1
        end
    end

    pdk.response.exit(200, { err_message = "OK", projects = res })
end

function common_controller.routers()

    local query = pdk.request.query()

    common_controller.check_schema(schema.common.routers, query)

    common_controller.user_authenticate()

    local res, err
    if common_controller.is_owner then
        res, err = db.router.all(query.q)
    else
        res, err = db.router.query_by_uid(common_controller.uid, query.q)
    end

    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", routers = res })
end

return common_controller
