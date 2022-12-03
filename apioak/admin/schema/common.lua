local _M = {}

_M.id = {
    type      = "string",
    minLength = 36,
    maxLength = 36,
    pattern   = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
}

_M.name = {
    type      = "string",
    minLength = 3,
    maxLength = 35,
    pattern   = "^\\*?[0-9a-zA-Z-_.]+$",
}

_M.items_object_id_or_name = {
    type       = "object",
    properties = {
        id   = _M.id,
        name = _M.name,
    },
    anyOf      = {
        {
            required = { "id" }
        },
        {
            required = { "name" }
        }
    }
}

_M.items_object_id_or_name_or_null = {
    type       = "object",
    properties = {
        id   = _M.id,
        name = _M.name,
    },
    anyOf      = {
        {
            required = { "id" }
        },
        {
            required = { "name" }
        },
        {}
    }
}

_M.items_object_id = {
    type       = "object",
    properties = {
        id   = _M.id
    }
}

_M.items_array_id_or_name = {
    type        = "array",
    uniqueItems = true,
    minItems    = 1,
    items       = _M.items_object_id_or_name
}

_M.items_array_id_or_name_or_null = {
    type        = "array",
    uniqueItems = true,
    items       = _M.items_object_id_or_name
}

_M.items_array_id = {
    type        = "array",
    uniqueItems = true,
    items       = _M.items_object_id
}

_M.param_key = {
    anyOf = {
        _M.id,
        _M.name,
    }
}

return _M
