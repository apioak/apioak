package t::APIOAK;

use Cwd qw(cwd);
use Test::Nginx::Socket::Lua::Stream -Base;

repeat_each(1);
log_level('info');
no_root_location();
no_long_string();
no_shuffle();
worker_connections(128);

sub read_file($) {
    my $infile = shift;
    open my $in, $infile
        or die "cannot open $infile for reading: $!";
    my $cert = do { local $/; <$in> };
    close $in;
    $cert;
}

my $pwd = cwd();
my $apioak_config = read_file("conf/apioak.yaml");

add_block_preprocessor(sub {
    my ($block) = @_;

    my $main_config = $block->main_config // <<_EOC_;

    worker_rlimit_core  500M;
    working_directory   $pwd;

_EOC_

    $block->set_value("main_config", $main_config);


    my $http_config = $block->http_config;
    $http_config .= <<_EOC_;

    lua_package_path  "$pwd/t/?.lua;$pwd/deps/share/lua/5.1/?.lua;$pwd/?.lua;/usr/share/lua/5.1/?.lua;;";
    lua_package_cpath "$pwd/deps/lib64/lua/5.1/?.so;$pwd/deps/lib/lua/5.1/?.so;/usr/lib64/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;;";
    lua_code_cache on;

    resolver 8.8.8.8 114.114.114.114 ipv6=on;

    client_max_body_size 0;

    real_ip_header X-Real-IP;
    set_real_ip_from 127.0.0.1;
    set_real_ip_from unix:;

    more_set_headers 'Server: APIOAK API Gateway';

    lua_shared_dict apioak 100m;
    lua_shared_dict plugin_limit_conn  10m;
    lua_shared_dict plugin_limit_req   10m;
    lua_shared_dict plugin_limit_count 10m;
    lua_shared_dict upstream_health_check 10m;
    lua_shared_dict upstream_worker_event 10m;

    upstream apioak_backend {
        server 0.0.0.1;
        balancer_by_lua_block {
            apioak.http_balancer()
        }
        keepalive 1024;
    }

    init_by_lua_block {
        apioak = require "apioak.apioak"
        apioak.init()
    }

    init_worker_by_lua_block {
        apioak.init_worker()
    }

    server {
        listen 10777;
        listen [::]:10777;
        location / {
            content_by_lua_block {
                local json = require "cjson"
                ngx.status = 200
                ngx.header["Content-Type"] = "application/json"
                local response = {}
                response["host"]   = ngx.var.host
                response["uri"]    = ngx.var.uri
                response["query"]  = ngx.req.get_uri_args()
                ngx.req.read_body()
                response["body"]   = ngx.req.get_post_args()
                response["header"] = ngx.req.get_headers()
                ngx.say(json.encode(response))
            }
        }
    }

_EOC_

    $block->set_value("http_config", $http_config);


    my $config = $block->config;
    $config .= <<_EOC_;

    location /apioak/admin {
        content_by_lua_block {
            apioak.http_admin()
        }
    }

    location / {
        add_header X-Request-Id \$request_id;

        access_by_lua_block {
            apioak.http_access()
        }

        header_filter_by_lua_block {
            apioak.http_header_filter()
        }

        body_filter_by_lua_block {
            apioak.http_body_filter()
        }

        log_by_lua_block {
            apioak.http_log()
        }

        set \$upstream_scheme             'http';
        set \$upstream_host               \$host;
        set \$upstream_upgrade            '';
        set \$upstream_connection         '';
        set \$upstream_uri                '';

        proxy_http_version 1.1;
        proxy_set_header   Host              \$upstream_host;
        proxy_set_header   Upgrade           \$upstream_upgrade;
        proxy_set_header   Connection        \$upstream_connection;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Request-Id      \$request_id;
        proxy_pass_header  Server;
        proxy_pass_header  Date;
        proxy_pass         \$upstream_scheme://apioak_backend\$upstream_uri;
    }

_EOC_

    $block->set_value("config", $config);

    my $user_files = $block->user_files;
    $user_files .= <<_EOC_;

>>> ../conf/apioak.yaml
$apioak_config

_EOC_

    $block->set_value("user_files", $user_files);

    $block;
});

1;
