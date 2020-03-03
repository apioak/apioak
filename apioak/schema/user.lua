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
            minimum = 0
        }
    },
    required = { "name", "password", "valid_password", "email", "is_enable" }
}

_M.updated_password = {
    type = "object",
    properties = {
        user_id = {
            anyOf = {
                {
                    type = "string",
                    minLength = 1,
                    pattern = [[^[1-9]+$]]
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

_M.updated_status = {
    type = "object",
    properties = {
        user_id = {
            anyOf = {
                {
                    type = "string",
                    minLength = 1,
                    pattern = [[^[1-9]+$]]
                },
                {
                    type = "number",
                    minimum = 1
                }
            }
        },
        is_enable = {
            type = 'number',
            minimum = 0
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
                    pattern = [[^[1-9]+$]]
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
