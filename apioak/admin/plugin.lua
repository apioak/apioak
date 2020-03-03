local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local plugin_controller = controller.new("plugin")

function plugin_controller.plugin_list()

    plugin_controller.user_authenticate()

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

function plugin_controller.project_list(params)

    plugin_controller.check_schema(schema.plugin.project_list, params)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        local role = plugin_controller.project_authenticate(params.project_id, plugin_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local res, err = db.plugin.query_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", plugins = res })
end

function plugin_controller.project_created(params)

    local body      = plugin_controller.get_body()
    body.project_id = params.project_id

    plugin_controller.check_schema(schema.plugin.project_created, body)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        local role = plugin_controller.project_authenticate(params.project_id, plugin_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local _, err = db.plugin.create_by_res(db.plugin.RESOURCES_TYPE_PROJECT, params.project_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function plugin_controller.project_updated(params)

    local body      = plugin_controller.get_body()
    body.project_id = params.project_id
    body.plugin_id  = params.plugin_id

    plugin_controller.check_schema(schema.plugin.project_updated, body)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        local role = plugin_controller.project_authenticate(params.project_id, plugin_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local _, err = db.plugin.update(params.plugin_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function plugin_controller.project_deleted(params)

    plugin_controller.check_schema(schema.plugin.project_deleted, params)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        local role = plugin_controller.project_authenticate(params.project_id, plugin_controller.uid)
        if role.is_admin ~= 1 then
            pdk.response.exit(401, { err_message = "no permission to create group member" })
        end
    end

    local _, err = db.plugin.delete(params.plugin_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function plugin_controller.router_list(params)

    plugin_controller.check_schema(schema.plugin.router_list, params)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        plugin_controller.router_authenticate(params.router_id, plugin_controller.uid)
    end

    local res, err = db.plugin.query_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", plugins = res })
end

function plugin_controller.router_created(params)

    local body      = plugin_controller.get_body()
    body.router_id  = params.router_id

    plugin_controller.check_schema(schema.plugin.router_created, body)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        plugin_controller.router_authenticate(params.router_id, plugin_controller.uid)
    end

    local _, err = db.plugin.create_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function plugin_controller.router_updated(params)

    local body      = plugin_controller.get_body()
    body.router_id  = params.router_id
    body.plugin_id  = params.plugin_id

    plugin_controller.check_schema(schema.plugin.router_updated, body)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        plugin_controller.router_authenticate(params.router_id, plugin_controller.uid)
    end

    local _, err = db.plugin.update(params.plugin_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

function plugin_controller.router_deleted(params)

    plugin_controller.check_schema(schema.plugin.router_deleted, params)

    plugin_controller.user_authenticate()

    if not plugin_controller.is_owner then
        plugin_controller.router_authenticate(params.router_id, plugin_controller.uid)
    end

    local _, err = db.plugin.delete(params.plugin_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK" })
end

return plugin_controller
