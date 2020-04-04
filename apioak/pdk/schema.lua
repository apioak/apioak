local jsonschema = require 'jsonschema'

local _M = {}

function _M.check(schema, json)
    local validator = jsonschema.generate_validator(schema)
    return validator(json)
end

return _M
