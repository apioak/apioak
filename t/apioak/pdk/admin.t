use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: get router etcd key by master env
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key(nil, 1001, 1002)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/master/routers/1002
--- error_code chomp
200



=== TEST 2: get router etcd key by prod env
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key("prod", 1001, 1002)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/prod/routers/1002
--- error_code chomp
200



=== TEST 3: get router etcd key by beta env
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key("beta", 1001, 1002)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/beta/routers/1002
--- error_code chomp
200



=== TEST 4: get router etcd key by dev env
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key("dev", 1001, 1002)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/dev/routers/1002
--- error_code chomp
200



=== TEST 5: get router etcd key by master service
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key(nil, 1001)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/master/routers
--- error_code chomp
200



=== TEST 6: get router etcd key by prod service
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key("prod", 1001)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/prod/routers
--- error_code chomp
200



=== TEST 7: get router etcd key by beta service
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key("beta", 1001)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/beta/routers
--- error_code chomp
200



=== TEST 8: get router etcd key by dev service
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_router_etcd_key("dev", 1001)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/X1001/dev/routers
--- error_code chomp
200



=== TEST 9: get service 1001 etcd key
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_service_etcd_key(1001)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services/1001
--- error_code chomp
200



=== TEST 10: get services id
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_service_etcd_key(nil)
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
/services
--- error_code chomp
200



=== TEST 11: get service id for service key
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').admin
        local key  = t.get_service_id_by_etcd_key("/services/1001")
        ngx.status = 200
        ngx.say(key)
    }
}
--- request
GET /t
--- response_body
1001
--- error_code chomp
200
