local ngx_log = ngx.log

local _NGX_LOG_LEVELS = {
    debug  = ngx.DEBUG,
    info   = ngx.INFO,
    notice = ngx.NOTICE,
    warn   = ngx.WARN,
    error  = ngx.ERR,
    crit   = ngx.CRIT,
    alert  = ngx.ALERT,
    emerg  = ngx.EMERG,
}

local _M = {}

for log_name, log_level in pairs(_NGX_LOG_LEVELS) do
    _M[log_name] = function(...)
        return ngx_log(log_level, ...)
    end
end

return _M
