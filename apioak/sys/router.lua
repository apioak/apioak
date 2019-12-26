local ngx      = ngx
local pdk      = require("apioak.pdk")
local ipairs   = ipairs
local r3route  = require("resty.r3")
local timer_at = ngx.timer.at

local router

local merge_plugins = function(service_plugins, router_plugins)
    if not router_plugins then
        return service_plugins
    end
    if service_plugins then
        for plugin_key, plugin_config in ipairs(service_plugins) do
            if not router_plugins[plugin_key] then
                router_plugins[plugin_key] = plugin_config
            end
        end
    end
    return router_plugins
end

local _M = {}

function _M.init_worker()
    timer_at(0, function (premature)
        if premature then
            return
        end

        local service_etcd_key = pdk.admin.get_service_etcd_key()
        local res, code, err   = pdk.etcd.query(service_etcd_key)
        if not res then
            pdk.log.error("failed to read \"service\" response body when try to fetch etcd")
        end

        local routers = {}
        for _, service in ipairs(res.nodes) do
            if service.value then
                local service_id        = pdk.admin.get_service_id_by_etcd_key(service.key)
                local service_prefix    = service.value.prefix
                local service_plugins   = service.value.plugins
                local service_upstreams = service.value.upstreams

                local envs = pdk.admin.envs
                for _, env in ipairs(envs) do
                    local router_etcd_key = pdk.admin.get_router_etcd_key(env, service_id)
                    res, code, err        = pdk.etcd.query(router_etcd_key)
                    if res and res.nodes then
                        for _, service_router in ipairs(res.nodes) do
                            if service_router.value then
                                local router_info = service_router.value
                                local router_upstream = service_upstreams[env]
                                local router_plugins  = merge_plugins(service_plugins, router_info.plugins)
                                local router_abs_path = "/" .. env .. service_prefix .. router_info.path

                                pdk.table.insert(routers, {
                                    path   = router_abs_path,
                                    method = { router_info.method },
                                    handler = function(params, oak_ctx)
                                        oak_ctx.router = {}
                                        oak_ctx.router.uri            = router_info.path
                                        oak_ctx.router.method         = router_info.method
                                        oak_ctx.router.abs_uri        = router_abs_path
                                        oak_ctx.router.environment    = env
                                        oak_ctx.router.enable_cors    = router_info.enable_cors
                                        oak_ctx.router.request_params = router_info.request_params
                                        oak_ctx.router.uri_prefix     = service_prefix

                                        oak_ctx.backend = {}
                                        oak_ctx.backend.uri             = router_info.service_path
                                        oak_ctx.backend.method          = router_info.service_method
                                        oak_ctx.backend.timeout         = router_info.timeout
                                        oak_ctx.backend.request_params  = router_info.service_params
                                        oak_ctx.backend.constant_params = router_info.constant_params

                                        oak_ctx.response = {}
                                        oak_ctx.response.type            = router_info.response_type
                                        oak_ctx.response.success_content = router_info.response_success
                                        oak_ctx.response.failure_content = router_info.response_fail
                                        oak_ctx.response.error_codes     = router_info.response_error_codes

                                        oak_ctx.upstream = router_upstream
                                        oak_ctx.plugins  = router_plugins

                                        oak_ctx.request = {}
                                        oak_ctx.request.client_ip = ngx.var.remote_addr

                                        oak_ctx.matched = {}
                                        oak_ctx.matched.params = params or {}
                                    end
                                })
                            end
                        end
                    end
                end
            end
        end

        router = r3route.new(routers)
        router:compile()
    end)
end

function _M.get()
    if not router then
        _M.create_r3_routes()
    end
    return router
end

return _M
