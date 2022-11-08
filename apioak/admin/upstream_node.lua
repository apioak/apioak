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

    local res, err = dao.upstream_node.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end

return upstream_node_controller
