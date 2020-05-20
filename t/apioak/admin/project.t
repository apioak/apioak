use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: account register
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, _ = t('/apioak/admin/account/register', ngx.HTTP_POST, {
            name = "test account",
            password = "123456",
            valid_password = "123456",
            email = "test@email.com",
        })

        local _, message = t('/apioak/admin/account/register', ngx.HTTP_POST, {
            name = "project user",
            password = "123456",
            valid_password = "123456",
            email = "project_user@email.com",
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
            name = "testCaseProject",
            path = "/test_case_project",
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
                            ip = "127.0.0.1",
                            port = 80,
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



=== TEST 4: project updated
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin    = account.user_info("test@email.com")
        local _, token    = account.get_token(admin.id)
        local _, p_info   = project.project_info("testCaseProject", "/test_case_project")
        local _, u_p_info = project.project_upstream(p_info.id, "PROD")
        local _, u_b_info = project.project_upstream(p_info.id, "BETA")
        local _, u_t_info = project.project_upstream(p_info.id, "TEST")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id, ngx.HTTP_PUT, {
            name = "testCaseProject",
            path = "/test_case_project_u",
            description = "test case project created description updated",
            upstreams = {
                {
                    id = u_p_info.id,
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
                            ip = "127.0.0.1",
                            port = 80,
                            weight = 100,
                        }
                    }
                },
                {
                    id = u_b_info.id,
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
                    id = u_b_info.id,
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



=== TEST 5: project selected
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id, ngx.HTTP_GET, {}, request_header)
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



=== TEST 6: project member created
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, user   = account.user_info("project_user@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/member', ngx.HTTP_POST, {
            user_id = user.id,
            is_admin = 0,
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



=== TEST 7: project member updated
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, user   = account.user_info("project_user@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/member/' .. user.id, ngx.HTTP_PUT, {
            is_admin = 1,
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



=== TEST 8: project member selected
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/members', ngx.HTTP_GET, {}, request_header)
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



=== TEST 9: project member deleted
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, user   = account.user_info("project_user@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/member/' .. user.id, ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 10: project plugin created
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/plugin', ngx.HTTP_POST, {
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



=== TEST 11: project plugin updated
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")
        local _, l_info = project.plugins_info("PROJECT", p_info.id, "limit-req")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/plugin/' .. l_info.id, ngx.HTTP_PUT, {
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



=== TEST 12: project plugin selected
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/plugins', ngx.HTTP_GET, {}, request_header)
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



=== TEST 13: project plugin deleted
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")
        local _, l_info = project.plugins_info("PROJECT", p_info.id, "limit-req")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/plugin/' .. l_info.id, ngx.HTTP_DELETE, {}, request_header)
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



=== TEST 14: project routers
--- config
location /t {
    content_by_lua_block {
        local t       = require("tools.request").test
        local account = require("tools.account")
        local project = require("tools.project")

        local _, admin  = account.user_info("test@email.com")
        local _, token  = account.get_token(admin.id)
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

        local request_header = {}
        request_header["APIOAK-ADMIN-TOKEN"] = token
        local code, message = t('/apioak/admin/project/' .. p_info.id .. '/routers', ngx.HTTP_GET, {}, request_header)
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
        local _, p_info = project.project_info("testCaseProject", "/test_case_project_u")

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

        local _, admin   = account.user_info("test@email.com")
        local code, _    = account.user_delete(admin.id)

        local _, user    = account.user_info("project_user@email.com")
        local _, message = account.user_delete(user.id)

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
