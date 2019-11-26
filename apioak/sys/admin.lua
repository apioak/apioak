local r3route = require("resty.r3")
local _M = {}
local router

local resources = {
    routes    = require("apioak.admin.routes"),
    upstreams = require("apioak.admin.upstreams"),
    plugins   = require("apioak.admin.plugins"),
}

local router_handle = function()
    
end

local router_config = {
    {
        path = [[/admin/routes/{:\w+}"]],
        method = {"GET", "PUT", "POST", "DELETE", "PATCH"},
        handler = router_handle
    },
    {
        path = [[/admin/routes/{:\w+}"]],
        method = {"GET", "PUT", "POST", "DELETE", "PATCH"},
        handler = router_handle
    },
    {
        path = [[/admin/routes/{:\w+}"]],
        method = {"GET", "PUT", "POST", "DELETE", "PATCH"},
        handler = router_handle
    },
}

function _M.init_worker()
    local r3 = r3route.new(router_config)
    r3:compile()
    router = r3
end

function _M.match(uri, method)
    router:dispatch(uri, method)
end

return _M
