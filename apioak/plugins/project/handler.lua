--
-- Created by IntelliJ IDEA.
-- User: Janko.Shuai
-- Date: 2019-03-25
-- Time: 11:29
-- Site: https://lemon.myphp.org
--

local response       = require "lib.response"
local ngx_log        = ngx.log
local ngx_timer_at   = ngx.timer.at
local ngx_ERR        = ngx.ERR
local plugin         = require "plugins.base_plugin"
local projects       = require "plugins.project.service"

local ProjectHandler = plugin:extend()
local ProjectService = projects:new()

function ProjectHandler:new()
    ProjectHandler.super.new(self, "project")
end

function ProjectHandler:init_worker()
    if ngx.worker.id() == 0 then
        local ok, err = ngx_timer_at(0, function(premature)
            -- 初始化全部项目配置
            ProjectService:init_config()
        end)
        if not ok then
            ngx_log(ngx_ERR, "failed to create the timer: ", err)
            return
        end
    end
end

function ProjectHandler:access(ctx)
    -- 预请求直接响应成功
    if ctx.method == 'OPTIONS' then
        return response:success():response()
    end
    -- 获取项目配置
    local upstream = ProjectService:get_config_by_backendname(ctx.backend_name)
    if not upstream then
        return response:error(404, 'Not Project'):response()
    end
    local var = ngx.var
    -- 设置应用服务器域名
    var.upstream_host = upstream.domain
    -- 设置应用服务器信息（后续流程需要应用）
    ctx.upstream = upstream
end

return ProjectHandler
