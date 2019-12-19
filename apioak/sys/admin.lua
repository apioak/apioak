local r3route = require("resty.r3")
local admin = require("apioak.admin")
local _M = {}

local router

function _M.init_worker()

    router = r3route.new()

    -- Router Manager URI
    router:insert_route("/apioak/admin/routers", admin.router.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/router", admin.router.create,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}", admin.router.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{router_id}", admin.router.update,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}", admin.router.delete,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin", admin.router.plugin_create,
            { method = { "POST", "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_key}", admin.router.plugin_delete,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{router_id}/env/{env}", admin.router.env_create,
            { method = { "POST", "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}/env/{env}", admin.router.env_delete,
            { method = { "DELETE" } })

    -- Service Manager URI
    router:insert_route("/apioak/admin/services", admin.service.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/service", admin.service.create,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/service/{service_id}", admin.service.update,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/service/{service_id}", admin.service.delete,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/service/{service_id}", admin.service.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/service/{service_id}/plugin", admin.service.plugin_create,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/service/{service_id}/plugin/{plugin_key}", admin.service.plugin_delete,
            { method = { "DELETE" } })

    -- Plugin Manager URI
    router:insert_route("/apioak/admin/plugins", admin.plugin.list,
            { method = { "GET" } })


    router:compile()
end

function _M.routers()
    return router
end

return _M
