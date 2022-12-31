local ngx      = ngx
local plstring = require("pl.stringx")

local _M = {}

_M.format   = string.format

_M.lower    = string.lower

_M.upper    = string.upper

_M.find     = string.find

_M.len      = string.len

_M.char     = string.char

_M.split    = plstring.split

_M.replace  = plstring.replace

_M.md5      = ngx.md5

_M.null     = ngx.null

_M.tonumber = tonumber

_M.trim     = function(str)
    str = ngx.re.gsub(str, [[^\s+]], "", "mjo")
    str = ngx.re.gsub(str, [[\s+$]], "", "mjo")
    return str
end

-- 验证IPV4 or IPV6
function _M.parse_address(address)
    local address_obj
    if string.sub(address, 1, 1) == '[' then
        address_obj = plstring.split(address, ']:')
        return address_obj[1] .. ']', tonumber(address_obj[2])
    else
        address_obj = plstring.split(address, ':')
        return address_obj[1], tonumber(address_obj[2])
    end
end

return _M
