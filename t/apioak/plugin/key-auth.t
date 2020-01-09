use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST key-auth:
--- config
location = /t {
    content_by_lua_block {

        local set = require("tools.etcd").set_data
        local name  = "Key Auth"
        local keys = '["key-auth1","key-auth2"]'

        local code, msg = set(name, keys)

        ngx.status = code
        ngx.say(msg)

    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200

