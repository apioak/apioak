local dao        = require("apioak.dao")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local upstream_node_controller = controller.new("upstream_node")

function upstream_node_controller.created()

    local body = upstream_node_controller.get_body()

    upstream_node_controller.check_schema(schema.upstream_node.created, body)

    if body.check.enabled == true then
        if (body.check.tcp == nil) and ((body.check.http == nil) or (body.check.method == nil)) then
            pdk.response.exit(400, { message = "one of tcp or http and method is required" })
        end
    end

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_UPSTREAM_NODES)

    if check_name then
        pdk.response.exit(400, { message = "the upstream_node name[" .. body.name .. "] already exists" })
    end

    local res, err = dao.upstream_node.created(body)

    if err then
        pdk.log.error("upstream-node-create create upstream node exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "create upstream node exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function upstream_node_controller.lists()

    local res, err = dao.upstream_node.lists()

    if err then
        pdk.log.error("upstream-node-list get upstream node list exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream node list exception" })
    end

    pdk.response.exit(200, res)
end

function upstream_node_controller.updated(params)

    local body = upstream_node_controller.get_body()
    body.upstream_node_key = params.upstream_node_key

    upstream_node_controller.check_schema(schema.upstream_node.created, body)

    if body.check.enabled == true then
        if (body.check.tcp == nil) and ((body.check.http == nil) or (body.check.method == nil)) then
            pdk.response.exit(400, { message = "health check parameter error" })
        end
    end

    local detail, err = dao.upstream_node.detail(body.upstream_node_key)

    if err then
        pdk.log.error("upstream-node-update get upstream detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream node detail exception" })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.upstream_node.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, {
                message = "the upstream node name[" .. body.name .. "] already exists" })
        end
    end

    local res, err = dao.upstream_node.updated(body, detail)

    if err then
        pdk.log.error("upstream-node-update update upstream node exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "update upstream node exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function upstream_node_controller.detail(params)

    upstream_node_controller.check_schema(schema.upstream_node.updated, params)

    local detail, err = dao.upstream_node.detail(params.upstream_node_key)

    if err then
        pdk.log.error("upstream-node-detail get upstream node detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream node detail exception" })
    end

    pdk.response.exit(200, detail)
end

function upstream_node_controller.deleted(params)

    upstream_node_controller.check_schema(schema.upstream_node.updated, params)

    local detail, err = dao.upstream_node.detail(params.upstream_node_key)

    if err then
        pdk.log.error("upstream-node-delete get upstream node detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream node detail exception" })
    end

    if not detail then
        pdk.response.exit(400, { message = "the upstream node not found" })
    end

    local upstream_list, upstream_list_err = dao.upstream.upstream_list_by_node(detail)

    if upstream_list_err then
        pdk.log.error("upstream-node-delete upstream exception when detecting upstream nodes: ["
                              .. upstream_list_err .. "]")
        pdk.response.exit(500, { message = "upstream exception when detecting upstream nodes" })
    end

    if upstream_list and (#upstream_list > 0) then

        local upstream_names = {}

        for i = 1, #upstream_list do
            table.insert(upstream_names, upstream_list[i]['name'])
        end

        pdk.response.exit(400, {
            message = "upstream node is in use by upstream [" .. table.concat(upstream_names, ",") .. "]" })
    end

    local res, err = dao.upstream_node.deleted(detail)

    if err then
        pdk.log.error("upstream-node-delete remove upstream node exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "remove upstream node exception" })
    end

    pdk.response.exit(200, res)
end

return upstream_node_controller
