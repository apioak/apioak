use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: service create
--- config
location /t {
    content_by_lua_block {
        local t = require("tools.request").test
        local code, message = t('/apioak/admin/services', ngx.HTTP_POST, {
            "name" = "foo-service",
            "protocols" = ["http", "https"],
            "hosts" = ["foo.com", "bar.com"],
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
