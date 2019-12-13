local type        = type
local pairs       = pairs
local tostring    = tostring
local clear_tab   = require("table.clear")
local json_decode = require("cjson.safe").decode
local json_encode = require("cjson.safe").encode
local cached_tab  = {}

local _M = {}

local function serialise_obj(data)
    if type(data) == "function" or type(data) == "userdata"
            or type(data) == "cdata"
            or type(data) == "table" then
        return tostring(data)
    end

    return data
end

local function tab_clone_with_serialise(data)
    if type(data) ~= "table" then
        return serialise_obj(data)
    end

    local t = {}
    for k, v in pairs(data) do
        if type(v) == "table" then
            if cached_tab[v] then
                t[serialise_obj(k)] = tostring(v)
            else
                cached_tab[v] = true
                t[serialise_obj(k)] = tab_clone_with_serialise(v)
            end

        else
            t[serialise_obj(k)] = serialise_obj(v)
        end
    end

    return t
end

_M.decode = json_decode

_M.encode = function(data, force)
    if force then
        clear_tab(cached_tab)
        data = tab_clone_with_serialise(data)
    end
    return json_encode(data)
end

return _M
