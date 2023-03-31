local pdk    = require("apioak.pdk")
local uuid   = require("resty.jit-uuid")
local common = require("apioak.admin.dao.common")
local router = require("apioak.admin.dao.router")

local _M = {}

function _M.created(params)

    local id = uuid.generate_v4()

    local data = {
        id              = id,
        name            = params.name,
        algorithm       = params.algorithm or pdk.const.BALANCER_ROUNDROBIN,
        nodes           = params.nodes     or {},
        connect_timeout = params.connect_timeout or pdk.const.UPSTREAM_DEFAULT_TIMEOUT,
        write_timeout   = params.write_timeout   or pdk.const.UPSTREAM_DEFAULT_TIMEOUT,
        read_timeout    = params.read_timeout    or pdk.const.UPSTREAM_DEFAULT_TIMEOUT
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.upstreams .. id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.upstreams .. params.name,
                Value = pdk.json.encode(data),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create upstream FAIL [".. err .."]"
    end

    local update_associate_upstream_err = router.update_associate_upstream()

    if update_associate_upstream_err then
        pdk.log.error("dao-upstream-created update_associate_upstream err: [" .. update_associate_upstream_err .. "]")
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-upstream-create update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return { id = id }, nil
end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.upstreams)

    if err then
        return nil, "get upstream list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.updated(params, detail)

    local old_name = detail.name

    if params.name then
        detail.name = params.name
    end
    if params.algorithm then
        detail.algorithm = params.algorithm
    end
    if params.nodes then
        detail.nodes = params.nodes
    end
    if params.connect_timeout then
        detail.connect_timeout = params.connect_timeout
    end
    if params.write_timeout then
        detail.write_timeout = params.write_timeout
    end
    if params.read_timeout then
        detail.read_timeout = params.read_timeout
    end

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.upstreams .. old_name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.upstreams .. detail.id,
                Value = detail.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.upstreams .. detail.name,
                Value = pdk.json.encode(detail),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update upstream FAIL, err[".. tostring(err) .."]"
    end

    local update_associate_upstream_err = router.update_associate_upstream()

    if update_associate_upstream_err then
        pdk.log.error("dao-upstream-update update_associate_upstream err: [" .. update_associate_upstream_err .. "]")
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-upstream-update update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return { id = detail.id }, nil
end

function _M.detail(key)
    if uuid.is_valid(key) then

        local name, err = common.get_key(common.SYSTEM_PREFIX_MAP.upstreams .. key)

        if err then
            return nil, "upstream key:[".. key .. "] does not exist"
        end

        if not name then
            return nil, nil
        end

        key = name
    end

    local detail, err = common.get_key(common.PREFIX_MAP.upstreams .. key)

    if err then
        return nil, "upstream detail:[".. key .."] does not exist"
    end

    if not detail then
        return nil, nil
    end

    return  pdk.json.decode(detail), nil
end

function _M.deleted(detail)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.upstreams .. detail.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.upstreams .. detail.name,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete upstream FAIL, err[".. tostring(err) .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-upstream-delete update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return {}, nil
end

function _M.upstream_list_by_node(detail)

    if not detail.id and not detail.name then
        return nil, nil
    end

    local list, err = common.list_keys(common.PREFIX_MAP.upstreams)

    if err then
        return nil, "upstream_list_by_node: get upstream list FAIL [".. err .."]"
    end

    local upstream_list = {}

    for i = 1, #list['list'] do

        local upstream_info = list['list'][i]

        repeat

            if not upstream_info['nodes'] then
                break
            end

            local upstream_nodes = upstream_info['nodes']

            for j = 1, #upstream_nodes do

                if upstream_nodes[j].id and (upstream_nodes[j].id == detail.id) then
                    table.insert(upstream_list, upstream_info)
                    break
                end

                if upstream_nodes[j].name and (upstream_nodes[j].name == detail.name) then
                    table.insert(upstream_list, upstream_info)
                    break
                end
            end

        until true
    end

    return upstream_list
end

function _M.update_associate_node()

    local upstreams_list, upstreams_list_err = common.list_keys(common.PREFIX_MAP.upstreams)

    if upstreams_list_err then
        return "update_associate_node: get upstreams list FAIL [".. upstreams_list_err .."]"
    end

    if not upstreams_list.list or (#upstreams_list.list == 0) then
        return nil
    end

    local nodes_list, nodes_list_err = common.list_keys(common.PREFIX_MAP.upstream_nodes)

    if nodes_list_err then
        return "update_associate_node: get nodes list FAIL [".. nodes_list_err .."]"
    end

    if not nodes_list.list or (#nodes_list.list == 0) then
        return nil
    end

    local nodes_id_map, nodes_name_map = {}, {}

    for i = 1, #nodes_list.list do

        if not nodes_id_map[nodes_list.list[i].id] then
            nodes_id_map[nodes_list.list[i].id] = nodes_list.list[i].name
        end

        if not nodes_name_map[nodes_list.list[i].name] then
            nodes_name_map[nodes_list.list[i].name] = nodes_list.list[i].id
        end

    end

    for i = 1, #upstreams_list.list do

        repeat

            local upstream_info = upstreams_list.list[i]

            if not upstream_info.nodes or (#upstream_info.nodes == 0) then
                break
            end

            local associate_nodes = upstream_info.nodes

            local new_nodes = {
                nodes = {}
            }

            local update = false

            for j = 1, #associate_nodes do

                repeat

                    if associate_nodes[j].id and nodes_id_map[associate_nodes[j].id] and
                            (associate_nodes[j].name ~= nodes_id_map[associate_nodes[j].id]) then

                        update = true

                        table.insert(new_nodes.nodes, {
                            id = associate_nodes[j].id,
                            name = nodes_id_map[associate_nodes[j].id]
                        })

                        break
                    end

                    if associate_nodes[j].name and nodes_name_map[associate_nodes[j].name] and
                            (associate_nodes[j].id ~= nodes_name_map[associate_nodes[j].name]) then

                        update = true

                        table.insert(new_nodes.nodes, {
                            id = nodes_name_map[associate_nodes[j].name],
                            name = associate_nodes[j].name
                        })

                        break
                    end

                    table.insert(new_nodes.nodes, associate_nodes[j])

                until true
            end

            if update then

                local _, update_err = _M.updated(new_nodes, upstream_info)

                if update_err then
                    return "update_associate_node: update nodes FAIL [".. update_err .."]"
                end

            end

        until true
    end

    return nil
end


return _M