use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: limit-conn
--- config
location /t {
    content_by_lua_block {
        local t       = require("apioak.plugin.limit-conn")
        local res, err = t.http_access({
            plugins = {
                ["limit-conn"] = {
                    rate = 200,
                    burst = 100,
                    key = "remote_addr",
                    default_conn_delay = 1
                }
            }
        })

        ngx.status = 200
        ngx.say("OK")
    }

    log_by_lua_block {
        local t       = require("apioak.plugin.limit-conn")
        local res, err = t.http_log()
    }
}
--- request
GET /t
--- response_body
OK
--- error_code chomp
200

