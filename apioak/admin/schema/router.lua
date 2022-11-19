local router = require "apioak.admin.dao.router"
local common = require "apioak.admin.schema.common"

local _M = {}

local paths = {
    type = "array",
    minItems = 1,
    uniqueItems = true,
    items = {
        type = "string",
        pattern = "^\\/\\*?[0-9a-zA-Z-.=?_*/{}]+$"
    }
}

local headers = {
    type = "object"
}

_M.created = {
    type = "object",
    properties = {
        name = common.name,
        methods = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = {
                    router.METHODS_ALL,
                    router.METHODS_GET,
                    router.METHODS_POST,
                    router.METHODS_PUT,
                    router.METHODS_DELETE,
                    router.PATH
                }
            },
            default = { router.METHODS_ALL }
        },
        paths = paths,
        headers = headers,
        service = common.items_object_id_or_name,
        plugins = common.items_array_id_or_name,
        upstream = common.items_object_id_or_name,
        enabled = {
            type = "boolean",
            default = true
        }
    },
    required = { "name", "paths", "service" }
}

_M.updated = {
    type = "object",
    properties = {
        router_key = common.param_key,
        methods = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = {
                    router.METHODS_ALL,
                    router.METHODS_GET,
                    router.METHODS_POST,
                    router.METHODS_PUT,
                    router.METHODS_DELETE,
                    router.PATH
                }
            }
        },
        paths = paths,
        headers = headers,
        service = common.items_object_id_or_name,
        plugins = common.items_array_id_or_name,
        upstream = common.items_object_id_or_name,
        enabled = {
            type = "boolean",
        }
    },
    required = { "router_key" }
}

_M.detail = {
    type = "object",
    properties = {
        router_key = common.items_object_id_or_name
    },
    required = { "router_key"}
}

_M.deleted = {
    type = "object",
    properties = {
        router_key = common.items_object_id_or_name
    },
    required = { "router_key"}
}

return _M
