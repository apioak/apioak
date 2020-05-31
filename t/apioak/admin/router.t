use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: account register
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/account/register', ngx.HTTP_POST, {
            name = "test account",
            password = "123456",
            valid_password = "123456",
            email = "test@email.com",
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



=== TEST 2: account login and set admin
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local code, message, user_info = t('/apioak/admin/account/login', ngx.HTTP_PUT, {
            password = "123456",
            email = "test@email.com",
        })
        ngx.status = code

        local _, set_res = account.set_admin(user_info.user.id)
        ngx.say(set_res)
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 3: project created
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")

        local _, admin = account.user_info("test@email.com")
        local _, token = account.get_token(admin.id)

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project', ngx.HTTP_POST, {
            name = "caseProject",
            path = "/case_project",
            description = "test case project created description",
            upstreams = {
                {
                    id = 0,
                    env = "PROD",
                    host = "produce",
                    type = "CHASH",
                    timeouts = {
                        connect = 5000,
                        send = 5000,
                        read = 5000,
                    },
                    nodes = {
                        {
                            ip = "::1",
                            port = 10777,
                            weight = 100,
                        }
                    }
                },
                {
                    id = 0,
                    env = "BETA",
                    host = "beta",
                    type = "CHASH",
                    timeouts = {
                        connect = 5000,
                        send = 5000,
                        read = 5000,
                    },
                    nodes = {
                        {
                            ip = "127.0.0.1",
                            port = 80,
                            weight = 100,
                        }
                    }
                },
                {
                    id = 0,
                    env = "TEST",
                    host = "test",
                    type = "CHASH",
                    timeouts = {
                        connect = 5000,
                        send = 5000,
                        read = 5000,
                    },
                    nodes = {
                        {
                            ip = "127.0.0.1",
                            port = 80,
                            weight = 100,
                        }
                    }
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



=== TEST 4: router created
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router', ngx.HTTP_POST, {
            project_id = p_info.id,
            id = 0,
            name = "路由测试",
            enable_cors = 1,
            description = "路由备注",
            request_path = "/test/router",
            request_method = "GET",
            request_params = {
                {
                    name = "id",
                    position = "QUERY",
                    type = "STRING",
                    default_val = "",
                    required = 1,
                    description = "this is id",
                    isTrusted = true
                }
            },
            backend_path = "/test/router/back",
            backend_method = "GET",
            backend_params = {
                {
                    request_param_position = "QUERY",
                    request_param_type = "STRING",
                    request_param_name = "id",
                    request_param_required = 1,
                    name = "id",
                    position = "QUERY",
                    request_param_description = "is id",
                    request_param_default_val = ""
                }
            },
            constant_params = {
                {
                    name = "content",
                    type = "STRING",
                    isTrusted = true,
                    description = "this is constant params",
                    position = "HEADER",
                    value = "123"
                }
            },
            response_type = "application/json",
            response_success = "",
            response_failure = "",
            response_codes = {},
            response_schema = {},
            response_success_schema = {},
            response_failure_schema = {}
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



=== TEST 5: router updated
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id, ngx.HTTP_PUT, {
            name = "路由测试更新",
            enable_cors = 1,
            description = "路由备注更新测试",
            request_path = "/test/router",
            request_method = "GET",
            request_params = {
                {
                    name = "id",
                    position = "QUERY",
                    type = "STRING",
                    default_val = "",
                    required = 1,
                    description = "this is id",
                    isTrusted = true
                }
            },
            backend_path = "/test/router/back",
            backend_method = "GET",
            backend_params = {
                {
                    request_param_position = "QUERY",
                    request_param_type = "STRING",
                    request_param_name = "id",
                    request_param_required = 1,
                    name = "id",
                    position = "QUERY",
                    request_param_description = "is id",
                    request_param_default_val = ""
                }
            },
            constant_params = {
                {
                    name = "content",
                    type = "STRING",
                    isTrusted = true,
                    description = "this is constant params",
                    position = "HEADER",
                    value = "123"
                }
            },
            response_type = "application/json",
            response_success = "",
            response_failure = "",
            response_codes = {},
            response_schema = {},
            response_success_schema = {},
            response_failure_schema = {}
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



=== TEST 6: router query
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id, ngx.HTTP_GET, {}, request_header)
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



=== TEST 7: router plugin created
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id .. '/plugin', ngx.HTTP_POST, {
            id = 0,
            name = "limit-req",
            type = "Traffic Control",
            description = "Lua module for limiting request rate.",
            config = {
                rate = 100,
                burst = 100
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



=== TEST 8: router plugin updated
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")
        local _, l_info = project.plugins_info("ROUTER", r_info.id, "limit-req")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id .. '/plugin/' .. l_info.id, ngx.HTTP_PUT, {
            name = "limit-req",
            type = "Traffic Control",
            description = "Lua module for limiting request rate.",
            config = {
                rate = 200,
                burst = 100
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



=== TEST 9: router plugins
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id .. '/plugins', ngx.HTTP_GET, {}, request_header)
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



=== TEST 10: router env push
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id .. '/env/PROD', ngx.HTTP_POST, {}, request_header)
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



=== TEST 11: router access
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local code, message = t('/case_project/test/router', ngx.HTTP_GET, {}, {}, 10080)
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



=== TEST 12: router env pull
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id .. '/env/TEST', ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 13: router plugin deleted
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")
        local _, l_info = project.plugins_info("ROUTER", r_info.id, "limit-req")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id .. '/plugin/' .. l_info.id, ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 14: router deleted
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")
        local _, r_info = project.routers_info(p_info.id, "/test/router", "GET")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/router/' .. r_info.id, ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 15: project deleted
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("caseProject", "/case_project")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id, ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 16: account delete
--- config
location /t {
    content_by_lua_block {
        local account = require("tools.account")

        local _, admin      = account.user_info("test@email.com")
        local code, message = account.user_delete(admin.id)
        ngx.status = code
        ngx.say(message)
    }
}
--- request
GET /t
--- response_body
1
--- error_code chomp
200
