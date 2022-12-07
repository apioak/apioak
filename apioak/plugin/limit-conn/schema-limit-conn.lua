local _M = {}

_M.schema = {
    type       = "object",
    properties = {
        rate               = {
            type    = "number",
            minimum = 1,
            maximum = 100000,
        },
        burst              = {
            type    = "number",
            minimum = 1,
            maximum = 50000,
        },
        default_conn_delay = {
            type    = "number",
            minimum = 1,
            maximum = 60,
        }
    },
    required   = { "rate", "burst", "default_conn_delay" }
}

return _M