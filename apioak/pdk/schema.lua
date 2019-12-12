local jsonschema = require 'jsonschema'

local _M = {}

local ipv4_pattern = "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$"

local host_pattern = "^\\*?[0-9a-zA-Z-.]+$"

local id_define = {
    anyOf = {
        {
            type = "string", minLength = 1, maxLength = 32,
            pattern = [[^[0-9]+$]]
        },
        {
            type = "number",
            minimum = 1
        }
    }
}

local router = {
    type = 'object',
    properties = {
        id = { type = 'number' },
        uri = { type = 'string', minLength = 1, maxLength = 4096 },
        method = {
            type = "string",
            enum = { "GET", "POST", "PUT", "DELETE" }
        },
        required = { "uri" },
    },
}

local service_plugins = {

}

local service_upstreams = {
    type = "object",
    properties = {
        host = {
            type = "string",
            pattern = host_pattern
        },
        type = {
            type = "string",
            enum = { "chash", "roundrobin" }
        },
        nodes = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    ip = {
                        type = "string",
                        pattern = ipv4_pattern
                    },
                    port = {
                        type = "number",
                        minimum = 1,
                        maximum = 65535,
                    },
                    weight = {
                        type = "number",
                        minimum = 0,
                        maximum = 100,
                    },
                },
                required = { "ip", "port", "weight" }
            }
        }
    }
}

local service = {
    type = "object",
    properties = {
        id = id_define,
        name = {
            type = 'string',
            minLength = 1,
            maxLength = 20
        },
        prefix = {
            type = 'string',
            minLength = 1,
            maxLength = 20
        },
        desc = {
            type = 'string',
            minLength = 1,
            maxLength = 50
        },
        upstreams = {
            type = "object",
            minItems = 1,
            properties = {
                prod = service_upstreams,
                beta = service_upstreams,
                dev = service_upstreams
            }
        }
    },
    required = { "name", "prefix", "upstreams" },
}

_M.service = service

_M.router = router

function _M.check(schema, json)
    local validator = jsonschema.generate_validator(schema)
    return validator(json)
end

return _M
