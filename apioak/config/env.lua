--
-- Created by IntelliJ IDEA.
-- User: shuaijinchao
-- Date: 2019/1/28
-- Time: 7:23 PM
-- To change this template use File | Settings | File Templates.
--

local _M = {}

-- 环境配置（test、beta、prod）
_M.env = 'prod'

-- MySQL配置
_M.mysql = {
    db_host = '172.22.0.2',
    db_port = 3306,
    db_user = 'apigateway',
    db_password = 'apigateway',
    db_name = 'apigateway',
    db_timeout = 10000,
    db_charset = 'utf8',
}

return _M
