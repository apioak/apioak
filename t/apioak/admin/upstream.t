use t::APIOAK 'no_plan';

no_shuffle();
run_tests();

__DATA__

=== TEST 1: upstream created: upstream node abnormal (upstream name: test-nginx-upstream-created, node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstreams", ngx.HTTP_POST, {
            name = "test-nginx-upstream-created",
            nodes = {
                {
                    name = "test-nginx-upstream-node-created"
                }
            },
            algorithm = "round-robin",
            connect_timeout = 1000,
            write_timeout = 1000,
            read_timeout = 1000,
        })

        ngx.status = code
        ngx.say(message)

        local json = require("cjson.safe")
        ngx.say(json.encode(body))
    }
}
--- request
GET /t
--- response_body
FAIL
{"message":"the upstream nodes is abnormal"}
--- error_code chomp
400



=== TEST 2: upstream created success (upstream name: test-nginx-upstream-created, node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstream/nodes", ngx.HTTP_POST, {
            name = "test-nginx-upstream-node-created",
            address = "127.0.0.1",
            port = 8888,
            check = {}
        })

        ngx.status = code
        ngx.say(message)

        local code, message, body = t("/apioak/admin/upstreams", ngx.HTTP_POST, {
            name = "test-nginx-upstream-created",
            nodes = {
                {
                    name = "test-nginx-upstream-node-created"
                }
            },
            algorithm = "round-robin",
            connect_timeout = 1000,
            write_timeout = 1000,
            read_timeout = 1000
        })

        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
--- error_code chomp
200



=== TEST 3: upstream update success (upstream name: test-nginx-upstream-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstreams/test-nginx-upstream-created", ngx.HTTP_PUT, {
            name = "test-nginx-upstream-created",
            algorithm = "round-robin",
            connect_timeout = 2000,
            write_timeout = 3000,
            read_timeout = 4000,
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



=== TEST 4: upstream list success
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstreams", ngx.HTTP_GET)

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



=== TEST 5: upstream detail success (upstream name: test-nginx-upstream-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstreams/test-nginx-upstream-created", ngx.HTTP_GET)

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



=== TEST 6: upstream deleted success (upstream name: test-nginx-upstream-created, node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstreams/test-nginx-upstream-created", ngx.HTTP_DELETE)

        ngx.status = code
        ngx.say(message)

        local code, message, body = t("/apioak/admin/upstream/nodes/test-nginx-upstream-node-created", ngx.HTTP_DELETE)

        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
OK
OK
--- error_code chomp
200
