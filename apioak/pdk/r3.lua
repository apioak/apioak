
local r3route = require "resty.r3"

local _M = {}

--创建路由
function _M.create(routes)

    --参数校验
    if type(routes) ~= "table" then
        error("invalid argument routes", 2)
    end

    --声明默认回调
    local function default_handler(params)
        --存在参数，则进行设置当前参数
        if params then
            ngx.ctx.uri_params = params
        end
    end

    --声明当前路由组
    local self_routes = {}

    for _, route in pairs(routes) do
        --参数校验
        if type(route) ~= "table" then
            return nil, "invalid argument routes info"
        end
        if (not route.path) or (type(route.path) ~= "string") then
            return nil, "invalid argument routes.path"
        end
        if (not route.method) or (type(route.method) ~= "table") then
            return nil, "invalid argument routes.method"
        end
        if (route.handler and (type(route.handler) ~= "function"))then
            return nil, "invalid argument routes.handler"
        end

        --只过滤使用三个路由参数
        local path = route.path or ""
        local method = route.method or ""
        local handler = route.handler or default_handler

        --整合路由参数
        table.insert(self_routes, {
            path = path,
            method = method,
            handler = handler,
        })
    end

    --载入设置的路由
    local r3 = r3route.new(self_routes)
    r3:compile()

    return r3, nil
end

--检索路由
function _M.match(r3, path, method, ...)

    --统一转换为大写
    local u_method = string.upper(method)

    --匹配当前的传递的地址和请求方式
    local ok = r3:dispatch(path, u_method, ...)
    return ok, nil
end

return _M


