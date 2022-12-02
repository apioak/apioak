local ngx     = ngx
local pdk     = require("apioak.pdk")
local db      = require("apioak.db")
local dao     = require("apioak.dao")
local process = require("ngx.process")
local events  = require("resty.worker.events")
local schema  = require("apioak.schema")
local pairs               = pairs
local oakrouting          = require("resty.oakrouting")
local sys_certificate     = require("apioak.sys.certificate")
local ngx_var             = ngx.var
local ngx_sleep           = ngx.sleep
local ngx_timer_at        = ngx.timer.at
local ngx_worker_exiting  = ngx.worker.exiting

local router_objects
local router_latest_hash_id
local router_cached_hash_id

local events_source_router     = "events_source_router"
local events_type_put_router   = "events_type_put_router"
local oakrouting_router_method = "OPTIONS"

local _M = {}

local create_routers = function(project, router, env_router, environment)
    if not env_router then
        env_router = {}
        env_router.request_path     = "/" .. environment .. project.path .. router.request_path
        env_router.request_method   = router.request_method
        env_router.response_type    = router.response_type
        env_router.response_success = router.response_success
        env_router.is_mock_request  = true
    else
        local project_upstreams = project.upstreams
        if project_upstreams then
            env_router.upstream = project_upstreams[environment] or {}
        end

        local router_plugins  = env_router.plugins
        local project_plugins = project.plugins
        for router_plugin_name, router_plugin_config in pairs(router_plugins) do
            project_plugins[router_plugin_name] = router_plugin_config
        end
        env_router.plugins = project_plugins or {}

        env_router.request_path = "/" .. environment .. project.path .. router.request_path
    end

    return {
        path    = env_router.request_path,
        method  = env_router.request_method,
        handler = function(params, oak_ctx)
            oak_ctx.router       = env_router
            oak_ctx.matched.path = params
        end
    }
end

local loading_routers = function()
    local router_caches = {}
    local res, err = db.project.query_env_all()
    if err then
        pdk.log.error("[sys.router] reading projects from MySQL failure, ", err)
        return
    end

    local projects = res
    for p = 1, #projects do
        local project = projects[p]
        res, err = db.router.query_env_by_pid(project.id)
        if err then
            pdk.log.error("[sys.router] reading routers from MySQL failure, ", err)
            return
        end

        local routers = res
        for a = 1, #routers do
            local router = routers[a]

            local prod_env_handler = create_routers(project, router, router.env_prod_config, pdk.const.ENVIRONMENT_PROD)
            pdk.table.insert(router_caches, prod_env_handler)

            local beta_env_handler = create_routers(project, router, router.env_beta_config, pdk.const.ENVIRONMENT_BETA)
            pdk.table.insert(router_caches, beta_env_handler)

            local test_env_handler = create_routers(project, router, router.env_test_config, pdk.const.ENVIRONMENT_TEST)
            pdk.table.insert(router_caches, test_env_handler)
        end
    end

    router_objects = oakrouting.new(router_caches)
end

local function automatic_sync_hash_id(premature)
    if premature then
        return
    end

    local i = 0
    while not ngx_worker_exiting() and i <= 10 do
        i = i + 1

        local res, err = db.router.query_last_updated_hid()
        if err then
            pdk.log.error("[sys.router] automatic sync routers last updated timestamp reading failure, ", err)
            break
        end
        local router_hash_id = res.hash_id or pdk.string.md5("routers")

        res, err = db.project.query_last_updated_hid()
        if err then
            pdk.log.error("[sys.router] automatic sync projects last updated timestamp reading failure, ", err)
            break
        end
        local project_hash_id = res.hash_id or pdk.string.md5("projects")

        res, err = db.plugin.query_project_last_updated_hid()
        if err then
            pdk.log.error("[sys.router] automatic sync plugins last updated timestamp reading failure, ", err)
            break
        end
        local plugin_hash_id = res.hash_id or pdk.string.md5("plugins")

        router_latest_hash_id = pdk.string.md5(project_hash_id .. router_hash_id .. plugin_hash_id)

        ngx_sleep(10)
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_hash_id)
    end
end

local function plugins_map_id()

    local list, err = dao.common.list_keys(dao.common.PREFIX_MAP.plugins)

    if err then
        pdk.log.error("plugins_map_id: get upstream list FAIL [".. err .."]")
        return nil
    end

    if not list or not list.list or (#list.list == 0) then
        pdk.log.error("plugins_map_id: plugin list null [" .. pdk.json.encode(list, true) .. "]")
        return nil
    end

    local plugins_map = {}

    for i = 1, #list.list do

        repeat
            local _, err = pdk.schema.check(schema.plugin.plugin_data, list.list[i])

            if err then
                pdk.log.error("upstream_nodes_map_id: plugin schema check err:[" .. err .. "]["
                                      .. pdk.json.encode(list.list[i], true) .. "]")
                break
            end

            local schema_key = list.list[i].key

            local plugin_schema = require("apioak.plugin." .. schema_key .. ".schema-" .. schema_key)

            local _, err = pdk.schema.check(plugin_schema, list.list[i].config)

            if err then
                pdk.log.error("upstream_nodes_map_id: plugin config schema check err:[" .. err .. "]["
                                      .. pdk.json.encode(list.list[i], true) .. "]")
                break
            end

            plugins_map[list.list[i].id] = {
                key    = list.list[i].key,
                config = list.list[i].config,
            }
        until true

    end

    if next(plugins_map) then
        return plugins_map
    end

   return nil
end

local function router_map_service_id(plugin_map)

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

            if #list.list[i].plugins > 0 then

                local plugin_data = {}

                for j = 1, #list.list[i].plugins do

                    repeat
                        if not list.list[i].plugins[j].id or not plugin_map[list.list[i].plugins[j].id] then
                            break
                        end

                        table.insert(plugin_data, plugin_map[list.list[i].plugins[j].id])

                    until true
                end

                list.list[i].plugins = plugin_data

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

    local plugin_map = plugins_map_id()

    local router_map = router_map_service_id(plugin_map)

    local service_router_list = {}

    for j = 1, #service_list do

        repeat
            local routers = {}

            if router_map[service_list[j].id] then
                routers = router_map[service_list[j].id]
            end

            if not next(routers) then
                break
            end

            service_list[j].routers = routers

            if #service_list[j].plugins > 0 then

                local plugin_data = {}

                for k = 1, #service_list[j].plugins do

                    repeat

                        if not service_list[j].plugins[k].id or not plugin_map[service_list[j].plugins[k].id] then
                            break
                        end

                        table.insert(plugin_data, plugin_map[service_list[j].plugins[k].id])

                    until true
                end

                service_list[j].plugins = plugin_data
            end

            table.insert(service_router_list, service_list[j])

        until true
    end

    return service_router_list
end

local function automatic_sync_ssl_router(premature)
    if premature then
        return
    end

    if process.type() ~= "privileged agent" then
        return
    end

    local i, limit, err_times, err_times_limit = 0, 10, 0, 5

    while not ngx_worker_exiting() and i <= limit do
        i = i + 1

        repeat
            local sync_data, err = dao.common.get_sync_data()

            if err then
                err_times = err_times + 1

                pdk.log.error("automatic_sync_ssl_router_get_sync_data_err: ["
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

                local sync_ssl_data, sync_ssl_err = sys_certificate.sync_update_ssl_data()

                if sync_ssl_err then
                    pdk.log.error("automatic_sync_ssl_router: get sync ssl data err:["
                                          .. i .."][" .. tostring(sync_ssl_err) .. "]")
                end

                local sync_router_data, sync_router_err = sync_update_router_data()

                if sync_router_err then
                    pdk.log.error("automatic_sync_ssl_router: get sync router data err:["
                                          .. i .."][" .. tostring(sync_router_err) .. "]")
                end

                local post_ssl, post_ssl_err = events.post(
                        sys_certificate.events_source_ssl, sys_certificate.events_type_put_ssl, sync_ssl_data)

                if post_ssl_err then
                    pdk.log.error("automatic_sync_ssl_router: sync ssl data post err:["
                                          .. i .."][" .. tostring(post_ssl_err) .. "]")
                end

                local post_router, post_router_err = events.post(
                        events_source_router, events_type_put_router, sync_router_data)

                if post_router_err then
                    pdk.log.error("automatic_sync_ssl_router: sync router data post err:["
                                          .. i .."][" .. tostring(post_router_err) .. "]")
                end

                if post_ssl and post_router then
                    dao.common.update_sync_data_hash(true)
                end

            end

            ngx_sleep(2)
        until true
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_ssl_router)
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

                                oak_ctx.params = params

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

local function worker_sync_event_register()

    local ssl_handler = sys_certificate.ssl_handler

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

    if process.type() ~= "privileged agent" then
        events.register(ssl_handler, sys_certificate.events_source_ssl, sys_certificate.events_type_put_ssl)
        events.register(router_handler, events_source_router, events_type_put_router)
    end
end

function _M.init_worker()
    ngx_timer_at(0, automatic_sync_hash_id)

    worker_sync_event_register()

    ngx_timer_at(0, automatic_sync_ssl_router)
end

local checked_request_params = function(rule, params)
    local query_val = params[rule.request_param_name]
    if rule.required == 1 then
        if not query_val then
            return nil, "request param \"[" ..
                    rule.request_param_position .. "." ..
                    rule.request_param_name .. "]\" undefined"
        end
    else
        if not query_val then
            query_val = rule.request_param_default_val
        end
    end

    return query_val, nil
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

function _M.matched(oak_ctx)
    if not router_cached_hash_id or router_cached_hash_id ~= router_latest_hash_id then
        loading_routers()
        router_cached_hash_id = router_latest_hash_id
    end

    local match_uri = pdk.string.format("/%s%s", oak_ctx.matched.header[pdk.const.REQUEST_API_ENV_KEY],
            ngx_var.uri)

    local match_ok = router_objects:dispatch(match_uri, pdk.request.get_method(), oak_ctx)

    if not match_ok then
        return false
    end
    return true
end

function _M.mapping(oak_ctx)
    local router = oak_ctx.router
    local backend_param_rules = router.backend_params
    for b = 1, #backend_param_rules do
        local backend_param_rule     = backend_param_rules[b]
        local backend_param_position = pdk.string.lower(backend_param_rule.position)
        local request_param_position = pdk.string.lower(backend_param_rule.request_param_position)

        if backend_param_position == request_param_position then
            local request_params = oak_ctx.matched[request_param_position]

            local request_value, err = checked_request_params(backend_param_rule, request_params)
            if err then
                pdk.response.exit(403, { err_message = err })
            end

            if backend_param_rule.name ~= backend_param_rule.request_param_name then
                request_params[backend_param_rule.request_param_name] = nil
                request_params[backend_param_rule.name]               = request_value
            end

            oak_ctx.matched[request_param_position] = request_params
        else
            local request_params = oak_ctx.matched[request_param_position]
            local backend_params = oak_ctx.matched[backend_param_position]

            local request_value, err = checked_request_params(backend_param_rule, request_params)
            if err then
                pdk.response.exit(403, { err_message = err })
            end

            request_params[backend_param_rule.request_param_name] = nil
            backend_params[backend_param_rule.name]               = request_value

            oak_ctx.matched[request_param_position] = request_params
            oak_ctx.matched[backend_param_position] = backend_params
        end
    end

    local constant_param_rules = router.constant_params
    for c = 1, #constant_param_rules do
        local constant_param_rule     = constant_param_rules[c]
        local constant_param_position = pdk.string.lower(constant_param_rule.position)
        local constant_param_value    = constant_param_rule.value
        local constant_param_name     = constant_param_rule.name

        oak_ctx.matched[constant_param_position][constant_param_name] = constant_param_value
    end
end

function _M.router_match(oak_ctx)

    if not oak_ctx.matched or not oak_ctx.matched.host or not oak_ctx.matched.uri then
        pdk.log.error("router_match: oak_ctx data format err: [" .. pdk.json.encode(oak_ctx, true) .. "]")
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
