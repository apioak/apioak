local _M = {}

_M.projects = {
    q = {
        type = "string",
        minLength = 1,
        maxLength = 50,
    }
}

_M.routers = {
    q = {
        type = "string",
        minLength = 1,
        maxLength = 50,
    }
}

return _M
