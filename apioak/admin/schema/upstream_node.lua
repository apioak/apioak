local upstream_node = require "apioak.admin.dao.upstream_node"

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
            maximum = 65535,
            default = upstream_node.DEFAULT_PORT
        },
        weight  = {
            type    = "number",
            minimum = 1,
            maximum = 100,
            default = upstream_node.DEFAULT_WEIGHT
        },
        health  = {
            type = "string",
            enum = { upstream_node.DEFAULT_HEALTH, upstream_node.DEFAULT_UNHEALTH }
        },
        check   = {
            type       = "object",
            properties = {
                enabled  = {
                    type    = "boolean",
                    default = upstream_node.DEFAULT_ENABLED,
                },
                tcp      = {
                    type      = "string",
                    default   = nil,
                    minLength = 3,
                },
                method   = {
                    type    = "string",
                    default = nil,
                    enum    = { "GET", "POST", "HEADER" }
                },
                http     = {
                    type      = "string",
                    minLength = 3,
                    default   = nil,
                    pattern   = "(http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+" ..
                            "([\\w\\-\\.,@?^=%&:/~\\+#]*[\\w\\-\\@?^=%&/~\\+#])?"
                },
                interval = {
                    type    = "number",
                    minimum = 0,
                    maximum = 86400,
                    default = upstream_node.DEFAULT_INTERVAL
                },
                timeout  = {
                    type    = "number",
                    minimum = 0,
                    maximum = 86400,
                    default = upstream_node.DEFAULT_TIMEOUT
                }
            }
        }
    },
    required   = { "name", "address", "port", "check" }
}

_M.updated = {
    type       = "object",
    properties = {
        upstream_node_key    = {
            type  = "string",
            anyOf = {
                {
                    minLength = 3,
                    maxLength = 35,
                    pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
                },
                {
                    minLength = 36,
                    maxLength = 36,
                    pattern   = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
                }
            }
        },
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
            maximum = 65535,
        },
        weight  = {
            type    = "number",
            minimum = 1,
            maximum = 100,
        },
        health  = {
            type = "string",
            enum = { upstream_node.DEFAULT_HEALTH, upstream_node.DEFAULT_UNHEALTH }
        },
        check   = {
            type       = "object",
            properties = {
                enabled  = {
                    type    = "boolean",
                },
                tcp      = {
                    type      = "string",
                    minLength = 3,
                },
                method   = {
                    type    = "string",
                    enum    = { "GET", "POST", "HEADER" }
                },
                http     = {
                    type      = "string",
                    minLength = 3,
                    pattern   = "(http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+" ..
                            "([\\w\\-\\.,@?^=%&:/~\\+#]*[\\w\\-\\@?^=%&/~\\+#])?"
                },
                interval = {
                    type    = "number",
                    minimum = 0,
                    maximum = 86400,
                },
                timeout  = {
                    type    = "number",
                    minimum = 0,
                    maximum = 86400,
                }
            }
        }
    },
    required   = { "upstream_node_key" }
}

return _M