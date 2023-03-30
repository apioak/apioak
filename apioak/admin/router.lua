local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

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

    if check_service then
        body.service = { id = check_service.id, name = check_service.name }
    end

    if body.plugins and (#body.plugins > 0) then

        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.log.error("router-create detect plugin exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect plugin exceptions" })
        end

        if check_plugin then
            local exit_plugin_id_map, exit_plugin_name_map = {}, {}

            for j = 1, #check_plugin do
                exit_plugin_id_map[check_plugin[j]['id']] = check_plugin[j]['name']
                exit_plugin_name_map[check_plugin[j]['name']] = check_plugin[j]['id']
            end

            for k = 1, #body.plugins do
                if body.plugins[k]['id'] and exit_plugin_id_map[body.plugins[k]['id']] then

                    body.plugins[k] = {
                        id = body.plugins[k]['id'],
                        name = exit_plugin_id_map[body.plugins[k]['id']]
                    }

                elseif body.plugins[k]['name'] and exit_plugin_name_map[body.plugins[k]['name']] then

                    body.plugins[k] = {
                        id = exit_plugin_name_map[body.plugins[k]['name']],
                        name = body.plugins[k]['name']
                    }

                end
            end
        end
    end

    if next(body.upstream) ~= nil then

        local check_upstream, err = dao.common.check_kv_exists(body.upstream, pdk.const.CONSUL_PRFX_UPSTREAMS)

        if err then
            pdk.log.error("router-create detect upstream exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect upstream exceptions" })
        end

        if check_upstream then
            body.upstream = { id = check_upstream.id, name = check_upstream.name }
        end
    end

    local service_info
    if next(body.service) ~= nil then
        service_info = body.service
    end
    local exist_paths, exist_paths_err = dao.router.exist_path(body.paths, service_info)

    if exist_paths_err ~= nil then
        pdk.log.error("router-create exception when checking if path exists: [" .. exist_paths_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if path exists" })
    end

    if exist_paths and (#exist_paths > 0) then
        pdk.response.exit(400, { message = "exists paths [ " .. table.concat(exist_paths, ", ") .. " ]" })
    end

    body.methods = pdk.const.DEFAULT_METHODS(body.methods)

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

    local service_info
    if next(body.service) ~= nil then
        service_info = body.service
    end
    local exist_paths, exist_paths_err = dao.router.exist_path(body.paths, service_info)

    if exist_paths_err then
        pdk.log.error("router-update exception when checking if path exists: [" .. exist_paths_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if path exists" })
    end

    if exist_paths and (#exist_paths > 1) then
        pdk.response.exit(400, { message = "exists paths [" .. table.concat(exist_paths, ",") .. "]" })
    end

    if  next(body.upstream) ~= nil then

        local check_upstream, err = dao.common.check_kv_exists(body.upstream, pdk.const.CONSUL_PRFX_UPSTREAMS)

        if err then
            pdk.log.error("router-update detect upstream exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect upstream exceptions" })
        end

        if check_upstream then
            body.upstream = { id = check_upstream.id, name = check_upstream.name }
        end
    end

    if body.service then

        local check_service, err = dao.common.check_kv_exists(body.service, pdk.const.CONSUL_PRFX_SERVICES)

        if err then
            pdk.log.error("router-update detect service exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect service exceptions" })
        end

        if check_service then
            body.service = { id = check_service.id, name = check_service.name }
        end
    end

    if body.plugins and (#body.plugins > 0) then

        local check_plugin, err = dao.common.batch_check_kv_exists(body.plugins, pdk.const.CONSUL_PRFX_PLUGINS)

        if err then
            pdk.log.error("router-update detect plugin exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect plugin exceptions" })
        end

        if check_plugin then
            local exit_plugin_id_map, exit_plugin_name_map = {}, {}

            for j = 1, #check_plugin do
                exit_plugin_id_map[check_plugin[j]['id']] = check_plugin[j]['name']
                exit_plugin_name_map[check_plugin[j]['name']] = check_plugin[j]['id']
            end

            for k = 1, #body.plugins do
                if body.plugins[k]['id'] and exit_plugin_id_map[body.plugins[k]['id']] then

                    body.plugins[k] = {
                        id = body.plugins[k]['id'],
                        name = exit_plugin_id_map[body.plugins[k]['id']]
                    }

                elseif body.plugins[k]['name'] and exit_plugin_name_map[body.plugins[k]['name']] then

                    body.plugins[k] = {
                        id = exit_plugin_name_map[body.plugins[k]['name']],
                        name = body.plugins[k]['name']
                    }

                end
            end
        end
    end

    body.methods = pdk.const.DEFAULT_METHODS(body.methods)

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
