use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: service list
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services', ngx.HTTP_GET)
        ngx.status = code

        local json = require("cjson.safe")
        print(json.encode(body))
        ngx.say(message)

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200
--- SKIP



=== TEST 2: service create
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = "foo-service-test2",
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })
        ngx.status = code
        local json = require("cjson.safe")
        print(json.encode(body))
        ngx.say("OK")
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200
--- SKIP



=== TEST 3: service create name exists
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = "foo-service-test2",
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })
        ngx.status = code
        local json = require("cjson.safe")
        ngx.say(json.encode(body))
    }
}
--- request
GET /t
--- response_body
{"message":"the service name[foo-service-test2] already exists"}
--- error_code chomp
500



