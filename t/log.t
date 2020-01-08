use t::APIOAK 'no_plan';

run_tests();

__DATA__

=== TEST 1: debug log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.debug("debug log")
    }
}
--- log_level chomp
debug
--- request
GET /t
--- error_log
debug log



=== TEST 2: info log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.info("info log")
    }
}
--- log_level chomp
info
--- request
GET /t
--- error_log
info log



=== TEST 3: notice log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.notice("notice log")
    }
}
--- log_level chomp
notice
--- request
GET /t
--- error_log
notice log



=== TEST 4: warn log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.warn("warn log")
    }
}
--- log_level chomp
warn
--- request
GET /t
--- error_log
warn log



=== TEST 5: error log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.error("error log")
    }
}
--- log_level chomp
error
--- request
GET /t
--- error_log
error log



=== TEST 6: crit log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.crit("crit log")
    }
}
--- log_level chomp
crit
--- request
GET /t
--- error_log
crit log



=== TEST 7: alert log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.alert("alert log")
    }
}
--- log_level chomp
alert
--- request
GET /t
--- error_log
alert log



=== TEST 8: emerg log
--- config
location /t {
    content_by_lua_block {
        local t = require("apioak.pdk").log
        t.emerg("emerg log")
    }
}
--- log_level chomp
alert
--- request
GET /t
--- error_log
emerg log
