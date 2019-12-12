local ngx = ngx
local ngx_say    = ngx.say
local ngx_exit   = ngx.exit
local ngx_header = ngx.header

local _M = {}

function _M.exit(response)
    local code = response.code or 404
    local body = response.body or nil
    local headers = response.headers or {}
    for head_key, head_val in ipairs(headers) do
        _M.set_header(head_key, head_val)
    end
    if body then
        ngx_say(body)
    end
    ngx_exit(code)
end

function _M.set_header(key, value)
    ngx_header[key] = value
end

return _M
