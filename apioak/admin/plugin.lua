local pdk = require("apioak.pdk")

local _M = {}

function _M.list()
    local result = {}
    local config_all = pdk.config.all()
    result.code = 200
    result.body = pdk.json.encode(config_all.plugins)
    pdk.response.exit(result)
end

return _M
