local type       = type
local ngx_shared = ngx.shared
local cJson      = require("cjson.safe")

local function new(block)

    local _SHARED = {}


    function _SHARED._valid(key)
        if not ngx_shared[block] then
            error("[pdk.shared] dict [" .. block .. "] invalid")
        end

        if not key and type(key) ~= "string" then
            error("[pdk.shared] key [" .. key .. "] invalid")
        end
    end


    function _SHARED.get(key)

        _SHARED._valid(key)

        local response = ngx_shared[block]:get(key)

        if response then
            response = cJson.decode(response)
        end

        return response
    end


    function _SHARED.set(key, value, ttl)

        _SHARED._valid(key)

        ttl = ttl or 0

        if type(value) == "table" then
            value = cJson.encode(value)
        end

        return ngx_shared[block]:set(key, value, ttl)
    end


    return _SHARED
end

return {
    new = new
}
