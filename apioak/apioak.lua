local ngx    = ngx
local ipairs = ipairs
local pairs  = pairs
local pdk    = require("apioak.pdk")
local sys    = require("apioak.sys")

local function run_plugin(phase, oak_ctx)
    local plugins = pdk.plugin.loading()
    for _, plugin in ipairs(plugins) do
        if plugin[phase] then
            plugin[phase](oak_ctx)
        end
    end
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

    sys.admin.init_worker()

    sys.router.init_worker()

    sys.plugin.init_worker()

end

function APIOAK.http_access()

    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    if not oak_ctx then
        oak_ctx = pdk.pool.fetch("oak_ctx", 0, 32)
        ngx_ctx.oak_ctx = oak_ctx
    end

    local env = pdk.request.header(pdk.const.REQUEST_API_ENV_KEY)
    if env then
        env = pdk.string.upper(env)
    else
        env = pdk.const.ENVIRONMENT_PROD
    end

    local routers  = sys.router.get()
    local match_ok = routers:dispatch("/" .. env .. ngx.var.uri, ngx.req.get_method(), oak_ctx)
    if not match_ok then
        pdk.response.exit(404, { err_message = "\"URI\" Undefined" })
    end

    if oak_ctx.router.is_mock_request then
        pdk.response.exit(200, oak_ctx.router.response_success)
    end

    sys.router.init_request(oak_ctx)

    local router  = oak_ctx.router
    local matched = oak_ctx.matched

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

    ngx.var.upstream_uri = upstream_uri

    run_plugin("http_access", oak_ctx)
end

function APIOAK.http_balancer()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    sys.balancer.go(oak_ctx)
end

function APIOAK.http_header_filter()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    run_plugin("http_header_filter", oak_ctx)
end

function APIOAK.http_body_filter()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    run_plugin("http_body_filter", oak_ctx)
end

function APIOAK.http_log()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    run_plugin("http_log", oak_ctx)
end

function APIOAK.http_admin()
    local admin_routers = sys.admin.routers()
    local ok = admin_routers:dispatch(ngx.var.uri, ngx.req.get_method())
    if not ok then
        ngx.exit(404)
    end
end

return APIOAK
