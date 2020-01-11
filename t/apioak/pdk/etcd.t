use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: etcd create
--- config
location /t {
    content_by_lua_block {
        local t       = require('apioak.pdk').etcd
        local res, code, err  = t.create("/t", "test")
        ngx.status = code
        if err then
            ngx.say(err)
        else
            ngx.say("OK")
        end

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
201



=== TEST 2: etcd update (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t       = require('apioak.pdk').etcd
        local res, code, err  = t.update("/t/1001", "test_t2")
        ngx.status = code
        if err then
            ngx.say(err)
        else
            ngx.say("OK")
        end

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
201



=== TEST 3: etcd query (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t       = require('apioak.pdk').etcd
        local res, code, err  = t.query("/t/1001")
        ngx.status = code
        if err then
            ngx.say(err)
        else
            ngx.say("OK")
        end

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200



=== TEST 4: etcd delete (id: 1001)
--- config
location /t {
    content_by_lua_block {
        local t       = require('apioak.pdk').etcd
        local res, code, err  = t.delete("/t/1001")
        ngx.status = code
        if err then
            ngx.say(err)
        else
            ngx.say("OK")
        end

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200