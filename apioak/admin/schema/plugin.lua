local pdk = require("apioak.pdk")
local common = require "apioak.admin.schema.common"

local _M = {}

local key = {
    type = "string",
    enum = pdk.const.PLUGINS()
}

local config = {
    type = "object",
}

_M.created = {
    type       = "object",
    properties = {
        name   = common.name,
        key    = key,
        config = config,
    },
    required   = { "name", "key", "config" }
}

_M.updated = {
    type       = "object",
    properties = {
        plugin_key = common.param_key,
        name       = common.name,
        config     = config,
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

_M.plugin_data = {
    type       = "object",
    properties = {
        id     = common.id,
        name   = common.name,
        key    = key,
        config = config,
    },
    required   = { "id", "name", "key", "config" }
}

return _M
