local upstream = require "apioak.admin.dao.upstream"
local common   = require "apioak.admin.schema.common"

local _M = {}

_M.created = {
    type       = "object",
    properties = {
        name            = common.name,
        algorithm       = {
            type    = "string",
            default = upstream.DEFAULT_ALGORITHM,
            enum    = { upstream.DEFAULT_ALGORITHM }
        },
        nodes           = common.items_array_id_or_name,
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

_M.updated = {
    type       = "object",
    properties = {
        upstream_key    = common.param_key,
        name            = common.name,
        algorithm       = {
            type = "string",
            enum = { upstream.DEFAULT_ALGORITHM }
        },
        nodes           = common.items_array_id_or_name,
        connect_timeout = {
            type    = "number",
            minimum = 0,
            maximum = 3600000,
        },
        write_timeout   = {
            type    = "number",
            minimum = 0,
            maximum = 3600000,
        },
        read_timeout    = {
            type    = "number",
            minimum = 0,
            maximum = 3600000,
        }
    },
    required   = { "upstream_key" }
}

return _M