local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = "string",
            minLength = 1,
            maxLength = 50,
            pattern = "^\\*?[0-9a-zA-Z-._]+$"
        },
        methods = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = { "ALL", "GET", "POST", "PUT", "DELETE", "PATH" }
            },
            default = {"ALL"}
        },
        paths = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                pattern = "^\\*?[0-9a-zA-Z-./]+$"
            },

        },
        headers = {
            type = "object",
        },
        service = {
            type = "object",
            properties = {
                id = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-_.]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-_.]+$"
                },
            },
        },
        plugins = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    id = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-]+$"
                    },
                    name = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-._]+$"
                    }
                }
            },
        },
        upstream = {
            type = "object",
            properties = {
                id = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-._]+$"
                },
            },
        },
        enabled = {
            type = "boolean",
            default = true
        }
    },
    required = { "name", "paths", "service" }
}

_M.updated = {
    type = "object",
    properties = {
        router_key = {
            type = "string",
            minLength = 1,
            maxLength = 50,
            pattern = "^\\*?[0-9a-zA-Z-._]+$"
        },
        methods = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                enum = { "ALL", "GET", "POST", "PUT", "DELETE", "PATH" }
            },
            default = {"ALL"}
        },
        paths = {
            type = "array",
            minItems = 1,
            uniqueItems = true,
            items = {
                type = "string",
                pattern = "^\\*?[0-9a-zA-Z-./]+$"
            },
        },
        headers = {
            type = "object",
        },
        service = {
            type = "object",
            properties = {
                id = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-_.]+$"
                },
            },
        },
        plugins = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    id = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-]+$"
                    },
                    name = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-_.]+$"
                    }
                }
            },
        },
        upstream = {
            type = "object",
            properties = {
                id = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-_.]+$"
                },
            },
        },
        enabled = {
            type = "boolean",
            default = true
        }
    },
    required = {"router_key", "name", "paths", "service" }
}

_M.detail = {
    type = "object",
    properties = {
        router_key = {
            type = "string",
            minLength = 1,
            maxLength = 50
        }
    },
    required = { "router_key"}
}

_M.deleted = {
    type = "object",
    properties = {
        router_key = {
            type = "string",
            minLength = 1,
            maxLength = 50
        }
    },
    required = { "router_key"}
}

return _M
