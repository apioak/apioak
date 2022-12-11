local pdk    = require("apioak.pdk")
local common = require "apioak.admin.schema.common"

local _M = {}

local paths = {
    type        = "array",
    minItems    = 1,
    uniqueItems = true,
    items       = {
        type    = "string",
        pattern = "^\\/\\*?[0-9a-zA-Z-.=?_*/{}]+$"
    }
}

local headers = {
    type = "object"
}

local methods = {
    type        = "array",
    minItems    = 1,
    uniqueItems = true,
    items       = {
        type = "string",
        enum = pdk.const.ALL_METHODS_ALL
    }
}

local enabled = {
    type = "boolean",
}

_M.created = {
    type       = "object",
    properties = {
        name     = common.name,
        methods  = {
            type        = "array",
            minItems    = 1,
            uniqueItems = true,
            items       = {
                type = "string",
                enum = pdk.const.ALL_METHODS_ALL
            },
            default     = { pdk.const.METHODS_ALL }
        },
        paths    = paths,
        headers  = headers,
        service  = common.items_object_id_or_name,
        plugins  = common.items_array_id_or_name_or_null,
        upstream = common.items_object_id_or_name_or_null,
        enabled  = {
            type    = "boolean",
            default = true
        }
    },
    required   = { "name", "paths", "service" }
}

_M.updated = {
    type       = "object",
    properties = {
        router_key = common.param_key,
        methods    = methods,
        paths      = paths,
        headers    = headers,
        service    = common.items_object_id_or_name,
        plugins    = common.items_array_id_or_name_or_null,
        upstream   = common.items_object_id_or_name_or_null,
        enabled    = enabled
    },
    required   = { "router_key" }
}

_M.detail = {
    type       = "object",
    properties = {
        router_key = common.param_key
    },
    required   = { "router_key" }
}

_M.deleted = {
    type       = "object",
    properties = {
        router_key = common.param_key
    },
    required   = { "router_key" }
}

_M.router_data = {
    type       = "object",
    properties = {
        id       = common.id,
        name     = common.name,
        methods  = methods,
        paths    = paths,
        headers  = headers,
        service  = common.items_object_id,
        plugins  = common.items_array_id,
        upstream = {
            type = "object"
        },
        enabled  = enabled
    },
    required   = { "id", "name", "methods", "paths", "headers", "service", "plugins", "upstream", "enabled" }
}

return _M
