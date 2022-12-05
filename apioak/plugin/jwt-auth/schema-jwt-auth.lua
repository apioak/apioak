local _M = {}

_M.schema = {
    type       = "object",
    properties = {
        jwt_key = {
            type      = "string",
            minLength = 10,
            maxLength = 32,
        }
    },
    required   = { "jwt_key" }
}

return _M