local setmetatable = setmetatable

local pool     = require "lib.core.db"
local ngx_cache    = require "lib.cache"
local next     = next
local type     = type
local cjson    = require "cjson"
local utils    = require "lib.tools.utils"
local iputils  = require "lib.core.iputils"
local response = require "lib.response"
local tonumber = tonumber
local pairs    = pairs
local ngx_log       = ngx.log
local ngx_DEBUG     = ngx.DEBUG
local string_format = string.format
local string_len    = string.len
local tostring      = tostring

local _M = {}

function _M:new()
    local instance = {}
    instance.db = pool:new()
    instance.cachekey = "waf"
    setmetatable(instance, {
        __index = self
    })
    return instance
end

function _M:init_config()
    local wafs = self.db:query("select name, rules from wafs where type = ?", { tonumber(2) })
    if wafs and next(wafs) then
        iputils.enable_lrucache()
        for _, waf in pairs(wafs) do
            if waf.rules then
                local rules = cjson.decode(waf.rules)
                if rules and next(rules) then
                    local success, error = ngx_cache:set(self.cachekey, waf.name, iputils.parse_cidrs(rules))
                    ngx_log(ngx_DEBUG, string_format("CREATE WAF INFO [%s] status:%s error:%s", waf.name,
                        success, error))
                end
            end
        end
    end
end

function _M:update_config_by_wafname(wafname)
    local status = false
    local waf = self.db.one("select name, rules from wafs where type = ? and name = ?", { tonumber(2), tostring(wafname) })
    if waf and next(waf) and waf.rules then
        iputils.enable_lrucache()
        local rules = cjson.decode(waf.rules)
        if rules and next(rules) then
            local success, error = ngx_cache:set(self.cachekey, waf.name, iputils.parse_cidrs(rules))
            if success then
                status = true
            end
            ngx_log(ngx_DEBUG, string_format("UPDATE WAF INFO [%s] status:%s error:%s", waf.name,
                success, error))
        end
    end
    return status
end

function _M:get_config_by_wafname(wafname)
    if not wafname or type(wafname) ~= "string" or string_len(wafname) <= 0 then
        return nil
    end
    local waf = ngx_cache:get(self.cachekey, wafname)
    if not waf then
        local succ = self:update_config_by_wafname(wafname)
        if succ then
            waf = ngx_cache:get(self.cachekey, wafname)
        end
    end
    return waf
end

return _M
