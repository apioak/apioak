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



=== TEST 3: user created
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/user', ngx.HTTP_POST, {
            name = "user_created",
            password = "123456",
            valid_password = "123456",
            email = "test_nginx@email.com",
            is_enable = 1,
        }, request_header)
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



=== TEST 4: user password
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)
        local user_code, user   = account.user_info("test_nginx@email.com")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/user/' .. user.id .. '/password', ngx.HTTP_PUT, {
            password = "1234567",
            valid_password = "1234567",
        }, request_header)
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



=== TEST 5: user disable
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)
        local user_code, user   = account.user_info("test_nginx@email.com")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/user/' .. user.id .. '/disable', ngx.HTTP_PUT, {}, request_header)
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



=== TEST 6: user enable
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)
        local user_code, user   = account.user_info("test_nginx@email.com")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/user/' .. user.id .. '/enable', ngx.HTTP_PUT, {}, request_header)
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



=== TEST 6: user deleted
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local admin_code, admin = account.user_info("test@email.com")
        local token_code, token = account.get_token(admin.id)
        local user_code, user   = account.user_info("test_nginx@email.com")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/user/' .. user.id, ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 5: account delete
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
