local pdk      = require("apioak.pdk")
local ipairs   = ipairs
local tostring = tostring
local etcd_key
local uri_params

local ENV_DEV    = "dev"
local ENV_BETA   = "beta"
local ENV_PROD   = "prod"
local ENV_MASTER = "master"
local env_names  = { ENV_PROD, ENV_BETA, ENV_DEV }

local _M = {}

local function create_etcd_key(env, service_id, router_id)
    if not router_id then
        etcd_key = "/services/X" .. tostring(service_id) .. "/" .. env .. "/routers"
    else
        etcd_key = "/services/X" .. tostring(service_id) .. "/" .. env .. "/routers/" .. tostring(router_id)
    end
end

local function get_service_id()
    local service_id = pdk.request.header('APIOAK-SERVICE-ID')
    if not service_id then
        pdk.response.exit(500, { err_message = "property \"HEADER: APIOAK-SERVICE-ID\" is required" })
    end
    return service_id
end

local function get_body()
    local body, err = pdk.request.body()
    if err then
        pdk.response.exit(500, { err_message = err })
    end
    return body
end

local function check_schema(schema, body)
    local _, err = pdk.schema.check(schema, body)
    if err then
        pdk.response.exit(500, { err_message = err })
    end
end

local function get_uri_param(key)
    local val = uri_params[key] or nil
    if not val then
        if key == "env" then
            return ENV_MASTER
        else
            pdk.response.exit(500,
                    { err_message = pdk.string.format("property \"URI: %s\" is required", key) })
        end
    end
    return val
end

function _M.list(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local service_id = get_service_id()

    create_etcd_key(env, service_id)

    local data, code, err = pdk.etcd.query(etcd_key)
    if err then
        return pdk.response.exit(code, { err_message = err })
    end

    return pdk.response.exit(code, data)
end

function _M.query(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local service_id = get_service_id()

    create_etcd_key(env, service_id, router_id)

    local data, code, etcd_err = pdk.etcd.query(etcd_key)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, { err_message = etcd_err })
    end
end

function _M.create(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local body       = get_body()
    local service_id = get_service_id()

    check_schema(pdk.schema.router, body)

    create_etcd_key(env, service_id)

    if not body.push_env then
        body.push_env = {}
        for _, env_name in ipairs(env_names) do
            body.push_env[env_name] = false
        end
    end

    ngx.say(etcd_key)

    local data, code, etcd_err = pdk.etcd.create(etcd_key, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.update(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local body       = get_body()
    local service_id = get_service_id()

    check_schema(pdk.schema.router, body)

    create_etcd_key(env, service_id, router_id)

    local res, code, err = pdk.etcd.query(etcd_key)
    if res and res.value.push_env then
        body.push_env = res.value.push_env
    else
        body.push_env = {}
        for _, env_name in ipairs(env_names) do
            body.push_env[env_name] = false
        end
    end

    res, code, err = pdk.etcd.update(etcd_key, body)
    if res then
        pdk.response.exit(code, res)
    else
        pdk.response.exit(code, { err_message = err })
    end
end

function _M.delete(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local service_id = get_service_id()

    create_etcd_key(env, service_id, router_id)

    local data, code, etcd_err = pdk.etcd.delete(etcd_key)

    if env == ENV_MASTER then
        for _, env_name in ipairs(env_names) do
            create_etcd_key(env_name, service_id, router_id)
            pdk.etcd.delete(etcd_key)
        end
    end

    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, { err_message = etcd_err })
    end
end

function _M.plugin_create(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local body       = get_body()
    local service_id = get_service_id()

    check_schema(pdk.schema.plugin, body)

    create_etcd_key(env, service_id, router_id)

    local res, code, err = pdk.etcd.query(etcd_key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    if res.value.plugins then
        res.value.plugins[body.key] = body.config or {}
    else
        local plugins = {}
        plugins[body.key] = body.config or {}
        res.value.plugins = plugins
    end

    res, code, err = pdk.etcd.update(etcd_key, res.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end
    pdk.response.exit(code, res)
end

function _M.plugin_delete(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local plugin_key = get_uri_param('plugin_key')
    local service_id = get_service_id()

    create_etcd_key(env, service_id, router_id)

    local res, code, err = pdk.etcd.query(etcd_key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    if not res.value.plugins or not res.value.plugins[plugin_key] then
        pdk.response.exit(500,
                { err_message = pdk.string.format("property \"PLUGIN: %s\" not found", plugin_key) })
    end

    res.value.plugins[plugin_key] = nil

    res, code, err = pdk.etcd.update(etcd_key, res.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end
    pdk.response.exit(code, res)
end

function _M.env_create(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local service_id = get_service_id()

    create_etcd_key(ENV_MASTER, service_id, router_id)

    local router, code, err = pdk.etcd.query(etcd_key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    router.value.push_env[env] = true

    router, code, err = pdk.etcd.update(etcd_key, router.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    create_etcd_key(env, service_id, router_id)

    router.value.push_env = nil

    router, code, err = pdk.etcd.update(etcd_key, router.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end
    pdk.response.exit(code, router)
end

function _M.env_delete(params)
    uri_params       = params
    local env        = get_uri_param('env')
    local router_id  = get_uri_param('router_id')
    local service_id = get_service_id()

    create_etcd_key(ENV_MASTER, service_id, router_id)

    local res, code, err = pdk.etcd.query(etcd_key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    res.value.push_env[env] = false

    res, code, err = pdk.etcd.update(etcd_key, res.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    create_etcd_key(env, service_id, router_id)

    res, code, err = pdk.etcd.delete(etcd_key)

    if res then
        pdk.response.exit(code, res)
    else
        pdk.response.exit(code, { err_message = err })
    end
end

return _M
