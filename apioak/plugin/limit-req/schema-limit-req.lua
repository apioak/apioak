local _M = {}

_M.schema = {
    type       = "object",
    properties = {
        rate  = {
            type      = "integer",
            minLength = 1,
            minimum   = 1,
            maximum   = 100000,
        },
        burst = {
            type    = "integer",
            minimum = 0,
            maximum = 5000,
        }
    },
    required   = { "rate", "burst" }
}

return _M