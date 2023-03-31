local pdk    = require("apioak.pdk")
local common = require("apioak.admin.dao.common")
local uuid   = require("resty.jit-uuid")

local _M = {}

function _M.created(params)

    local router_id = uuid.generate_v4()

    local router_body = {
        id        = router_id,
        name      = params.name,
        methods   = params.methods or pdk.const.ALL_METHODS,
        paths     = params.paths,
        headers   = params.headers or {},
        service   = params.service,
        plugins   = params.plugins or {},
        upstream  = params.upstream or {},
        enabled   = params.enabled
    }

    local payload = {
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. router_id,
                Value = params.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.routers .. params.name,
                Value = pdk.json.encode(router_body),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "create router FAIL [".. tostring(err) .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-router-create update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return { id = router_id }, nil
end

function _M.updated(params, detail)

    local old_name = detail.name

    if params.name then
        detail.name = params.name
    end
    if params.methods then
        detail.methods = params.methods
    end
    if params.paths then
        detail.paths = params.paths
    end
    if params.headers then
        detail.headers = params.headers
    end
    if params.service then
        detail.service = params.service
    end
    if params.plugins then
        detail.plugins = params.plugins
    end
    if params.upstream then
        detail.upstream = params.upstream
    end
    if params.enabled then
        detail.enabled = true
    else
        detail.enabled = false
    end

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.routers .. old_name,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. detail.id,
                Value = detail.name,
            }
        },
        {
            KV = {
                Verb  = "set",
                Key   = common.PREFIX_MAP.routers .. detail.name,
                Value = pdk.json.encode(detail),
            }
        },
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "update router FAIL, err[".. tostring(err) .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-router-update update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return { id = detail.id }, nil
end

function _M.lists()

    local res, err = common.list_keys(common.PREFIX_MAP.routers)

    if err then
        return nil, "get router list FAIL [".. err .."]"
    end

    return res, nil
end

function _M.detail(key)

    if uuid.is_valid(key) then
        local tmp, err = common.get_key(common.SYSTEM_PREFIX_MAP.routers .. key)

        if err then
            return nil, "router:[".. key .. "] does not exists, err [".. tostring(err) .."]"
        end

        if not tmp then
            return nil, nil
        end

        key = tmp
    end

    local res, err = common.get_key(common.PREFIX_MAP.routers .. key)

    if err then
        return nil, "router:[".. key .. "] does not exists, err [".. tostring(err) .."]"
    end

    if not res  then
        return nil, nil
    end

    return pdk.json.decode(res), nil
end

function _M.deleted(detail)

    local payload = {
        {
            KV = {
                Verb  = "delete",
                Key   = common.SYSTEM_PREFIX_MAP.routers .. detail.id,
                Value = nil,
            }
        },
        {
            KV = {
                Verb  = "delete",
                Key   = common.PREFIX_MAP.routers .. detail.name,
                Value = nil,
            }
        }
    }

    local res, err = common.txn(payload)

    if err or not res then
        return nil, "delete router FAIL, err[".. tostring(err) .."]"
    end

    local _, update_hash_err = common.update_sync_data_hash()

    if update_hash_err then
        pdk.log.error("dao-router-delete update_sync_data_hash err: [" .. update_hash_err .. "]")
    end

    return {}, nil
end

function _M.exist_path(paths, service_info)

    if (#paths == 0) or (service_info == nil) or ((service_info.id == nil) and (service_info.name == nil)) then
        return {}, nil
    end

    local paths_map = {}
    for i = 1, #paths do
        paths_map[paths[i]] = 0
    end

    local list, err = common.list_keys(common.PREFIX_MAP.routers)

    if err then
        return nil, "get paths list FAIL [".. err .."]"
    end

    local exist_paths = {}

    for i = 1, #list.list do

        repeat

            if (list.list[i].service == nil) or (next(list.list[i].service) == nil) then
                break
            end

            if #list.list[i].paths > 0 then
                for j = 1, #list.list[i].paths do
                    if service_info.id ~= nil then
                        if (service_info.id == list.list[i].service.id) and paths_map[list.list[i].paths[j]] then
                            table.insert(exist_paths, list.list[i].paths[j])
                        end
                    elseif service_info.name ~= nil then
                        if (service_info.name == list.list[i].service.name) and paths_map[list.list[i].paths[j]] then
                            table.insert(exist_paths, list.list[i].paths[j])
                        end
                    end
                end
            end

        until true
    end

    if #exist_paths == 0 then
        return nil, nil
    end

    return exist_paths, nil
end

function _M.router_list_by_service(detail)

    if not detail.id and not detail.name then
        return nil, nil
    end

    local list, err = common.list_keys(common.PREFIX_MAP.routers)

    if err then
        return nil, "get router list FAIL [".. err .."]"
    end

    local router_list = {}

    for i = 1, #list['list'] do

        local router_info = list['list'][i]

        repeat

            if not router_info['service'] then
                break
            end

            if router_info['service'].id and (router_info['service'].id == detail.id) then
                table.insert(router_list, router_info)
                break
            end

            if router_info['service'].name and (router_info['service'].name == detail.name) then
                table.insert(router_list, router_info)
                break
            end

        until true
    end

    return router_list
end

function _M.router_list_by_plugin(detail)

    if not detail.id and not detail.name then
        return nil, nil
    end

    local list, err = common.list_keys(common.PREFIX_MAP.routers)

    if err then
        return nil, "get router list FAIL [".. err .."]"
    end

    local router_list = {}

    for i = 1, #list['list'] do

        local router_info = list['list'][i]

        repeat

            if not router_info['plugins'] then
                break
            end

            local router_plugins = router_info['plugins']

            for j = 1, #router_plugins do

                if router_plugins[j].id and (router_plugins[j].id == detail.id) then
                    table.insert(router_list, router_info)
                    break
                end

                if router_plugins[j].name and (router_plugins[j].name == detail.name) then
                    table.insert(router_list, router_info)
                    break
                end
            end

        until true
    end

    return router_list
end

function _M.router_list_by_upstream(detail)

    if not detail.id and not detail.name then
        return nil, nil
    end

    local list, err = common.list_keys(common.PREFIX_MAP.routers)

    if err then
        return nil, "get router list FAIL [".. err .."]"
    end

    local router_list = {}

    for i = 1, #list['list'] do

        local router_info = list['list'][i]

        repeat

            if not router_info['upstream'] then
                break
            end

            if router_info['upstream'].id and (router_info['upstream'].id == detail.id) then
                table.insert(router_list, router_info)
                break
            end

            if router_info['upstream'].name and (router_info['upstream'].name == detail.name) then
                table.insert(router_list, router_info)
                break
            end

        until true
    end

    return router_list
end

function _M.update_associate_upstream()

    local router_list, router_list_err = common.list_keys(common.PREFIX_MAP.routers)

    if router_list_err then
        return "update_associate_upstream: get router list FAIL [".. router_list_err .."]"
    end

    if not router_list.list or (#router_list.list == 0) then
        return nil
    end

    local upstream_list, upstream_list_err = common.list_keys(common.PREFIX_MAP.upstreams)

    if upstream_list_err then
        return "update_associate_upstream: get upstream list FAIL [".. upstream_list_err .."]"
    end

    if not upstream_list.list or (#upstream_list.list == 0) then
        return nil
    end

    local upstream_id_map, upstream_name_map = {}, {}

    for i = 1, #upstream_list.list do

        if not upstream_id_map[upstream_list.list[i].id] then
            upstream_id_map[upstream_list.list[i].id] = upstream_list.list[i].name
        end

        if not upstream_name_map[upstream_list.list[i].name] then
            upstream_name_map[upstream_list.list[i].name] = upstream_list.list[i].id
        end

    end

    for j = 1, #router_list.list do

        repeat

            local router_info = router_list.list[j]

            if not router_info.upstream or (next(router_info.upstream) == nil) then
                break
            end

            if router_info.upstream.id and upstream_id_map[router_info.upstream.id] then

                if (router_info.upstream.name == upstream_id_map[router_info.upstream.id]) then
                    break
                end

                local new_upstream = {
                    upstream = { id = router_info.upstream.id, name = upstream_id_map[router_info.upstream.id] }
                }

                local _, update_name_err = _M.updated(new_upstream, router_info)

                if update_name_err then
                    return "update_associate_upstream: update upstream name FAIL [".. update_name_err .."]"
                end

                break
            end

            if router_info.upstream.name and upstream_name_map[router_info.upstream.name] then

                if router_info.upstream.id == upstream_name_map[router_info.upstream.name] then
                    break
                end

                local new_upstream = {
                    upstream = { id = upstream_name_map[router_info.upstream.name], name = router_info.upstream.name }
                }

                local _, update_id_err = _M.updated(new_upstream, router_info)

                if update_id_err then
                    return "update_associate_upstream: update upstream id FAIL [".. update_id_err .."]"
                end
            end

        until true
    end

    return nil
end

function _M.update_associate_service()

    local router_list, router_list_err = common.list_keys(common.PREFIX_MAP.routers)

    if router_list_err then
        return "update_associate_service: get router list FAIL [".. router_list_err .."]"
    end

    if not router_list.list or (#router_list.list == 0) then
        return nil
    end

    local services_list, services_list_err = common.list_keys(common.PREFIX_MAP.services)

    if services_list_err then
        return "update_associate_service: get services list FAIL [".. services_list_err .."]"
    end

    if not services_list.list or (#services_list.list == 0) then
        return nil
    end

    local services_id_map, services_name_map = {}, {}

    for i = 1, #services_list.list do

        if not services_id_map[services_list.list[i].id] then
            services_id_map[services_list.list[i].id] = services_list.list[i].name
        end

        if not services_name_map[services_list.list[i].name] then
            services_name_map[services_list.list[i].name] = services_list.list[i].id
        end

    end

    for j = 1, #router_list.list do

        repeat

            local router_info = router_list.list[j]

            if not router_info.service or (next(router_info.service) == nil) then
                break
            end

            if router_info.service.id and services_id_map[router_info.service.id] then

                if (router_info.service.name == services_id_map[router_info.service.id]) then
                    break
                end

                local new_service = {
                    service = { id = router_info.service.id, name = services_id_map[router_info.service.id] }
                }

                local _, update_name_err = _M.updated(new_service, router_info)

                if update_name_err then
                    return "update_associate_service: update service name FAIL [".. update_name_err .."]"
                end

                break
            end

            if router_info.service.name and services_name_map[router_info.service.name] then

                if router_info.service.id == services_name_map[router_info.service.name] then
                    break
                end

                local new_service = {
                    service = { id = services_name_map[router_info.service.name], name = router_info.service.name }
                }

                local _, update_id_err = _M.updated(new_service, router_info)

                if update_id_err then
                    return "update_associate_service: update service id FAIL [".. update_id_err .."]"
                end
            end

        until true
    end

    return nil
end

function _M.update_associate_routers_plugin()

    local routers_list, routers_list_err = common.list_keys(common.PREFIX_MAP.routers)

    if routers_list_err then
        return "update_associate_routers_plugin: get routers list FAIL [".. routers_list_err .."]"
    end

    if not routers_list.list or (#routers_list.list == 0) then
        return nil
    end

    local plugins_list, plugins_list_err = common.list_keys(common.PREFIX_MAP.plugins)

    if plugins_list_err then
        return "update_associate_routers_plugin: get plugins list FAIL [".. plugins_list_err .."]"
    end

    if not plugins_list.list or (#plugins_list.list == 0) then
        return nil
    end

    local plugins_id_map, plugins_name_map = {}, {}

    for i = 1, #plugins_list.list do

        if not plugins_id_map[plugins_list.list[i].id] then
            plugins_id_map[plugins_list.list[i].id] = plugins_list.list[i].name
        end

        if not plugins_name_map[plugins_list.list[i].name] then
            plugins_name_map[plugins_list.list[i].name] = plugins_list.list[i].id
        end

    end

    for i = 1, #routers_list.list do

        repeat

            local routers_info = routers_list.list[i]

            if not routers_info.plugins or (#routers_info.plugins == 0) then
                break
            end

            local associate_plugins = routers_info.plugins

            local new_plugins = {
                plugins = {}
            }

            local update = false

            for j = 1, #associate_plugins do

                repeat

                    if associate_plugins[j].id and plugins_id_map[associate_plugins[j].id] and
                            (associate_plugins[j].name ~= plugins_id_map[associate_plugins[j].id]) then

                        update = true

                        table.insert(new_plugins.plugins, {
                            id = associate_plugins[j].id,
                            name = plugins_id_map[associate_plugins[j].id]
                        })

                        break
                    end

                    if associate_plugins[j].name and plugins_name_map[associate_plugins[j].name] and
                            (associate_plugins[j].id ~= plugins_name_map[associate_plugins[j].name]) then

                        update = true

                        table.insert(new_plugins.plugins, {
                            id = plugins_name_map[associate_plugins[j].name],
                            name = associate_plugins[j].name
                        })

                        break
                    end

                    table.insert(new_plugins.plugins, associate_plugins[j])

                until true
            end

            if update then

                local _, update_err = _M.updated(new_plugins, routers_info)

                if update_err then
                    return "update_associate_routers_plugin: update plugin FAIL [".. update_err .."]"
                end

            end

        until true
    end

    return nil
end

return _M