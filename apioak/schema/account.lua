local _M = {}

_M.register = {
    type = "object",
    properties = {
        name = {
            type = 'string',
            minLength = 4,
            maxLength = 16,
        },
        password = {
            type = 'string',
            minLength = 6,
            maxLength = 20,
        },
        valid_password = {
            type = 'string',
            minLength = 6,
            maxLength = 20,
        },
        email = {
            type = 'string',
            pattern = "^[a-zA-Z0-9\\_\\-\\.]+\\@[a-zA-Z0-9_-]+\\.[a-zA-Z\\.]+$"
        }
    },
    required = { "name", "password", "valid_password", "email" }
}

_M.login = {
    type = "object",
    properties = {
        password = {
            type = 'string',
            minLength = 6,
            maxLength = 20,
        },
        email = {
            type = 'string',
            pattern = "^[a-zA-Z0-9\\_\\-\\.]+\\@[a-zA-Z0-9_-]+\\.[a-zA-Z\\.]+$"
        }
    },
    required = { "password", "email" }
}

return _M
