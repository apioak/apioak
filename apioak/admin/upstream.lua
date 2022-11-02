local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")
local dao        = require("apioak.dao")

local upstream_controller = controller.new("upstream")

function upstream_controller.created()

    local body = upstream_controller.get_body()

    upstream_controller.check_schema(schema.upstream.created, body)

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_UPSTREAMS)

    if check_name then
        pdk.response.exit(400, { message = "the upstream name[".. body.name .."] already exists" })
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

    local  res, err = dao.upstream.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

return upstream_controller