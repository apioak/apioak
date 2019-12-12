local pdk = require("apioak.pdk")

local etcd_key = "/services"

local _M = {}

_M.etcd_key = etcd_key

function _M.list()
    local data, code, etcd_err = pdk.etcd.query(etcd_key)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.query(params)
    local service_id = params.id or nil
    if not service_id then
        pdk.response.exit(404, "service not found")
    end

    local data, code, etcd_err = pdk.etcd.query(etcd_key .. "/" .. service_id)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.create()
    local body, body_err = pdk.request.body()
    if body_err then
        pdk.response.exit(500, { err_message = body_err })
    end

    local _, schema_err = pdk.schema.check(pdk.schema.service, body)
    if schema_err then
        pdk.response.exit(500, { err_message = schema_err })
    end

    local data, code, etcd_err = pdk.etcd.create(etcd_key, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.update(params)
    local service_id = params.id or nil
    if not service_id then
        pdk.response.exit(404, "service not found")
    end

    local body, body_err = pdk.request.body()
    if body_err then
        pdk.response.exit(500, { err_message = body_err })
    end

    body.id = service_id
    local _, schema_err = pdk.schema.check(pdk.schema.service, body)
    if schema_err then
        pdk.response.exit(500, { err_message = schema_err })
    end

    local data, code, etcd_err = pdk.etcd.update(etcd_key .. "/" .. service_id, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.delete(params)
    local service_id = params.id or nil
    if not service_id then
        pdk.response.exit(404, "service not found")
    end

    local data, code, etcd_err = pdk.etcd.delete(etcd_key .. "/" .. service_id)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.plugin_create(params)
    local service_id = params.id or nil
    if not service_id then
        pdk.response.exit(404, "router not found")
    end

    local body, body_err = pdk.request.body()
    if body_err then
        pdk.response.exit(500, { err_message = body_err })
    end

    local _, schema_err = pdk.schema.check(pdk.schema.plugin, body)
    if schema_err then
        pdk.response.exit(500, { err_message = schema_err })
    end

    local key = etcd_key .. '/' .. service_id
    local res, code, err = pdk.etcd.query(key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    if res.value.plugins then
        res.value.plugins[body.name] = body.config or {}
    else
        local plugins = {}
        plugins[body.name] = body.config or {}
        res.value.plugins = plugins
    end

    res, code, err = pdk.etcd.update(key, res.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end
    pdk.response.exit(code, res)
end

function _M.plugin_delete(params)
    local service_id = params.id or nil
    local plugin_key = params.plugin_key or nil
    if not service_id or not plugin_key then
        pdk.response.exit(404, "router not found")
    end

    local key = etcd_key .. '/' .. service_id
    local res, code, err = pdk.etcd.query(key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    if not res.value.plugins or not res.value.plugins[plugin_key] then
        pdk.response.exit(500, { err_message = "plugin empty" })
    end

    res.value.plugins[plugin_key] = nil

    res, code, err = pdk.etcd.update(key, res.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end
    pdk.response.exit(code, res)
end

return _M
