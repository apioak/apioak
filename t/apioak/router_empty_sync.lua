local original_ngx = ngx
local process_type = "worker"
local registered_handler
local registered_source
local registered_event
local scheduled = {}
local router_posts = 0
local sync_data = { new = "pending", old = "applied" }

local function run()
    local pdk = {
        const = {},
        json = { encode = function() return "{}" end },
        log = { error = function() end, info = function() end, warn = function() end },
        schema = { check = function() return true, nil end },
        string = { lower = string.lower },
    }

    local service = {
        id = "service-1",
        name = "service",
        hosts = { "api.example.test" },
        protocols = { "http" },
        plugins = {},
        enabled = true,
    }

    local dao = {
        common = {
            PREFIX_MAP = { services = "services/", routers = "routers/" },
            list_keys = function(prefix)
                if prefix == "services/" then
                    return { list = { service } }, nil
                end
                return { list = {} }, nil
            end,
            get_sync_data = function()
                return { new = sync_data.new, old = sync_data.old }, nil
            end,
            update_sync_data_hash = function(init)
                if init then
                    sync_data.old = sync_data.new
                end
                return true, nil
            end,
        },
    }

    local events = {
        register = function(handler, source, event)
            registered_handler = handler
            registered_source = source
            registered_event = event
        end,
        post = function(source, event, data)
            if source == registered_source and event == registered_event then
                router_posts = router_posts + 1
                registered_handler(data, event, source)
            end
            return true, nil
        end,
    }

    local oakrouting = {
        new = function(routes)
            return {
                dispatch = function(_, path, method, ctx)
                    for _, route in ipairs(routes) do
                        if route.path == path then
                            for _, allowed_method in ipairs(route.method) do
                                if allowed_method == method then
                                    route.handler(path, ctx)
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end,
            }
        end,
    }

    local schema = {
        service = { service_data = {} },
        router = { router_data = {} },
    }

    local certificate = {
        events_source_ssl = "events_source_ssl",
        events_type_put_ssl = "events_type_put_ssl",
        sync_update_ssl_data = function() return {} end,
    }
    local balancer = {
        events_source_upstream = "events_source_upstream",
        events_type_put_upstream = "events_type_put_upstream",
        sync_update_upstream_data = function() return {} end,
    }
    local plugin = {
        events_source_plugin = "events_source_plugin",
        events_type_put_plugin = "events_type_put_plugin",
        sync_update_plugin_data = function() return {} end,
    }

    package.preload["apioak.pdk"] = function() return pdk end
    package.preload["apioak.dao"] = function() return dao end
    package.preload["resty.worker.events"] = function() return events end
    package.preload["apioak.schema"] = function() return schema end
    package.preload["resty.oakrouting"] = function() return oakrouting end
    package.preload["apioak.sys.certificate"] = function() return certificate end
    package.preload["apioak.sys.balancer"] = function() return balancer end
    package.preload["apioak.sys.plugin"] = function() return plugin end
    package.preload["ngx.process"] = function()
        return { type = function() return process_type end }
    end

    ngx = {
        sleep = function() end,
        timer = {
            at = function(_, callback)
                scheduled[#scheduled + 1] = callback
                return true, nil
            end,
        },
        worker = { exiting = function() return false end },
    }

    package.loaded["apioak.sys.router"] = nil
    local router = require("apioak.sys.router")
    router.init_worker()

    assert(registered_handler ~= nil, "worker should register its router event handler")
    assert(scheduled[1] ~= nil, "init_worker should schedule synchronization")

    registered_handler({
        {
            hosts = { "api.example.test" },
            protocols = { "http" },
            routers = {
                {
                    paths = { "/deleted" },
                    methods = { "GET" },
                    headers = {},
                    plugins = {},
                    upstream = {},
                },
            },
        },
    }, registered_event, registered_source)

    local ctx = {
        matched = {
            host = "api.example.test",
            uri = "/deleted",
            scheme = "http",
            method = "GET",
            header = {},
        },
    }
    assert(router.router_match(ctx), "route should match before deletion sync")

    process_type = "privileged agent"
    scheduled[1](false)

    assert(router_posts == 1, "empty route state should be broadcast to workers")
    assert(not router.router_match(ctx), "deleted route must not remain in the worker cache")
end

local ok, err = pcall(run)
_G.ngx = original_ngx
if not ok then
    error(err)
end

return true
