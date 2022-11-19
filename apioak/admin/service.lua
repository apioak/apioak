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

    local exist_hosts, exist_hosts_err = dao.service.exist_host(body.hosts)

    if exist_hosts_err ~= nil then
        pdk.log.error("exception when checking if host exists: [", exist_hosts_err, "]")
        pdk.response.exit(500, { message = "exception when checking if host exists" })
    end

    if exist_hosts and (#exist_hosts > 0) then
        pdk.response.exit(400, {message = "exists hosts [" .. table.concat(exist_hosts, ",") .. "]"})
    end

    if body.plugins then
        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.response.exit(400, { message = err })
        end

        if not check_plugin then
            pdk.response.exit(400, { message = "the plugin is abnormal" })
        end
    end

    local res, err = dao.service.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {id = res.id})
end

function service_controller.updated(params)

    local body = service_controller.get_body()
    body.service_key = params.service_key

    service_controller.check_schema(schema.service.updated, body)

    local detail, err = dao.service.detail(params.service_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.service.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, { message = "the service name[" .. body.name .. "] already exists" })
        end
    end

    local exist_hosts, exist_hosts_err = dao.service.exist_host(body.hosts, detail.id)

    if exist_hosts_err ~= nil then
        pdk.response.exit(500, { message = "host detection failed [" .. exist_hosts_err .. "]" })
    end

    if exist_hosts and (#exist_hosts > 0) then
        pdk.response.exit(400, {
            message = "exists hosts [" .. table.concat(exist_hosts, ",") .. "] " })
    end

    if body.plugins then
        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.response.exit(400, { message = err })
        end

        if not check_plugin then
            pdk.response.exit(400, { message = "the plugin is abnormal" })
        end
    end

    local  res, err = dao.service.updated(body, detail)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end

function service_controller.detail(params)

    service_controller.check_schema(schema.service.detail, params)

    local  res, err = dao.service.detail(params.service_key)
    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function service_controller.lists()

    local  res, err = dao.service.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function service_controller.deleted(params)

    service_controller.check_schema(schema.service.deleted, params)

    local detail, err = dao.service.detail(params.service_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    local _, err = dao.service.deleted(detail)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, {})
end


return service_controller
