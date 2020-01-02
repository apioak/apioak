use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: plugin list
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/plugins')
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
