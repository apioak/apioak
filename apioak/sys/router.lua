local r3route = require("resty.r3")
local pdk = require("apioak.pdk")
local ipairs = ipairs
local ngx_timer_at = ngx.timer.at

local router

local _M = {}

function _M.init_worker()
    ngx_timer_at(0, function (premature)
        if premature then
            return
        end
        local etcd_cli = pdk.etcd.new()
        local route_responses, err = etcd_cli.get('routes')
        local route_body = route_responses.body
        local route_nodes = {}
        if not route_body.node or not route_body.node.nodes then
            pdk.log.error("[sys.router] router not set")
        else
            route_nodes = route_body.node.nodes
        end

        local default_method = { "GET", "PUT", "POST", "DELETE", "PATCH" }
        local r3_routes = {}
        for _, route_node in ipairs(route_nodes) do
            if route_node.value.method then
                default_method = { route_node.value.method }
            end

            pdk.table.insert(r3_routes, {
                path = route_node.value.uri,
                method = default_method,
            })
        end

        local shared_cli = pdk.shared.new('sys_routes')
        shared_cli.set("routes", r3_routes, 0)
    end)
end

function _M.create_r3_routes()
    local shared_cli = pdk.shared.new('sys_routes')
    local routes = shared_cli.get('routes')
    for key, route in ipairs(routes) do
        routes[key].handler = function(param, oak_ctx)
            oak_ctx.matched = {}
            oak_ctx.matched.param = param
            oak_ctx.matched.path = route.path
        end
    end
    router = r3route.new(routes)
    router:compile()
end

function _M.get()
    if not router then
        _M.create_r3_routes()
    end
    return router
end

return _M
