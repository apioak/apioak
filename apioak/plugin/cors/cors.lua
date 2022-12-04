local pdk = require("apioak.pdk")

local _M = {}

function _M.header_filter(oak_ctx, plugin_config)

    pdk.log.error("*************[",
                  pdk.json.encode(oak_ctx, true), "]*********[",
                  pdk.json.encode(plugin_config, true), "]*******************")

end

return _M