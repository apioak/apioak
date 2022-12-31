local _M = {}

local methods_enum = {
    "*",
    "GET",
    "PUT",
    "POST",
    "HEAD",
    "PATCH",
    "TRACE",
    "DELETE",
    "OPTIONS",
    "CONNECT",
}

_M.schema_methods_enum = {
    type       = "object",
    properties = {
        method = {
            type = "string",
            enum = methods_enum
        }
    }
}

_M.schema = {
    type       = "object",
    properties = {
        allow_methods    = {
            type      = "string",
            minLength = 0,
            maxLength = 80,
            default   = "",
        },
        allow_origins    = {
            type      = "string",
            minLength = 0,
            maxLength = 80,
            default   = "",
        },
        allow_headers    = {
            type      = "string",
            minLength = 0,
            maxLength = 80,
            default   = "",
        },
        allow_credential = {
            type    = "boolean",
            default = false,
        },
        max_age          = {
            type    = "number",
            minimum = 0,
            maximum = 86400,
            default = 0,
        },
    }
}

return _M