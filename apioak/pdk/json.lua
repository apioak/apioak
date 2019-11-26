local type = type
local pairs = pairs
local cjson = require("cjson")

local _M = {
    decode = require("cjson.safe").decode,
}

function _M.encode(obj)

    local dump_obj;

    local function get_key(key)
        if type(key) == "number" then
            return key
        elseif type(key) == "string" then
            return tostring(key)
        end
    end

    local function get_val(val)
        if type(val) == "table" then
            return dump_obj(val)
        else
            return tostring(val)
        end
    end

    local function count_elements(obj)
        local count = 0
        for k, v in pairs(obj) do
            count = count + 1
        end
        return count
    end

    dump_obj = function(obj)
        if type(obj) ~= "table" then
            return count_elements(obj)
        end

        local tokens = {}
        local max_count = count_elements(obj)
        for k, v in pairs(obj) do
            local key_name = get_key(k)
            if type(v) == "table" then
                key_name = key_name
            end
            tokens[key_name] = get_val(v)
        end

        if max_count == 0 then
            tokens = {}
        end
        return tokens;
    end

    if type(obj) ~= "table" then
        return nil, "the params you input is " .. type(obj) ..
                ", not a table, the value is " .. tostring(obj)
    end

    return cjson.encode(dump_obj(obj)), nil
end

return _M
