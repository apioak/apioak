local upstream = require "apioak.admin.dao.upstream"

local _M   = {}

_M.created = {
    type       = "object",
    properties = {
        name            = {
            type      = "string",
            minLength = 3,
            maxLength = 50,
            pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
        },
        algorithm       = {
            type    = "string",
            default = upstream.DEFAULT_ALGORITHM,
            enum    = { upstream.DEFAULT_ALGORITHM }
        },
        nodes           = {
            type     = "array",
            minItems = 1,
            items    = {
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
                        maxLength = 50,
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
        },
        connect_timeout = {
            type    = "number",
            minimum = 0,
            maximum = 3600000,
            default = upstream.DEFAULT_TIMEOUT
        },
        write_timeout   = {
            type    = "number",
            minimum = 0,
            maximum = 3600000,
            default = upstream.DEFAULT_TIMEOUT
        },
        read_timeout    = {
            type    = "number",
            minimum = 0,
            maximum = 3600000,
            default = upstream.DEFAULT_TIMEOUT
        }
    },
    required   = { "name", "nodes" }
}

return _M