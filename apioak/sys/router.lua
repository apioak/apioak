local ngx     = ngx
local pdk     = require("apioak.pdk")
local db      = require("apioak.db")
local dao     = require("apioak.dao")
local process = require("ngx.process")
local events  = require("resty.worker.events")
local pairs               = pairs
local oakrouting          = require("resty.oakrouting")
local sys_certificate     = require("apioak.sys.certificate")
local ngx_var             = ngx.var
local ngx_sleep           = ngx.sleep
local ngx_timer_at        = ngx.timer.at
local ngx_worker_exiting  = ngx.worker.exiting
local empty_table         = {}

local router_objects
local router_latest_hash_id
local router_cached_hash_id

local events_source_router   = "events_source_router"
local events_type_put_router = "events_type_put_router"

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

--local function authenticate_request(router_table)
--
--    -- @todo 处理当前请求是否符合配置要求，同时设置全局变量为进行后续的阶段操作提供配置数据
--
--end

local function generate_router_data(params_data)

    -- @todo 这里需要生成流量请求匹配到该路由上的数据（用在流量请求接收上）

    return nil, nil
end

local function worker_sync_event_register()

    local ssl_handler = sys_certificate.ssl_handler

    local router_handler = function(data, event, source)

        local res = {}

        local data, _ = generate_router_data(data)

        table.insert(res, data)

        router_objects = oakrouting.new(res)
    end

    if process.type() ~= "privileged agent" then
        events.register(ssl_handler, sys_certificate.events_source_ssl, sys_certificate.events_type_put_ssl)
        events.register(router_handler, events_source_router, events_type_put_router)
    end
end

local function sync_update_router_data()

    -- 当前获取数据以服务为单位获取



    -- @todo 整理与路由相关联的数据进行推送到各个worker进程中（相关数据： router、service、plugin、upstream、upstream_node）

    return nil, nil
end

local function automatic_sync_ssl_router(premature)
    if premature then
        return
    end

    if process.type() ~= "privileged agent" then
        return
    end

    local i, limit, times, times_limit = 0, 10, 0, 5

    while not ngx_worker_exiting() and i <= limit do
        i = i + 1

        repeat
            local sync_data, err = dao.common.get_sync_data()

            if err then
                times = times + 1

                pdk.log.error("automatic_sync_ssl_router_get_sync_data_err: ["
                                      .. times .. "] [" .. tostring(err) .. "]")

                if times == times_limit then
                    times = 0

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

                if sync_ssl_data and (sync_ssl_data ~= empty_table) then

                    local _, post_ssl_err = events.post(
                            sys_certificate.events_source_ssl, sys_certificate.events_type_put_ssl, sync_ssl_data)

                    if post_ssl_err then
                        pdk.log.error("automatic_sync_ssl_router: sync ssl data post err:["
                                              .. i .."][" .. tostring(post_ssl_err) .. "]")
                    end
                end

                local sync_router_data, sync_router_err = sync_update_router_data()

                if sync_router_err then
                    pdk.log.error("automatic_sync_ssl_router: get sync router data err:["
                                          .. i .."][" .. tostring(sync_router_err) .. "]")
                end

                if sync_router_data and (sync_router_data ~= empty_table) then

                    local _, post_router_err = events.post(
                            events_source_router, events_type_put_router, sync_router_data)

                    if post_router_err then
                        pdk.log.error("automatic_sync_ssl_router: sync router data post err:["
                                              .. i .."][" .. tostring(post_router_err) .. "]")
                    end
                end

            end

            ngx_sleep(2)
        until true
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_ssl_router)
    end
end

local function clear_sync_update_data()

    if process.type() ~= "privileged agent" then
        return
    end

    local sync_data, err = dao.common.get_sync_data()

    if err then
        pdk.log.error("[sys.dao] get sync data err: ", err)
    end

    if not sync_data or sync_data == empty_table then
        return
    end

    local _, err = dao.common.clear_sync_data()

    if err then
        pdk.log.error("[sys.dao] clear sync data err: ", err)
        return
    end
end

function _M.init_worker()
    ngx_timer_at(0, automatic_sync_hash_id)

    ngx_timer_at(0, clear_sync_update_data)

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
    oak_ctx.matched.query    = pdk.request.query()
    oak_ctx.matched.header   = pdk.request.header()

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

return _M
