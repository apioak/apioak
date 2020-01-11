use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: limit-req
--- config
location /t {
    content_by_lua_block {
        local t       = require("apioak.plugin.limit-req")
        local res, err = t.http_access({
          plugins = {
              ["limit-req"] = {
                  rate = 1,
                  burst = 1,
                  key = "remote_addr"
              }
          }
       })

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

