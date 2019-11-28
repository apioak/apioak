local ngx_balancer     = require "ngx.balancer"
local get_last_failure = ngx_balancer.get_last_failure
local set_current_peer = ngx_balancer.set_current_peer
local set_timeouts     = ngx_balancer.set_timeouts
local set_more_tries   = ngx_balancer.set_more_tries
local pdk = require("apioak.pdk")
local tonumber = tonumber
local ngx_crc32_long = ngx.crc32_long
local ngx_exit = ngx.exit


local _M = {}

function _M.init_worker()

end


function _M.go()
    local ctx = {}
    ctx.upstream = {
        servers = {
            {
                host = "127.0.0.1",
                port = "10111"
            },
            {
                host = "127.0.0.1",
                port = "10222"
            },
        }
    }
    ctx.api = {}
    ctx.api.try_times = 0
    ctx.api.timeout   = 0
    ctx.path      = ngx.var.upstream_uri
    ctx.method    = ngx.req.get_method()
    ctx.client_ip = ngx.var.remote_addr

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
        pdk.log.error(ctx.backend_host .. ":" .. ctx.backend_port .. " request:" .. state .. " code:" .. code)
    else
        -- 把相同IP的请求分配到固定的服务器上
        local key = ctx.client_ip .. ctx.path .. ctx.method
        if server_count > 1 then
            local hash = ngx_crc32_long(key)
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
        pdk.log.error( "failed to set the current peer: ", err)
        ngx_exit(500)
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
        pdk.log.error("could not set upstream timeouts: ", err)
    end
end

return _M
