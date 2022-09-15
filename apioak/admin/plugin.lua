local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

local plugin_controller = controller.new("plugin")

function plugin_controller.created()

    local body = plugin_controller.get_body()

    plugin_controller.check_schema(schema.plugin.created, body)

    -- plugin_controller.user_authenticate()

    local res, err = dao.plugin.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {id = res.id})
end

function plugin_controller.updated(params)

    local body      = plugin_controller.get_body()
    body.plugin_key = params.plugin_key

    plugin_controller.check_schema(schema.plugin.updated, body)

    -- plugin_controller.user_authenticate()

    local  res, err = dao.plugin.updated(params.plugin_key, body)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })

end

function plugin_controller.detail(params)

    plugin_controller.check_schema(schema.plugin.detail, params)

    -- plugin_controller.user_authenticate()

    local  res, err = dao.plugin.detail(params)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function plugin_controller.lists()

    -- plugin_controller.user_authenticate()

    local  res, err = dao.plugin.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function plugin_controller.deleted(params)

    plugin_controller.check_schema(schema.plugin.deleted, params)

    -- plugin_controller.user_authenticate()

    local _, err = dao.plugin.deleted(params)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {})
end


return plugin_controller
