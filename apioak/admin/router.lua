local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local router_controller = controller.new("router")

function router_controller.created()

    local body = router_controller.get_body()

    router_controller.check_schema(schema.router.created, body)

    router_controller.user_authenticate()

    local res, err = db.router.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    if res == nil or res.id == nil then
        pdk.response.exit(500, { message = err })
        return
    end

    if not res.id then
        pdk.response.exit(500, { message = "create router FAIL" })
    end

    pdk.response.exit(200, {id = res.id})
end

function router_controller.updated(params)

    local body      = router_controller.get_body()
    body.route_id = params.router_id

    router_controller.check_schema(schema.router.updated, body)

    router_controller.user_authenticate()

    local  res, err = db.router.updated(params.router_id, body)
    if err then
        pdk.response.exit(500, { message = err })
    end

    if res == nil or res.id == nil then
        pdk.response.exit(500, { message = err })
        return
    end

    if not res.id then
        pdk.response.exit(500, { message = "update router FAIL" })
    end

    pdk.response.exit(200, { id = res.id })
    
end

function router_controller.detail(params)

    local body      = router_controller.get_body()
    body.router_id = params.router_id

    router_controller.check_schema(schema.router.detail, body)

    router_controller.user_authenticate()

    local  res, err = db.router.detail(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    if not res or not res.id then
        pdk.response.exit(500, { message = "update router FAIL" })
    else
        pdk.response.exit(200, { id = res })
    end
end

function router_controller.lists(params)

    router_controller.user_authenticate()

    local  res, err = db.router.lists(params)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function router_controller.deleted(params)

    local body      = router_controller.get_body()
    body.router_id = params.router_id

    router_controller.check_schema(schema.router.deleted, body)

    router_controller.user_authenticate()

    local  res, err = db.router.deleted(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    if res == "" then
        pdk.response.exit(500, { message = "update router FAIL" })
    else
        pdk.response.exit(200, { id = res })
    end
end


return router_controller
