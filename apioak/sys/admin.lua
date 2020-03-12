local r3route = require("resty.r3")
local admin   = require("apioak.admin")
local router

local _M = {}

function _M.init_worker()

    router = r3route.new()

    -- Common Service Related APIs
    router:insert_route("/apioak/admin/plugins", admin.plugin.plugin_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/users", admin.user.list,
            { method = { "GET" } })


    -- Project Related APIs
    router:insert_route("/apioak/admin/projects", admin.project.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project", admin.project.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}", admin.project.updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/project/{project_id}", admin.project.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}", admin.project.deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugins", admin.plugin.project_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin", admin.plugin.project_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.plugin.project_updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.plugin.project_deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/project/{project_id}/routers", admin.router.list,
            { method = { "GET" } })

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

    router:insert_route("/apioak/admin/router/{router_id}/plugins", admin.plugin.router_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin", admin.plugin.router_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.plugin.router_updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.plugin.router_deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{router_id}/env/{env}", admin.router.env_push,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}/env/{env}", admin.router.env_pull,
            { method = { "DELETE" } })


    -- Account Manager API
    router:insert_route("/apioak/admin/account/register", admin.user.register,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/account/login", admin.user.login,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/account/logout", admin.user.logout,
            { method = { "GET" } })

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
