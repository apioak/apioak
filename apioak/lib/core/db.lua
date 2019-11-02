local mysql = require "resty.mysql"
local config = require "module.config"
local tinsert = table.insert
local type = type
local ipairs = ipairs
local setmetatable = setmetatable
local ngx_quote_sql_str = ngx.quote_sql_str
local utils = require("lib.tools.utils")
local _M = {}
_M._VERSION = '0.01'

local mt = { __index = _M }


--[[    把连接返回到连接池
        用set_keepalive代替close() 将开启连接池特性,可以为每个nginx工作进程，指定连接最大空闲时间，和连接池最大连接数
--]]

-- --[[    查询有结果数据集时返回结果数据集
--         无数据数据集时返回查询影响返回:
--         false,出错信息,sqlstate结构.
--         true,结果集,sqlstate结构.
-- --]]

function _M:exec(sql)
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return
    end
    local options = {
        host = self.db_host,
        port = self.db_port,
        user = self.db_user,
        password = self.db_password,
        database = self.db_name
    }
    db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = db:connect(options)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

--    ngx.log(ngx.INFO, "connected to mysql, reused_times:", db:get_reused_times(), " sql:", sql)

    db:query("SET NAMES utf8")
    local res, err, errno, sqlstate = db:query(sql)
    if not res or err then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    end
    local ok, err = db:set_keepalive(60000, 1000)
--    local ok, err = db:set_keepalive(conf.pool_config.max_idle_timeout, conf.pool_config.pool_size)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    end

    return res, err, errno, sqlstate
end

--function DB:query(sql, params)
--    sql = self:parse_sql(sql, params)
--    return self:exec(sql)
--end
function _M.query(self ,sql, params)

    sql = self:parse_sql(sql, params)
    local ret, err, _ = self:exec(sql)
    if not ret then
        ngx.log(ngx.ERR, "sql错误 " .. (sql or "nil"))
        ngx.log(ngx.ERR, "query db error. res: " .. (err or "nil"))
        return nil
    end

    return ret
end
function _M.queryIn(self ,sql, params)
    sql = self:parse_sql(sql, params)
    local ret, res, _ = self:exec(sql)
    if not ret then
        ngx.log(ngx.ERR, "query db error. res: " .. (res or "nil"))
        return nil
    end

    return ret
end
function _M.one(self ,sql, params)
    sql = self:parse_sql(sql, params)
    local ret, res, _ = self:exec(sql)
    if not ret then
        ngx.log(ngx.ERR, "query db error. res: " .. (res or "nil"))
        return nil
    end

    return ret[1]
end
function _M:parse_sql(sql, params)
    if not params or not utils.table_is_array(params) or #params == 0 then
        return sql
    end

    local new_params = {}
    for _, v in ipairs(params) do
        if v and type(v) == "string" then
            v = ngx_quote_sql_str(v)
        end

        tinsert(new_params, v)
    end

    local t = utils.split(sql,"?")
    local new_sql = utils.compose(t, new_params)
    return new_sql
end

function _M.new(self, opts)
    opts = opts or {}
    local db_config = config['mysql']
    local db_host = opts.db_host or db_config['db_host']
    local db_port = opts.db_port or db_config['db_port']
    local db_user = opts.db_user or db_config['db_user']
    local db_password = opts.db_password or db_config['db_password']
    local db_name = opts.db_name or db_config['db_name']
    local db_timeout =  opts.db_timeout or db_config['db_timeout']
    local db_charset = opts.db_charset or db_config['db_charset']
    return setmetatable({
        db_host = db_host,
        db_port = db_port,
        db_user = db_user,
        db_password = db_password,
        db_name = db_name,
        db_timeout = db_timeout,
        db_charset = db_charset }, mt)
end


return _M
