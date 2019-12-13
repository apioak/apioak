local r3route = require("resty.r3")
local admin = require("apioak.admin")
local _M = {}

local router

function _M.init_worker()

    router = r3route.new()

    router:insert_route("/apioak/admin/routers/{service_id}", admin.router.list, { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{service_id}/{id}", admin.router.query, { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{service_id}", admin.router.create, { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{service_id}/{id}", admin.router.update, { method = { "PUT" } })

    router:insert_route("/apioak/admin/router/{service_id}/{id}", admin.router.delete, { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{id}/plugin", admin.router.plugin_create, { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{id}/plugin", admin.router.plugin_delete, { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{id}/push_upstream", admin.router.push_upstream, { method = { "PUT" } })

    router:insert_route("/apioak/admin/services", admin.service.list, { method = { "GET" } })

    router:insert_route("/apioak/admin/service", admin.service.create, { method = { "POST" } })

    router:insert_route("/apioak/admin/service/{id}", admin.service.update, { method = { "PUT" } })

    router:insert_route("/apioak/admin/service/{id}", admin.service.delete, { method = { "DELETE" } })

    router:insert_route("/apioak/admin/service/{id}", admin.service.query, { method = { "GET" } })

    router:insert_route("/apioak/admin/service/{id}/plugin", admin.service.plugin_create, { method = { "POST" } })

    router:insert_route("/apioak/admin/service/{id}/plugin", admin.service.plugin_delete, { method = { "DELETE" } })

    router:insert_route("/apioak/admin/plugins", admin.plugin.list, { method = { "GET" } })

    router:compile()
end

function _M.routers()
    return router
end

return _M
