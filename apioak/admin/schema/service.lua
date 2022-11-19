local service = require "apioak.admin.dao.service"

local _M = {}

local service_key = {
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
}

local name = {
    type = "string",
    minLength = 3,
    maxLength = 35,
    pattern = "^\\*?[0-9a-zA-Z-_.]+$"
}

local hosts = {
    type = "array",
    minItems = 1,
    uniqueItems = true,
    items = {
        type = "string",
        minLength = 3,
        pattern = "^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$"
    },
}

local plugins = {
    type = "array",
    uniqueItems = true,
    items       = {
        type       = "object",
        properties = {
            id   = {
                type      = "string",
                minLength = 36,
                maxLength = 36,
                pattern   = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
            },
            name = {
                type      = "string",
                minLength = 3,
                maxLength = 35,
                pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
            }
        },
        anyOf      = {
            {
                required = { "id" }
            },
            {
                required = { "name" }
            }
        }
    }
}

_M.created = {
    type = "object",
    properties = {
        name = name,
        protocols = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = { service.PROTOCOLS_HTTP, service.PROTOCOLS_HTTPS }
            },
            default = { service.PROTOCOLS_HTTP }
        },
        hosts = hosts,
        plugins = plugins,
        enabled = {
            type = "boolean",
            default = true
        }
    },
    required = { "name", "hosts" }
}

_M.updated = {
    type = "object",
    properties = {
        service_key = service_key,
        name = name,
        protocols = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = { service.PROTOCOLS_HTTP, service.PROTOCOLS_HTTPS }
            },
        },
        hosts = hosts,
        plugins = plugins,
        enabled = {
            type = "boolean"
        }
    },
    required = { "service_key"}
}

_M.detail = {
    type = "object",
    properties = {
        service_key = service_key
    },
    required = { "service_key"}
}

_M.deleted = {
    type = "object",
    properties = {
        service_key = service_key
    },
    required = { "service_key"}
}

return _M
