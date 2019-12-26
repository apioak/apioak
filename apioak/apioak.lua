local ngx    = ngx
local ipairs = ipairs
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

    sys.balancer.init_worker()
end

function APIOAK.http_access()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    if not oak_ctx then
        oak_ctx = pdk.pool.fetch("oak_ctx", 0, 32)
        ngx_ctx.oak_ctx = oak_ctx
    end

    local env = pdk.request.header("APIOAK-ENV")
    if env then
        env = pdk.string.lower(env)
    else
        env = pdk.admin.ENV_MASTER
    end

    local routers = sys.router.get()
    local match_ok = routers:dispatch("/" .. env .. ngx.var.uri, ngx.req.get_method(), oak_ctx)
    if not match_ok then
        pdk.response.exit(404, { err_message = "\"URI\" not found" })
    end

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
