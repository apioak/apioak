local pool          = require "lib.core.db"
local ngx_cache     = require "lib.cache"
local singletons    = require "config.singletons"
local cjson         = require "cjson"
local pl_stringx    = require "pl.stringx"
local tonumber      = tonumber
local setmetatable  = setmetatable
local ipairs        = ipairs
local next          = next
local type          = type
local ngx_log       = ngx.log
local ngx_DEBUG     = ngx.DEBUG
local string_format = string.format
local string_len    = string.len
local string_split  = pl_stringx.split
local table_insert  = table.insert

local _M = {}

function _M:new()
    local instance = {}
    instance.db = pool:new()
    instance.cachekey = "projects"
    setmetatable(instance, {
        __index = self
    })
    return instance
end

-- 初始化全部项目配置
function _M:init_config()
    local env = singletons.config.env
    local projects = self.db:query("select backend_name, test_servers, beta_servers, prod_servers from projects where status = ?", {tonumber(1)})
    if projects and next(projects) then
        for _, project in ipairs(projects) do
            local envserver = cjson.decode(project[env .. "_servers"])
            local servers = {}
            servers.domain = envserver.domain or "localhost"
            local hosts = {}
            if envserver.servers and next(envserver.servers) then
                for _, addr in ipairs(envserver.servers) do
                    local addrinfo = string_split(addr, ":")
                    table_insert(hosts, {
                        host = addrinfo[1],
                        port = addrinfo[2] or 80
                    })
                end
            end
            servers.servers = hosts
            local success, error = ngx_cache:set(self.cachekey, project.backend_name, servers)
            ngx_log(ngx_DEBUG, string_format("CREATE PROJECT SETTING [%s] status:%s error:%s", project.backend_name,
                success, error))
        end
    end
end

-- 拉取按项目标识更新项目配置
function _M:update_config_by_backendname(backendname)
    local status = false
    local env = singletons.config.env
    local project = self.db:one("select backend_name, test_servers, beta_servers, prod_servers from projects where backend_name = ? and status = ?", { backendname, tonumber(1) })
    if project then
        local envserver = cjson.decode(project[env .. "_servers"])
        local servers = {}
        servers.domain = envserver.domain or "localhost"
        local hosts = {}
        if envserver.servers and next(envserver.servers) then
            for _, addr in ipairs(envserver.servers) do
                local addrinfo = string_split(addr, ":")
                table_insert(hosts, {
                    host = addrinfo[1],
                    port = addrinfo[2] or 80
                })
            end
        end
        servers.servers = hosts
        local succ, err = ngx_cache:set(self.cachekey, backendname, servers)
        if succ then
            status = true
        end
        ngx_log(ngx_DEBUG, string_format("UPDATE PROJECT SETTING [%s] status:%s error:%s", backendname, succ, err))
    end
    return status
end

-- 拉取按项目标识拉取项目配置
function _M:get_config_by_backendname(backendname)
    if not backendname or type(backendname) ~= "string" and string_len(backendname) <= 0 then
        return nil
    end
    local projectconf = ngx_cache:get(self.cachekey, backendname)
    if not projectconf then
        -- 如果获取失败重新拉取
        local succ = self:update_config_by_backendname(backendname)
        if succ then
            projectconf = ngx_cache:get(self.cachekey, backendname)
        end
    end
    return projectconf
end


return _M
