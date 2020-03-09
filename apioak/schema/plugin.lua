local _M = {}

_M.project_list = {
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
        }
    }
}

_M.project_created = {
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
    required = { "project_id", "name", "type", "config", "description" }
}

_M.project_updated = {
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

_M.project_deleted = {
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

_M.router_list = {
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

_M.router_created = {
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

_M.router_updated = {
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

_M.router_deleted = {
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
