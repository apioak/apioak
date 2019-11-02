--
-- Created by IntelliJ IDEA.
-- User: renyineng
-- Date: 17/11/6
-- Time: 下午6:11
-- To change this template use File | Settings | File Templates.
--
local tools = require('lib.tools.utils')
local request = require('lib.core.request')

local router = require "plugins.router.service"
local RouterService = router:new()

local project = require "plugins.project.service"
local Projectservice = project:new()

local waf = require "plugins.waf.service"
local WafService = waf:new()

local _M = {}
local cache_list = {
    "sgin-auth",
    "routes",
    "projects",
    "waf",
}

function _M.view(product_line, key)
    --获取缓存
    local result = {
        status = 200,
        result = {},
        message = 'OK',
    }
    if tools.table_contains(cache_list, key) == false then
        result['status'] = 404
        result['message'] = key .. ': 缓存key错误'
    else
        local data
        if key == "routes" then
            data = RouterService:get_config_by_backendname(product_line)
        end

        if key == "projects" then
            data = Projectservice:get_config_by_backendname(product_line)
        end

        if not data then
            result['status'] = 404
            result['message'] = key .. ': 缓存不存在'
        end

        result['result'] = data
    end
    return result
end

--全局配置更新
function _M.global_update()
    local result = {
        status = 200,
        result = {},
        message = 'OK',
    }
    local key = request.input('key', '')
    if tools.table_contains(cache_list, key) == false then
        result['status'] = 404
        result['message'] = key .. ': 缓存key错误'
    else
        if key == 'waf' then
            WafService:init_config()
        end
    end
    return result
end

function _M.update()
    local result = {
        status = 200,
        result = {},
        message = 'OK',
    }
    local product_line = request.input('product_line', '')
    local key = request.input('key', '')
    if product_line == '' or key == '' then
        result['status'] = 901
        result['message'] = '参数不合法'
    else
        if key == 'routes' then
            local succ = RouterService:update_config_by_backendname(product_line)
            if not succ then
                result['status'] = 901
                result['message'] = '服务端错误，缓存失败'
            end
        else
            local succ = Projectservice:update_config_by_backendname(product_line)
            if not succ then
                result['status'] = 901
                result['message'] = '服务端错误,缓存更新失败'
            end
        end
    end
    return result
end

return _M
