package = "apioak"
version = "master-0"
rockspec_format = "3.0"
supported_platforms = {"linux", "macosx"}

source = {
    url = "git://github.com/apioak/apioak",
    branch = "master",
}

description = {
    summary = "APIOAK provides full life cycle management of API release, management, and operation and maintenance.",
    homepage = "https://github.com/apioak/apioak",
    license = "Apache License 2.0",
    maintainer = "Janko <shuaijinchao@gmail.com>"
}

dependencies = {
    "lua-resty-worker-events == 2.0.1-1",
    "lua-resty-balancer == 0.02rc5",
    "lua-resty-jwt == 0.2.0",
    "lua-resty-oakrouting == 0.2.0-1",
    "lua-resty-http == 0.15-0",
    "lua-resty-lrucache == 0.09-2",
    "jsonschema == 0.9.8-0",
    "luasocket == 3.0rc1-2",
    "luafilesystem == 1.7.0-2",
    "lua-tinyyaml == 0.1",
    "multipart == 0.5.5-1",
    "penlight == 1.5.4-1",
    "lua-resty-consul == 0.3-2",
    "lua-resty-jit-uuid == 0.0.7-2",
    "lua-resty-dns == 0.21-1"
}

build = {
    type = "builtin",
    modules = {
        -- Core modules
        ["apioak"] = "apioak/apioak.lua",
        ["apioak.admin"] = "apioak/admin.lua",
        ["apioak.dao"] = "apioak/dao.lua",
        ["apioak.pdk"] = "apioak/pdk.lua",
        ["apioak.schema"] = "apioak/schema.lua",
        ["apioak.sys"] = "apioak/sys.lua",

        -- Admin modules
        ["apioak.admin.certificate"] = "apioak/admin/certificate.lua",
        ["apioak.admin.controller"] = "apioak/admin/controller.lua",
        ["apioak.admin.plugin"] = "apioak/admin/plugin.lua",
        ["apioak.admin.router"] = "apioak/admin/router.lua",
        ["apioak.admin.service"] = "apioak/admin/service.lua",
        ["apioak.admin.upstream"] = "apioak/admin/upstream.lua",
        ["apioak.admin.upstream_node"] = "apioak/admin/upstream_node.lua",

        -- Admin DAO modules
        ["apioak.admin.dao.certificate"] = "apioak/admin/dao/certificate.lua",
        ["apioak.admin.dao.common"] = "apioak/admin/dao/common.lua",
        ["apioak.admin.dao.plugin"] = "apioak/admin/dao/plugin.lua",
        ["apioak.admin.dao.router"] = "apioak/admin/dao/router.lua",
        ["apioak.admin.dao.service"] = "apioak/admin/dao/service.lua",
        ["apioak.admin.dao.upstream"] = "apioak/admin/dao/upstream.lua",
        ["apioak.admin.dao.upstream_node"] = "apioak/admin/dao/upstream_node.lua",

        -- Admin Schema modules
        ["apioak.admin.schema.certificate"] = "apioak/admin/schema/certificate.lua",
        ["apioak.admin.schema.common"] = "apioak/admin/schema/common.lua",
        ["apioak.admin.schema.plugin"] = "apioak/admin/schema/plugin.lua",
        ["apioak.admin.schema.router"] = "apioak/admin/schema/router.lua",
        ["apioak.admin.schema.service"] = "apioak/admin/schema/service.lua",
        ["apioak.admin.schema.upstream"] = "apioak/admin/schema/upstream.lua",
        ["apioak.admin.schema.upstream_node"] = "apioak/admin/schema/upstream_node.lua",

        -- Command modules
        ["apioak.cmd"] = "apioak/cmd/init.lua",
        ["apioak.cmd.env"] = "apioak/cmd/env.lua",
        ["apioak.cmd.help"] = "apioak/cmd/help.lua",
        ["apioak.cmd.init"] = "apioak/cmd/init.lua",
        ["apioak.cmd.quit"] = "apioak/cmd/quit.lua",
        ["apioak.cmd.reload"] = "apioak/cmd/reload.lua",
        ["apioak.cmd.restart"] = "apioak/cmd/restart.lua",
        ["apioak.cmd.start"] = "apioak/cmd/start.lua",
        ["apioak.cmd.stop"] = "apioak/cmd/stop.lua",
        ["apioak.cmd.test"] = "apioak/cmd/test.lua",
        ["apioak.cmd.version"] = "apioak/cmd/version.lua",

        -- Command Utils modules
        ["apioak.cmd.utils.common"] = "apioak/cmd/utils/common.lua",
        ["apioak.cmd.utils.kill"] = "apioak/cmd/utils/kill.lua",
        ["apioak.cmd.utils.nginx_signals"] = "apioak/cmd/utils/nginx_signals.lua",

        -- PDK modules
        ["apioak.pdk.const"] = "apioak/pdk/const.lua",
        ["apioak.pdk.consul"] = "apioak/pdk/consul.lua",
        ["apioak.pdk.ctx"] = "apioak/pdk/ctx.lua",
        ["apioak.pdk.json"] = "apioak/pdk/json.lua",
        ["apioak.pdk.log"] = "apioak/pdk/log.lua",
        ["apioak.pdk.plugin"] = "apioak/pdk/plugin.lua",
        ["apioak.pdk.request"] = "apioak/pdk/request.lua",
        ["apioak.pdk.response"] = "apioak/pdk/response.lua",
        ["apioak.pdk.schema"] = "apioak/pdk/schema.lua",
        ["apioak.pdk.shared"] = "apioak/pdk/shared.lua",
        ["apioak.pdk.string"] = "apioak/pdk/string.lua",
        ["apioak.pdk.table"] = "apioak/pdk/table.lua",
        ["apioak.pdk.tablepool"] = "apioak/pdk/tablepool.lua",
        ["apioak.pdk.time"] = "apioak/pdk/time.lua",

        -- Plugin modules
        ["apioak.plugin.plugin_common"] = "apioak/plugin/plugin_common.lua",

        -- CORS Plugin
        ["apioak.plugin.cors.cors"] = "apioak/plugin/cors/cors.lua",
        ["apioak.plugin.cors.schema-cors"] = "apioak/plugin/cors/schema-cors.lua",

        -- JWT Auth Plugin
        ["apioak.plugin.jwt-auth.jwt-auth"] = "apioak/plugin/jwt-auth/jwt-auth.lua",
        ["apioak.plugin.jwt-auth.schema-jwt-auth"] = "apioak/plugin/jwt-auth/schema-jwt-auth.lua",

        -- Key Auth Plugin
        ["apioak.plugin.key-auth.key-auth"] = "apioak/plugin/key-auth/key-auth.lua",
        ["apioak.plugin.key-auth.schema-key-auth"] = "apioak/plugin/key-auth/schema-key-auth.lua",

        -- Limit Connection Plugin
        ["apioak.plugin.limit-conn.limit-conn"] = "apioak/plugin/limit-conn/limit-conn.lua",
        ["apioak.plugin.limit-conn.schema-limit-conn"] = "apioak/plugin/limit-conn/schema-limit-conn.lua",

        -- Limit Count Plugin
        ["apioak.plugin.limit-count.limit-count"] = "apioak/plugin/limit-count/limit-count.lua",
        ["apioak.plugin.limit-count.schema-limit-count"] = "apioak/plugin/limit-count/schema-limit-count.lua",

        -- Limit Request Plugin
        ["apioak.plugin.limit-req.limit-req"] = "apioak/plugin/limit-req/limit-req.lua",
        ["apioak.plugin.limit-req.schema-limit-req"] = "apioak/plugin/limit-req/schema-limit-req.lua",

        -- Mock Plugin
        ["apioak.plugin.mock.mock"] = "apioak/plugin/mock/mock.lua",
        ["apioak.plugin.mock.schema-mock"] = "apioak/plugin/mock/schema-mock.lua",

        -- System modules
        ["apioak.sys.admin"] = "apioak/sys/admin.lua",
        ["apioak.sys.balancer"] = "apioak/sys/balancer.lua",
        ["apioak.sys.cache"] = "apioak/sys/cache.lua",
        ["apioak.sys.certificate"] = "apioak/sys/certificate.lua",
        ["apioak.sys.config"] = "apioak/sys/config.lua",
        ["apioak.sys.dao"] = "apioak/sys/dao.lua",
        ["apioak.sys.meta"] = "apioak/sys/meta.lua",
        ["apioak.sys.plugin"] = "apioak/sys/plugin.lua",
        ["apioak.sys.router"] = "apioak/sys/router.lua",
    },
}
