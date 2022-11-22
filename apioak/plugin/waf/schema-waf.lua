local _M = {}

_M.config = {
    type = "object",
    properties = {
        waf_config = {
            type = "string"
        }
    },
    required = { "waf_config" }
}

return _M

