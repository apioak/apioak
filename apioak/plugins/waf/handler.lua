local iputils      = require "lib.core.iputils"
local singletons   = require "config.singletons"
local response     = require "lib.response"
local ngx_log      = ngx.log
local ngx_timer_at = ngx.timer.at
local ngx_ERR      = ngx.ERR
local BasePlugin   = require "plugins.base_plugin"
local waf          = require "plugins.waf.service"
local WafService   = waf:new()

local WafHandler = BasePlugin:extend()

function WafHandler:new()
    WafHandler.super.new(self, "waf")
end

function WafHandler:init_worker()
    if ngx.worker.id() == 0 then
        local ok, err = ngx_timer_at(0, function(premature)
            if premature then
                return
            end
            WafService:init_config()
        end)
        if not ok then
            ngx_log(ngx_ERR, "failed to create the timer: ", err)
            return
        end
    end
end

function WafHandler:access(ctx)
    --判断是否全局黑名单
    --判断内网还是外网
    if singletons.waf == nil then
        singletons.waf = {}
        singletons.waf.whitelist = WafService:get_config_by_wafname('whitelist')
        singletons.waf.blacklist = WafService:get_config_by_wafname('blacklist')
    end
    -- 黑名单
    if singletons.waf.blacklist and iputils.ip_in_cidrs(ctx.client_ip, singletons.waf.blacklist) then
       return response:error(403, '您已被禁止访问'):response()
    end
    -- 白名单
    if singletons.waf.whitelist and iputils.ip_in_cidrs(ctx.client_ip, singletons.waf.whitelist) then
        -- Noting
    end
end

return WafHandler
