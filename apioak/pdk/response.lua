local ngx = ngx
local type = type
local ngx_say     = ngx.say
local ngx_exit    = ngx.exit
local ngx_header  = ngx.header
local const = require("apioak.pdk.const")
local json  = require("apioak.pdk.json")

local _M = {}

function _M.exit(code, body, content_type)
    if code and type(code) == "number" then
        ngx.status = code
    else
        code = nil
    end

    if body then
        if type(body) == "table" then
            local res, err = json.encode(body)
            if err then
                ngx_header[const.CONTENT_TYPE] = const.CONTENT_TYPE_HTML
                ngx_say(err)
            else
                ngx_header[const.CONTENT_TYPE] = content_type or const.CONTENT_TYPE_JSON
                ngx_say(res)
            end
        else
            ngx_header[const.CONTENT_TYPE] = content_type or const.CONTENT_TYPE_HTML
            ngx_say(body)
        end
    end

    if code then
        ngx_exit(code)
    end
end

function _M.say(code, body)
    if code and type(code) == "number" then
        ngx.status = code
    else
        code = nil
    end
    ngx_header[const.CONTENT_TYPE] = const.CONTENT_TYPE_HTML
    ngx_say(body)
end

function _M.set_header(key, value)
    ngx_header[key] = value
end

return _M
