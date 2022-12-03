local pdk    = require("apioak.pdk")
local common = require "apioak.admin.schema.common"

local _M = {}

local timeout_minimum = 1
local timeout_maximum = 600000

local algorithm = {
    type = "string",
    enum = { pdk.const.BALANCER_ROUNDROBIN, pdk.const.BALANCER_CHASH }
}

local connect_timeout = {
    type    = "number",
    minimum = timeout_minimum,
    maximum = timeout_maximum,
}

local write_timeout = {
    type    = "number",
    minimum = timeout_minimum,
    maximum = timeout_maximum,
}

local read_timeout = {
    type    = "number",
    minimum = timeout_minimum,
    maximum = timeout_maximum,
}

_M.created = {
    type       = "object",
    properties = {
        name            = common.name,
        algorithm       = {
            type    = "string",
            default = pdk.const.BALANCER_ROUNDROBIN,
            enum    = { pdk.const.BALANCER_ROUNDROBIN, pdk.const.BALANCER_CHASH }
        },
        nodes           = common.items_array_id_or_name,
        connect_timeout = {
            type    = "number",
            minimum = timeout_minimum,
            maximum = timeout_maximum,
            default = pdk.const.UPSTREAM_DEFAULT_TIMEOUT
        },
        write_timeout   = {
            type    = "number",
            minimum = timeout_minimum,
            maximum = timeout_maximum,
            default = pdk.const.UPSTREAM_DEFAULT_TIMEOUT
        },
        read_timeout    = {
            type    = "number",
            minimum = timeout_minimum,
            maximum = timeout_maximum,
            default = pdk.const.UPSTREAM_DEFAULT_TIMEOUT
        }
    },
    required   = { "name", "nodes" }
}

_M.updated = {
    type       = "object",
    properties = {
        upstream_key    = common.param_key,
        name            = common.name,
        algorithm       = algorithm,
        nodes           = common.items_array_id_or_name,
        connect_timeout = connect_timeout,
        write_timeout   = write_timeout,
        read_timeout    = read_timeout
    },
    required   = { "upstream_key" }
}

_M.upstream_data = {
    type       = "object",
    properties = {
        id              = common.id,
        name            = common.name,
        algorithm       = algorithm,
        nodes           = common.items_array_id_or_name,
        connect_timeout = connect_timeout,
        write_timeout   = write_timeout,
        read_timeout    = read_timeout
    },
    required   = { "id", "name", "algorithm", "nodes", "connect_timeout", "write_timeout", "read_timeout" }
}

return _M