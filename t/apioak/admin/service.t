use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: add service
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service', ngx.HTTP_POST, {
            name = "test service",
            prefix = "/test",
            desc = "this is a test project",
            upstreams = {
                prod = {
                    host = "prod.apioak.com",
                    type = "chash",
                    nodes = {
                        {
                            port = 10111,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                        {
                            port = 10222,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                    }
                },
                beta = {
                    host = "prod.apioak.com",
                    type = "roundrobin",
                    nodes = {
                        {
                            port = 10111,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                        {
                            port = 10222,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                    }
                },
                test = {
                    host = "prod.apioak.com",
                    type = "chash",
                    nodes = {
                        {
                            port = 10111,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                        {
                            port = 10222,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                    }
                }
            }
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



=== TEST 2: update service (id:1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001', ngx.HTTP_PUT, {
            name = "test service",
            prefix = "/test",
            desc = "this is a test project",
            upstreams = {
                prod = {
                    host = "prod.apioak.com",
                    type = "chash",
                    nodes = {
                        {
                            port = 10111,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                        {
                            port = 10222,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                    }
                },
                beta = {
                    host = "prod.apioak.com",
                    type = "roundrobin",
                    nodes = {
                        {
                            port = 10111,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                        {
                            port = 10222,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                    }
                },
                test = {
                    host = "prod.apioak.com",
                    type = "chash",
                    nodes = {
                        {
                            port = 10111,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                        {
                            port = 10222,
                            ip = "127.0.0.1",
                            weight = 50,
                        },
                    }
                }
            }
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



=== TEST 3: query service (id:1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001', ngx.HTTP_GET)
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



=== TEST 4: query service list
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/services', ngx.HTTP_GET)
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


=== TEST 5: add plugin for service (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001/plugin', ngx.HTTP_POST, {
            key = "limit-conn",
            config = {
                rate = 200,
                burst = 100,
                key = "http_x_real_ip",
                default_conn_delay = 1
            }
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



=== TEST 6: del plugin for service (id: 1001; plugin_key: limit-conn)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001/plugin/limit-conn', ngx.HTTP_DELETE)
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



=== TEST 7: remove service (id:1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001', ngx.HTTP_DELETE)
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
