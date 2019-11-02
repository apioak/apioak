local cjson = require "cjson"

local _M = {}

_M.result = {
    status = 200,
    message = 'OK'
}

function _M.error(self, status, message)
    self.result['status'] = status
    if status == 401 then
        ngx.status = 401
    elseif status > 600 then
        ngx.status = 422
    else
        ngx.status = status
    end
    self.result['message'] = message
    return self
end

function _M.success(self, message)
    self.result['status'] = 200
    self.result['message'] = message
    return self
end

function _M.response(self, result, message)
    if result ~= nil then
        self.result['result'] = result
    else
        self.result['result'] = {}
    end

    if message ~= nil then
        self.result['message'] = message
    end
    ngx.say(cjson.encode(self.result))
    return ngx.exit(ngx.status)
end

return _M
