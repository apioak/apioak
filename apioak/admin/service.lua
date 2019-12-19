local pdk      = require("apioak.pdk")
local tostring = tostring

local etcd_key
local uri_params

local function create_etcd_key(service_id)
    if service_id then
        etcd_key = "/services/" .. tostring(service_id)
    else
        etcd_key = "/services"
    end
end

local function get_uri_param(key)
    local val = uri_params[key] or nil
    if not val then
        pdk.response.exit(500,
                { err_message = pdk.string.format("property \"URI: %s\" is required", key) })
    end
    return val
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

local _M = {}

function _M.list()
    create_etcd_key()

    local data, code, etcd_err = pdk.etcd.query(etcd_key)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.query(params)
    uri_params       = params
    local service_id = get_uri_param('service_id')

    create_etcd_key(service_id)

    local data, code, etcd_err = pdk.etcd.query(etcd_key)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.create()
    local body = get_body()

    check_schema(pdk.schema.service, body)

    create_etcd_key()

    local data, code, etcd_err = pdk.etcd.create(etcd_key, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.update(params)
    uri_params       = params
    local service_id = get_uri_param('service_id')
    local body       = get_body()

    check_schema(pdk.schema.service, body)

    create_etcd_key(service_id)

    local data, code, etcd_err = pdk.etcd.update(etcd_key, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.delete(params)
    uri_params       = params
    local service_id = get_uri_param('service_id')

    create_etcd_key(service_id)

    local data, code, etcd_err = pdk.etcd.delete(etcd_key)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.plugin_create(params)
    uri_params       = params
    local service_id = get_uri_param('service_id')
    local body       = get_body()

    check_schema(pdk.schema.plugin, body)

    create_etcd_key(service_id)

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
    local service_id = get_uri_param('service_id')
    local plugin_key = get_uri_param('plugin_key')

    create_etcd_key(service_id)

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

return _M
