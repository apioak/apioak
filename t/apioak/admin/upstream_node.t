use t::APIOAK 'no_plan';

no_shuffle();
run_tests();

__DATA__

=== TEST 1: upstream node created success (upstream node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstream/nodes", ngx.HTTP_POST, {
            name = "test-nginx-upstream-node-created",
            address = "127.0.0.1",
            port = 8888,
            health = "HEALTH",
            weight = 1,
            check = {
                enabled = false,
            },
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



=== TEST 2: upstream node updated success (upstream node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstream/nodes/test-nginx-upstream-node-created", ngx.HTTP_PUT, {
            name = "test-nginx-upstream-node-created",
            address = "127.0.0.1",
            port = 8888,
            health = "UNHEALTH",
            weight = 1,
            check = {
                enabled = false,
            },
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



=== TEST 3: upstream node list success
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstream/nodes", ngx.HTTP_GET)

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



=== TEST 4: upstream node detail success (upstream node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstream/nodes/test-nginx-upstream-node-created", ngx.HTTP_GET)

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



=== TEST 5: upstream node deleted success (upstream node name: test-nginx-upstream-node-created)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test

        local code, message, body = t("/apioak/admin/upstream/nodes/test-nginx-upstream-node-created", ngx.HTTP_DELETE)

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
