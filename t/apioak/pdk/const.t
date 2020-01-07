use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: get const local ip
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').const
        local ip   = t.LOCAL_IP
        ngx.status = 200
        ngx.say(ip)
    }
}
--- request
GET /t
--- response_body
127.0.0.1
--- error_code chomp
200



=== TEST 2: get const local host
--- config
location /t {
    content_by_lua_block {
        local t    = require('apioak.pdk').const
        local host = t.LOCAL_HOST
        ngx.status = 200
        ngx.say(host)
    }
}
--- request
GET /t
--- response_body
localhost
--- error_code chomp
200



=== TEST 3: get const balancer chash
--- config
location /t {
    content_by_lua_block {
        local t     = require('apioak.pdk').const
        local chash = t.BALANCER_CHASH
        ngx.status  = 200
        ngx.say(chash)
    }
}
--- request
GET /t
--- response_body
chash
--- error_code chomp
200



=== TEST 4: get const balancer roundrobin
--- config
location /t {
    content_by_lua_block {
        local t          = require('apioak.pdk').const
        local roundrobin = t.BALANCER_ROUNDROBIN
        ngx.status       = 200
        ngx.say(roundrobin)
    }
}
--- request
GET /t
--- response_body
roundrobin
--- error_code chomp
200
