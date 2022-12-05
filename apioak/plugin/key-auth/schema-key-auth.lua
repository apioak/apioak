local _M = {}

_M.schema = {
    type       = "object",
    properties = {
        secret = {
            type      = "string",
            minLength = 10,
            maxLength = 32,
        }
    },
    required   = { "secret" }
}

return _M

