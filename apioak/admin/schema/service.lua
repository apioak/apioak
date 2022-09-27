local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = "string",
            minLength = 1,
            maxLength = 50
        },
        protocols = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = { "http", "https" }
            },
            default = {"http"}
        },
        hosts = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                pattern = "^\\*?[0-9a-zA-Z-.]+$"
            },
        },
        ports = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "number",
                pattern = "^\\*?[0-9]+$"
            },
            default = {80}
        },
        plugins = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    id = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-.]+$"
                    },
                    name = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-.]+$"
                    }
                }
            },
        },
        enabled = {
            type = "boolean",
            default = true
        }
    },
    required = { "name", "hosts" }
}

_M.updated = {
    type = "object",
    properties = {
        service_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        },
        name = {
            type = "string",
            minLength = 1,
            maxLength = 50
        },
        protocols = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = { "http", "https" }
            },
            default = {"http"}
        },
        hosts = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                pattern = "^\\*?[0-9a-zA-Z-.]+$"
            },
        },
        ports = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "number",
                pattern = "^\\*?[0-9]+$"
            },
            default = {80}
        },
        plugins = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    id = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-.]+$"
                    },
                    name = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-.]+$"
                    }
                }
            },
        },
        enabled = {
            type = "boolean",
            default = true
        }
    },
    required = { "service_id", "name", "hosts" }
}

_M.detail = {
    type = "object",
    properties = {
        service_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        }
    },
    required = { "service_id"}
}

_M.deleted = {
    type = "object",
    properties = {
        service_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        }
    },
    required = { "service_id"}
}

return _M
