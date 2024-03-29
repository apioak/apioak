local ngx    = ngx
local pairs  = pairs
local pdk    = require("apioak.pdk")
local sys    = require("apioak.sys")

local function run_plugin(phase, oak_ctx)
    if oak_ctx == nil or oak_ctx.config == nil then
        return
    end

    local config = oak_ctx.config

    if not config then
        pdk.log.error("run_plugin plugin data not ready!")
        pdk.response.exit(500, { message = "config not ready" })
    end

    local service_router  = config.service_router
    local service_plugins = service_router.plugins
    local router_plugins  = service_router.router.plugins

    local plugin_objects = sys.plugin.plugin_subjects()

    local router_plugin_keys_map = {}

    if #router_plugins > 0 then

        for i = 1, #router_plugins do

            repeat

                if not plugin_objects[router_plugins[i].id] then
                    break
                end

                local router_plugin_object = plugin_objects[router_plugins[i].id]

                router_plugin_keys_map[router_plugin_object.key] = 0

                if not router_plugin_object.handler[phase] then
                    break
                end

                router_plugin_object.handler[phase](oak_ctx, router_plugin_object.config)

            until true
        end

    end

    if #service_plugins > 0 then

        for j = 1, #service_plugins do

            repeat

                if not plugin_objects[service_plugins[j].id] then
                    break
                end

                local service_plugin_object = plugin_objects[service_plugins[j].id]

                if router_plugin_keys_map[service_plugin_object.key] then
                    break
                end

                if not service_plugin_object.handler[phase] then
                    break
                end

                service_plugin_object.handler[phase](oak_ctx, service_plugin_object.config)

            until true
        end

    end

end

local function options_request_handle()
    if pdk.request.get_method() == "OPTIONS" then
        pdk.response.exit(200, {
            err_message = "Welcome to APIOAK"
        })
    end
end

local function enable_cors_handle()
    pdk.response.set_header("Access-Control-Allow-Origin", "*")
    pdk.response.set_header("Access-Control-Allow-Credentials", "true")
    pdk.response.set_header("Access-Control-Expose-Headers", "*")
    pdk.response.set_header("Access-Control-Max-Age", "3600")
end

local APIOAK = {}

function APIOAK.init()
    require("resty.core")
    if require("ffi").os == "Linux" then
        require("ngx.re").opt("jit_stack_size", 200 * 1024)
    end

    require("jit.opt").start("minstitch=2", "maxtrace=4000",
            "maxrecord=8000", "sizemcode=64",
            "maxmcode=4000", "maxirconst=1000")

    local process = require("ngx.process")
    local ok, err = process.enable_privileged_agent()
    if not ok then
        pdk.log.error("failed to enable privileged process, error: ", err)
    end
end

function APIOAK.init_worker()

    sys.config.init_worker()

    sys.admin.init_worker()

    sys.dao.init_worker()

    sys.cache.init_worker()

    sys.certificate.init_worker()

    sys.balancer.init_worker()

    sys.plugin.init_worker()

    sys.router.init_worker()

end

function APIOAK.ssl_certificate()

    local ngx_ssl = require("ngx.ssl")
    local server_name = ngx_ssl.server_name()

    local oak_ctx = {
        matched = {
            host = server_name
        }
    }
    sys.certificate.ssl_match(oak_ctx)
end

function APIOAK.http_access()

    options_request_handle()

    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    if not oak_ctx then
        oak_ctx = pdk.pool.fetch("oak_ctx", 0, 64)
        ngx_ctx.oak_ctx = oak_ctx
    end

    sys.router.parameter(oak_ctx)

    local match_succeed = sys.router.router_match(oak_ctx)

    if not match_succeed then
        pdk.response.exit(404, { err_message = "\"URI\" Undefined" })
    end

    sys.balancer.init_resolver()

    sys.balancer.check_replenish_upstream(oak_ctx)

    local matched  = oak_ctx.matched

    local upstream_uri = matched.uri

    for path_key, path_val in pairs(matched.path) do
        upstream_uri = pdk.string.replace(upstream_uri, "{" .. path_key .. "}", path_val)
    end

    for header_key, header_val in pairs(matched.header) do
        pdk.request.add_header(header_key, header_val)
    end

    local query_args = {}

    for query_key, query_val in pairs(matched.query) do
        if query_val == true then
            query_val = ""
        end
        pdk.table.insert(query_args, query_key .. "=" .. query_val)
    end

    if #query_args > 0 then
        upstream_uri = upstream_uri .. "?" .. pdk.table.concat(query_args, "&")
    end

    pdk.request.set_method(matched.method)

    ngx.var.upstream_uri = upstream_uri

    ngx.var.upstream_host = matched.host

    run_plugin("http_access", oak_ctx)
end

function APIOAK.http_balancer()
    local oak_ctx = ngx.ctx.oak_ctx
    sys.balancer.gogogo(oak_ctx)
end

function APIOAK.http_header_filter()
    local oak_ctx = ngx.ctx.oak_ctx
    run_plugin("http_header_filter", oak_ctx)
end

function APIOAK.http_body_filter()
    local oak_ctx = ngx.ctx.oak_ctx
    run_plugin("http_body_filter", oak_ctx)
end

function APIOAK.http_log()
    local oak_ctx = ngx.ctx.oak_ctx
    run_plugin("http_log", oak_ctx)
    if oak_ctx then
        pdk.pool.release("oak_ctx", oak_ctx)
    end
end

function APIOAK.http_admin()

    options_request_handle()

    enable_cors_handle()

    local admin_routers = sys.admin.routers()
    local ok = admin_routers:dispatch(ngx.var.uri, ngx.req.get_method())
    if not ok then
        ngx.exit(404)
    end
end

return APIOAK
