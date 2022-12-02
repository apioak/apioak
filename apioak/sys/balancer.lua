local ngx     = ngx
local pdk     = require("apioak.pdk")
local dao     = require("apioak.dao")
local schema  = require("apioak.schema")
local process = require("ngx.process")
local events  = require("resty.worker.events")
local ngx_sleep          = ngx.sleep
local ngx_timer_at       = ngx.timer.at
local ngx_worker_exiting = ngx.worker.exiting
local balancer_round     = require('resty.roundrobin')
local balancer_chash     = require('resty.chash')

local events_source_upstream   = "events_source_upstream"
local events_type_put_upstream = "events_type_put_upstream"

local upstream_objects = {}

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

    if process.type() ~= "privileged agent" then
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

        ngx_sleep(5)
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
            upstream_balancer.round_handler = balancer_round:new(node_list)
            upstream_balancer.chash_handler = ngx.null
        end

        if  upstream_balancer.algorithm == pdk.const.BALANCER_CHASH then
            upstream_balancer.round_handler = ngx.null
            upstream_balancer.chash_handler = balancer_chash:new(node_list)
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

                upstream_objects[upstream_id].algorithm     = new_upstream_objects[upstream_id].algorithm
                upstream_objects[upstream_id].round_handler = new_upstream_objects[upstream_id].round_handler
                upstream_objects[upstream_id].chash_handler = new_upstream_objects[upstream_id].chash_handler

            else

                local handler, new_handler

                if upstream_objects[upstream_id].algorithm == pdk.const.BALANCER_ROUNDROBIN then
                    handler = upstream_objects[upstream_id].round_handler
                    new_handler = new_upstream_objects[upstream_id].round_handler
                else
                    handler = upstream_objects[upstream_id].chash_handler
                    new_handler = new_upstream_objects[upstream_id].chash_handler
                end

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

    if process.type() ~= "privileged agent" then
        events.register(upstream_balancer_handler, events_source_upstream, events_type_put_upstream)
    end
end

function _M.init_worker()

    ngx_timer_at(0, worker_event_upstream_balancer_register)

    ngx_timer_at(0, automatic_sync_upstream)

end

return _M
