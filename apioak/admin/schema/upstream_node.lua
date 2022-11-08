local _M = {}

_M.created = {
    type       = "object",
    properties = {
        name    = {
            type      = "string",
            minLength = 3,
            maxLength = 35,
            pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
        },
        address = {
            type  = "string",
            anyOf = {
                {
                    format = "ipv4"
                },
                {
                    format = "ipv6"
                }
            }
        },
        port    = {
            type    = "number",
            minimum = 1,
            maximum = 65535
        },
        weight  = {
            type    = "number",
            minimum = 1,
            maximum = 100,
            default = 1
        },
        health  = {
            type = "string",
            enum = { "HEALTH", "UNHEALTH" }
        },
        check   = {
            type       = "object",
            properties = {
                tcp      = {
                    type      = "string",
                    default   = "",
                    minLength = 3,
                },
                method   = {
                    type    = "string",
                    default = "",
                    enum    = { "GET", "POST", "HEADER" }
                },
                http     = {
                    type      = "string",
                    minLength = 3,
                    default   = "",
                    pattern   = "(http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+" ..
                            "([\\w\\-\\.,@?^=%&:/~\\+#]*[\\w\\-\\@?^=%&/~\\+#])?"
                },
                interval = {
                    type    = "number",
                    minimum = 0,
                    maximum = 86400,
                    default = 5
                },
                timeout  = {
                    type    = "number",
                    minimum = 0,
                    maximum = 86400,
                    default = 1
                },
                enabled  = {
                    type    = "boolean",
                    default = false,
                },
            },
        },
    },
    required   = { "name", "address", "port", "check" }
}

return _M