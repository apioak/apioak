local common = require "apioak.admin.schema.common"
local upstream_node = require "apioak.admin.dao.upstream_node"

local _M = {}

local address = {
    type  = "string",
    anyOf = {
        {
            format = "ipv4"
        },
        {
            format = "ipv6"
        }
    }
}

local method_enum = {
    "GET",
    "POST",
    "HEADER"
}

local http_pattern = "(http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&:/~\\+#]*[\\w\\-\\@?^=%&/~\\+#])?"

_M.created = {
    type       = "object",
    properties = {
        name    = common.name,
        address = address,
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
                    default = upstream_node.DEFAULT_ENABLED_FALSE,
                },
                tcp      = {
                    type      = "string",
                    default   = nil,
                    minLength = 3,
                },
                method   = {
                    type    = "string",
                    default = nil,
                    enum    = method_enum
                },
                http     = {
                    type      = "string",
                    minLength = 3,
                    default   = nil,
                    pattern   = http_pattern
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
        upstream_node_key = common.param_key,
        name              = common.name,
        address           = address,
        port              = {
            type    = "number",
            minimum = 1,
            maximum = 65535,
        },
        weight            = {
            type    = "number",
            minimum = 1,
            maximum = 100,
        },
        health            = {
            type = "string",
            enum = { upstream_node.DEFAULT_HEALTH, upstream_node.DEFAULT_UNHEALTH }
        },
        check             = {
            type       = "object",
            properties = {
                enabled  = {
                    type = "boolean",
                },
                tcp      = {
                    type      = "string",
                    minLength = 3,
                },
                method   = {
                    type = "string",
                    enum = method_enum
                },
                http     = {
                    type      = "string",
                    minLength = 3,
                    pattern   = http_pattern
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