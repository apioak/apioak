local setmetatable  = setmetatable
local next          = next
local type          = type
local pairs         = pairs
local pool          = require "lib.core.db"
local ngx_cache     = require "lib.cache"
local ngx_log       = ngx.log
local ngx_DEBUG     = ngx.DEBUG
local string_format = string.format
local string_len    = string.len
local tostring      = tostring


local _M = {}

function _M:new()
    local instance = {}
    instance.db = pool:new()
    instance.cachekey = "jwt-auth"
    setmetatable(instance, {
        __index = self
    })
    return instance
end

-- 初始化插件配置到缓存中
function _M:init_config()
    --读取系统配置规则
    local secrets = self.db:query("select project_name, secret_key, secret_alg from jwts")
    if secrets and next(secrets) ~= nil then
        for _, secret in pairs(secrets) do
            local success, error = ngx_cache:set(self.cachekey, secret.project_name, secret)
            ngx_log(ngx_DEBUG, string_format("CREATE JWT SECRET [%s] status:%s error:%s", secret.project_name,
                success, error))
        end
    end
end

-- 根据项目标识更新JWT配置
function _M:update_config_by_backendname(backendname)
    local status = false
    if not backendname then
        return status
    end
    local secrets = self.db:query("select project_name, secret_key, secret_alg from jwts where project_name = ? limit 1",
        { tostring(backendname) })
    if secrets and next(secrets) then
        local succ, err = ngx_cache:set(self.cachekey, backendname, secrets[1])
        if succ then
            status = true
        end
        ngx_log(ngx_DEBUG, string_format("UPDATE JWT SECRET [%s] status:%s error:%s", backendname, succ, err))
    end
    return status
end

-- 根据项目标识获取JWT配置
function _M:get_config_by_backendname(backendname)
    if not backendname or type(backendname) ~= "string" or string_len(backendname) <= 0 then
        return nil
    end
    local jwtconf = ngx_cache:get(self.cachekey, backendname)
    if not jwtconf then
        local succ = self:update_config_by_backendname(backendname)
        if succ then
            jwtconf = ngx_cache:get(self.cachekey, backendname)
        end
    end
    return jwtconf
end

return _M
