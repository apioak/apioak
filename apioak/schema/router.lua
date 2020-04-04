local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = "string",
            minLength = 3,
            maxLength = 20,
        },
        enable_cors = {
            type = "number",
            enum = { 0, 1 }
        },
        description = {
            type = 'string',
            minLength = 0,
            maxLength = 100
        },
        request_path = {
            type = 'string',
            minLength = 2,
            maxLength = 50
        },
        request_method = {
            type = "string",
            enum = { "GET", "HEAD", "POST", "OPTIONS", "PUT", "DELETE", "TRACE", "CONNECT" }
        },
        request_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    type = {
                        type = "string",
                        enum = { "BOOLEAN", "INTEGER", "FLOAT", "STRING" }
                    },
                    default_value = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    },
                    required = {
                        type = "number",
                        enum = { 0, 1 }
                    },
                    description = {
                        type = "string",
                        minLength = 0,
                        maxLength = 100
                    }
                },
                required = { "name", "position", "type", "required" }
            }
        },
        backend_path = {
            type = 'string',
            minLength = 2,
            maxLength = 50
        },
        backend_method = {
            type = "string",
            enum = { "GET", "HEAD", "POST", "OPTIONS", "PUT", "DELETE", "TRACE", "CONNECT" }
        },
        backend_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    request_param_name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    request_param_position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    request_param_type = {
                        type = "string",
                        enum = { "BOOLEAN", "INTEGER", "FLOAT", "STRING" }
                    },
                    request_param_required = {
                        type = "number",
                        enum = { 0, 1 }
                    },
                    request_param_default_val = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    },
                    request_param_description = {
                        type = "string",
                        minLength = 0,
                        maxLength = 100
                    }
                },
                required = { "name", "position", "request_param_name", "request_param_position", "request_param_type", "request_param_description" }
            }
        },
        constant_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    type = {
                        type = "string",
                        enum = { "BOOLEAN", "INTEGER", "FLOAT", "STRING" }
                    },
                    value = {
                        type = "string"
                    },
                },
                required = { "name", "position", "type", "value" }
            }
        },
        response_type = {
            type = "string",
            enum = {
                "text/html",
                "text/xml",
                "application/json",
            }
        },
        response_success = {
            type = 'string',
            minLength = 0
        },
        response_failure = {
            type = 'string',
            minLength = 0
        },
        response_codes = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    code = {
                        type = "number",
                        minimum = 200,
                        maximum = 599
                    },
                    message = {
                        type = "string",
                        minLength = 1,
                        maxLength = 20
                    },
                    description = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    }
                },
                required = { "code", "message" }
            }
        },
        response_schema = {
            type = "array",
        },
        project_id = {
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
    },
    required = { "name", "enable_cors", "description", "request_path", "request_method", "request_params", "backend_path",
                 "backend_method", "backend_params", "constant_params", "response_type",
                 "response_success", "response_failure", "response_codes", "response_schema", "project_id" }
}

_M.updated = {
    type = "object",
    properties = {
        name = {
            type = "string",
            minLength = 3,
            maxLength = 20,
        },
        enable_cors = {
            type = "number",
            enum = { 0, 1 }
        },
        description = {
            type = 'string',
            minLength = 0,
            maxLength = 100
        },
        request_path = {
            type = 'string',
            minLength = 2,
            maxLength = 50
        },
        request_method = {
            type = "string",
            enum = { "GET", "HEAD", "POST", "OPTIONS", "PUT", "DELETE", "TRACE", "CONNECT" }
        },
        request_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    type = {
                        type = "string",
                        enum = { "BOOLEAN", "INTEGER", "FLOAT", "STRING" }
                    },
                    default_value = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    },
                    required = {
                        type = "number",
                        enum = { 0, 1 }
                    },
                    description = {
                        type = "string",
                        minLength = 0,
                        maxLength = 100
                    }
                },
                required = { "name", "position", "type", "required" }
            }
        },
        backend_path = {
            type = 'string',
            minLength = 2,
            maxLength = 50
        },
        backend_method = {
            type = "string",
            enum = { "GET", "HEAD", "POST", "OPTIONS", "PUT", "DELETE", "TRACE", "CONNECT" }
        },
        backend_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    request_param_name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    request_param_position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    request_param_type = {
                        type = "string",
                        enum = { "BOOLEAN", "INTEGER", "FLOAT", "STRING" }
                    },
                    request_param_required = {
                        type = "number",
                        enum = { 0, 1 }
                    },
                    request_param_default_val = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    },
                    request_param_description = {
                        type = "string",
                        minLength = 0,
                        maxLength = 100
                    }
                },
                required = { "name", "position", "request_param_name", "request_param_position", "request_param_type", "request_param_description" }
            }
        },
        constant_params = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    name = {
                        type = 'string',
                        minLength = 1,
                        maxLength = 50
                    },
                    position = {
                        type = "string",
                        enum = { "QUERY", "HEADER", "PATH" }
                    },
                    type = {
                        type = "string",
                        enum = { "BOOLEAN", "INTEGER", "FLOAT", "STRING" }
                    },
                    value = {
                        type = "string"
                    },
                },
                required = { "name", "position", "type", "value" }
            }
        },
        response_type = {
            type = "string",
            enum = {
                "text/html",
                "text/xml",
                "application/json",
            }
        },
        response_success = {
            type = 'string',
            minLength = 0
        },
        response_failure = {
            type = 'string',
            minLength = 0
        },
        response_codes = {
            type = "array",
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    code = {
                        type = "number",
                        minimum = 200,
                        maximum = 599
                    },
                    message = {
                        type = "string",
                        minLength = 1,
                        maxLength = 20
                    },
                    description = {
                        type = "string",
                        minLength = 0,
                        maxLength = 50
                    }
                },
                required = { "code", "message" }
            }
        },
        response_schema = {
            type = "array",
        },
        router_id = {
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
    },
    required = { "name", "enable_cors", "description", "request_path", "request_method", "request_params", "backend_path",
                 "backend_method", "backend_params", "constant_params", "response_type",
                 "response_success", "response_failure", "response_codes", "response_schema", "router_id" }
}

_M.deleted = {
    type = "object",
    properties = {
        project_id = {
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
        router_id = {
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
        project_id = {
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
        router_id = {
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

_M.env_push = {
    type = "object",
    properties = {
        router_id = {
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
        env = {
            type = "string",
            enum = {
                "PROD",
                "BETA",
                "TEST",
                "prod",
                "beta",
                "test",
            }
        }
    }
}

_M.env_pull = {
    type = "object",
    properties = {
        router_id = {
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
        env = {
            type = "string",
            enum = {
                "PROD",
                "BETA",
                "TEST",
                "prod",
                "beta",
                "test",
            }
        }
    }
}

_M.plugins = {
    type = "object",
    properties = {
        router_id = {
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

_M.plugin_created = {
    type = "object",
    properties = {
        router_id = {
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
            type = "string",
            minLength = 5,
            maxLength = 20,
        },
        type = {
            type = "string",
            minLength = 5,
            maxLength = 20,
        },
        description = {
            type = "string",
            minLength = 5,
            maxLength = 100,
        },
        config = {
            type = "object"
        }
    },
    required = { "router_id", "name", "type", "config", "description" }
}

_M.plugin_updated = {
    type = "object",
    properties = {
        plugin_id = {
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
        router_id = {
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
            type = "string",
            minLength = 5,
            maxLength = 20,
        },
        type = {
            type = "string",
            minLength = 5,
            maxLength = 20,
        },
        description = {
            type = "string",
            minLength = 5,
            maxLength = 100,
        },
        config = {
            type = "object"
        }
    },
    required = { "plugin_id", "name", "type", "config", "description" }
}

_M.plugin_deleted = {
    type = "object",
    properties = {
        router_id = {
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
        plugin_id = {
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
    }
}

return _M
