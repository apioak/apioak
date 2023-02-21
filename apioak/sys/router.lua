local ngx    = ngx
local pairs  = pairs
local pdk    = require("apioak.pdk")
local dao    = require("apioak.dao")
local events = require("resty.worker.events")
local schema = require("apioak.schema")
local oakrouting          = require("resty.oakrouting")
local sys_certificate     = require("apioak.sys.certificate")
local sys_balancer        = require("apioak.sys.balancer")
local sys_plugin          = require("apioak.sys.plugin")
local ngx_process         = require("ngx.process")
local ngx_sleep           = ngx.sleep
local ngx_timer_at        = ngx.timer.at
local ngx_worker_exiting  = ngx.worker.exiting

local router_objects

local events_source_router     = "events_source_router"
local events_type_put_router   = "events_type_put_router"
local oakrouting_router_method = "OPTIONS"

local _M = {}

local function router_map_service_id()

    local list, err = dao.common.list_keys(dao.common.PREFIX_MAP.routers)

    if err then
        pdk.log.error("router_map_service_id: get router list FAIL [".. err .."]")
        return nil
    end

    if not list or not list.list or (#list.list == 0) then
        pdk.log.error("router_map_service_id: router list null [" .. pdk.json.encode(list, true) .. "]")
        return nil
    end

    local router_map_service = {}

    for i = 1, #list.list do

        repeat
            local _, err = pdk.schema.check(schema.router.router_data, list.list[i])

            if err then
                pdk.log.error("router_map_service_id: router schema check err:["
                                      .. err .. "][" .. list.list[i].name .. "]")
                break
            end

            if list.list[i].enabled == false then
                break
            end

            if not router_map_service[list.list[i].service.id] then
                router_map_service[list.list[i].service.id] = {}
            end

            table.insert(router_map_service[list.list[i].service.id], {
                paths    = list.list[i].paths,
                methods  = list.list[i].methods,
                headers  = list.list[i].headers,
                upstream = list.list[i].upstream,
                plugins  = list.list[i].plugins,
            })
        until true

    end

    if next(router_map_service) then
        return router_map_service
    end

    return nil
end

local function sync_update_router_data()

    local list, err = dao.common.list_keys(dao.common.PREFIX_MAP.services)

    if err then
        pdk.log.error("sync_update_router_data: get service list FAIL [".. err .."]")
        return nil
    end

    if not list or not list.list or (#list.list == 0) then
        pdk.log.error("sync_update_router_data: service list null [" .. pdk.json.encode(list, true) .. "]")
        return nil
    end

    local service_list = {}

    for i = 1, #list.list do

        repeat
            local _, err = pdk.schema.check(schema.service.service_data, list.list[i])

            if err then
                pdk.log.error("sync_update_router_data: service schema check err:["
                                      .. err .. "][" .. list.list[i].name .. "]")
                break
            end

            if list.list[i].enabled == false then
                break
            end

            table.insert(service_list, {
                id        = list.list[i].id,
                hosts     = list.list[i].hosts,
                protocols = list.list[i].protocols,
                plugins   = list.list[i].plugins,
            })
        until true

    end

    if #service_list == 0 then
        return nil
    end

    local router_map = router_map_service_id()

    local service_router_list = {}

    for j = 1, #service_list do

        repeat
            local routers = {}

            if router_map and router_map[service_list[j].id] then
                routers = router_map[service_list[j].id]
            end

            if not next(routers) then
                break
            end

            service_list[j].routers = routers

            table.insert(service_router_list, service_list[j])

        until true
    end

    if #service_router_list == 0 then
        return nil
    end

    return service_router_list
end

local function automatic_sync_resource_data(premature)
    if premature then
        return
    end

    if ngx_process.type() ~= "privileged agent" then
        return
    end

    local i, limit, err_times, err_times_limit = 0, 10, 0, 5

    while not ngx_worker_exiting() and i <= limit do
        i = i + 1

        repeat
            local sync_data, err = dao.common.get_sync_data()

            if err then
                err_times = err_times + 1

                pdk.log.error("automatic_sync_resource_data: get_sync_data_err: ["
                                      .. err_times .. "] [" .. tostring(err) .. "]")

                if err_times == err_times_limit then
                    err_times = 0

                    ngx_sleep(15)
                    break
                end

                ngx_sleep(2)
                break
            end

            if not sync_data then
                sync_data = {}
            end

            if not sync_data.new or (sync_data.new ~= sync_data.old) then

                local sync_ssl_data      = sys_certificate.sync_update_ssl_data()
                local sync_upstream_data = sys_balancer.sync_update_upstream_data()
                local sync_plugin_data   = sys_plugin.sync_update_plugin_data()
                local sync_router_data   = sync_update_router_data()

                local post_ssl, post_ssl_err = events.post(
                        sys_certificate.events_source_ssl, sys_certificate.events_type_put_ssl, sync_ssl_data)

                local post_upstream, post_upstream_err = events.post(
                        sys_balancer.events_source_upstream, sys_balancer.events_type_put_upstream, sync_upstream_data)

                local post_plugin, post_plugin_err = events.post(
                        sys_plugin.events_source_plugin, sys_plugin.events_type_put_plugin, sync_plugin_data)

                local post_router, post_router_err = events.post(
                        events_source_router, events_type_put_router, sync_router_data)

                if post_ssl_err then
                    pdk.log.error("automatic_sync_resource_data: sync ssl data post err:["
                                          .. i .."][" .. tostring(post_ssl_err) .. "]")
                end

                if post_upstream_err then
                    pdk.log.error("automatic_sync_resource_data: sync upstream data post err:["
                                          .. i .."][" .. tostring(post_upstream_err) .. "]")
                end

                if post_plugin_err then
                    pdk.log.error("automatic_sync_resource_data: sync plugin data post err:["
                                          .. i .."][" .. tostring(post_plugin_err) .. "]")
                end

                if post_router_err then
                    pdk.log.error("automatic_sync_resource_data: sync router data post err:["
                                          .. i .."][" .. tostring(post_router_err) .. "]")
                end

                if post_ssl and post_upstream and post_plugin and post_router then
                    dao.common.update_sync_data_hash(true)
                end

            end

            ngx_sleep(2)
        until true
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_resource_data)
    end
end

local function generate_router_data(router_data)

    if not router_data or type(router_data) ~= "table" then
        return nil, "generate_router_data: the data is empty or the data format is wrong["
                .. pdk.json.encode(router_data, true) .. "]"
    end

    if not router_data.hosts or not router_data.routers or (#router_data.hosts == 0) or (#router_data.routers == 0) then
        return nil, "generate_router_data: Missing data required fields["
                .. pdk.json.encode(router_data, true) .. "]"
    end

    local router_data_list = {}

    for i = 1, #router_data.hosts do

        for j = 1, #router_data.routers do

            repeat
                if (type(router_data.routers[j].paths) ~= "table") or (#router_data.routers[j].paths == 0) then
                    break
                end

                for k = 1, #router_data.routers[j].paths do
                    repeat

                        if #router_data.routers[j].paths[k] == 0 then
                            break
                        end

                        local host_router_data = {
                            plugins   = router_data.plugins,
                            protocols = router_data.protocols,
                            host      = router_data.hosts[i],
                            router    = {
                                path     = router_data.routers[j].paths[k],
                                plugins  = router_data.routers[j].plugins,
                                upstream = router_data.routers[j].upstream,
                                headers  = router_data.routers[j].headers,
                                methods  = router_data.routers[j].methods,
                            }
                        }

                        table.insert(router_data_list, {
                            path    = host_router_data.host .. ":" .. host_router_data.router.path,
                            method  = oakrouting_router_method,
                            handler = function(params, oak_ctx)

                                oak_ctx.matched.path = params

                                oak_ctx.config = {}
                                oak_ctx.config.service_router = host_router_data
                            end
                        })
                    until true
                end

            until true
        end
    end

    if #router_data_list > 0 then
        return router_data_list, nil
    end

    return nil, nil
end

local function worker_event_router_handler_register()

    local router_handler = function(data, event, source)

        if source ~= events_source_router then
            return
        end

        if event ~= events_type_put_router then
            return
        end

        if (type(data) ~= "table") or (#data == 0) then
            return
        end

        local oak_router_data = {}

        for i = 1, #data do

            repeat
                local router_data, router_data_err = generate_router_data(data[i])

                if router_data_err then
                    pdk.log.error("worker_sync_event_register: generate router data err: ["
                                          .. tostring(router_data_err) .. "]")
                    break
                end

                if not router_data then
                    break
                end

                for j = 1, #router_data do
                    table.insert(oak_router_data, router_data[j])
                end

            until true
        end

        router_objects = oakrouting.new(oak_router_data)
    end

    if ngx_process.type() ~= "privileged agent" then
        events.register(router_handler, events_source_router, events_type_put_router)
    end
end

function _M.init_worker()

    worker_event_router_handler_register()

    ngx_timer_at(0, automatic_sync_resource_data)

end

function _M.parameter(oak_ctx)
    local env = pdk.request.header(pdk.const.REQUEST_API_ENV_KEY)
    if env then
        env = pdk.string.upper(env)
    else
        env = pdk.const.ENVIRONMENT_PROD
    end

    oak_ctx.matched = {}
    oak_ctx.matched.host   = ngx.var.host
    oak_ctx.matched.uri    = ngx.var.uri
    oak_ctx.matched.scheme = ngx.var.scheme
    oak_ctx.matched.query  = pdk.request.query()
    oak_ctx.matched.method = pdk.request.get_method()
    oak_ctx.matched.header = pdk.request.header()

    oak_ctx.matched.header[pdk.const.REQUEST_API_ENV_KEY] = env
end

function _M.router_match(oak_ctx)

    if not oak_ctx.matched or not oak_ctx.matched.host or not oak_ctx.matched.uri then
        pdk.log.error("router_match: oak_ctx data format err: [" .. pdk.json.encode(oak_ctx, true) .. "]")
        return false
    end

    if not router_objects then
        pdk.log.error("router_match: router_objects is null")
        return false
    end

    local match_path = oak_ctx.matched.host .. ":" .. oak_ctx.matched.uri

    local match, err = router_objects:dispatch(match_path, oakrouting_router_method, oak_ctx)

    if err then
        pdk.log.error("router_match: router_objects dispatch err: [" .. tostring(err) .. "]")
        return false
    end

    if not match then
        return false
    end

    local service_router = oak_ctx.config.service_router
    local matched = oak_ctx.matched

    local match_protocols = false

    if service_router.protocols and matched.scheme then
        for i = 1, #service_router.protocols do
            if pdk.string.lower(service_router.protocols[i]) == pdk.string.lower(matched.scheme) then
                match_protocols = true
            end
        end
    end

    if not match_protocols then
        return false
    end

    if service_router.router.headers and next(service_router.router.headers) then
        local match_header = true

        for h_key, h_value in pairs(service_router.router.headers) do
            local matched_header_value = matched.header[h_key]

            if matched_header_value ~= h_value then
                match_header = false
            end
        end

        if not match_header then
            return false
        end

    end

    local config_methods = {}

    if service_router.router.methods and (#service_router.router.methods > 0) then

        for i = 1, #service_router.router.methods do
            if service_router.router.methods[i] == pdk.const.METHODS_ALL then
                config_methods = {}

                for j = 1, #pdk.const.ALL_METHODS do
                    config_methods[pdk.string.upper(pdk.const.ALL_METHODS[j])] = 0
                end

                break
            else
                config_methods[pdk.string.upper(service_router.router.methods[i])] = 0
            end
        end

    end

    if not config_methods[pdk.string.upper(matched.method)] then
        return false
    end

    return true
end


return _M
