local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = "string",
            minLength = 1,
            maxLength = 50
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
                pattern = "^\\*?[0-9a-zA-Z-.]+$"
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
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
            },
        },
        plugin = {
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
        upstream = {
            type = "object",
            properties = {
                id = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
            },
        },
        enabled = {
            type = "boolean",
            default = true
        },
        prefix = {
            type = "string",
            minLength = 0,
            maxLength = 50
        }
    },
    required = { "name", "paths", "service" }
}

_M.updated = {
    type = "object",
    properties = {
        router_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
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
                pattern = "^\\*?[0-9a-zA-Z-.]+$"
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
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
            },
        },
        plugin = {
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
        upstream = {
            type = "object",
            properties = {
                id = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
                name = {
                    type = "string",
                    pattern = "^\\*?[0-9a-zA-Z-.]+$"
                },
            },
        },
        enabled = {
            type = "boolean",
            default = true
        },
        prefix = {
            type = "string",
            minLength = 0,
            maxLength = 50
        }
    },
    required = {"router_id", "name", "paths", "service" }
}

_M.lists = {
    type = "object",
    properties = {
        prefix = {
            type = "string",
            minLength = 0,
            maxLength = 50
        }
    }
}

_M.detail = {
    type = "object",
    properties = {
        router_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        },
        prefix = {
            type = "string",
            minLength = 0,
            maxLength = 50
        }
    },
    required = { "router_id"}
}

_M.deleted = {
    type = "object",
    properties = {
        router_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        },
        prefix = {
            type = "string",
            minLength = 0,
            maxLength = 50
        }
    },
    required = { "router_id"}
}

return _M
