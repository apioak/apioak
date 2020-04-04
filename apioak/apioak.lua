local ngx    = ngx
local pairs  = pairs
local pdk    = require("apioak.pdk")
local sys    = require("apioak.sys")

local function run_plugin(phase, oak_ctx)
    local plugins, err = pdk.plugin.loading()
    if err then
        pdk.log.error("failure to loading plugins, ", err)
        plugins = {}
    end

    for i = 1, #plugins do
        local plugin = plugins[i]
        if plugin[phase] then
            plugin[phase](oak_ctx)
        end
    end
end

local function options_request_handle()
    if pdk.request.get_method() == "OPTIONS" or ngx.var.uri == "/" then
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
end

function APIOAK.init_worker()

    sys.config.init_worker()

    sys.admin.init_worker()

    sys.router.init_worker()

    sys.balancer.init_worker()

    sys.cache.init_worker()
end

function APIOAK.http_access()

    options_request_handle()

    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    if not oak_ctx then
        oak_ctx = pdk.pool.fetch("oak_ctx", 0, 32)
        ngx_ctx.oak_ctx = oak_ctx
    end

    sys.router.parameter(oak_ctx)

    local match_succeed = sys.router.matched(oak_ctx)
    if not match_succeed then
        pdk.response.exit(404, { err_message = "\"URI\" Undefined" })
    end

    if oak_ctx.router.enable_cors == 1 then
        enable_cors_handle()
    end

    if oak_ctx.router.is_mock_request then
        pdk.response.set_header(pdk.const.RESPONSE_MOCK_REQUEST_KEY, true)
        pdk.response.exit(200, oak_ctx.router.response_success, oak_ctx.router.response_type)
    end

    sys.router.mapping(oak_ctx)

    local router   = oak_ctx.router
    local matched  = oak_ctx.matched
    local upstream = router.upstream

    local upstream_uri = router.backend_path
    for path_key, path_val in pairs(matched.path) do
        upstream_uri = pdk.string.replace(upstream_uri, "{" .. path_key .. "}", path_val)
    end

    for header_key, header_val in pairs(matched.header) do
        pdk.request.add_header(header_key, header_val)
    end

    local query_args = {}
    for query_key, query_val in pairs(matched.query) do
        pdk.table.insert(query_args, query_key .. "=" .. query_val)
    end
    if #query_args > 0 then
        upstream_uri = upstream_uri .. "?" .. pdk.table.concat(query_args, "&")
    end

    pdk.request.set_method(router.backend_method)

    ngx.var.upstream_uri = upstream_uri

    ngx.var.upstream_host = upstream.host

    sys.balancer.loading()

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
