use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: limit-count
--- config
location /t {
    content_by_lua_block {
        local t       = require("apioak.plugin.limit-count")
        local config = {
           plugins = {
               limit_count = {
                   rate = 100,
                   burst = 200,
                   key = "remote_addr",
                   default_conn_delay = 1
               }
           }
        }

        t.http_access(config)

        ngx.status = 200
        ngx.say("OK")
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200

