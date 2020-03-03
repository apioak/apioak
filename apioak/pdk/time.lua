local _M = {}

_M.time      = os.time

_M.date      = os.date

_M.strtotime = function(date_str)
    local _, _, year, month, day, hour, min, sec = string.find(date_str,
            "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    if not year or not month or not day or not hour or not min or not sec then
        return nil, "params \"date_str\" invalid"
    end
    return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

return _M
