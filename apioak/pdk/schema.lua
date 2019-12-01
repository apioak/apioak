local jsonschema = require 'jsonschema'

local _M = {}

local routes = {
    type = 'object',
    properties = {
        id = { type = 'number' },
        uri = { type = 'string', minLength = 1, maxLength = 4096 },
        required = { "uri" },
    },
}

_M.routes = routes

function _M.check(schema, json)
    local validator = jsonschema.generate_validator(schema)
    return validator(json)
end

return _M
