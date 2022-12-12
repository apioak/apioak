local pdk = require("apioak.pdk")
local schema = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao = require("apioak.dao")

local router_controller = controller.new("router")

function router_controller.created()

    local body = router_controller.get_body()

    router_controller.check_schema(schema.router.created, body)

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_ROUTERS)

    if check_name then
        pdk.response.exit(400, { message = "the router name[" .. body.name .. "] already exists" })
    end

    local check_service, err = dao.common.check_kv_exists(body.service, pdk.const.CONSUL_PRFX_SERVICES)

    if err then
        pdk.log.error("router-create detect service exceptions: [" .. err .. "]")
        pdk.response.exit(500, { message = "detect service exceptions" })
    end

    if not check_service then
        pdk.response.exit(400, { message = "detect service not found" })
    end

    body.service = {id = check_service.id}

    if body.plugins then

        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.log.error("router-create detect plugin exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect plugin exceptions" })
        end

        if not check_plugin then
            pdk.response.exit(400, { message = "detect plugin not found" })
        end

        local plugin_ids = {}

        for i = 1, #check_plugin do
            table.insert(plugin_ids, {id = check_plugin[i].id})
        end

        body.plugins = plugin_ids
    end

    if body.upstream then

        local check_upstream, err = dao.common.check_kv_exists(body.upstream, pdk.const.CONSUL_PRFX_UPSTREAMS)

        if err then
            pdk.log.error("router-create detect upstream exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect upstream exceptions" })
        end

        if not check_upstream then
            pdk.response.exit(400, { message = "detect upstream not found" })
        end

        body.upstream = {id = check_upstream.id}
    end

    local exist_paths, exist_paths_err = dao.router.exist_path(body.paths)

    if exist_paths_err ~= nil then
        pdk.log.error("router-create exception when checking if path exists: [" .. exist_paths_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if path exists" })
    end

    if exist_paths and (#exist_paths > 0) then
        pdk.response.exit(400, { message = "exists paths [" .. table.concat(exist_paths, ",") .. "]" })
    end

    local res, err = dao.router.created(body)

    if err then
        pdk.log.error("router-create create router exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "create router exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function router_controller.updated(params)

    local body = router_controller.get_body()
    body.router_key = params.router_key

    router_controller.check_schema(schema.router.updated, body)

    local detail, err = dao.router.detail(params.router_key)

    if err then
        pdk.log.error("router-update get router detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get router detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the router not found" })
    end

    if body.name and (body.name ~= detail.name) then

        local name_detail, _ = dao.service.detail(body.name)

        if name_detail then
            pdk.response.exit(400, { message = "the router name[" .. body.name .. "] already exists" })
        end
    end

    local exist_paths, exist_paths_err = dao.router.exist_path(body.paths, detail.id)

    if exist_paths_err then
        pdk.log.error("router-update exception when checking if path exists: [" .. exist_paths_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if path exists" })
    end

    if exist_paths and (#exist_paths > 0) then
        pdk.response.exit(400, { message = "exists paths [" .. table.concat(exist_paths, ",") .. "]" })
    end

    if body.upstream and next(body.upstream) then

        local check_upstream, err = dao.common.check_kv_exists(body.upstream, pdk.const.CONSUL_PRFX_UPSTREAMS)

        if err then
            pdk.log.error("router-update detect upstream exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect upstream exceptions" })
        end

        if not check_upstream then
            pdk.response.exit(400, { message = "detect upstream not found" })
        end

        body.upstream = {id = check_upstream.id}
    end

    if body.service then

        local check_service, err = dao.common.check_kv_exists(body.service, pdk.const.CONSUL_PRFX_SERVICES)

        if err then
            pdk.log.error("router-update detect service exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect service exceptions" })
        end

        if not check_service then
            pdk.response.exit(400, { message = "detect service not found" })
        end

        body.service = {id = check_service.id}
    end

    if body.plugins and (#body.plugins > 0) then

        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.log.error("router-update detect plugin exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect plugin exceptions" })
        end

        if not check_plugin then
            pdk.response.exit(400, { message = "detect plugin not found" })
        end

        local plugin_ids = {}

        for i = 1, #check_plugin do
            table.insert(plugin_ids, {id = check_plugin[i].id})
        end

        body.plugins = plugin_ids
    end

    local res, err = dao.router.updated(body, detail)

    if err then
        pdk.log.error("router-update update route exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "update route exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function router_controller.detail(params)

    router_controller.check_schema(schema.router.detail, params)

    local detail, err = dao.router.detail(params.router_key)

    if err then
        pdk.log.error("router-detail get route detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get route detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the router not found" })
    end

    pdk.response.exit(200, detail)
end

function router_controller.lists()

    local res, err = dao.router.lists()

    if err then
        pdk.log.error("router-list get route list exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get route list exception" })
    end

    pdk.response.exit(200, res)
end

function router_controller.deleted(params)

    router_controller.check_schema(schema.router.deleted, params)

    local detail, err = dao.router.detail(params.router_key)

    if err then
        pdk.log.error("router-delete get route detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get route detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the router not found" })
    end

    local _, err = dao.router.deleted(detail)

    if err then
        pdk.log.error("router-delete remove route exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "remove route exception" })
    end

    pdk.response.exit(200, {})
end

return router_controller
