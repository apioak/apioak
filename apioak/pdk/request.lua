local ngx  = ngx
local type = type
local find = string.find
local json = require("cjson.safe")
local multipart = require "multipart"

local CONTENT_TYPE           = "Content-Type"

local CONTENT_TYPE_POST      = "application/x-www-form-urlencoded"
local CONTENT_TYPE_JSON      = "application/json"
local CONTENT_TYPE_FORM_DATA = "multipart/form-data"

local _M = {}

local function _header(key)
    local headers = ngx.req.get_headers()
    if key then
        return headers[key]
    end
    return headers
end

function _M.body()
    local req_method = ngx.var.request_method
    local content_type = _header(CONTENT_TYPE)
    if req_method ~= "POST" then
        return nil, "[pdk.request] " .. req_method .. " request cannot get body"
    end

    ngx.req.read_body()
    if find(content_type, CONTENT_TYPE_POST, 1, true) == 1 then
        local body_data, err = ngx.req.get_post_args()
        if not body_data then
            return nil, err
        end

        return body_data, nil

    elseif find(content_type, CONTENT_TYPE_JSON, 1, true) == 1 then
        local body, err = ngx.req.get_body_data()
        if not body then
            return nil, err
        end

        local body_data = json.decode(body)
        if type(body_data) ~= "table" then
            return nil, "[pdk.request] invalid json body"
        end

        return body_data, nil

    elseif find(content_type, CONTENT_TYPE_FORM_DATA, 1, true) == 1 then
        local body, err = ngx.req.get_body_data()
        if not body then
            return nil, err
        end

        return multipart(body, content_type):get_all(), nil
    else
        return nil, "[pdk.request] unsupported content type '" .. content_type .. "'"
    end
end

_M.header = _header

return _M
