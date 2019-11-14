use Test::Nginx::Socket 'no_plan';
run_tests();

__DATA__

=== TEST 1: hi, shuaijinchao
This is just a simple demonstration of the
echo directive provided by ngx_http_echo_module.
--- config
location = /t {
    echo "hi,shuaijinchao.";
}
--- request
GET /t
--- response_body
hi,shuaijinchao.
--- error_code chomp
200
--- ONLY

=== TEST 2: hi, shuaichuxin
This is just a simple demonstration of the
echo directive provided by ngx_http_echo_module.
--- config
location = /t {
    echo "hi,shuaichuxin";
}
--- request
GET /t
--- response_body
hi,shuaichuxin
--- error_code chomp
200
