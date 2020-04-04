local ngx           = ngx
local type          = type
local cJson         = require("cjson.safe")
local apioak_shared = ngx.shared.apioak

local _M = {}

function _M.set(key, value, ttl)
    ttl = ttl or 0
    if type(value) == "table" then
        value = cJson.encode(value)
    end
    return apioak_shared:set(key, value, ttl)
end

function _M.get(key)
    local response = apioak_shared:get(key)
    if response then
        return cJson.decode(response), nil
    else
        return nil, "\"key\" value not found"
    end
end

return _M
