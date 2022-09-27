local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

local service_controller = controller.new("service")

function service_controller.created()

    local body = service_controller.get_body()

    service_controller.check_schema(schema.service.created, body)

    service_controller.user_authenticate()

    local res, err = dao.service.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {id = res.id})
end

function service_controller.updated(params)

    local body      = service_controller.get_body()
    body.service_id = params.service_id

    service_controller.check_schema(schema.service.updated, body)

    service_controller.user_authenticate()

    local  res, err = dao.service.updated(params.service_id, body)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
    
end

function service_controller.detail(params)

    service_controller.check_schema(schema.service.detail, params)

    service_controller.user_authenticate()

    local  res, err = dao.service.detail(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function service_controller.lists()

    service_controller.user_authenticate()

    local  res, err = dao.service.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function service_controller.deleted(params)

    service_controller.check_schema(schema.service.deleted, params)

    service_controller.user_authenticate()

    local _, err = dao.service.deleted(params)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {})
end


return service_controller
