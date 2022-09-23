use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: service create
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/services', ngx.HTTP_POST, {
            "name" = "my-service-test",
            "protocols" = ["http", "https"],
            "hosts" = ["example.com", "foo.test"],
            "ports" = [80, 443], 
            "plugins" = [],
            "enabled" = true
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
