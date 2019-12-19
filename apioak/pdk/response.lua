local ngx = ngx
local type = type
local ngx_say     = ngx.say
local ngx_exit    = ngx.exit
local ngx_header  = ngx.header
local json_encode = require("cjson.safe").encode

local CONTENT_TYPE      = "Content-Type"

local CONTENT_TYPE_JSON = "application/json"
local CONTENT_TYPE_HTML = "text/html"

local _M = {}

function _M.exit(code, body)
    if code and type(code) == "number" then
        ngx.status = code
    else
        code = nil
    end

    if body then
        if type(body) == "table" then
            local json_body, err = json_encode(body)
            if err then
                ngx_header[CONTENT_TYPE] = CONTENT_TYPE_HTML
                ngx_say(err)
            else
                ngx_header[CONTENT_TYPE] = CONTENT_TYPE_JSON
                ngx_say(json_body)
            end
        else
            ngx_header[CONTENT_TYPE] = CONTENT_TYPE_HTML
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
    ngx_header[CONTENT_TYPE] = CONTENT_TYPE_HTML
    ngx_say(body)
end

function _M.set_header(key, value)
    ngx_header[key] = value
end

return _M
