local plugin        = require "plugins.base_plugin"
local cors          = require "plugins.cors.service"
local CorsService   = cors:new()
local CorsHandler   = plugin:extend()

function CorsHandler:new()
    CorsHandler.super.new(self, "cors")
end

-- 响应数据收集阶段
function CorsHandler:header_filter(ctx)
    -- 改写header头
    if ctx.reponse_type == 1 then
        ngx.header.Content_Type = "application/json"
    end
    if ngx.status ~= 200 then
        ngx.header.X_Request_Id = ngx.var.request_id
    end
    CorsService:allow_credentials(false)
    CorsService:run()
end

return CorsHandler
