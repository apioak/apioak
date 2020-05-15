local _M = {}

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
        }
    }
}

_M.updated = {
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
            type = 'string',
            minLength = 1,
            maxLength = 50
        },
        path = {
            type = 'string',
            minLength = 2,
            maxLength = 20
        },
        description = {
            type = 'string',
            minLength = 0,
            maxLength = 100
        },
        upstreams = {
            type = "array",
            minItems = 3,
            maxItems = 3,
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    id = {
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
                    host = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-.]+$"
                    },
                    type = {
                        type = "string",
                        enum = { "CHASH", "ROUNDROBIN" }
                    },
                    env = {
                        type = "string",
                        enum = { "PROD", "BETA", "TEST" }
                    },
                    timeouts = {
                        type = "object",
                        properties = {
                            connect = {
                                type = "number",
                                minimum = 0,
                                maximum = 60000,
                            },
                            send = {
                                type = "number",
                                minimum = 0,
                                maximum = 60000,
                            },
                            read = {
                                type = "number",
                                minimum = 0,
                                maximum = 60000,
                            }
                        }
                    },
                    nodes = {
                        type = "array",
                        minItems = 1,
                        uniqueItems = true,
                        items = {
                            type = "object",
                            properties = {
                                ip = {
                                    anyOf = {
                                        {
                                            type = "string",
                                            pattern = "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$"
                                        },
                                        {
                                            type = "string",
                                            pattern = "^\\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:)))(%.+)?\\s*$"
                                        }
                                    }
                                },
                                port = {
                                    type = "number",
                                    minimum = 1,
                                    maximum = 65535,
                                },
                                weight = {
                                    type = "number",
                                    minimum = 0,
                                    maximum = 100,
                                },
                            },
                            required = { "ip", "port", "weight" }
                        }
                    }
                },
                required = { "id", "host", "type", "env", "timeouts", "nodes" }
            },
        }
    },
    required = { "project_id", "name", "path", "upstreams", "description" }
}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = 'string',
            minLength = 1,
            maxLength = 50
        },
        path = {
            type = 'string',
            minLength = 2,
            maxLength = 20
        },
        description = {
            type = 'string',
            minLength = 0,
            maxLength = 100
        },
        upstreams = {
            type = "array",
            minItems = 3,
            maxItems = 3,
            uniqueItems = true,
            items = {
                type = "object",
                properties = {
                    host = {
                        type = "string",
                        pattern = "^\\*?[0-9a-zA-Z-.]+$"
                    },
                    type = {
                        type = "string",
                        enum = { "CHASH", "ROUNDROBIN" }
                    },
                    env = {
                        type = "string",
                        enum = { "PROD", "BETA", "TEST" }
                    },
                    timeouts = {
                        type = "object",
                        properties = {
                            connect = {
                                type = "number",
                                minimum = 0,
                                maximum = 60000,
                            },
                            send = {
                                type = "number",
                                minimum = 0,
                                maximum = 60000,
                            },
                            read = {
                                type = "number",
                                minimum = 0,
                                maximum = 60000,
                            }
                        }
                    },
                    nodes = {
                        type = "array",
                        minItems = 1,
                        uniqueItems = true,
                        items = {
                            type = "object",
                            properties = {
                                ip = {
                                    anyOf = {
                                        {
                                            type = "string",
                                            pattern = "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$"
                                        },
                                        {
                                            type = "string",
                                            pattern = "^\\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(\\.(25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}))|:)))(%.+)?\\s*$"
                                        }
                                    }
                                },
                                port = {
                                    type = "number",
                                    minimum = 1,
                                    maximum = 65535,
                                },
                                weight = {
                                    type = "number",
                                    minimum = 0,
                                    maximum = 100,
                                },
                            },
                            required = { "ip", "port", "weight" }
                        }
                    }
                },
                required = { "host", "type", "env", "timeouts", "nodes" }
            },
        }
    },
    required = { "name", "path", "upstreams", "description" }
}

_M.plugins = {
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

_M.plugin_created = {
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

_M.plugin_deleted = {
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

_M.members = {
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
    },
    required = { "project_id" }
}

_M.member_created = {
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
    required = { "project_id", "user_id", "is_admin" }
}

_M.member_deleted = {
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
    },
    required = { "project_id", "user_id" }
}

_M.member_updated = {
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
    required = { "project_id", "user_id", "is_admin" }
}

_M.routers = {
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

return _M
