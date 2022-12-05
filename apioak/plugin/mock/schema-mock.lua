local pdk = require("apioak.pdk")

local _M = {}

local response_type_enum = {
    pdk.const.CONTENT_TYPE_JSON,
    pdk.const.CONTENT_TYPE_HTML,
    pdk.const.CONTENT_TYPE_XML
}

_M.schema = {
    type       = "object",
    properties = {
        response_type = {
            type      = "string",
            minLength = 1,
            maxLength = 32,
            enum      = response_type_enum
        },
        http_code     = {
            type    = "number",
            minimum = 100,
            maximum = 599
        },
        http_body     = {
            type      = "string",
            minLength = 1
        },
        http_headers  = {
            type = "object"
        }
    },
    required   = { "response_type", "http_code", "http_body" }
}

return _M