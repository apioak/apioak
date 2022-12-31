local oakrouting = require("resty.oakrouting")
local admin      = require("apioak.admin")
local router

local _M = {}

function _M.init_worker()

    router = oakrouting.new()

    -- New Services Related APIs
    router:post("/apioak/admin/services", admin.service.created)

    router:put("/apioak/admin/services/{service_key}", admin.service.updated)

    router:get("/apioak/admin/services", admin.service.lists)

    router:get("/apioak/admin/services/{service_key}", admin.service.detail)

    router:delete("/apioak/admin/services/{service_key}", admin.service.deleted)

    -- New Routers Related APIs
    router:post("/apioak/admin/routers", admin.router.created)

    router:put("/apioak/admin/routers/{router_key}", admin.router.updated)

    router:get("/apioak/admin/routers", admin.router.lists)

    router:get("/apioak/admin/routers/{router_key}", admin.router.detail)

    router:delete("/apioak/admin/routers/{router_key}", admin.router.deleted)

    -- New Plugins Related APIs
    router:post("/apioak/admin/plugins", admin.plugin.created)

    router:put("/apioak/admin/plugins/{plugin_key}", admin.plugin.updated)

    router:get("/apioak/admin/plugins", admin.plugin.lists)

    router:get("/apioak/admin/plugins/{plugin_key}", admin.plugin.detail)

    router:delete("/apioak/admin/plugins/{plugin_key}", admin.plugin.deleted)

    -- Upstreams Related APIs
    router:post("/apioak/admin/upstreams", admin.upstream.created)

    router:put("/apioak/admin/upstreams/{upstream_key}", admin.upstream.updated)

    router:get("/apioak/admin/upstreams", admin.upstream.lists)

    router:get("/apioak/admin/upstreams/{upstream_key}", admin.upstream.detail)

    router:delete("/apioak/admin/upstreams/{upstream_key}", admin.upstream.deleted)

    -- Upstream nodes Related APIs
    router:post("/apioak/admin/upstream/nodes", admin.upstream_node.created)

    router:put("/apioak/admin/upstream/nodes/{upstream_node_key}", admin.upstream_node.updated)

    router:get("/apioak/admin/upstream/nodes", admin.upstream_node.lists)

    router:get("/apioak/admin/upstream/nodes/{upstream_node_key}", admin.upstream_node.detail)

    router:delete("/apioak/admin/upstream/nodes/{upstream_node_key}", admin.upstream_node.deleted)

    -- Certificates Related APIs
    router:post("/apioak/admin/certificates", admin.certificates.created)

    router:put("/apioak/admin/certificates/{certificate_key}", admin.certificates.updated)

    router:get("/apioak/admin/certificates", admin.certificates.lists)

    router:get("/apioak/admin/certificates/{certificate_key}", admin.certificates.detail)

    router:delete("/apioak/admin/certificates/{certificate_key}", admin.certificates.deleted)

end

function _M.routers()
    return router
end

return _M
