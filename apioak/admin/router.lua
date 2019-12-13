local pdk = require("apioak.pdk")
local etcd_key = "/routers"

local _M = {}

_M.etcd_key = etcd_key

function _M.list()
    local result, code, err = pdk.etcd.query(etcd_key)
    if err then
        return pdk.response.exit(code, { err_message = err })
    end

    return pdk.response.exit(code, result.nodes)
end

function _M.query(params)
    ngx.say("query: ", params.id)
end

function _M.create(params)
    ngx.say("create: ", params.id)
end

function _M.update(params)
    ngx.say("update: ", params.id)
end

function _M.delete(params)
    local router_id = params.id or nil
    if not router_id then
        pdk.response.exit(404, "router not found")
    end

    local result, code, err = pdk.etcd.delete(etcd_key .. '/' .. router_id)
    if err then
        return pdk.response.exit(code, { err_message = err })
    end

    delete_all_upstream(router_id)
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
    if not router_id then
        pdk.response.exit(404, "service not found")
    end

    local args = ngx.req.get_uri_args()
    if not args['plugin_name'] then
        pdk.response.exit(404, args)
    end
    local plugin_key = args['plugin_name']

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
    upstream_router(router_id, router.value, body.push_upstream, body.push_status)
    pdk.response.exit(code, router)
end

function upstream_router(router_id, router, push_schema, push_status)
    local key = etcd_key .. '_' .. push_schema .. '/' .. router_id
    if push_status then
        local res, code, err = pdk.etcd.update(key, router)
    else
        local res, code, err = pdk.etcd.delete(key)
    end
    if err then
        pdk.response.exit(code, {err_message = 'upstream_router error: ' .. err})
    end
end

function delete_all_upstream(router_id)
    for _, index in ipairs({'mock', 'dev', 'beta', 'prod'}) do
        upstream_router(router_id, nil, index, false)
    end
end

return _M
