local pdk = require("apioak.pdk")

local _M = {}

_M.cached_key = "services"

function _M.list()

end

function _M.list()

end

function _M.query(params)
    ngx.say("query: ", params.id)
end

function _M.create(params)
    ngx.say("create: ", params.id)
end

function _M.update(params)
    ngx.say("update: ", params.id)
end

function _M.delete(params)
    ngx.say("delete: ", params.id)
end

return _M
