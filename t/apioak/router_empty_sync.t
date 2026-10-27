use Cwd qw(cwd);
use Test::Nginx::Socket::Lua;

repeat_each(1);
workers(1);
no_long_string();

my $pwd = cwd();
our $HttpConfig = qq{lua_package_path "$pwd/?.lua;;";};

run_tests();

__DATA__

=== TEST 1: removing the last route clears the worker router cache
--- http_config eval: $::HttpConfig
--- config
location /t {
    content_by_lua_block {
        local ok, err = pcall(require, "t.apioak.router_empty_sync")
        if not ok then
            ngx.status = 500
            ngx.say(err)
            return
        end
        ngx.say("cleared")
    }
}
--- request
GET /t
--- response_body
cleared
--- error_code chomp
200
