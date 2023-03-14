local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

local service_controller = controller.new("service")

function service_controller.created()

    local body = service_controller.get_body()

    service_controller.check_schema(schema.service.created, body)

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_SERVICES)

    if check_name then
        pdk.response.exit(400, { message = "the service name[" .. body.name .. "] already exists" })
    end

    if body.plugins then
        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.log.error("service-create detect plugin exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect plugin exceptions" })
        end

        if not check_plugin then
            pdk.response.exit(400, { message = "detect plugin not found" })
        end

        local plugins = {}

        for i = 1, #check_plugin do
            table.insert(plugins, { id = check_plugin[i].id, name = check_plugin[i].name })
        end

        body.plugins = plugins
    end

    local exist_hosts, exist_hosts_err = dao.service.exist_host(body.hosts)

    if exist_hosts_err ~= nil then
        pdk.log.error("service-create exception when checking if host exists: [" .. exist_hosts_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if host exists" })
    end

    if exist_hosts and (#exist_hosts > 0) then
        pdk.response.exit(400, { message = "exists hosts [" .. table.concat(exist_hosts, ",") .. "]" })
    end

    local res, err = dao.service.created(body)

    if err then
        pdk.log.error("service-create create service exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "create service exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function service_controller.updated(params)

    local body = service_controller.get_body()
    body.service_key = params.service_key

    service_controller.check_schema(schema.service.updated, body)

    local detail, err = dao.service.detail(params.service_key)

    if err then
        pdk.log.error("service-update get service detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get service detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the service not found" })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.service.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, { message = "the service name[" .. body.name .. "] already exists" })
        end
    end

    local exist_hosts, exist_hosts_err = dao.service.exist_host(body.hosts, detail.id)

    if exist_hosts_err ~= nil then
        pdk.log.error("service-update exception when checking if host exists: [" .. exist_hosts_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if host exists" })
    end

    if exist_hosts and (#exist_hosts > 0) then
        pdk.response.exit(400, { message = "exists hosts [" .. table.concat(exist_hosts, ",") .. "] " })
    end

    if body.plugins then
        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.log.error("service-update detect plugin exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect plugin exceptions" })
        end

        if not check_plugin then
            pdk.response.exit(400, { message = "detect plugin not found" })
        end

        local plugins = {}

        for i = 1, #check_plugin do
            table.insert(plugins, { id = check_plugin[i].id, name = check_plugin[i].name })
        end

        body.plugins = plugins
    end

    local res, err = dao.service.updated(body, detail)

    if err then
        pdk.log.error("service-update update service exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "update service exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function service_controller.detail(params)

    service_controller.check_schema(schema.service.detail, params)

    local detail, err = dao.service.detail(params.service_key)

    if err then
        pdk.log.error("service-detail get service detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get service detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the service not found" })
    end

    pdk.response.exit(200, detail)
end

function service_controller.lists()

    local res, err = dao.service.lists()

    if err then
        pdk.log.error("service-list get service list exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get service list exception" })
    end

    pdk.response.exit(200, res)
end

function service_controller.deleted(params)

    service_controller.check_schema(schema.service.deleted, params)

    local detail, err = dao.service.detail(params.service_key)

    if err then
        pdk.log.error("service-delete get service detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get service detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the service not found" })
    end

    local router_list, router_list_err = dao.router.router_list_by_service(detail)

    if router_list_err then
        pdk.log.error("service-delete exception when detecting service router: [" .. router_list_err .. "]")
        pdk.response.exit(500, { message = "exception when detecting service router" })
    end

    if router_list and (#router_list > 0) then
        pdk.response.exit(400, { message = "service is in use by router" })
    end

    local _, err = dao.service.deleted(detail)

    if err then
        pdk.log.error("service-delete remove service exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "remove service exception" })
    end

    pdk.response.exit(200, {})
end

return service_controller
