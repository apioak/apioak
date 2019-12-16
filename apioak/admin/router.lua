local pdk = require("apioak.pdk")
local prefix_key = "/services"
local etcd_key = "/routers"

local _M = {}

_M.etcd_key = etcd_key

local function get_key(params)
    local service_id = params.service_id or nil
    local route_id = params.id or nil
    if not service_id then
        pdk.response.exit(404, "service_id not found")
    end
    if not route_id then
        pdk.response.exit(404, "route_id not found")
    end
    local key = prefix_key .. "/" .. tonumber(service_id) .. etcd_key .. "/" .. route_id

    return key
end

function _M.list(params)
    local service_id = params.service_id or nil
    if not service_id then
        pdk.response.exit(404, "service_id not found")
    end
    local key = prefix_key .. "/" .. tonumber(service_id) .. etcd_key

    local result, code, err = pdk.etcd.query(key)
    if err then
        return pdk.response.exit(code, { err_message = err })
    end

    return pdk.response.exit(code, result.nodes)
end

function _M.query(params)
    local key = get_key(params)

    local data, code, etcd_err = pdk.etcd.query(key)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.create(params)
    local service_id = params.service_id or nil
    if not service_id then
        pdk.response.exit(404, "service_id not found")
    end
    local key = prefix_key .. "/" .. tonumber(service_id) .. etcd_key

    local body, body_err = pdk.request.body()
    if body_err then
        pdk.response.exit(500, { err_message = body_err })
    end

    local _, schema_err = pdk.schema.check(pdk.schema.router, body)
    if schema_err then
        pdk.response.exit(500, { err_message = schema_err })
    end

    local data, code, etcd_err = pdk.etcd.create(key, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.update(params)
    local key = get_key(params)

    local body, body_err = pdk.request.body()
    if body_err then
        pdk.response.exit(500, { err_message = body_err })
    end

    local _, schema_err = pdk.schema.check(pdk.schema.router, body)
    if schema_err then
        pdk.response.exit(500, { err_message = schema_err })
    end

    local data, code, etcd_err = pdk.etcd.update(key, body)
    if data then
        pdk.response.exit(code, data)
    else
        pdk.response.exit(code, etcd_err)
    end
end

function _M.delete(params)
    local key = get_key(params)

    local result, code, err = pdk.etcd.delete(key)
    if err then
        return pdk.response.exit(code, { err_message = err })
    end

    return pdk.response.exit(code, result)
end

function _M.plugin_create(params)
    local router_id = params.id or nil
    if not router_id then
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

    local key = etcd_key .. '/' .. router_id
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
    local router_id = params.id or nil
    local plugin_key = params.plugin_key or nil
    if not router_id or not plugin_key then
        pdk.response.exit(404, "router not found")
    end

    local key = etcd_key .. '/' .. router_id
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

local push_schema = {
    type = "object",
    properties = {
        push_upstream = {
            type = "string",
            enum = { "dev", "beta", "prod" }
        },
        push_status = {
            type = "boolean"
        }
    },
    required = { "push_upstream", "push_status" }
}

function _M.push_upstream(params)
    local router_id = params.id or nil
    if not router_id then
        pdk.response.exit(404, "router not found")
    end
    local body, body_err = pdk.request.body()
    if body_err then
        pdk.response.exit(500, { err_message = body_err })
    end

    local _, schema_err = pdk.schema.check(push_schema, body)
    if schema_err then
        pdk.response.exit(500, { err_message = schema_err })
    end

    local key = etcd_key .. '/' .. router_id
    local router, code, err = pdk.etcd.query(key)
    if err then
        pdk.response.exit(code, { err_message = err })
    end

    router.value.is_push[body.push_upstream] = body.push_status
    router, code, err = pdk.etcd.update(key, router.value)
    if err then
        pdk.response.exit(code, { err_message = err })
    end
    pdk.response.exit(code, router)
end

return _M
