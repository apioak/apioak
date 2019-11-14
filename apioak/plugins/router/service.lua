local setmetatable  = setmetatable
local pool          = require "lib.core.db"
local ngx_cache     = require "lib.cache"
local tonumber      = tonumber
local tostring      = tostring
local ipairs        = ipairs
local next          = next
local type          = type
local ngx_log       = ngx.log
local ngx_DEBUG     = ngx.DEBUG
local string_format = string.format
local string_len    = string.len
local ngx_re_find   = ngx.re.find
local ngx_re_gsub   = ngx.re.gsub

local _M = {}

function _M:new()
    local instance = {}
    instance.db = pool:new()
    instance.cachekey = "routes"
    setmetatable(instance, {
        __index = self
    })
    return instance
end

-- 初始化路由配置到内存中
function _M:init_config()
    local projects = self.db:query("select id, backend_name from projects where status = ?", {tonumber(1)})
    if projects and next(projects) then
        for _, project in ipairs(projects) do
            local apis = self:get_apis_by_projectid(project.id)
            if apis and next(apis) then
                local succ, err = ngx_cache:set(self.cachekey, project.backend_name, apis)
                ngx_log(ngx_DEBUG, string_format("CREATE ROUTER API [%s] status:%s error:%s", project.backend_name,
                    succ, err))
            end
        end
    end
end

-- 根据项目ID获取路由信息
function _M:get_apis_by_projectid(projectid)
    local routersmap = {}
    if projectid and tonumber(projectid) > 0 then
        local routers = self.db:query("select path, server_path, is_auth, is_sign, version, method, response_type, network, timeout, is_cache, try_times, upstream_url, response_text, test_api_id, beta_api_id, prod_api_id from apis where project_id = ?", { tonumber(projectid) })
        if routers and next(routers) then
            -- 初始化自定义参数个数
            local customparamnum = 0
            -- 自定义参数个数自增
            local customparamrep = function(m)
                customparamnum = customparamnum + 1
                return "$" .. tostring(customparamnum)
            end
            for _, router in ipairs(routers) do
                local apppath = router['server_path']
                local routerkey = tostring(router["method"]) .. "/" .. tostring(router["version"])
                -- 检查路由中是否有自定义参数
                local pathcustomparams = ngx_re_find(router['path'], "({[a-z_]+})", "jo")
                if pathcustomparams then
                    -- 替换网关路由参数变量
                    local gatewaypath = ngx_re_gsub(router['path'], "{[a-z_]+}", "(.+)")
                    -- 替换应用路由参数变量
                    apppath = ngx_re_gsub(router['server_path'], "{[a-z_]+}", customparamrep)
                    routerkey = tostring(routerkey) .. tostring(gatewaypath)
                    -- 重设自定义参数个数为初始化状态
                    customparamnum = 0
                else
                    routerkey = tostring(routerkey) .. tostring(router['path'])
                end
                -- 组装API所需参数
                local routervals = {
                    path          = apppath,
                    route_path    = router['path'],
                    is_auth       = router['is_auth'],
                    network       = router['network'],
                    is_sign       = router['is_sign'],
                    method        = router['method'],
                    timeout       = router['timeout'],
                    is_cache      = router['is_cache'],
                    try_times     = router['try_times'],
                    upstream_url  = router['upstream_url'],
                    response_type = router['response_type'],
                    response_text = router['response_text'] or {},
                    test_api_id   = router['test_api_id'],
                    beta_api_id   = router['beta_api_id'],
                    prod_api_id   = router['prod_api_id'],
                }
                routersmap[routerkey] = routervals
            end
        end
    end
    return routersmap
end

-- 通过产品线标识更新API列表
function _M:update_config_by_backendname(backendname)
    local status = false
    if not backendname or type(backendname) ~= "string" and string_len(backendname) <= 0 then
        return nil
    end
    local project = self.db:one("select id, backend_name from projects where backend_name = ?", { tostring(backendname) })
    if project and next(project) then
        local apilist = self:get_apis_by_projectid(project.id)
        if apilist and next(apilist) then
            local succ, err = ngx_cache:set(self.cachekey, backendname, apilist)
            -- 更新状态
            if succ then status = true end
            ngx_log(ngx_DEBUG, string_format("UPDATE ROUTER API [%s] status:%s error:%s", backendname,
                succ, err))
        end
    end
    return status
end

-- 通过产品线标识获取API列表
function _M:get_config_by_backendname(backendname)
    if not backendname or type(backendname) ~= "string" and string_len(backendname) <= 0 then
        return nil
    end
    local routerapis = ngx_cache:get(self.cachekey, backendname)
    if not routerapis then
        local succ = self:update_config_by_backendname(backendname)
        if succ then
            routerapis = ngx_cache:get(self.cachekey, backendname)
        end
    end
    return routerapis
end

return _M
