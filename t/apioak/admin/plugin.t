use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: hello case
--- config
location /t {
    content_by_lua_block {
        ngx.say("hello case");
    }
}
--- request
GET /t
--- response_body
hello case
--- error_code chomp
200
