local _M = {}

_M.created = {
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
        },
        is_enable = {
            type = "number",
            enum = { 0, 1 }
        }
    },
    required = { "name", "password", "valid_password", "email", "is_enable" }
}

_M.password = {
    type = "object",
    properties = {
        user_id = {
            anyOf = {
                {
                    type = "string",
                    minLength = 1,
                    pattern = [[^[0-9]+$]]
                },
                {
                    type = "number",
                    minimum = 1
                }
            }
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
        }
    }
}

_M.enable = {
    type = "object",
    properties = {
        user_id = {
            anyOf = {
                {
                    type = "string",
                    minLength = 1,
                    pattern = [[^[0-9]+$]]
                },
                {
                    type = "number",
                    minimum = 1
                }
            }
        }
    }
}

_M.disable = {
    type = "object",
    properties = {
        user_id = {
            anyOf = {
                {
                    type = "string",
                    minLength = 1,
                    pattern = [[^[0-9]+$]]
                },
                {
                    type = "number",
                    minimum = 1
                }
            }
        }
    }
}

_M.deleted = {
    type = "object",
    properties = {
        user_id = {
            anyOf = {
                {
                    type = "string",
                    minLength = 1,
                    pattern = [[^[0-9]+$]]
                },
                {
                    type = "number",
                    minimum = 1
                }
            }
        }
    }
}

return _M
