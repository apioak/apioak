local r3route = require("resty.r3")
local admin   = require("apioak.admin")
local router

local _M = {}

function _M.init_worker()

    router = r3route.new()

    -- Plugin Manager URI
    router:insert_route("/apioak/admin/plugins", admin.plugin.plugin_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugins", admin.plugin.project_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin", admin.plugin.project_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.plugin.project_updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/project/{project_id}/plugin/{plugin_id}", admin.plugin.project_deleted,
            { method = { "DELETE" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugins", admin.plugin.router_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin", admin.plugin.router_created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.plugin.router_updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/router/{router_id}/plugin/{plugin_id}", admin.plugin.router_deleted,
            { method = { "DELETE" } })

    -- Group Manager URI
    router:insert_route("/apioak/admin/groups", admin.group.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/group", admin.group.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/group/{group_id}", admin.group.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/group/{group_id}", admin.group.updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/group/{group_id}", admin.group.deleted,
            { method = { "DELETE" } })

    -- Group User Manager URI
    router:insert_route("/apioak/admin/group/{group_id}/users", admin.group.user_list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/group/{group_id}/user", admin.group.user_create,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/group/{group_id}/user/{user_id}", admin.group.user_update,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/group/{group_id}/user/{user_id}", admin.group.user_delete,
            { method = { "DELETE" } })

    -- Group Project Manager URI
    router:insert_route("/apioak/admin/group/{group_id}/projects", admin.project.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/group/{group_id}/project", admin.project.create,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/group/{group_id}/project/{project_id}", admin.project.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/group/{group_id}/project/{project_id}", admin.project.update,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/group/{group_id}/project/{project_id}", admin.project.update,
            { method = { "DELETE" } })


    -- Project Router Manager URI
    router:insert_route("/apioak/admin/project/{project_id}/routers", admin.router.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/router", admin.router.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/project/{project_id}/router/{router_id}", admin.router.query,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/project/{project_id}/router/{router_id}", admin.router.updated,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/project/{project_id}/router/{router_id}", admin.router.deleted,
            { method = { "DELETE" } })

    -- Router Publish Manager URI
    router:insert_route("/apioak/admin/router/{router_id}/publish/{env}", admin.router.online,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/router/{router_id}/publish/{env}", admin.router.offline,
            { method = { "DELETE" } })

    -- Account Manager API
    router:insert_route("/apioak/admin/account/register", admin.user.register,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/account/login", admin.user.login,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/account/logout", admin.user.logout,
            { method = { "GET" } })

    -- User Manager API
    router:insert_route("/apioak/admin/users", admin.user.list,
            { method = { "GET" } })

    router:insert_route("/apioak/admin/user", admin.user.created,
            { method = { "POST" } })

    router:insert_route("/apioak/admin/user/{user_id}/password", admin.user.updated_password,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/user/{user_id}/status", admin.user.updated_status,
            { method = { "PUT" } })

    router:insert_route("/apioak/admin/user/{user_id}", admin.user.deleted,
            { method = { "DELETE" } })


    router:compile()
end

function _M.routers()
    return router
end

return _M
