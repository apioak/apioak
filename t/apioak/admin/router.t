use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: router list
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/beta/routers', ngx.HTTP_GET)
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



=== TEST 2: router created
--- config
location /t {
    content_by_lua_block {

        local random_number = math.random(100000)
        local t = require("tools.request").test

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local plugin_name = "foo-router-plugin-" .. random_number
        local code_p, message_p = t('/apioak/admin/plugins', ngx.HTTP_POST, {
            name = plugin_name,
            key = "foo-plugin-001-1",
            config = { foo = "xxx", bar = "xxx"},
        })

        ngx.say(message_p)

        local router_name = "foo-router-" .. random_number
        local code, message, body = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name = router_name,
            methods = {"GET", "POST"},
            paths = {"/foo", "/bar"},
            headers = {x = "test"},
            service = {name = service_name},
            plugins = {}
        })

        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
OK
--- error_code chomp
200


=== TEST 3: router create name exists
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local random_number = math.random(100000)

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local router_name = "foo-router-" .. random_number
        local code_r_1, message_r_1 = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message_r_1)

        local code_r_2, message_r_2, body = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })
        local json = require("cjson.safe")
        print(json.encode(body))

        ngx.say(code_r_2)
        ngx.say(message_r_2)
    }
}
--- request
GET /t
--- response_body
OK
OK
500
FAIL
--- error_code chomp
200



=== TEST 4: router detail by name
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local random_number = math.random(100000)

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local router_name = "foo-router-" .. random_number
        local code_r_1, message_r_1 = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message_r_1)

        local code, message, body = t('/apioak/admin/routers/' .. router_name, ngx.HTTP_GET)

        if body.name == router_name then
            ngx.say(message)
        else
            ngx.say('FAIL')
        end
    }
}
--- request
GET /t
--- response_body
OK
OK
OK
--- error_code chomp
200



=== TEST 5: router update by id
--- config
location /t {
    content_by_lua_block {

        local t = require("tools.request").test
        local random_number = math.random(100000)

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local router_name = "foo-router-" .. random_number
        local code_r_1, message_r_1 = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message_r_1)

        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/routers/", router_name)

        local random_number_2 = math.random(100000)

        local code, message, body = t('/apioak/admin/routers/' .. id, ngx.HTTP_PUT, {
            name     = "foo-router-" .. random_number_2,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {x = "bla"},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
OK
--- error_code chomp
200



=== TEST 6: router update by name
--- config
location /t {
    content_by_lua_block {

        local t = require("tools.request").test
        local random_number = math.random(100000)

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local router_name = "foo-router-" .. random_number
        local code_r_1, message_r_1 = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message_r_1)

        local random_number_2 = math.random(100000)

        local code, message, body = t('/apioak/admin/routers/' .. router_name, ngx.HTTP_PUT, {
            name     = "foo-router-" .. random_number_2,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {x = "bla"},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
OK
--- error_code chomp
200



=== TEST 7: router delete by id
--- config
location /t {
    content_by_lua_block {

        local t = require("tools.request").test
        local random_number = math.random(100000)

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local router_name = "foo-router-" .. random_number
        local code_r_1, message_r_1 = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message_r_1)

        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/routers/", router_name)

        local code, message, body = t('/apioak/admin/routers/' .. id, ngx.HTTP_DELETE)

        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
OK
--- error_code chomp
200



=== TEST 8: router delete by name[foo-router-001-to-delete]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local random_number = math.random(100000)

        local service_name = "foo-router-service-" .. random_number
        local code_s, message_s = t('/apioak/admin/services', ngx.HTTP_POST, {
            name = service_name,
            protocols = {"http", "https"},
            hosts = {"foo.com", "bar.com"},
            ports = {80, 443},
            plugins = {},
            enabled = true
        })

        ngx.say(message_s)

        local router_name = "foo-router-" .. random_number
        local code_r_1, message_r_1 = t('/apioak/admin/routers', ngx.HTTP_POST, {
            name     = router_name,
            methods  = {"GET", "POST"},
            paths    = {"/foo", "/bar"},
            headers  = {},
            service  = {name = service_name},
            plugins  = {},
            upstream = {},
            enabled  = true
        })

        ngx.say(message_r_1)

        local code, message, body = t('/apioak/admin/routers/' .. router_name, ngx.HTTP_DELETE)

        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
OK
--- error_code chomp
200