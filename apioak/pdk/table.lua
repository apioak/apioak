local ipairs = ipairs

local _M = {}

_M.insert = table.insert

_M.concat = table.concat

_M.clear = table.clear

_M.clone = table.clone

_M.has = function(val, tab)
    for _, v in ipairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end

return _M
