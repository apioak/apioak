--
-- Created by IntelliJ IDEA.
-- User: renyineng
-- Date: 17/11/6
-- Time: 下午6:04
-- To change this template use File | Settings | File Templates.
--
local kvstore = require "api.kvstore"
local audit = require "api.http.controller.audit"
local cjson = require "cjson"

local _M = {}

_M.url_route = {}
_M.mime_type = {}
_M.mime_type['.js'] = "application/x-javascript"
_M.mime_type['.css'] = "text/css"
_M.mime_type['.html'] = "text/html"

local base_uri = '/api'
function _M.filter()
    local method = ngx.req.get_method()
    local uri = ngx.var.uri
    if string.find(uri, base_uri) == 1 then
        local path = string.sub(uri, string.len(base_uri) + 1)
        for i, item in ipairs(_M.route_table) do
            local s = ngx.re.match(path, item['rules'] .. '$', "jo")
            if s ~= nil and method == item['method'] then
                s[0] = nil
                local params = s
                local func = item['handle'];
                ngx.say(cjson.encode(func(unpack(params))))
                ngx.exit(ngx.HTTP_OK)
            end
        end
    end
end

_M.route_table = {
    { ['method'] = "GET", ['auth'] = false, ["rules"] = "/kvstore/global/(.+)", ['handle'] = kvstore.global },
    { ['method'] = "POST", ['auth'] = false, ["rules"] = "/kvstore/global", ['handle'] = kvstore.global_update },
    { ['method'] = "GET", ['auth'] = false, ["rules"] = "/kvstore/(.+)/(.+)", ['handle'] = kvstore.view },
    { ['method'] = "POST", ['auth'] = false, ["rules"] = "/kvstore", ['handle'] = kvstore.update },
    -- APP接口
    { ['method'] = "GET", ['auth'] = false, ["rules"] = "/audit/projects/(.+)", ['handle'] = audit.index },
    { ['method'] = "POST", ['auth'] = false, ["rules"] = "/audits", ['handle'] = audit.update },
}

return _M
