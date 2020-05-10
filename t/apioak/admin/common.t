use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: account register
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/account/register', ngx.HTTP_POST, {
            name = "test account",
            password = "123456",
            valid_password = "123456",
            email = "test@email.com",
        })
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 2: account login and set admin
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local code, message, user_info = t('/apioak/admin/account/login', ngx.HTTP_PUT, {
            password = "123456",
            email = "test@email.com",
        })
        ngx.status = code

        local set_code, set_res = account.set_admin(user_info.user.id)
        ngx.say(set_res)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 3: common users
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/users', ngx.HTTP_GET, {}, request_header)
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 4: common members
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/members', ngx.HTTP_GET, {}, request_header)
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 5: common projects
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/projects', ngx.HTTP_GET, {}, request_header)
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 6: common routers
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/routers', ngx.HTTP_GET, {}, request_header)
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 7: common plugins
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/plugins', ngx.HTTP_GET, {}, request_header)
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 8: account delete
--- config
location /t {
    content_by_lua_block {
        local account = require("tools.account")

        local user_code, user_info = account.user_info("test@email.com")
        local code, message        = account.user_delete(user_info.id)

        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
1
--- error_code chomp
200
