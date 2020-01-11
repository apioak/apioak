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
            prefix = "/demo01",
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


=== TEST 2: add router (id: 100101)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1001
        local code, message = t('/apioak/admin/router/100101', ngx.HTTP_PUT, {
            name = "test service plugin",
            path = "/service/plugin",
            method = "GET",
            enable_cors = true,
            desc = "test api",
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


=== TEST 4: test key-auth plugin for service (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["Authentication"] = "service-key-auth-plugin-test"
        local code, message = t("/demo01/service/plugin", ngx.HTTP_GET, nil, request_header)
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


=== TEST 5: add service (id:1002)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/service/1002', ngx.HTTP_PUT, {
            name = "test service",
            prefix = "/demo02",
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


=== TEST 6: add router (id: 100201)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1002
        local code, message = t('/apioak/admin/router/100201', ngx.HTTP_PUT, {
            name = "test service plugin",
            path = "/router/plugin",
            method = "GET",
            enable_cors = true,
            desc = "test api",
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



=== TEST 7: add plugin for router (service_id:1002 router_id:100201)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["APIOAK-SERVICE-ID"] = 1002
        local code, message = t('/apioak/admin/router/100201/plugin', ngx.HTTP_POST, {
            key = "key-auth",
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


=== TEST 8: test key-auth plugin for router (id: 100201)
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local request_header = {}
        request_header["Authentication"] = "router-key-auth-plugin-test"
        local code, message = t("/demo02/router/plugin", ngx.HTTP_GET, nil, request_header)
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




