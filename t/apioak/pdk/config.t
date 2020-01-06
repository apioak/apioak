use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: get apioak configs
--- config
location /t {
    content_by_lua_block {
        local t       = require('apioak.pdk').config
        local config  = t.all()
        if type(config) == "table" then
            ngx.status = 200
            ngx.say("OK")
        else
            ngx.status = 500
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
