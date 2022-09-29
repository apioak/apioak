local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

local router_controller = controller.new("router")

function router_controller.created()

    local body = router_controller.get_body()

    router_controller.check_schema(schema.router.created, body)

    -- router_controller.user_authenticate()

    local res, err = dao.router.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {id = res.id})
end

function router_controller.updated(params)

    local body      = router_controller.get_body()
    body.router_key = params.router_key

    router_controller.check_schema(schema.router.updated, body)

    -- router_controller.user_authenticate()

    local  res, err = dao.router.updated(params.router_key, body)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })

end

function router_controller.detail(params)

    router_controller.check_schema(schema.router.detail, params)

    -- router_controller.user_authenticate()

    local  res, err = dao.router.detail(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function router_controller.lists()

    -- router_controller.user_authenticate()

    local  res, err = dao.router.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function router_controller.deleted(params)

    router_controller.check_schema(schema.router.deleted, params)

    -- router_controller.user_authenticate()

    local _, err = dao.router.deleted(params)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {})
end


return router_controller
