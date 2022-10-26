use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: plugin list
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins', ngx.HTTP_GET)
        ngx.status = code

        local json = require("cjson.safe")
        ngx.say(message)

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200


=== TEST 2: plugin create
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins', ngx.HTTP_POST, {
            name = "foo-plugin-001",
            key = "foo-plugin-001-1",
            config = { foo = "xxx", bar = "xxx"},
        })
        ngx.status = code
        ngx.say("OK")

        local t = require("tools.request").test
        local code2, message2, body2 = t('/apioak/admin/bete/plugins', ngx.HTTP_POST, {
            name = "foo-plugin-001-to-delete",
            key = "foo-plugin-001-to-delete-1",
            config = { foo = "xxx", bar = "xxx"},
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



=== TEST 3: plugin create name exists
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins', ngx.HTTP_POST, {
            name = "foo-plugin-001",
            key = "foo-plugin-001-1",
            config = { foo = "xxx", bar = "xxx"},
        })
        ngx.status = code
        local json = require("cjson.safe")
        ngx.say(json.encode(body))
    }
}
--- request
GET /t
--- response_body
{"message":"the plugin name[foo-plugin-001] already exists"}
--- error_code chomp
500



=== TEST 4: plugin detail by name[foo-plugin-001]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins/foo-plugin-001', ngx.HTTP_GET)
        ngx.status = code
        ngx.say(body.name)
    }
}
--- request
GET /t
--- response_body
foo-plugin-001
--- error_code chomp
200



=== TEST 5: plugin detail by id
--- config
location /t {
    content_by_lua_block {
        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/plugins/", "foo-plugin-001")

        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins/' .. id, ngx.HTTP_GET)
        ngx.status = code
        ngx.say(body.name)
    }
}
--- request
GET /t
--- response_body
foo-plugin-001
--- error_code chomp
200



=== TEST 6: plugin update by id
--- config
location /t {
    content_by_lua_block {

        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/plugins/", "foo-plugin-001")

        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins/' .. id, ngx.HTTP_PUT, {
            name = "foo-plugin-001-update",
            key = "foo-plugin-001-2",
            config = { foo = "xxx", bar = "xxx"},
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



=== TEST 7: plugin update by name[foo-plugin-001-update]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins/foo-plugin-001-update', ngx.HTTP_PUT, {
            name = "foo-plugin-001-update-by-name",
            key = "foo-plugin-001-2",
            config = { foo = "xxx", bar = "xxx"},
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



=== TEST 8: plugin delete by id
--- config
location /t {
    content_by_lua_block {
        local consul = require("tools.consul")
        local id = consul.get_kv_id("apioak/plugins/", "foo-plugin-001-update-by-name")

        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins/' .. id, ngx.HTTP_DELETE)
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



=== TEST 9: plugin delete by name[foo-plugin-001-to-delete]
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message, body = t('/apioak/admin/bete/plugins/foo-plugin-001-to-delete', ngx.HTTP_DELETE)
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