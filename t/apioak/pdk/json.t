use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: json encode
--- config
location /t {
    content_by_lua_block {
        local t = require('apioak.pdk').json
        local d = t.encode({
            test = "json"
        })
        ngx.status = 200
        ngx.say(d)
    }
}
--- request
GET /t
--- response_body
{"test":"json"}
--- error_code chomp
200



=== TEST 2: json encode function
--- config
location /t {
    content_by_lua_block {
        local t = require('apioak.pdk').json
        local d = t.encode({
            test = "json",
            func = function() end
        }, true)
        ngx.status = 200
        ngx.say(d)
    }
}
--- request
GET /t
--- response_body_like eval
qr/\{"test":"json","func":"function: 0x[0-9a-f]+"}/
--- error_code chomp
200



=== TEST 3: json decode
--- config
location /t {
    content_by_lua_block {
        local t = require('apioak.pdk').json
        local d = t.decode("{\"test\":\"json\"}")
        ngx.status = 200
        ngx.say(d.test)
    }
}
--- request
GET /t
--- response_body
json
--- error_code chomp
200
