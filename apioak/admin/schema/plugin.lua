local common = require "apioak.admin.schema.common"

local _M = {}

_M.created = {
    type       = "object",
    properties = {
        name   = common.name,
        key    = {
            type      = "string",
            minLength = 3,
            maxLength = 35,
            pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
            enum      = {
                "waf"
            }
        },
        config = {
            type = "object",
        },
    },
    required   = { "name", "key", "config" }
}

_M.updated = {
    type       = "object",
    properties = {
        plugin_key = common.param_key,
        name       = common.name,
        config     = {
            type = "object",
        },
    },
    required   = { "plugin_key" }
}

_M.detail = {
    type       = "object",
    properties = {
        plugin_key = common.param_key
    },
    required   = { "plugin_key" }
}

_M.deleted = {
    type       = "object",
    properties = {
        plugin_key = common.param_key
    },
    required   = { "plugin_key" }
}

return _M
