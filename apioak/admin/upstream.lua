local dao        = require("apioak.dao")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local upstream_controller = controller.new("upstream")


function upstream_controller.created()

    local body = upstream_controller.get_body()

    upstream_controller.check_schema(schema.upstream.created, body)

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_UPSTREAMS)

    if check_name then
        pdk.response.exit(400, { message = "the upstream name[" .. body.name .. "] already exists" })
    end

    local check_nodes, err = dao.common.batch_check_kv_exists(body.nodes, pdk.const.CONSUL_PRFX_UPSTREAM_NODES)

    if err then
        pdk.log.error("upstream-create detect upstream node exceptions: [" .. err .. "]")
        pdk.response.exit(500, { message = "detect upstream node exceptions" })
    end

    if check_nodes then
        local exit_node_id_map, exit_node_name_map = {}, {}

        for j = 1, #check_nodes do
            exit_node_id_map[check_nodes[j]['id']] = check_nodes[j]['name']
            exit_node_name_map[check_nodes[j]['name']] = check_nodes[j]['id']
        end

        for k = 1, #body.nodes do
            if body.nodes[k]['id'] and exit_node_id_map[body.nodes[k]['id']] then

                body.nodes[k] = {
                    id = body.nodes[k]['id'],
                    name = exit_node_id_map[body.nodes[k]['id']]
                }

            elseif body.nodes[k]['name'] and exit_node_name_map[body.nodes[k]['name']] then

                body.nodes[k] = {
                    id = exit_node_name_map[body.nodes[k]['name']],
                    name = body.nodes[k]['name']
                }

            end
        end
    end

    local res, err = dao.upstream.created(body)

    if err then
        pdk.log.error("upstream-create create upstream exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "create upstream exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function upstream_controller.updated(params)

    local body = upstream_controller.get_body()
    body.upstream_key = params.upstream_key

    upstream_controller.check_schema(schema.upstream.updated, body)

    local detail, err = dao.upstream.detail(body.upstream_key)

    if err then
        pdk.log.error("upstream-update get upstream detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the upstream not found" })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.upstream.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, { message = "the upstream name[" .. body.name .. "] already exists" })
        end
    end

    if body.nodes then

        local check_nodes, err = dao.common.batch_check_kv_exists(body.nodes, pdk.const.CONSUL_PRFX_UPSTREAM_NODES)

        if err then
            pdk.log.error("upstream-update detect upstream-node exceptions: [" .. err .. "]")
            pdk.response.exit(500, { message = "detect upstream-node exceptions" })
        end

        if check_nodes then
            local exit_node_id_map, exit_node_name_map = {}, {}

            for j = 1, #check_nodes do
                exit_node_id_map[check_nodes[j]['id']] = check_nodes[j]['name']
                exit_node_name_map[check_nodes[j]['name']] = check_nodes[j]['id']
            end

            for k = 1, #body.nodes do
                if body.nodes[k]['id'] and exit_node_id_map[body.nodes[k]['id']] then

                    body.nodes[k] = {
                        id = body.nodes[k]['id'],
                        name = exit_node_id_map[body.nodes[k]['id']]
                    }

                elseif body.nodes[k]['name'] and exit_node_name_map[body.nodes[k]['name']] then

                    body.nodes[k] = {
                        id = exit_node_name_map[body.nodes[k]['name']],
                        name = body.nodes[k]['name']
                    }

                end
            end
        end
    end

    local res, err = dao.upstream.updated(body, detail)

    if err then
        pdk.log.error("upstream-update update upstream exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "update upstream exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function upstream_controller.lists()

    local res, err = dao.upstream.lists()

    if err then
        pdk.log.error("upstream-list get upstream list exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream list exception" })
    end

    pdk.response.exit(200, res)
end

function upstream_controller.detail(params)

    upstream_controller.check_schema(schema.upstream.updated, params)

    local detail, err = dao.upstream.detail(params.upstream_key)

    if err then
        pdk.log.error("upstream-detail get upstream detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the upstream not found" })
    end

    pdk.response.exit(200, detail)
end

function upstream_controller.deleted(params)

    upstream_controller.check_schema(schema.upstream.updated, params)

    local detail, err = dao.upstream.detail(params.upstream_key)

    if err then
        pdk.log.error("upstream-delete get upstream detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get upstream detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the upstream not found" })
    end

    local router_list, router_list_err = dao.router.router_list_by_upstream(detail)

    if router_list_err then
        pdk.log.error("upstream-delete exception when detecting upstream router: [" .. router_list_err .. "]")
        pdk.response.exit(500, { message = "exception when detecting upstream router" })
    end

    if router_list and (#router_list > 0) then

        local router_names = {}

        for i = 1, #router_list do
            table.insert(router_names, router_list[i]['name'])
        end

        pdk.log.warn("upstream-delete upstream is in use by router [" .. table.concat(router_names, ",") .. "]")
    end

    local res, err = dao.upstream.deleted(detail)

    if err then
        pdk.log.error("upstream-delete remove upstream exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "remove upstream exception" })
    end

    pdk.response.exit(200, res)
end


return upstream_controller