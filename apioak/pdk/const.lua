local config = require("apioak.sys.config")

local _M = {}

_M.LOCAL_IP            = "127.0.0.1"

_M.LOCAL_HOST          = "localhost"

_M.BALANCER_CHASH      = "CHASH"

_M.BALANCER_ROUNDROBIN = "ROUNDROBIN"

_M.ALL_BALANCERS       = {
    _M.BALANCER_ROUNDROBIN,
    _M.BALANCER_CHASH,
}

_M.UPSTREAM_DEFAULT_TIMEOUT = 5000

_M.ENVIRONMENT_PROD    = "PROD"

_M.ENVIRONMENT_BETA    = "BETA"

_M.ENVIRONMENT_TEST    = "TEST"

_M.REQUEST_API_ENV_KEY       = "APIOAK-API-ENV"

_M.REQUEST_ADMIN_TOKEN_KEY   = "APIOAK-ADMIN-TOKEN"

_M.RESPONSE_MOCK_REQUEST_KEY = "APIOAK-MOCK-REQUEST"

_M.REQUEST_PARAM_POS_QUERY  = "QUERY"

_M.REQUEST_PARAM_POS_PATH   = "PATH"

_M.REQUEST_PARAM_POS_HEADER = "HEADER"

_M.CONTENT_TYPE        = "Content-Type"

_M.CONTENT_TYPE_JSON   = "application/json"

_M.CONTENT_TYPE_HTML   = "text/html"

_M.CONTENT_TYPE_XML    = "text/xml"

_M.CONSUL_PRFX_SERVICES = "services"

_M.CONSUL_PRFX_ROUTERS = "routers"

_M.CONSUL_PRFX_PLUGINS = "plugins"

_M.CONSUL_PRFX_UPSTREAMS = "upstreams"

_M.CONSUL_PRFX_CERTIFICATES = "certificates"

_M.CONSUL_PRFX_UPSTREAM_NODES = "upstream_nodes"

_M.CONSUL_SYNC_UPDATE = "sync_update"

_M.METHODS_ALL    = "ALL"

_M.METHODS_GET    = "GET"

_M.METHODS_PUT    = "PUT"

_M.METHODS_POST   = "POST"

_M.METHODS_PATCH  = "PATCH"

_M.METHODS_DELETE = "DELETE"

_M.METHODS_OPTIONS = "OPTIONS"

_M.ALL_METHODS    = {
    _M.METHODS_GET,
    _M.METHODS_PUT,
    _M.METHODS_POST,
    _M.METHODS_PATCH,
    _M.METHODS_DELETE,
    _M.METHODS_OPTIONS,
}

_M.ALL_METHODS_ALL    = {
    _M.METHODS_ALL,
    _M.METHODS_GET,
    _M.METHODS_PUT,
    _M.METHODS_POST,
    _M.METHODS_PATCH,
    _M.METHODS_DELETE,
    _M.METHODS_OPTIONS,
}

_M.PLUGINS = function ()
    return config.query("plugins")
end

_M.DEFAULT_METHODS = function(methods)

    if (type(methods) ~= "table") or (#methods == 0) then
        return _M.ALL_METHODS
    end

    local all = false

    for i = 1, #methods do
        methods[i] = string.upper(methods[i])
        if methods[i] == _M.METHODS_ALL then
            all = true
        end
    end

    if all then
        return _M.ALL_METHODS
    end

    return methods
end

return _M
