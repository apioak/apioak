local dao        = require("apioak.dao")
local pdk        = require("apioak.pdk")
local schema     = require("apioak.schema")
local controller = require("apioak.admin.controller")

local certificate_controller = controller.new("certificate")

function certificate_controller.created()
    local body = certificate_controller.get_body()

    certificate_controller.check_schema(schema.certificate.created, body)

    local check_name = dao.common.check_key_exists(body.name, pdk.const.CONSUL_PRFX_CERTIFICATES)

    if check_name then
        pdk.response.exit(400, { message = "the certificate name[" .. body.name .. "] already exists" })
    end

    local res, err = dao.certificate.created(body)

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, { id = res.id })
end


function certificate_controller.lists()

    local res, err = dao.certificate.lists()

    if err then
        pdk.response.exit(500, { message = err })
    end

    pdk.response.exit(200, res)
end

return certificate_controller