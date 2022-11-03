local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type      = "string",
            minLength = 3,
            maxLength = 35,
            pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
        },
        snis = {
            type     = "array",
            minItems = 1,
            items    = {
                type      = "string",
                minLength = 3,
                maxLength = 35,
                pattern   = "^(?=^.{3,255}$)[a-zA-Z0-9-*-.][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$",
            }
        },
        cert = {
            type      = "string",
            pattern   = "^\\*?[0-9a-zA-Z-_.|/+=]+$",
        },
        key = {
            type      = "string",
            pattern   = "^\\*?[0-9a-zA-Z-_.|/+=]+$",
        }
    },
    required   = { "name", "snis", "cert", "key" }
}

return _M