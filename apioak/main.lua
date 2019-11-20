local env              = require "conf.env"
local ipairs           = ipairs
local utils            = require "apioak.lib.tools.utils"
local singletons       = require "apioak.singletons"
local response         = require "apioak.lib.response"
local ngx_balancer     = require "ngx.balancer"
local get_last_failure = ngx_balancer.get_last_failure
local set_current_peer = ngx_balancer.set_current_peer
local set_timeouts     = ngx_balancer.set_timeouts
local set_more_tries   = ngx_balancer.set_more_tries
local tonumber         = tonumber
local ngx_re_match     = ngx.re.match
local string_format    = string.format
local table_insert     = table.insert
local ngx_log          = ngx.log
local ngx_DEBUG        = ngx.DEBUG
local ngx_ERR          = ngx.ERR
local ngx_WARN         = ngx.WARN

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
local _M = {}

-- 初始化项目配置
function _M.init(options)
    options = options or {}
    singletons.config = env
    plugins = loading_plugins(enable_plugins)
end

-- 初始化插件配置
function _M.init_worker()
    for _, plugin in ipairs(plugins) do
        plugin.handler:init_worker()
    end
end

-- 请求转发、重定向等操作
function _M.rewrite()
    for _, plugin in ipairs(plugins) do
        plugin.handler:rewrite()
    end
end

-- 请求IP准入、权限认证相关操作
function _M.access()
    -- 获取Nginx内置变量
    local var = ngx.var
    -- 获取Nginx共享变量
    local ctx = ngx.ctx
    -- 获取Header信息
    local headers = ngx.req.get_headers()
    -- 获取网关的请求地址
    local gateway_path = var.uri
    -- 匹配URI中地址及信息产品标识信息
    local gateway_path_info = ngx_re_match(gateway_path, "/([a-z-0-9]+)/(.*)", "jo")
    -- 信息匹配失败响应欢迎信息
    if gateway_path_info == nil or gateway_path_info[1] == nil or gateway_path_info[2] == nil then
        return response:error(200, 'Welcome Used API Gateway System'):response()
    end

    -- 初始化API请求版本
    headers.k_version = headers.k_version or 'v1'
    -- 初始化来源平台
    headers.k_platform = headers.k_platform or 'web'

    -- 获取后端请求地址
    ctx.path = gateway_path_info[2]
    -- 获取产品线标识
    ctx.backend_name = gateway_path_info[1]
    -- 获取请求方式
    ctx.method = var.request_method
    -- 获取API请求版本
    ctx.version = headers.k_version
    -- 获取当前来源的平台
    ctx.platform = headers.k_platform
    -- 获取客户端IP地址
    ctx.client_ip = utils.get_client_ip()
    -- 初始化网络 1 外网 2 内网
    ctx.client_network = 1
    -- 声明API信息存储共享变量
    ctx.api = {}
    -- 声明项目信息存储共享变量
    ctx.upstream = {}
    -- 当请求为POST时允许读取Body
    if ctx.method == "POST" then
        ngx.req.read_body()
    end
    --加载插件
    for _, plugin in ipairs(plugins) do
        plugin.handler:access(ctx)
    end
end

--负载均衡 优先接口自定义，之后是项目设置
function _M.balancer()
    local ctx = ngx.ctx
    local upstream = ctx.upstream
    -- 初始化错误重试计数器
    if not ctx.tries then
        ctx.tries = 0
    end
    -- 获取应用服务器数量
    local server_count = #upstream.servers
    if ctx.api.try_times > server_count then
        --最大重试次数为后端服务器数量减1
        ctx.api.try_times = server_count - 1
    end
    -- 初始化服务器组索引
    if not ctx.hash then
        ctx.hash = 1
    end
    -- 如果当前是重试的访问
    if ctx.tries > 0 then
        local state, code = get_last_failure()
        -- 失败情况下设置下次读取的后端服务器
        if ctx.hash >= server_count then
            ctx.hash = 1
        else
            ctx.hash = ctx.hash + 1
        end
        ngx_log(ngx_ERR, ctx.backend_host .. ":" .. ctx.backend_port .. " request:" .. state .. " code:" .. code)
    else
        -- 把相同IP的请求分配到固定的服务器上
        local key = ctx.client_ip .. ctx.path .. ctx.method
        if server_count > 1 then
            local hash = ngx.crc32_long(key)
            ctx.hash = (hash % server_count) + 1
        end
    end
    --3个概念，服务器数量，设置的最大重试次数，已经重试的次数
    --设置失败重试，如果设置的次数大于0  并且重试的次数小于设置的次数  并且后端服务器数据量大于1
    if ctx.api.try_times > 0 and ctx.tries < ctx.api.try_times and server_count > 1 then
        set_more_tries(1)
    end
    ctx.tries = ctx.tries + 1
    -- 获取后端应用IP地址
    ctx.backend_host = upstream.servers[ctx.hash]['host']
    -- 获取后端应用服务端口
    ctx.backend_port = upstream.servers[ctx.hash]['port'] or 80
    local ok, err = set_current_peer(ctx.backend_host, ctx.backend_port)
    if not ok then
        ngx_log(ngx_ERR, "failed to set the current peer: ", err)
        return ngx.exit(500)
    end
    -- 获取超时时间
    local timeout = tonumber(ctx.api.timeout)
    if timeout >= 10 or timeout <= 0 then
        timeout = 10
    end
    -- 初始化超时时间
    local balancer_address = {
        connect_timeout = 60, --考虑用户网络不好情况，设置大些
        send_timeout = 60,
        read_timeout = timeout,
    }
    ok, err = set_timeouts(balancer_address.connect_timeout, balancer_address.send_timeout, balancer_address.read_timeout)
    if not ok then
        ngx_log(ngx_ERR, "could not set upstream timeouts: ", err)
    end
end

-- 响应头部过滤处理
function _M.header_filter()
    local ctx = ngx.ctx
    for _, plugin in ipairs(plugins) do
        plugin.handler:header_filter(ctx)
    end
end

-- 响应体过滤处理
function _M.body_filter()
    local ctx = ngx.ctx
    for _, plugin in ipairs(plugins) do
        plugin.handler:body_filter(ctx)
    end
end

-- 会话完成后本地异步完成日志处理
function _M.log()
    local ctx = ngx.ctx
    for _, plugin in ipairs(plugins) do
        plugin.handler:log(ctx)
    end
end

return _M
