local pdk = require("apioak.pdk")
local _M = {}
metric = {}

function _M.init_worker()
    -- 初始化 prometheus
    init_prometheus()

end

-- 初始化 prometheus
function init_prometheus()
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

return _M
