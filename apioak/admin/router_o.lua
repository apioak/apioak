local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local router_o_controller = controller.new("router_o")

function router_o_controller.created()

    local body = router_o_controller.get_body()

    router_o_controller.check_schema(schema.router.created, body)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.project_authenticate(body.project_id, router_o_controller.uid)
    end

    local res, err = db.router.created(body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.insert_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.query(params)

    router_o_controller.check_schema(schema.router.query, params)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.router.query(params.router_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if #res == 0 then
        pdk.response.exit(500, { err_message = "router: " .. params.router_id .. "not exists" })
    end

    pdk.response.exit(200, { err_message = "OK", router = res[1] })
end

function router_o_controller.updated(params)

    local body      = router_o_controller.get_body()
    body.router_id  = params.router_id

    router_o_controller.check_schema(schema.router.updated, body)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.router.updated(params.router_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.deleted(params)

    router_o_controller.check_schema(schema.router.deleted, params)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.router.deleted(params.router_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.env_push(params)

    router_o_controller.check_schema(schema.router.env_push, params)

    router_o_controller.user_authenticate()
    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.router.query(params.router_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    local router = res[1]
    if router.response_type == pdk.const.CONTENT_TYPE_JSON then
        router.response_success = pdk.json.decode(router.response_success)
        router.response_failure = pdk.json.decode(router.response_failure)
    end

    local plugins = {}
    res, err = db.plugin.query_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end
    for q = 1, #res do
        plugins[res[q].name] = res[q]
    end
    router.plugins = plugins

    res, err = db.router.env_push(params.router_id, pdk.string.upper(params.env), router)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.env_pull(params)

    router_o_controller.check_schema(schema.router.env_pull, params)

    router_o_controller.user_authenticate()
    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.router.env_pull(params.router_id, pdk.string.upper(params.env))
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.plugins(params)

    router_o_controller.check_schema(schema.router.plugins, params)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.plugin.query_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    pdk.response.exit(200, { err_message = "OK", plugins = res })
end

function router_o_controller.plugin_created(params)

    local body      = router_o_controller.get_body()
    body.router_id  = params.router_id

    router_o_controller.check_schema(schema.router.plugin_created, body)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.plugin.create_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.insert_id == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.plugin_updated(params)

    local body      = router_o_controller.get_body()
    body.router_id  = params.router_id
    body.plugin_id  = params.plugin_id

    router_o_controller.check_schema(schema.router.plugin_updated, body)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.plugin.update_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id, params.plugin_id, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

function router_o_controller.plugin_deleted(params)

    router_o_controller.check_schema(schema.router.plugin_deleted, params)

    router_o_controller.user_authenticate()

    if not router_o_controller.is_owner then
        router_o_controller.router_authenticate(params.router_id, router_o_controller.uid)
    end

    local res, err = db.plugin.delete_by_res(db.plugin.RESOURCES_TYPE_ROUTER, params.router_id, params.plugin_id)
    if err then
        pdk.response.exit(500, { err_message = err })
    end

    if res.affected_rows == 0 then
        pdk.response.exit(500, { err_message = "FAIL" })
    else
        pdk.response.exit(200, { err_message = "OK" })
    end
end

return router_o_controller
