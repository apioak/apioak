local limit_req = require "resty.limit.req"
local ngx_var = ngx.var

local limit, err = limit_req.new("plug_limit_req", 200, 100)
if not limit then
    ngx.log(ngx.ERR, "failed to instantiate a resty.limit.req object: ", err)
    return ngx.exit(500)
end

local _M = {}

function _M.http_access(oak_ctx)
    local key = ngx_var.binary_remote_addr
    local delay, err = limit:incoming(key, true)
    if not delay then
        if err == "rejected" then
            return ngx.exit(503)
        end
        return ngx.exit(500)
    end

    if delay >= 0.001 then
        ngx.sleep(delay)
    end
    return;
end

return _M