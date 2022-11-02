local pdk = require("apioak.pdk")
local schema = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao = require("apioak.dao")

local upstream_controller = controller.new("upstream")


function upstream_controller.created()

    local body = upstream_controller.get_body()

    upstream_controller.check_schema(schema.upstream.created, body)

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_UPSTREAMS)

    if check_name then
        pdk.response.exit(400, { message = "the upstream name[" .. body.name .. "] already exists" })
    end

    local check_nodes, check_nodes_err = dao.common.batch_check_kv_exists(body.nodes, pdk.const.CONSUL_PRFX_NODES)

    if check_nodes_err or not check_nodes then
        pdk.response.exit(400, { message = "the upstream nodes is abnormal" })
    end

    local res, err = dao.upstream.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end


function upstream_controller.lists()

    local res, err = dao.upstream.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end


function upstream_controller.updated(params)

    local body = upstream_controller.get_body()
    body.upstream_key = params.upstream_key

    upstream_controller.check_schema(schema.upstream.updated, body)

    local detail, err = dao.upstream.detail(body.upstream_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.upstream.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, { message = "the upstream name[" .. body.name .. "] already exists" })
        end
    end

    if body.nodes then

        local check_nodes, check_nodes_err = dao.common.batch_check_kv_exists(body.nodes, pdk.const.CONSUL_PRFX_NODES)

        if check_nodes_err or not check_nodes then
            pdk.response.exit(400, { message = "the upstream nodes is abnormal" })
        end
    end

    local res, err = dao.upstream.updated(body, detail)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end


function upstream_controller.detail(params)

    upstream_controller.check_schema(schema.upstream.detail, params)

    local res, err = dao.upstream.detail(params.upstream_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    pdk.response.exit(200, res)
end


function upstream_controller.deleted(params)

    upstream_controller.check_schema(schema.upstream.detail, params)

    local detail, err = dao.upstream.detail(params.upstream_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    local res, err = dao.upstream.deleted(detail)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end


return upstream_controller