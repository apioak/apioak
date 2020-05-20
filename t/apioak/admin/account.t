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



=== TEST 2: account login
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/account/login', ngx.HTTP_PUT, {
            password = "123456",
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



=== TEST 3: account status
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local user_code, user_info   = account.user_info("test@email.com")
        local token_code, user_token = account.get_token(user_info.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = user_token
        local code, message = t('/apioak/admin/account/status', ngx.HTTP_GET, {}, request_header)
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



=== TEST 4: account logout
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local user_code, user_info   = account.user_info("test@email.com")
        local token_code, user_token = account.get_token(user_info.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = user_token
        local code, message = t('/apioak/admin/account/logout', ngx.HTTP_DELETE, {}, request_header)
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
