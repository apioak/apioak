use Test::Nginx::Socket 'no_plan';
# use Test::Nginx::Socket skip_all => "== NO TEST ==";
run_tests();

__DATA__

=== TEST 1: hello, shuaijinchao
This is just a simple demonstration of the
echo directive provided by ngx_http_echo_module.
--- config
location = /t {
    echo "hello,shuaijinchao.";
}
--- request
GET /t
--- response_body
hello,shuaijinchao.
--- error_code chomp
200
--- SKIP

=== TEST 2: hello, shuaichuxin
This is just a simple demonstration of the
echo directive provided by ngx_http_echo_module.
--- config
location = /t {
    echo "hello,shuaichuxin";
}
--- request
GET /t
--- response_body
hello,shuaichuxin
--- error_code chomp
200

