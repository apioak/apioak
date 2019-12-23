local type     = type
local tostring = tostring
local plstring = require("pl.stringx")

local ENV_DEV    = "dev"
local ENV_BETA   = "beta"
local ENV_PROD   = "prod"
local ENV_MASTER = "master"

local SERVICE_ID_PREFIX = "X"

local _M = {}

_M.ENV_DEV    = ENV_DEV
_M.ENV_BETA   = ENV_BETA
_M.ENV_PROD   = ENV_PROD
_M.ENV_MASTER = ENV_MASTER

_M.envs = { ENV_PROD, ENV_BETA, ENV_DEV, ENV_MASTER }

_M.get_router_etcd_key = function(env, service_id, router_id)
    env = env or ENV_MASTER
    if not router_id then
        return "/services/" .. SERVICE_ID_PREFIX .. tostring(service_id) .. "/" .. env .. "/routers"
    else
        return "/services/" .. SERVICE_ID_PREFIX .. tostring(service_id) .. "/" .. env .. "/routers/" .. tostring(router_id)
    end
end

_M.get_service_etcd_key = function(service_id)
    if service_id then
        return "/services/" .. tostring(service_id)
    else
        return "/services"
    end
end

_M.get_service_id_by_etcd_key = function(etcd_key)
    if not etcd_key or type(etcd_key) ~= "string" then
        return nil, "etcd_key invalid"
    end
    local key_arr = plstring.split(etcd_key, "/")
    local key
    if key_arr then
        key = key_arr[#key_arr]
    end
    if key then
        return plstring.replace(key, SERVICE_ID_PREFIX, ""), nil
    else
        return nil, "key not found"
    end
end

return _M
