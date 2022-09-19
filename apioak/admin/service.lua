local db         = require("apioak.db")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local service_controller = controller.new("service")

function service_controller.created()

    local body = service_controller.get_body()

    service_controller.check_schema(schema.service.created, body)

    service_controller.user_authenticate()

    local res, err = db.service.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    if res == nil or res.id == nil then
        pdk.response.exit(500, { message = err })
        return
    end

    if not res.id then
        pdk.response.exit(500, { message = "create service FAIL" })
    end

    pdk.response.exit(200, {id = res.id})
end

function service_controller.updated(params)

    local body      = service_controller.get_body()
    body.id = params.service_id

    service_controller.check_schema(schema.service.updated, body)

    service_controller.user_authenticate()

    local  res, err = db.service.updated(params.service_id, body)
    if err then
        pdk.response.exit(500, { message = err })
    end

    if res == nil or res.id == nil then
        pdk.response.exit(500, { message = err })
        return
    end

    if not res.id then
        pdk.response.exit(500, { message = "update service FAIL" })
    end

    pdk.response.exit(200, { id = res.id })
    
end

function service_controller.detail(params)

    local body      = service_controller.get_body()
    body.service_id = params.service_id

    service_controller.check_schema(schema.service.detail, body)

    service_controller.user_authenticate()

    local  res, err = db.service.detail(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    if not res or not res.id then
        pdk.response.exit(500, { message = "update service FAIL" })
    else
        pdk.response.exit(200, { id = res })
    end
end

function service_controller.lists(params)

    service_controller.user_authenticate()

    local  res, err = db.service.lists(params)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function service_controller.deleted(params)

    local body      = service_controller.get_body()
    body.service_id = params.service_id

    service_controller.check_schema(schema.service.deleted, body)

    service_controller.user_authenticate()

    local  res, err = db.service.deleted(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    if res == "" then
        pdk.response.exit(500, { message = "update service FAIL" })
    else
        pdk.response.exit(200, { id = res })
    end
end


return service_controller
