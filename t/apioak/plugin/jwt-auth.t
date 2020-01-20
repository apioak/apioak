use t::APIOAK 'no_plan';

run_tests();

__DATA__


=== TEST 1: add foo service (id:1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001', ngx.HTTP_PUT, {
            name = "test service",
            prefix = "/foo",
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


=== TEST 2: add foo router (id:100101)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/100101', ngx.HTTP_PUT, {
            name = "test router",
            path = "/foo/router",
            method = "GET",
            enable_cors = true,
            desc = "test router",
            request_params = {
                {
                    name = "time",
                    position = "Query",
                    type = "string",
                    default_val = "2020-01-10",
                    require = false,
                    desc = ""
                }
            },
            service_path = "/api/v1/test",
            service_method = "GET",
            timeout = 5,
            service_params = {
                {
                    service_name = "time",
                    service_position = "Query",
                    name = "time",
                    position = "Query",
                    type = "string",
                    desc = ""
                }
            },
            constant_params = {
                {
                    name = "gateway",
                    position = "Query",
                    value = "apioak",
                    desc = ""
                }
            },
            response_type = "JSON",
            response_success = "{\"code\":200,\"message\":\"OK\"}",
            response_fail = "{\"code\":500,\"message\":\"error\"}",
            response_error_codes = {
                {
                    code = 200,
                    msg = "OK",
                    desc = ""
                }
            }
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

=== TEST 3: add plugin for service (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1001/plugin', ngx.HTTP_POST, {
            key = "key-auth",
            config = {
                secret = "service-key-auth-plugin-test"
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

=== TEST 4: add plugin for router (service_id:1001 router_id:100101)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/100101/plugin', ngx.HTTP_POST, {
            key = "jwt-auth",
            config = {
                secret = "router-key-auth-plugin-test"
            }
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


=== TEST 5: verify auth in header
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["Authentication"] = "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmb28iOiJiYXIifQ.nZljQfIhbUM-Iyi-rddghB7Svsdwv2YLP6FcpLLpf0c"
        local code, message = t("/foo/foo/router", ngx.HTTP_GET, nil, request_header)
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


=== TEST 6: verify auth in query
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t("/foo/foo/router?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmb28iOiJiYXIifQ.nZljQfIhbUM-Iyi-rddghB7Svsdwv2YLP6FcpLLpf0c", ngx.HTTP_GET, nil, {})
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
