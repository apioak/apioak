local pdk  = require("apioak.pdk")
local json = require("cjson.safe")
local _M = {}

function _M.get_kv_id(prefix, name)

    local d, err = pdk.consul.instance:get_key(prefix .. name)

    if err then
        return ""
    end

    if type(d.body) ~= "table" then
        return ""
    end

    if not d.body[1].Value then
        return ""
    end

    local r = json.decode(d.body[1].Value)

    if not r.id then
        return ""
    end

    return r.id

end



return _M
