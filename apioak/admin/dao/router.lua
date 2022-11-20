local pdk    = require("apioak.pdk")
local common = require("apioak.admin.dao.common")
local uuid   = require("resty.jit-uuid")

local _M = {}

_M.METHODS_ALL    = "ALL"
_M.METHODS_GET    = "GET"
_M.METHODS_PUT    = "PUT"
_M.METHODS_POST   = "POST"
_M.METHODS_PATH   = "PATH"
_M.METHODS_DELETE = "DELETE"

function _M.created(params)

    local router_id = uuid.generate_v4()

    local router_body = {
        id        = router_id,
        name      = params.name,
        methods   = params.methods or { _M.METHODS_ALL },
        paths     = params.paths,
        headers   = params.headers or {},
        service   = params.service,
        plugins   = params.plugins or {},
        upstream  = params.upstream or {},
        enabled   = params.enabled or true
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
        detail.enabled = params.enabled
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

        if err or not tmp then
            return nil, "router:[".. key .. "] does not exists, err [".. tostring(err) .."]"
        end

        key = tmp
    end

    local res, err = common.detail_key(common.PREFIX_MAP.routers .. key)

    if err or not res then
        return nil, "router:[".. key .. "] does not exists, err [".. tostring(err) .."]"
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

    return {}, nil
end

function _M.exist_path(paths, filter_id)

    if #paths == 0 then
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

    for i = 1, #list['list'] do

        repeat

            if list['list'][i]['id'] == filter_id then
                break
            end

            if #list['list'][i]['paths'] > 0 then
                for j = 1, #list['list'][i]['paths'] do
                    if paths_map[list['list'][i]['paths'][j]] then
                        table.insert(exist_paths, list['list'][i]['paths'][j])
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

return _M