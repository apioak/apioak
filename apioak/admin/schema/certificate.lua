local common = require "apioak.admin.schema.common"

local _M = {}

local cert_key = {
    type      = "string",
    minLength = 128,
    maxLength = 64 * 1024
}

local snis = {
    type        = "array",
    uniqueItems = true,
    minItems    = 1,
    items       = {
        type      = "string",
        minLength = 1,
        maxLength = 35,
    }
}

_M.created = {
    type       = "object",
    properties = {
        name = common.name,
        snis = snis,
        cert = cert_key,
        key  = cert_key
    },
    required   = { "name", "snis", "cert", "key" }
}

_M.updated = {
    type       = "object",
    properties = {
        certificate_key = common.param_key,
        name            = common.name,
        snis            = snis,
        cert            = cert_key,
        key             = cert_key
    },
    required   = { "certificate_key" }
}

_M.sync_data_certificate = {
    type       = "object",
    properties = {
        snis = snis,
        cert = cert_key,
        key  = cert_key
    },
    required   = { "snis", "cert", "key" }
}

return _M