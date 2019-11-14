local setmetatable = setmetatable
local next          = next
local pairs         = pairs
local type          = type
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
    instance.cachekey = "sgin-auth"
    setmetatable(instance, {
        __index = self
    })
    return instance
end

-- 初始化全部签名
function _M:init_config()
    local db = pool:new()
    local secrets = db:query("select app_key, app_secret from secrets")
    if secrets and next(secrets) ~= nil then
        for _, secret in pairs(secrets) do
            local success, error = ngx_cache:set(self.cachekey, secret.app_key, secret.app_secret)
            ngx_log(ngx_DEBUG, string_format("CREATE SIGN SECRET [%s] status:%s error:%s", secret.app_key,
                success, error))
        end
    end
end

-- 通过appkey更新签名秘钥
function _M:update_config_by_appkey(appkey)
    local status = false
    if not appkey then
        return status
    end
    local db = pool:new()
    local secret = db:one("select app_key, app_secret from secrets where app_key = ?", { tostring(appkey) })
    if secret and next(secret) then
        local succ, err = ngx_cache:set(self.cachekey, appkey, secret.app_secret)
        if succ then
            status = true
        end
        ngx_log(ngx_DEBUG, string_format("UPDATE JWT SECRET [%s] status:%s error:%s", appkey, succ, err))
    end
    return status
end

-- 通过appkey获取签名秘钥
function _M:get_config_by_appkey(appkey)
    if not appkey or type(appkey) ~= "string" or string_len(appkey) <= 0 then
        return nil
    end
    local secret = ngx_cache:get(self.cachekey, appkey)
    if not secret then
        local succ = self:update_config_by_appkey(appkey)
        if succ then
            secret = ngx_cache:get(self.cachekey, appkey)
        end
    end
    return secret
end

return _M
