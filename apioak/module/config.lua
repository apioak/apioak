local _M = {}
local cjson = require "cjson"
local env = require "config.env"

_M.code = {
    [404] = '路由未找到',
    [601] = '签名参数不全',
    [602] = '业务参数不全',
    [603] = '网关地址不合法',
    [604] = 'body非json',
    [605] = '密匙错误',
    [609] = '签名计算错误',
}

_M.debug = 1
_M.env = env.env
_M.mysql = env.mysql

function _M.log_info(info, flag)
    if flag == nil then
        flag = ''
    end
    if type(info) == 'table' then
        info = cjson.encode(info)
    end
    ngx.log(ngx.INFO, flag .. ':', info)
end

function _M.log_error(info, flag)
    if flag == nil then
        flag = ''
    end
    if type(info) == 'table' then
        info = cjson.encode(info)
    end

    ngx.log(ngx.ERR, flag .. ':', info)
end

return _M
