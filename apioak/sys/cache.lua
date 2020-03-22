local pdk          = require("apioak.pdk")
local ngx_timer_at = ngx.timer.at
local lru_cache    = require("resty.lrucache")
local lru_global

local function created_cache(premature)
    if premature then
        return
    end

    local cache, err = lru_cache.new(1024)  -- allow up to 1024 items in the cache
    if not cache then
        pdk.log.error("failed to create the cache: ", err)
    end

    lru_global = cache
end

local _M = {}

function _M.init_worker()
    ngx_timer_at(0, created_cache)
end

function _M.get(key)
    if not lru_global then
        created_cache()
    end
    return lru_global:get(key)
end

function _M.set(key, val, ttl)
    if not lru_global then
        created_cache()
    end
    return lru_global:set(key, val, ttl)
end

function _M.del(key)
    if not lru_global then
        created_cache()
    end
    return lru_global:delete(key)
end

return _M
