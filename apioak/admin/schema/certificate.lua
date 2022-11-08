local _M = {}

_M.created = {
    type       = "object",
    properties = {
        name = {
            type      = "string",
            minLength = 3,
            maxLength = 35,
            pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
        },
        snis = {
            type        = "array",
            minItems    = 1,
            uniqueItems = true,
            items       = {
                type      = "string",
                minLength = 3,
                maxLength = 35,
                pattern   = "^(?=^.{3,255}$)[a-zA-Z0-9-*-.][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$",
            }
        },
        cert = {
            type      = "string",
            minLength = 128,
            maxLength = 64 * 1024,
            pattern   = "^\\*?[0-9a-zA-Z-_.|/+=]+$",
        },
        key  = {
            type      = "string",
            minLength = 128,
            maxLength = 64 * 1024,
            pattern   = "^\\*?[0-9a-zA-Z-_.|/+=]+$",
        }
    },
    required   = { "name", "snis", "cert", "key" }
}

_M.updated = {
    type       = "object",
    properties = {
        certificate_key = {
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
        },
        name            = {
            type      = "string",
            minLength = 3,
            maxLength = 35,
            pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
        },
        snis            = {
            type        = "array",
            uniqueItems = true,
            minItems    = 1,
            items       = {
                type      = "string",
                minLength = 3,
                maxLength = 35,
                pattern   = "^(?=^.{3,255}$)[a-zA-Z0-9-*-.][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$",
            }
        },
        cert            = {
            type    = "string",
            pattern = "^\\*?[0-9a-zA-Z-_.|/+=]+$",
        },
        key             = {
            type    = "string",
            pattern = "^\\*?[0-9a-zA-Z-_.|/+=]+$",
        }
    },
    required   = { "certificate_key" }
}

return _M