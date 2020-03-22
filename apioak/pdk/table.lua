local pairs  = pairs
local ipairs = ipairs

local _M = {}

_M.insert = table.insert

_M.concat = table.concat

_M.clear  = table.clear

_M.remove = table.remove

_M.new    = table.new

_M.has = function(val, tab)
    for _, v in ipairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end

_M.del = function(tab, key)
    for tab_key, _ in pairs(tab) do
        if tab_key == key then
            tab[tab_key] = nil
        end
    end
    return tab
end

return _M
