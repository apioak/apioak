local _M = {}

_M.created = {
    type = "object",
    properties = {
        name = {
            type = "string",
            minLength = 1,
            maxLength = 50,
            pattern = "^\\*?[0-9a-zA-Z-_.]+$"
        },
        key = {
            type = "string",
            minLength = 1,
            maxLength = 50,
            pattern = "^\\*?[0-9a-zA-Z-_.]+$"
        },
        config = {
            type = "object",
        },
    },
    required = { "name", "key", "config" }
}

_M.updated = {
    type = "object",
    properties = {
        plugin_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        },
        name = {
            type = "string",
            minLength = 1,
            maxLength = 50,
            pattern = "^\\*?[0-9a-zA-Z-_.]+$"
        },
        key = {
            type = "string",
            minLength = 1,
            maxLength = 50,
            pattern = "^\\*?[0-9a-zA-Z-_.]+$"
        },
        config = {
            type = "object",
        },
    },
    required = { "plugin_id", "name", "key", "config" }
}

_M.detail = {
    type = "object",
    properties = {
        plugin_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        }
    },
    required = { "plugin_id"}
}

_M.deleted = {
    type = "object",
    properties = {
        plugin_id = {
            type = "string",
            minLength = 1,
            maxLength = 50
        }
    },
    required = { "plugin_id"}
}

return _M
