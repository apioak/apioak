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

    local exist_snis, exist_snis_err = dao.certificate.exist_sni(body.snis)

    if exist_snis_err ~= nil then
        pdk.log.error("certificate-create exception when checking if sni exists: [" .. exist_snis_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if sni exists" })
    end

    if exist_snis and (#exist_snis > 0) then
        pdk.response.exit(400, {
            message = "exists certificate sni [" .. table.concat(exist_snis, ",") .. "] " })
    end

    local res, err = dao.certificate.created(body)

    if err then
        pdk.log.error("certificate-create create certificate exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "create certificate exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function certificate_controller.lists()

    local res, err = dao.certificate.lists()

    if err then
        pdk.log.error("certificate-list get certificate list exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get certificate list exception" })
    end

    pdk.response.exit(200, res)
end

function certificate_controller.updated(params)

    local body = certificate_controller.get_body()
    body.certificate_key = params.certificate_key

    certificate_controller.check_schema(schema.certificate.updated, body)

    local detail, err = dao.certificate.detail(body.certificate_key)

    if err then
        pdk.log.error("certificate-update get certificate detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get certificate detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the certificate not found" })
    end

    if (body.name ~= nil) and (body.name ~= detail.name) then

        local name_detail, _ = dao.certificate.detail(body.name)

        if name_detail ~= nil then
            pdk.response.exit(400, { message = "the certificate name[" .. body.name .. "] already exist" })
        end
    end

    local exist_sni, exist_sni_err = dao.certificate.exist_sni(body.snis, detail.id)

    if exist_sni_err ~= nil then
        pdk.log.error("certificate-update exception when checking if sni exists: [" .. exist_sni_err .. "]")
        pdk.response.exit(500, { message = "exception when checking if sni exists" })
    end

    if exist_sni and (#exist_sni > 0) then
        pdk.response.exit(400, {
            message = "exists certificate sni [" .. table.concat(exist_sni, ",") .. "] " })
    end

    local res, err = dao.certificate.updated(body, detail)

    if err then
        pdk.log.error("certificate-update update certificate exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "update certificate exception" })
    end

    pdk.response.exit(200, { id = res.id })
end

function certificate_controller.detail(params)

    certificate_controller.check_schema(schema.certificate.updated, params)

    local detail, err = dao.certificate.detail(params.certificate_key)

    if err then
        pdk.log.error("certificate-detail get certificate detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get certificate detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the certificate not found" })
    end

    pdk.response.exit(200, detail)
end

function certificate_controller.deleted(params)

    certificate_controller.check_schema(schema.certificate.updated, params)

    local detail, err = dao.certificate.detail(params.certificate_key)

    if err then
        pdk.log.error("certificate-delete get certificate detail exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "get certificate detail exception" })
    end

    if not detail then
        pdk.response.exit(404, { message = "the certificate not found" })
    end

    local res, err = dao.certificate.deleted(detail)

    if err then
        pdk.log.error("certificate-delete remove certificate exception: [" .. err .. "]")
        pdk.response.exit(500, { message = "remove certificate exception" })
    end

    pdk.response.exit(200, res)
end


return certificate_controller