--
-- Created by IntelliJ IDEA.
-- User: renyineng
-- Date: 17/11/8
-- Time: 下午12:28
-- To change this template use File | Settings | File Templates.
--

local cjson      = require "cjson"
local response   = require "lib.response"
local audit      = require "module.audit"
local singletons = require "config.singletons"

local _M = {}

function _M.index(project_id)
    local data = audit:get_audit(project_id, singletons.config.env)
    response:success('OK'):response(data)
end

function _M.update()
    ngx.req.read_body()
    --获取body体
    local body = ngx.req.get_body_data()
    local data = {}

    if (body ~= nil and body ~= '[]') then
        local res, table_body = pcall(cjson.decode, body)
        if res == false then
            response:error(901,  '参数不合法'):response()
        end
        data = table_body
    end
    if data['project_id'] == nil or data['versions'] == nil then
        response:error(901,  '缺少参数'):response()
    end
    local re = audit:update_audit(data['project_id'], data['versions'])
    if re ~= nil then
        response:response({}, 'OK')
    else
        response:response({}, '更新失败，服务异常')
    end
end
return _M

