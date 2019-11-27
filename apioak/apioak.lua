local ipairs           = ipairs
local utils            = require "apioak.lib.tools.utils"
local string_format    = string.format
local table_insert     = table.insert
local ngx_log          = ngx.log
local ngx_exit         = ngx.exit
local ngx_DEBUG        = ngx.DEBUG
local ngx_WARN         = ngx.WARN
local pdk              = require("apioak.pdk")
local sys              = require("apioak.sys")

-- 开启的插件名称
local enable_plugins = {
    'project',   -- 基础组件不可插拔
    'router',    -- 基础组件不可插拔
    'waf',       -- 黑白名单
    'jwt-auth',  -- JWT认证
    'sign-auth', -- 签名认证
    'cors',      -- 跨区访问
}

-- 加载插件
local function loading_plugins(plugins, store)
    local load_plugins = {}
    for _, name in ipairs(plugins) do
        -- 组装插件的加载路径
        local plugin_path = string_format("plugins.%s.handler", name)
        -- 加载模块
        local ok, plugin_handler = utils.load_module(plugin_path)
        if not ok then
            ngx_log(ngx_WARN, "The following plugin is not installed or has no handler: " .. name)
        else
            ngx_log(ngx_DEBUG, "Loading plugin: " .. name)
            -- 加载成功把插件信息装载到响应的Table中
            table_insert(load_plugins, {
                name    = name,
                handler = plugin_handler(store),
            })
        end
    end
    return load_plugins
end

-- 加载的插件
local plugins = {}

-- 定义执行流对象
local APIOAK = {}

-- 初始化项目配置
function APIOAK.init(options)
    options = options or {}
    plugins = loading_plugins(enable_plugins)
end

-- 初始化插件配置
function APIOAK.init_worker()

    sys.admin.init_worker()

    sys.router.init_worker()

    sys.plugin.init_worker()

    sys.upstream.init_worker()

end

-- 请求转发、重定向等操作
function APIOAK.rewrite()

end

-- 请求IP准入、权限认证相关操作
function APIOAK.access()
    ngx.ctx.oak_ctx = {}
    local oak_ctx = ngx.ctx.oak_ctx
    local routers = sys.router.get()
    -- pdk.log.error("---", type(routers))
    routers:dispatch(ngx.var.uri, ngx.req.get_method(), oak_ctx)
    ngx.say(oak_ctx.matched.route.path)
    ngx_exit(200)
end

--负载均衡 优先接口自定义，之后是项目设置
function APIOAK.balancer()

end

-- 响应头部过滤处理
function APIOAK.header_filter()

end

-- 响应体过滤处理
function APIOAK.body_filter()

end

-- 会话完成后本地异步完成日志处理
function APIOAK.log()

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
