local _M = {}

_M.schema = {
    type       = "object",
    properties = {
        count       = {
            type    = "integer",
            minimum = 1,
            maximum = 100000000,
        },
        time_window = {
            type    = "integer",
            minimum = 1,
            maximum = 86400,
        }
    },
    required   = { "count", "time_window" }
}

return _M