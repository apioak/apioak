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



=== TEST 2: service create
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = "foo-service-001",
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })
        ngx.status = code
        ngx.say("OK")

        local t = require("tools.request").test
        local code2, message2, body2 = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = "foo-service-001-to-delete",
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })
        ngx.status = code2
        ngx.say("OK")
    }
}
--- request
GET /t
--- response_body
OK
OK
--- error_code chomp
200



=== TEST 3: service create name exists
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = "foo-service-001",
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
{"message":"the service name[foo-service-001] already exists"}
--- error_code chomp
500



=== TEST 4: service detail by name[foo-service-001]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services/foo-service-001', ngx.HTTP_GET)
        ngx.status = code
        ngx.say(body.name)
    }
}
--- request
GET /t
--- response_body
foo-service-001
--- error_code chomp
200



=== TEST 5: service detail by id
--- config
location /t {
    content_by_lua_block {
        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/services/", "foo-service-001")

        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services/' .. id, ngx.HTTP_GET)
        ngx.status = code
        ngx.say(body.name)
    }
}
--- request
GET /t
--- response_body
foo-service-001
--- error_code chomp
200



=== TEST 6: service update by id
--- config
location /t {
    content_by_lua_block {

        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/services/", "foo-service-001")

        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services/' .. id, ngx.HTTP_PUT, {
            name = "foo-service-001-update",
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
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



=== TEST 7: service update by name[foo-service-001-update]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services/foo-service-001-update', ngx.HTTP_PUT, {
            name = "foo-service-001-update-by-name",
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
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



=== TEST 8: service delete by id
--- config
location /t {
    content_by_lua_block {
        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/services/", "foo-service-001-update-by-name")

        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services/' .. id, ngx.HTTP_DELETE)
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



=== TEST 9: service delete by name[foo-service-001-to-delete]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/services/foo-service-001-to-delete', ngx.HTTP_DELETE)
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