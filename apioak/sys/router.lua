local pdk = require("apioak.pdk")
local db  = require("apioak.db")
local pairs               = pairs
local r3route             = require("resty.r3")
local ngx_var             = ngx.var
local ngx_sleep           = ngx.sleep
local ngx_timer_at        = ngx.timer.at
local ngx_worker_exiting  = ngx.worker.exiting

local router_objects
local router_latest_hash_id
local router_cached_hash_id

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

    router_objects = r3route.new(router_caches)
    router_objects:compile()
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

function _M.init_worker()
    ngx_timer_at(0, automatic_sync_hash_id)
end

local checked_request_params = function(rule, params)
    local query_val = params[rule.request_param_name]
    if rule.required == 1 then
        if not query_val then
            return nil, "request param \"[" .. rule.request_param_position .. "." .. rule.request_param_name .. "]\" undefined"
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
