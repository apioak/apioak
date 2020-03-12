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

return _M
