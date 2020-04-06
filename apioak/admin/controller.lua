local db  = require("apioak.db")
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
            pdk.response.exit(500, { err_message = err })
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
            pdk.response.exit(500, { err_message = err })
        end
    end

    cls.user_authenticate = function()
        local token = cls.get_header(pdk.const.REQUEST_ADMIN_TOKEN_KEY)
        if not token then
            pdk.response.exit(401, { err_message = "property header \"" ..
                    pdk.const.REQUEST_ADMIN_TOKEN_KEY .. "\" is required" })
        end

        local res, err = db.token.query_by_token(token)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(401, { err_message = "property token \"" ..
                    token .. "\" invalid" })
        end

        local exp_at = pdk.time.strtotime(res[1].expired_at)
        local now_at = pdk.time.time()
        if exp_at < now_at then
            pdk.response.exit(401, { err_message = "property token \"" ..
                    token .. "\" expired" })
        end

        if (exp_at - now_at) < 3600 then
            db.token.continue_by_token(token)
        end

        res, err = db.user.query_by_id(res[1].user_id)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(401, { err_message = "account does not exist" })
        end

        local user = res[1]

        if user.is_enable == 0 then
            pdk.response.exit(401, { err_message = "account is disabled" })
        end

        cls.uid   = user.id
        cls.token = token

        if user.is_owner == 1 then
            cls.is_owner = true
        else
            cls.is_owner = false
        end

        return user
    end

    cls.project_authenticate = function(project_id, user_id)
        local res, err = db.role.query(project_id, user_id)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(501, { err_message = "no project permissions" })
        end

        return res[1]
    end

    cls.router_authenticate = function(router_id, user_id)
        local res, err = db.router.query(router_id)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(501, { err_message = "no router permissions" })
        end

        return cls.project_authenticate(res[1].project_id, user_id)
    end

    return cls
end

return {
    new = controller
}
