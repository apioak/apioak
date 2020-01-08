use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: add service (id:1001)
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



=== TEST 2: add router
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router', ngx.HTTP_POST, {
            name = "login interface",
            path = "/api/one",
            method = "GET",
            enable_cors = true,
            desc = "test api",
            request_params = {
                {
                    name = "time",
                    position = "Query",
                    type = "string",
                    default_val = "2019-12-12",
                    require = false,
                    desc = ""
                }
            },
            service_path = "/backend/api/one",
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



=== TEST 3: update router (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/1001', ngx.HTTP_PUT, {
            name = "login interface",
            path = "/api/one",
            method = "GET",
            enable_cors = true,
            desc = "test api",
            request_params = {
                {
                    name = "time",
                    position = "Query",
                    type = "string",
                    default_val = "2019-12-12",
                    require = false,
                    desc = ""
                }
            },
            service_path = "/backend/api/one",
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



=== TEST 4: query router (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/1001', ngx.HTTP_GET, nil, request_header)
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



=== TEST 5: query router list
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/routers', ngx.HTTP_GET, nil, request_header)
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



=== TEST 6: add plugin for router (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/1001/plugin', ngx.HTTP_POST, {
            key = "limit-conn",
            config = {
                rate = 200,
                burst = 100,
                key = "http_x_real_ip",
                default_conn_delay = 1
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



=== TEST 7: del plugin for router (id: 1001; plugin_key: limit-conn)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/1001/plugin/limit-conn', ngx.HTTP_DELETE, nil, request_header)
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



=== TEST 8: remove router (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/1001', ngx.HTTP_DELETE, nil, request_header)
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
