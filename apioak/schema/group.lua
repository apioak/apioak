local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = 'string',
            minLength = 5,
            maxLength = 20,
        },
        description = {
            type = 'string',
            minLength = 5,
            maxLength = 50,
        }
    },
    required = { "name", "description" }
}

_M.updated = {
    type = "object",
    properties = {
        group_id = {
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
        name = {
            type = 'string',
            minLength = 5,
            maxLength = 20,
        },
        description = {
            type = 'string',
            minLength = 5,
            maxLength = 50,
        }
    },
    required = { "group_id", "name", "description" }
}

_M.deleted = {
    type = "object",
    properties = {
        group_id = {
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

_M.query = {
    type = "object",
    properties = {
        group_id = {
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

_M.user_list = {
    type = "object",
    properties = {
        group_id = {
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

_M.user_created = {
    type = "object",
    properties = {
        group_id = {
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
        is_admin = {
            type = "number",
            enum = { 0, 1 }
        }
    },
    required = { "group_id", "user_id", "is_admin" }
}

_M.user_deleted = {
    type = "object",
    properties = {
        group_id = {
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

_M.user_updated = {
    type = "object",
    properties = {
        group_id = {
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
        is_admin = {
            type = "number",
            enum = { 0, 1 }
        }
    },
    required = { "group_id", "user_id", "is_admin" }
}

return _M
