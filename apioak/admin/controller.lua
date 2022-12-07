local pdk = require("apioak.pdk")

local controller = function(name)

    local cls = {}

    cls.__class  = name

    cls.uid      = nil

    cls.token    = nil

    cls.is_owner = nil

    cls.get_body = function(key)
        local body, err = pdk.request.body()
        if err then
            pdk.response.exit(500, { message = err, err_message = err })
        end
        if key then
            return body[key]
        end
        return body
    end

    cls.get_header = function(key)
        return pdk.request.header(key)
    end

    cls.check_schema = function(schema, body)
        local _, err = pdk.schema.check(schema, body)
        if err then
            pdk.log.error("schema check error: body[", pdk.json.encode(body, true), "], err[",
                          pdk.json.encode(err, true), "]")
            pdk.response.exit(400, { message = "Parameter error", err_message = err })
        end
    end

    cls.token_authenticate = function()

        local token = cls.get_header(pdk.const.REQUEST_ADMIN_TOKEN_KEY)
        if not token then
            pdk.response.exit(401, { err_message = "property header \"" ..
                    pdk.const.REQUEST_ADMIN_TOKEN_KEY .. "\" is required" })
        end

        return true
    end

    return cls
end

return {
    new = controller
}
