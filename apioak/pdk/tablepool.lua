local tablepool = require("tablepool")

local _M = {}

_M.fetch   = tablepool.fetch

_M.release = tablepool.release

return _M
