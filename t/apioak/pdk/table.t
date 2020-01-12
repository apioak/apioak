use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: table insert
--- config
location /t {
    content_by_lua_block {
        local test = {1}
        local t = require('apioak.pdk').table
        t.insert(test, 2)
        ngx.status = 200
        ngx.say(#test)
    }
}
--- request
GET /t
--- response_body
2
--- error_code chomp
200



=== TEST 2: table concat
--- config
location /t {
    content_by_lua_block {
        local t = require('apioak.pdk').table
        local test = t.concat({"table", "concat"}, "|")
        ngx.status = 200
        ngx.say(test)
    }
}
--- request
GET /t
--- response_body
table|concat
--- error_code chomp
200



=== TEST 3: table clear
--- config
location /t {
    content_by_lua_block {
        local test = {1}
        local t = require('apioak.pdk').table
        t.clear(test)
        ngx.status = 200
        ngx.say(#test)
    }
}
--- request
GET /t
--- response_body
0
--- error_code chomp
200



=== TEST 4: table remove
--- config
location /t {
    content_by_lua_block {
        local t = require('apioak.pdk').table
        local test = t.remove({1}, 1)
        ngx.status = 200
        ngx.say(test)
    }
}
--- request
GET /t
--- response_body
1
--- error_code chomp
200



=== TEST 5: table has
--- config
location /t {
    content_by_lua_block {
        local t = require('apioak.pdk').table
        local status = t.has("test", {"hello", "test"})
        ngx.status = 200
        if status then
            ngx.say("OK")
        else
            ngx.say("FAIL")
        end
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200
