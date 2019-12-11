local ngx    = ngx
local ipairs = ipairs
local pdk    = require("apioak.pdk")
local sys    = require("apioak.sys")

local function run_plugin(phase, oak_ctx)
    local plugins = sys.plugin.loading()
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

	    sys.admin.init_worker() --临时加入，提交代码之前删除掉
end

function APIOAK.init_worker()

    sys.admin.init_worker()

    sys.router.init_worker()

    sys.plugin.init_worker()

    sys.upstream.init_worker()

    sys.balancer.init_worker()
end

function APIOAK.http_rewrite()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    if not oak_ctx then
        ngx_ctx.oak_ctx = {}
    end
    run_plugin("http_rewrite", oak_ctx)
end

function APIOAK.http_access()
    local ngx_ctx = ngx.ctx
    local oak_ctx = ngx_ctx.oak_ctx
    local routers = sys.router.get()
    local match_ok = routers:dispatch(ngx.var.uri, ngx.req.get_method(), oak_ctx)
    if not match_ok then
        pdk.response.exit({ code = 404 })
    end
    ngx.var.upstream_uri = ngx.var.uri
    run_plugin("http_access", oak_ctx)
end

function APIOAK.http_balancer()
    sys.balancer.go()
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

do
    local admin_routers
    function APIOAK.http_admin()
        if not admin_routers then
            admin_routers = sys.admin.routers()
        end
        local ok = admin_routers:dispatch(ngx.var.uri, ngx.req.get_method())
        if not ok then
            ngx.exit(404)
        end
    end
end

return APIOAK
