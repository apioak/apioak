local pdk = require("apioak.pdk")
local ngx_var    = ngx.var

local plugin_name = "prometheus"

local _M = {
    name        = plugin_name,
    type        = "Service Monitoring",
    description = "Lua module for monitor server.",
}

local config_schema = {
    type = "object",
    additionalProperties = false
}

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
