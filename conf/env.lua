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
    db_host = '127.0.0.1',
    db_port = 3306,
    db_user = 'root',
    db_password = '123456',
    db_name = 'gateway',
    db_timeout = 10000,
    db_charset = 'utf8',
}

return _M
