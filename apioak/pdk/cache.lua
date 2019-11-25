local lrucache = require "resty.lrucache"

local _M = {}

local c, err = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
    error("failed to create the cache: " .. (err or "unknown"))
end

function _M.get(key)
    return c:get(key)
end

function _M.set(key, val, ttl)
    return c:set(key, val, ttl)
end

function _M.delete(key)
    return c:delete(key)
end

function _M:flush_all()
    return c:flush_all()
end

return _M