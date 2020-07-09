local pdk = require("apioak.pdk")
local ngx_var    = ngx.var

local plugin_name = "prometheus"
local metric = {}

local _M = {
    name        = plugin_name,
    type        = "Service Monitoring",
    description = "Lua module for monitor server.",
    init        = init
}

local config_schema = {
    type = "object",
    additionalProperties = false
}

-- 初始化 prometheus
function _M.init()
    prometheus = require("prometheus").init("prometheus_metrics")
    -- http 请求数
    metric.requests = prometheus:counter(
            "nginx_http_requests_total", "Number of HTTP requests", {"host", "status"})
    -- api 请求数
    metric.api_requests = prometheus:counter(
            "nginx_http_api_requests_total", "Number of HTTP requests", {"host", "api", "status"})
    -- http 请求耗时
    metric.latency = prometheus:histogram(
            "nginx_http_request_duration_seconds", "HTTP request latency", {"host", "api"})
    -- http 连接数
    metric.connections = prometheus:gauge(
            "nginx_http_connections", "Number of HTTP connections", {"state"})
    -- 总带宽
    metric.bandwidth = prometheus:counter("bandwidth", "Total bandwidth in bytes consumed per service in APIOAK",
            {"host", "api"})
end

function _M.http_access(oak_ctx)
    local router  = oak_ctx.router or {}
    local plugins = router.plugins

    if not plugins then
        return
    end

    local router_plugin = plugins[plugin_name]

    if not router_plugin then
        return
    end

    local plugin_config = router_plugin.config or {}

    local _, err_message = pdk.schema.check(config_schema, plugin_config)
    if err_message then
        pdk.log.error("[prometheus] Authorization FAIL, backend config error, " .. err_message)
        pdk.response.exit(500)
    end

    if not prometheus or not metric then
        pdk.log.error("prometheus: plugin is not initialized, please make sure ", "'prometheus_metrics' shared dict is present in nginx template ")
        pdk.response.exit(500, {"err_message : Prometheus has a system error"})
    end

    metric.requests:inc(1, {ngx_var.host, ngx_var.status})
    metric.api_requests:inc(1, {ngx_var.host, ngx_var.request_uri, ngx_var.status})
    metric.latency:observe(tonumber(ngx_var.request_time), {ngx_var.host, ngx_var.request_uri})
    metric.connections:set(ngx_var.connections_reading, {"reading"})
    metric.connections:set(ngx_var.connections_waiting, {"waiting"})
    metric.connections:set(ngx_var.connections_writing, {"writing"})
    metric.bandwidth:inc(tonumber(ngx_var.request_length), {ngx_var.host, ngx_var.request_uri})

end

return _M
