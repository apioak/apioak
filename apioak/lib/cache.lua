local cJson = require "cjson"
local NginxShared = ngx.shared
local type = type

local _M = {}

-- 设置Nginx缓存（超时时间秒）
function _M:set(dict, key, value, expTime)
    expTime = expTime or 0
    local nginxSharedDict = NginxShared[dict]
    if not nginxSharedDict then
        return false
    end
    if type(value) == 'table' then
        value = cJson.encode(value)
    end
    local success, error, _ = nginxSharedDict:set(key, value, expTime)
    return success, error
end

-- 获取Nginx缓存
function _M:get(dict, key)
    if not NginxShared[dict] then
        return nil
    end
    local data = NginxShared[dict]:get(key)
    if data ~= nil then
        return cJson.decode(data)
    end
    return data
end

return _M
