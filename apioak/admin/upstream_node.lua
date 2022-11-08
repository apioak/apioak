local dao        = require("apioak.dao")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local upstream_node_controller = controller.new("upstream_node")

function upstream_node_controller.created()

    local body = upstream_node_controller.get_body()

    upstream_node_controller.check_schema(schema.upstream_node.created, body)

    -- @todo 这里需要判断如果健康检查打开，则tcp必填 或者 http和method同时必填 的逻辑，或者是json_schema做关联关系的校验
    --if body.check.enabled == true then
    --    if (body.check.tcp == "") or ((body.check.http == "") and (body.check.method == "")) then
    --        pdk.response.exit(440, { message = "Parameter error" })
    --    end
    --end

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_UPSTREAM_NODES)

    if check_name then
        pdk.response.exit(400, { message = "the upstream_node name[" .. body.name .. "] already exists" })
    end

    local res, err = dao.upstream_node.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end

function upstream_node_controller.lists()

    local res, err = dao.upstream_node.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

function upstream_node_controller.updated(params)

    local body = upstream_node_controller.get_body()
    body.upstream_node_key = params.upstream_node_key

    upstream_node_controller.check_schema(schema.upstream_node.created, body)

    -- @todo 这里需要判断如果健康检查打开，则tcp必填 或者 http和method同时必填 的逻辑，或者是json_schema做关联关系的校验

    local detail, err = dao.upstream_node.detail(body.upstream_node_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.upstream_node.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, { message = "the upstream_node name[" .. body.name .. "] already exists" })
        end
    end

    local res, err = dao.upstream_node.updated(body, detail)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end

function upstream_node_controller.detail(params)

    upstream_node_controller.check_schema(schema.upstream_node.updated, params)

    local detail, err = dao.upstream_node.detail(params.upstream_node_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    pdk.response.exit(200, detail)
end

function upstream_node_controller.deleted(params)

    upstream_node_controller.check_schema(schema.upstream_node.updated, params)

    local detail, err = dao.upstream_node.detail(params.upstream_node_key)

    if err then
        pdk.response.exit(400, { message = err })
    end

    local res, err = dao.upstream_node.deleted(detail)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

return upstream_node_controller
