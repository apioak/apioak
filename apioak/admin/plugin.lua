local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

local plugin_controller = controller.new("plugin")

function plugin_controller.created()

    local body = plugin_controller.get_body()

    plugin_controller.check_schema(schema.plugin.created, body)

    local plugin_object = require("apioak.plugin." .. body.key .. "." .. body.key)

    if plugin_object.schema_config then
        local err = plugin_object.schema_config(body.config)

        if err then
            pdk.log.error("[" .. body.key .. "] plugin config schema err: [" .. tostring(err) .. "]")
            pdk.response.exit(400, { message = "Parameter error" })
        end
    end

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_PLUGINS)

    if check_name then
        pdk.response.exit(400, { message = "the plugin name[" .. body.name .. "] already exists" })
    end

    local res, err = dao.plugin.created(body)

    if err then
        pdk.log.error("plugin-create create plugin exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "create plugin exception" })
    end

    pdk.response.exit(200, {id = res.id})
end

function plugin_controller.updated(params)

    local body      = plugin_controller.get_body()
    body.plugin_key = params.plugin_key

    plugin_controller.check_schema(schema.plugin.updated, body)

    local detail, err = dao.plugin.detail(body.plugin_key)

    if err then
        pdk.log.error("plugin-update get plugin detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get plugin detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the plugin not found" })
    end

    if body.name and (body.name ~= detail.name) then

        local name_detail, _ = dao.plugin.detail(body.name)

        if name_detail then
            pdk.response.exit(400, { message = "the plugin name[" .. body.name .. "] already exists" })
        end
    end

    if body.config then

        local plugin_object = require("apioak.plugin." .. detail.key .. "." .. detail.key)

        if plugin_object.schema_config then
            local err = plugin_object.schema_config(body.config)

            if err then
                pdk.log.error("[" .. detail.key .. "] plugin config schema err: [" .. tostring(err) .. "]")
                pdk.response.exit(400, { message = "Parameter error" })
            end
        end

    end

    local  res, err = dao.plugin.updated(body, detail)

    if err then
        pdk.log.error("plugin-update update plugin exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "update plugin exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function plugin_controller.detail(params)

    plugin_controller.check_schema(schema.plugin.detail, params)

    local  detail, err = dao.plugin.detail(params.plugin_key)

    if err then
        pdk.log.error("plugin-detail get plugin detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get plugin detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the plugin not found" })
    end

    pdk.response.exit(200, detail)
end

function plugin_controller.lists()

    local  res, err = dao.plugin.lists()

    if err then
        pdk.log.error("plugin-list get plugin list exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get plugin list exception" })
    end

    pdk.response.exit(200, res)
end

function plugin_controller.deleted(params)

    plugin_controller.check_schema(schema.plugin.deleted, params)

    local detail, err = dao.plugin.detail(params.plugin_key)

    if err then
        pdk.log.error("plugin-delete get plugin detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get plugin detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the plugin not found" })
    end

    local router_list, router_list_err = dao.router.router_list_by_plugin(detail)

    if router_list_err then
        pdk.log.error("plugin-delete exception when detecting plugin route: [" .. router_list_err .. "]")
        pdk.response.exit(500, { message = "exception when detecting plugin route" })
    end

    if router_list and (#router_list > 0) then

        local router_names = {}

        for i = 1, #router_list do
            table.insert(router_names, router_list[i]['name'])
        end

        pdk.response.exit(400, { message = "plugin is in use by router [" .. table.concat(router_names, ",") .. "]" })
    end

    local service_list, service_list_err = dao.service.service_list_by_plugin(detail)

    if service_list_err then
        pdk.log.error("plugin-delete exception when detecting plugin service: [" .. service_list_err .. "]")
        pdk.response.exit(500, { message = "exception when detecting plugin service" })
    end

    if service_list and (#service_list > 0) then

        local service_names = {}

        for i = 1, #service_list do
            table.insert(service_names, service_list[i]['name'])
        end

        pdk.response.exit(400, { message = "plugin is in use by service [" .. table.concat(service_names, ",") .. "]" })
    end

    local _, err = dao.plugin.deleted(detail)

    if err then
        pdk.log.error("plugin-delete remove plugin exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "remove plugin exception" })
    end

    pdk.response.exit(200, {})
end


return plugin_controller
