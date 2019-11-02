local setmetatable = setmetatable

local Origin = 'Origin'
local AccessControlAllowOrigin = 'Access-Control-Allow-Origin'
local AccessControlMaxAge = 'Access-Control-Max-Age'
local AccessControlAllowCredentials = 'Access-Control-Allow-Credentials'
local AccessControlAllowMethods = 'Access-Control-Allow-Methods'
local AccessControlAllowHeaders = 'Access-Control-Allow-Headers'

local allow_hosts = {}
local allow_headers = {}
local allow_methods = {}
local expose_headers = {}
local max_age = 3600
local allow_credentials = true

local _M = {}

function _M:new()
    local instance = {}
    setmetatable(instance, {
        __index = self
    })
    return instance
end

function _M:allow_host(host)
    allow_hosts[#allow_hosts + 1] = host
end

function _M:allow_method(method)
    allow_methods[#allow_methods + 1] = method
end

function _M:allow_header(header)
    allow_headers[#allow_headers + 1] = header
end

function _M:expose_header(header)
    expose_headers[#expose_headers + 1] = header
end

function _M:max_age(age)
    max_age = age
end

function _M:allow_credentials(credentials)
    allow_credentials = credentials
end

function _M:run()
    local origin = ngx.req.get_headers()[Origin]
    if not origin then
        return
    end

    local from, _, _ = ngx.re.find(origin, [==[.*kmf\.com]==], "jo")
    if not from then
        return
    end

    ngx.header[AccessControlAllowOrigin] = origin
    ngx.header[AccessControlMaxAge] = max_age
    ngx.header[AccessControlAllowHeaders] = 'Origin, Accept, Authorization, Content-Type, K-Platform,K-Product-Line,K-Passport-Id,K-Version,X-CSRF-TOKEN,K-Mock-User'
    ngx.header[AccessControlAllowMethods] = 'GET,HEAD,PUT,PATCH,POST,DELETE'

    if allow_credentials == true then
        ngx.header[AccessControlAllowCredentials] = "true"
    else
        ngx.header[AccessControlAllowCredentials] = "false"
    end
end

return _M
