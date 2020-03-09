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


    cls.get_header_token = function()
        local token = cls.get_header(pdk.const.REQUEST_ADMIN_TOKEN_KEY)
        if not token then
            pdk.response.exit(401, { err_message = pdk.string.format(
                    "property header \"%s\" is required", cls.header_token_key) })
        end
        return token
    end

    cls.get_account_token = function(token)
        local res, err = db.token.query_by_token(token)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(401, { err_message = "login account token invalid" })
        end

        return res[1]
    end

    cls.get_account_info = function(uid)
        local res, err = db.user.query_by_id(uid)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(401, { err_message = "login account not exists" })
        end

        return res[1]
    end

    cls.user_authenticate = function()
        local header_token  = cls.get_header_token()
        local account_token = cls.get_account_token(header_token)

        local expired  = pdk.time.strtotime(account_token.expired_at)
        local now_time = pdk.time.time()
        if expired < now_time then
            pdk.response.exit(401, { err_message = "login status expired" })
        end

        local diff_time = expired - now_time
        if diff_time < 3600 then
            db.token.continue_by_token(cls.token)
        end

        local account_info  = cls.get_account_info(account_token.user_id)
        cls.uid         = account_info.id
        cls.token       = header_token

        if account_info.is_owner == 1 then
            cls.is_owner = true
        end
    end

    cls.group_authenticate = function(group_id, user_id)
        local res, err = db.role.query(group_id, user_id)
        if err then
            pdk.response.exit(500, { err_message = err })
        end
        if #res == 0 then
            pdk.response.exit(401, { err_message = "no permission to operate on this group" })
        end
        return res[1]
    end

    cls.project_authenticate = function(project_id, user_id)
        local res, err = db.project.query(project_id)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(500, { err_message = "project: " .. project_id .. " not exists" })
        end

        return cls.group_authenticate(res[1].group_id, user_id)
    end

    cls.router_authenticate = function(router_id, user_id)
        local res, err = db.router.query(router_id)
        if err then
            pdk.response.exit(500, { err_message = err })
        end

        if #res == 0 then
            pdk.response.exit(500, { err_message = "router: " .. router_id .. " not exists" })
        end

        return cls.project_authenticate(res[1].project_id, user_id)
    end

    return cls
end

return {
    new = controller
}
