local consul = require("apioak.pdk.consul")
local uuid   = require("resty.jit-uuid")

local _M = {}

function _M.init_worker()

    uuid.seed()

    consul.init()
end

return _M
