local oakrouting = require("resty.oakrouting")
local admin      = require("apioak.admin")
local router

local _M = {}

function _M.init_worker()

    router = oakrouting.new()

    -- Common Service Related APIs
    router:get("/apioak/admin/plugins", admin.common.plugins)

    router:get("/apioak/admin/users", admin.common.users)

    router:get("/apioak/admin/members", admin.common.members)

    router:get("/apioak/admin/projects", admin.common.projects)

    router:get("/apioak/admin/routers", admin.common.routers)


    -- Account Related APIs
    router:post("/apioak/admin/account/register", admin.account.register)

    router:put("/apioak/admin/account/login", admin.account.login)

    router:delete("/apioak/admin/account/logout", admin.account.logout)

    router:get("/apioak/admin/account/status", admin.account.status)


    -- Project Related APIs
    router:post("/apioak/admin/project", admin.project.created)

    router:put("/apioak/admin/project/{project_id}", admin.project.updated)

    router:get("/apioak/admin/project/{project_id}", admin.project.selected)

    router:delete("/apioak/admin/project/{project_id}", admin.project.deleted)

    router:get("/apioak/admin/project/{project_id}/routers", admin.project.routers)

    router:get("/apioak/admin/project/{project_id}/plugins", admin.project.plugins)

    router:post("/apioak/admin/project/{project_id}/plugin", admin.project.plugin_created)

    router:put("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.project.plugin_updated)

    router:delete("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.project.plugin_deleted)

    router:get("/apioak/admin/project/{project_id}/members", admin.project.members)

    router:post("/apioak/admin/project/{project_id}/member", admin.project.member_created)

    router:delete("/apioak/admin/project/{project_id}/member/{user_id}", admin.project.member_deleted)

    router:put("/apioak/admin/project/{project_id}/member/{user_id}", admin.project.member_updated)


    -- Router Related APIs
    router:post("/apioak/admin/router", admin.router_o.created)

    router:get("/apioak/admin/router/{router_id}", admin.router_o.query)

    router:put("/apioak/admin/router/{router_id}", admin.router_o.updated)

    router:delete("/apioak/admin/router/{router_id}", admin.router_o.deleted)

    router:get("/apioak/admin/router/{router_id}/plugins", admin.router_o.plugins)

    router:post("/apioak/admin/router/{router_id}/plugin", admin.router_o.plugin_created)

    router:put("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.router_o.plugin_updated)

    router:delete("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.router_o.plugin_deleted)

    router:post("/apioak/admin/router/{router_id}/env/{env}", admin.router_o.env_push)

    router:delete("/apioak/admin/router/{router_id}/env/{env}", admin.router_o.env_pull)


    -- User Manager API
    router:post("/apioak/admin/user", admin.user.created)

    router:delete("/apioak/admin/user/{user_id}", admin.user.deleted)

    router:put("/apioak/admin/user/{user_id}/password", admin.user.password)

    router:put("/apioak/admin/user/{user_id}/enable", admin.user.enable)

    router:put("/apioak/admin/user/{user_id}/disable", admin.user.disable)


    -- New Service Related APIs
    router:post("/apioak/admin/bete/services", admin.service.created)

    router:put("/apioak/admin/bete/services/{service_key}", admin.service.updated)

    router:get("/apioak/admin/bete/services", admin.service.lists)

    router:get("/apioak/admin/bete/services/{service_key}", admin.service.detail)

    router:delete("/apioak/admin/bete/services/{service_key}", admin.service.deleted)

    -- New Router Related APIs
    router:post("/apioak/admin/bete/routers", admin.router.created)

    router:put("/apioak/admin/bete/routers/{router_key}", admin.router.updated)

    router:get("/apioak/admin/bete/routers", admin.router.lists)

    router:get("/apioak/admin/bete/routers/{router_key}", admin.router.detail)

    router:delete("/apioak/admin/bete/routers/{router_key}", admin.router.deleted)

    -- New Plugins Related APIs
    router:post("/apioak/admin/bete/plugins", admin.plugin.created)

    router:put("/apioak/admin/bete/plugins/{plugin_key}", admin.plugin.updated)

    router:get("/apioak/admin/bete/plugins", admin.plugin.lists)

    router:get("/apioak/admin/bete/plugins/{plugin_key}", admin.plugin.detail)

    router:delete("/apioak/admin/bete/plugins/{plugin_key}", admin.plugin.deleted)

end

function _M.routers()
    return router
end

return _M
