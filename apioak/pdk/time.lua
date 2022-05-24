local ngx = ngx

local _M = {}

_M.time      = os.time

_M.date      = os.date

_M.strtotime = function(date)
    if not date or date == ngx.null then
        return 0, "params \"date\" invalid"
    end

    local _, _, year, month, day, hour, min, sec = string.find(date,
            "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
    if not year or not month or not day or not hour or not min or not sec then
        return 0, "params \"date\" invalid"
    end

    return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

return _M
