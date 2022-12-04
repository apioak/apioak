local ngx      = ngx
local pdk      = require("apioak.pdk")
local dao      = require("apioak.dao")
local schema   = require("apioak.schema")
local events   = require("resty.worker.events")
local cache    = require("apioak.sys.cache")
local resolver = require("resty.dns.resolver")
local math_random        = math.random
local ngx_sleep          = ngx.sleep
local ngx_timer_at       = ngx.timer.at
local ngx_worker_exiting = ngx.worker.exiting
local ngx_process        = require("ngx.process")
local balancer           = require("ngx.balancer")
local balancer_round     = require('resty.roundrobin')
local balancer_chash     = require('resty.chash')

local events_source_upstream   = "events_source_upstream"
local events_type_put_upstream = "events_type_put_upstream"

local resolver_address_cache_prefix = "resolver_address_cache_prefix"

local upstream_objects = {}
local resolver_client

local _M = {}

local function upstream_nodes_list()

    local upstream_list, err = dao.common.list_keys(dao.common.PREFIX_MAP.upstreams)

    if err then
        pdk.log.error("upstream_nodes_list: get upstream list FAIL [".. err .."]")
        return nil
    end

    if not upstream_list or not upstream_list.list or (#upstream_list.list == 0) then
        pdk.log.error("upstream_nodes_list: upstream list null ["
                              .. pdk.json.encode(upstream_list, true) .. "]")
        return nil
    end

    local node_list, err = dao.common.list_keys(dao.common.PREFIX_MAP.upstream_nodes)

    if err then
        pdk.log.error("upstream_nodes_list: get upstream node list FAIL [".. err .."]")
        return nil
    end

    local node_map_by_id = {}

    if node_list and node_list.list and (#node_list.list > 0) then

        local health = dao.upstream_node.DEFAULT_HEALTH

        for i = 1, #node_list.list do

            repeat
                local _, err = pdk.schema.check(schema.upstream_node.upstream_node_data, node_list.list[i])

                if err then
                    pdk.log.error("upstream_nodes_list: upstream node schema check err:[" .. err .. "]["
                                          .. pdk.json.encode(node_list.list[i], true) .. "]")
                    break
                end

                if node_list.list[i].health ~= health then
                    break
                end

                node_map_by_id[node_list.list[i].id] = {
                    address = node_list.list[i].address,
                    port    = node_list.list[i].port,
                    weight  = node_list.list[i].weight,
                }
            until true

        end

    end

    local all_balancer_map = {}

    for i = 1, #pdk.const.ALL_BALANCERS do
        all_balancer_map[pdk.const.ALL_BALANCERS[i]] = 0
    end

    local upstreams_nodes_list = {}

    for j = 1, #upstream_list.list do

        repeat
            local _, err = pdk.schema.check(schema.upstream.upstream_data, upstream_list.list[j])

            if err then
                pdk.log.error("upstream_nodes_list: upstream schema check err:[" .. err .. "]["
                                      .. pdk.json.encode(upstream_list.list[j], true) .. "]")
                break
            end

            if not all_balancer_map[upstream_list.list[j].algorithm] then
                break
            end

            local upstream_nodes = {}

            for k = 1, #upstream_list.list[j].nodes do

                repeat
                    local node = node_map_by_id[upstream_list.list[j].nodes[k].id]

                    if not node then
                        break
                    end

                    table.insert(upstream_nodes, node)
                until true

            end

            if #upstream_nodes == 0 then
                pdk.log.error("upstream_nodes_list: the upstream node does not match the data: ["
                                      .. pdk.json.encode(upstream_list.list[j], true) .. "]")
                break
            end

            table.insert(upstreams_nodes_list, {
                id              = upstream_list.list[j].id,
                nodes           = upstream_nodes,
                algorithm       = upstream_list.list[j].algorithm,
                read_timeout    = upstream_list.list[j].read_timeout,
                write_timeout   = upstream_list.list[j].write_timeout,
                connect_timeout = upstream_list.list[j].connect_timeout,
            })

        until true
    end

    if next(upstreams_nodes_list) then
        return upstreams_nodes_list
    end

    return nil
end

local function automatic_sync_upstream()

    if ngx_process.type() ~= "privileged agent" then
        return
    end

    local i, limit = 0, 10

    while not ngx_worker_exiting() and i <= limit do
        i = i + 1

        repeat

            local upstream_node_list = upstream_nodes_list()

            if not upstream_node_list then
                pdk.log.error("automatic_sync_upstream: the upstream and nodes list null")
                break
            end

            local _, post_upstream_err = events.post(
                    events_source_upstream, events_type_put_upstream, upstream_node_list)

            if post_upstream_err then
                pdk.log.error("automatic_sync_upstream: sync upstream data post err:["
                                      .. i .."][" .. tostring(post_upstream_err) .. "]")
            end

        until true

        ngx_sleep(3)
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_upstream)
    end
end

local function generate_upstream_balancer(upstream_data)

    if not upstream_data or (type(upstream_data) ~= "table") then
        return nil
    end

    local nodes = upstream_data.nodes

    local node_list = {}

    if nodes and (#nodes > 0) then

        for j = 1, #nodes do
            node_list[nodes[j].address .. '|' .. nodes[j].port] = nodes[j].weight
        end

    end

    local upstream_balancer = {
        algorithm       = upstream_data.algorithm,
        read_timeout    = upstream_data.read_timeout,
        write_timeout   = upstream_data.write_timeout,
        connect_timeout = upstream_data.connect_timeout
    }

    if next(node_list) then

        if  upstream_balancer.algorithm == pdk.const.BALANCER_ROUNDROBIN then
            upstream_balancer.handler = balancer_round:new(node_list)
        elseif upstream_balancer.algorithm == pdk.const.BALANCER_CHASH then
            upstream_balancer.handler = balancer_chash:new(node_list)
        end

    end

    return upstream_balancer
end

local function renew_upstream_balancer_object(new_upstream_objects)

    if not new_upstream_objects or not next(new_upstream_objects) then
        return
    end

    for upstream_id, _ in pairs(upstream_objects) do

        if not new_upstream_objects[upstream_id] then

            upstream_objects[upstream_id] = nil

        else

            if new_upstream_objects[upstream_id].write_timeout ~= upstream_objects[upstream_id].write_timeout then
                upstream_objects[upstream_id].write_timeout = new_upstream_objects[upstream_id].write_timeout
            end

            if new_upstream_objects[upstream_id].read_timeout ~= upstream_objects[upstream_id].read_timeout then
                upstream_objects[upstream_id].read_timeout = new_upstream_objects[upstream_id].read_timeout
            end

            if new_upstream_objects[upstream_id].connect_timeout ~= upstream_objects[upstream_id].connect_timeout then
                upstream_objects[upstream_id].connect_timeout = new_upstream_objects[upstream_id].connect_timeout
            end

            if new_upstream_objects[upstream_id].algorithm ~= upstream_objects[upstream_id].algorithm then
                upstream_objects[upstream_id].algorithm = new_upstream_objects[upstream_id].algorithm
                upstream_objects[upstream_id].handler   = new_upstream_objects[upstream_id].handler
            else

                local handler = upstream_objects[upstream_id].handler
                local new_handler = new_upstream_objects[upstream_id].handler

                local nodes, new_nodes = handler.nodes, new_handler.nodes

                for new_id, new_weight in pairs(new_nodes) do

                    if not nodes[new_id] then
                        handler:set(new_id, new_weight)
                    end

                end

                for id, weight in pairs(nodes) do

                    local new_weight = new_nodes[id]

                    if not new_weight then
                        handler:delete(id)
                    else
                        if new_weight ~= weight then
                            handler:set(id, new_weight)
                        end
                    end

                end

            end
        end
    end

    for upstream_id, object in pairs(new_upstream_objects) do

        if not upstream_objects[upstream_id] then
            upstream_objects[upstream_id] = object
        end

    end

end

local function worker_event_upstream_balancer_register()

    local upstream_balancer_handler = function(data, event, source)

        if source ~= events_source_upstream then
            return
        end

        if event ~= events_type_put_upstream then
            return
        end

        if (type(data) ~= "table") or (#data == 0) then
            return
        end

        local new_upstream_object = {}

        for i = 1, #data do
            new_upstream_object[data[i].id] = generate_upstream_balancer(data[i])
        end

        renew_upstream_balancer_object(new_upstream_object)

    end

    if ngx_process.type() ~= "privileged agent" then
        events.register(upstream_balancer_handler, events_source_upstream, events_type_put_upstream)
    end
end

function _M.init_worker()

    ngx_timer_at(0, worker_event_upstream_balancer_register)

    ngx_timer_at(0, automatic_sync_upstream)

end

function _M.init_resolver()

    local client, err = resolver:new{
        nameservers = { {"114.114.114.114", 53}, "8.8.8.8" },
        retrans = 3,  -- 3 retransmissions on receive timeout
        timeout = 500,  -- 500 ms
        no_random = false, -- always start with first nameserver
    }

    if err then
        pdk.log.error("init resolver error: [" .. tostring(err) .. "]")
        return
    end

    resolver_client = client
end

function _M.check_replenish_upstream(oak_ctx)

    if not oak_ctx.config or not oak_ctx.config.service_router or not oak_ctx.config.service_router.router then
        pdk.log.error("check_replenish_upstream: oak_ctx data format error: ["
                              .. pdk.json.encode(oak_ctx, true) .. "]")
        return
    end

    local service_router = oak_ctx.config.service_router

    if service_router.router.upstream and service_router.router.upstream.id and
            upstream_objects[service_router.router.upstream.id] then
        return
    end

    if not resolver_client or not oak_ctx.matched or not oak_ctx.matched.host or (#oak_ctx.matched.host == 0) then
        return
    end

    local address_cache_key = resolver_address_cache_prefix .. ":" .. oak_ctx.matched.host

    local address_cache = cache.get(address_cache_key)

    if address_cache then
        service_router.router.upstream.address = address_cache
        service_router.router.upstream.port    = 80
        return
    end

    local answers, err = resolver_client:query(oak_ctx.matched.host, nil, {})

    if err then
        pdk.log.error("failed to query the DNS server: [" .. pdk.json.encode(err, true) .. "]")
        return
    end

    local answers_list = {}

    for i = 1, #answers do

        if (answers[i].type == resolver_client.TYPE_A) or (answers[i].type == resolver_client.TYPE_AAAA) then
            pdk.table.insert(answers_list, answers[i])
        end

    end

    local resolver_result = answers[math_random(1, #answers)]

    if not resolver_result or not next(resolver_result) then
        return
    end

    cache.set(address_cache_key, resolver_result.address, 60)

    service_router.router.upstream.address = resolver_result.address
    service_router.router.upstream.port    = 80

end

function _M.gogogo(oak_ctx)

    if not oak_ctx.config or not oak_ctx.config.service_router or not oak_ctx.config.service_router.router or
            not oak_ctx.config.service_router.router.upstream or
            not next(oak_ctx.config.service_router.router.upstream) then
        pdk.log.error("[sys.balancer.gogogo] oak_ctx.config.service_router.router.upstream is null!")
        pdk.response.exit(500)
        return
    end

    local upstream = oak_ctx.config.service_router.router.upstream

    local address, port

    local timeout = {
        read_timeout    = pdk.const.UPSTREAM_DEFAULT_TIMEOUT,
        write_timeout   = pdk.const.UPSTREAM_DEFAULT_TIMEOUT,
        connect_timeout = pdk.const.UPSTREAM_DEFAULT_TIMEOUT,
    }

    if upstream.id then

        local upstream_object = upstream_objects[upstream.id]

        if not upstream_object then
            pdk.log.error("[sys.balancer.gogogo] upstream undefined, upstream_object is null!")
            pdk.response.exit(500)
            return
        end

        if not upstream_object.read_timeout then
            timeout.read_timeout = upstream_object.read_timeout
        end
        if not upstream_object.write_timeout then
            timeout.write_timeout = upstream_object.write_timeout
        end
        if not upstream_object.connect_timeout then
            timeout.connect_timeout = upstream_object.connect_timeout
        end

        local address_port

        if upstream_object.algorithm == pdk.const.BALANCER_ROUNDROBIN then
            address_port = upstream_object.handler:find()
        elseif upstream_object.algorithm == pdk.const.BALANCER_CHASH then
            address_port = upstream_object.handler:find(oak_ctx.config.service_router.host)
        end

        if not address_port then
            pdk.log.error("[sys.balancer.gogogo] upstream undefined, upstream_object find null!")
            pdk.response.exit(500)
            return
        end

        local address_port_table = pdk.string.split(address_port, "|")

        if #address_port_table ~= 2 then
            pdk.log.error("[sys.balancer.gogogo] address port format error: ["
                                  .. pdk.json.encode(address_port_table, true) .. "]")
            pdk.response.exit(500)
            return
        end

        address = address_port_table[1]
        port    = tonumber(address_port_table[2])

    else

        if not upstream.address or not upstream.port then
            pdk.log.error("[sys.balancer.gogogo] upstream address and port undefined")
            pdk.response.exit(500)
            return
        end

        address = upstream.address
        port    = upstream.port

    end

    if not address or not port or (address == ngx.null) or (port == ngx.null) then
        pdk.log.error("[sys.balancer.gogogo] address or port is null ["
                              .. pdk.json.encode(address, true) .. "]["
                              ..  pdk.json.encode(port, true) .. "]")
        pdk.response.exit(500)
        return
    end

    local _, err = pdk.schema.check(schema.upstream_node.schema_ip, address)

    if err then
        pdk.log.error("[sys.balancer.gogogo] address schema check err:[" .. address .. "][" .. err .. "]")
        pdk.response.exit(500)
        return
    end

    local _, err = pdk.schema.check(schema.upstream_node.schema_port, port)

    if err then
        pdk.log.error("[sys.balancer.gogogo] port schema check err:[" .. port .. "][" .. err .. "]")
        pdk.response.exit(500)
        return
    end

    local ok, err = balancer.set_timeouts(
            timeout.connect_timeout / 1000, timeout.write_timeout / 1000, timeout.read_timeout / 1000)

    if not ok then
        pdk.log.error("[sys.balancer] could not set upstream timeouts: [" .. pdk.json.encode(err, true) .. "]")
        return
    end

    local ok, err = balancer.set_current_peer(address, port)

    if not ok then
        pdk.log.error("[sys.balancer] failed to set the current peer: ", err)
        pdk.response.exit(500)
        return
    end
end

return _M
