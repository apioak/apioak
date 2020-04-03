local r3route = require("resty.r3")
local admin   = require("apioak.admin")
local router

local _M = {}

function _M.init_worker()

    router = r3route.new()

    -- Common Service Related APIs
    router:insert_route("/apioak/admin/plugins", admin.common.plugins,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/users", admin.common.users,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/members", admin.common.members,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/projects", admin.common.projects,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/routers", admin.common.routers,
            { method = { "GET" } })


    -- Account Related APIs
    router:insert_route("/apioak/admin/account/register", admin.account.register,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/account/login", admin.account.login,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/account/logout", admin.account.logout,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/account/status", admin.account.status,
            { method = { "GET" } })


    -- Project Related APIs
    router:insert_route("/apioak/admin/project", admin.project.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}", admin.project.updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/project/{project_id}", admin.project.selected,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}", admin.project.deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/project/{project_id}/routers", admin.project.routers,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugins", admin.project.plugins,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin", admin.project.plugin_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.project.plugin_updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.project.plugin_deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/project/{project_id}/members", admin.project.members,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/member", admin.project.member_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}/member/{user_id}", admin.project.member_deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/project/{project_id}/member/{user_id}", admin.project.member_updated,
            { method = { "PUT" } })


    -- Router Related APIs
    router:insert_route("/apioak/admin/router", admin.router.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}", admin.router.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{router_id}", admin.router.updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}", admin.router.deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugins", admin.router.plugins,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin", admin.router.plugin_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.router.plugin_updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.router.plugin_deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{router_id}/env/{env}", admin.router.env_push,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}/env/{env}", admin.router.env_pull,
            { method = { "DELETE" } })


    -- User Manager API
    router:insert_route("/apioak/admin/user", admin.user.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/user/{user_id}", admin.user.deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/user/{user_id}/password", admin.user.password,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/user/{user_id}/enable", admin.user.enable,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/user/{user_id}/disable", admin.user.disable,
            { method = { "PUT" } })


    router:compile()
end

function _M.routers()
    return router
end

return _M
