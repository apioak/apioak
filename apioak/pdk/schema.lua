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
        name = {
            type = 'string',
            minLength = 1,
            maxLength = 300
        },
        path = {
            type = 'string',
            minLength = 1,
            maxLength = 200
        },
        method = {
            type = "string",
            enum = { "GET", "POST", "PUT", "DELETE", "HEAD" }
        },
        enable_cors = {
            type = "boolean",
            enum = { true, false }
        },
        desc = {
            type = "string"
        },
        request_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 300
                    },
                    position = {
                        type = "string",
                        enum = { "Header", "Path", "Query" }
                    },
                    type = {
                        type = "string",
                        enum = { "string", "int", "long", "float", "double", "boolean" }
                    },
                    default_val = {
                        type = "string"
                    },
                    require = {
                        type = "boolean",
                        enum = { true, false }
                    },
                    desc = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    }
                }
            }
        },
        service_path = {
            type = 'string',
            minLength = 1,
            maxLength = 200
        },
        service_method = {
            type = "string",
            enum = { "GET", "POST", "PUT", "DELETE", "HEAD" }
        },
        timeout = {
            type = "number",
            minimum = 1,
            exclusiveMaximum = 181
        },
        service_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    service_name = {
                        type = "string",
                        minLength = 1,
                        maxLength = 300
                    },
                    service_position = {
                        type = "string",
                        enum = { "Header", "Path", "Query" }
                    },
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 300
                    },
                    position = {
                        type = "string",
                        enum = { "Header", "Path", "Query" }
                    },
                    type = {
                        type = "string",
                        enum = { "string", "int", "long", "float", "double", "boolean" }
                    },
                    desc = {
                        type = "string"
                    }
                }
            }
        },
        constant_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 300
                    },
                    position = {
                        type = "string",
                        enum = { "Header", "Path", "Query" }
                    },
                    value = {
                        type = "string",
                    },
                    desc = {
                        type = "string",
                    }
                }
            }
        },
        response_type = {
            type = "string",
            enum = { "JSON", "HTML", "TEXT", "XML", "BINARY" }
        },
        response_success = {
            type = "string",
        },
        response_fail = {
            type = "string",
        },
        response_error_codes = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    code = {
                        type = "number",
                    },
                    msg = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    },
                    desc = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    }
                }
            }
        }
    },
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
        },
        required = { "host", "type", "nodes" }
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
            minLength = 0,
            maxLength = 50
        },
        upstreams = {
            type = "object",
            minItems = 1,
            properties = {
                prod = service_upstreams,
                beta = service_upstreams,
                dev = service_upstreams
            },
        }
    },
    required = { "name", "prefix", "upstreams" },
}

local plugin = {
    type = "object",
    properties = {
        key = {
            type = "string",
        },
        config = {
            type = "object"
        },
    },
    required = { "key" }
}

_M.plugin = plugin

_M.service = service

_M.router = router

function _M.check(schema, json)
    local validator = jsonschema.generate_validator(schema)
    return validator(json)
end

return _M
