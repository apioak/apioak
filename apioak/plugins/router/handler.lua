local response     = require "lib.response"
local ngx_log      = ngx.log
local ngx_timer_at = ngx.timer.at
local ngx_ERR      = ngx.ERR
local pairs        = pairs
local singletons   = require "config.singletons"
local tostring     = tostring
local tonumber     = tonumber
local next         = next
local type         = type
local ngx_re_sub   = ngx.re.sub
local ngx_re_match = ngx.re.match
local string_len   = string.len
local ngx_HTTP_OK  = ngx.HTTP_OK
local ngx_print    = ngx.print
local ngx_exit     = ngx.exit
local plugin       = require "plugins.base_plugin"
local router       = require "plugins.router.service"

local RouteHandler  = plugin:extend()
local RouterService = router:new()

-- 匹配当前的URI信息
local function match_api(curapi, baseapis)
    -- 检查当前URI
    if not curapi or type(curapi) ~= "string" or string_len(curapi) <= 0 then
        return nil
    end
    -- 检查缓存APIS
    if not baseapis or type(baseapis) ~= "table" or next(baseapis) == nil then
        return nil
    end
    -- 匹配路由数据
    local apiinfo
    for k, v in pairs(baseapis) do
        local s = ngx_re_match(curapi, k .. '$', "jo")
        if s ~= nil then
            --匹配成功
            apiinfo = v
            apiinfo['rewrite_url'] = ngx_re_sub(curapi, k, v['path'])
            break
        end
    end
    return apiinfo
end

-- 获取当前API信息
local function get_api(ctx)
    local apiinfo
    if ctx.backend_name and ctx.method and ctx.version and ctx.path then
        local routerkey = tostring(ctx.method) .. "/" .. tostring(ctx.version) .. "/" .. tostring(ctx.path)
        local routerapis = RouterService:get_config_by_backendname(ctx.backend_name)
        apiinfo = match_api(routerkey, routerapis)
    end
    return apiinfo
end

function RouteHandler:new()
    RouteHandler.super.new(self, "router")
end

function RouteHandler:init_worker()
    if ngx.worker.id() == 0 then
        local ok, err = ngx_timer_at(0, function(premature)
            RouterService:init_config()
        end)
        if not ok then
            ngx_log(ngx_ERR, "failed to create the timer: ", err)
            return
        end
    end
end

function RouteHandler:access(ctx)
    -- 预请求直接响应成功
    if ctx.method == 'OPTIONS' then
        return response:success():response()
    end
    -- 版本为空在此初始化
    if ctx.version == nil then
        ctx.version = 'v1'
    end

    -- 获取API信息
    local apiinfo = get_api(ctx)
    if not apiinfo then
        return response:error(404, "Not Found"):response()
    end
    -- 如果接口未发布响应Mock数据
    local envfield = singletons.config.env .. "_api_id"
    if tonumber(apiinfo[envfield]) <= 0 then
        if apiinfo["response_type"] == 1 then
            ngx.header.Content_Type = "application/json"
        else
            ngx.header.Content_Type = "text/html"
        end
        ngx_print(apiinfo["response_text"])
        ngx_exit(ngx_HTTP_OK)
    end
    -- 外网访问，如果是内网接口，外网直接禁止访问
    if ctx.client_network == 1 and apiinfo['network'] == 2 then
        return response:error(403, "Forbidden"):response()
    end
    -- 重写请求URL地址
    ngx.req.set_uri(apiinfo["rewrite_url"], false)
    -- 获取Nginx内置变量
    local var = ngx.var
    -- 设置缓存
    if tonumber(apiinfo["is_cache"]) == 1 then
        var.no_cache = 0 -- 1 不触发生成缓存 0 触发生成缓存
    end
    var.upstream_request = apiinfo["rewrite_url"]
    var.route_path = apiinfo["route_path"]
    ctx.api = apiinfo
end

return RouteHandler

