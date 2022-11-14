local ngx  = ngx
local http = require("resty.http")
local json = require("cjson.safe")
local type = type

local methods = {
    [ngx.HTTP_GET]     = "GET",
    [ngx.HTTP_HEAD]    = "HEAD",
    [ngx.HTTP_PUT]     = "PUT",
    [ngx.HTTP_POST]    = "POST",
    [ngx.HTTP_DELETE]  = "DELETE",
    [ngx.HTTP_OPTIONS] = "OPTIONS",
    [ngx.HTTP_PATCH]   = "PATCH",
    [ngx.HTTP_TRACE]   = "TRACE",
}

local _M = {}

function _M.test(uri, method, body, headers)
    headers = headers or {}
    if type(body) == "table" then
        body = json.encode(body)
        headers["Content-Type"] = "application/json"
    end

    if type(method) == "number" then
        method = methods[method]
    end

    if not headers["Content-Type"] then
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    end

    local httpc = http.new()
    uri = ngx.var.scheme .. "://" .. ngx.var.server_addr .. ":" .. ngx.var.server_port .. uri
    local res, err = httpc:request_uri(uri,
            {
                method = method,
                body = body,
                keepalive = false,
                headers = headers,
            }
    )

    if not res then
        ngx.log(ngx.ERR, "failed http: ", err)
        return 500, "FAIL", err
    end

    if res.status == 200 or res.status == 201 then
        return 200, "OK", json.decode(res.body)
    end

    ngx.log(ngx.INFO, uri)
    ngx.log(ngx.INFO, res.body)

    return res.status, "FAIL", json.decode(res.body)
end

function _M.read_file(path)
    local file = assert(io.open(path, "r"))
    local content = file:read("*al")
    file:close()
    return content
end

return _M
