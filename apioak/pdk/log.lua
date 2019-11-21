local ngx_log = ngx.log

local _LEVELS = {
    debug  = ngx.DEBUG,
    info   = ngx.INFO,
    notice = ngx.NOTICE,
    warn   = ngx.WARN,
    err    = ngx.ERR,
    crit   = ngx.CRIT,
    alert  = ngx.ALERT,
    emerg  = ngx.EMERG,
}

local _M = {}

for log_name, log_level in pairs(_LEVELS) do
    _M[log_name] = function(...)
        ngx_log(log_level, ...)
    end
end

return _M
