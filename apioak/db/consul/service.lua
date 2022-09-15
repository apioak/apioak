local ngx = ngx
local pdk = require("apioak.pdk")
local json = require("apioak.pdk.json")
local uuid = require("resty.jit-uuid")

local _M = {}

local DEFAULT_SERVICE_PREFIX = "service/" -- 后期可考虑自定义
local DEFAULT_PROTOCOLS = {"http"}
local DEFAULT_PORT = {"80"}

function _M.check_plugin_exists(plugin_param)

    local consul, err = pdk.consul.new()

    if err ~= nil then
        return false
    end

    if plugin_param.len == 0 then
        return true
    end

    for _, value in ipairs(plugin_param) do
        local plugin_key = value.id or value.name or ""

        if plugin_key == "" then
            goto continue
        end

        local p, err = consul:get_key(plugin_key)
        if err ~= nil or p == nil or p.body == "" then
            return false
        end

        ::continue::
    end

    return true
end


function _M.created(params)

    local consul, err = pdk.consul.new()

    if err ~= nil then
        return nil, err
    end

    local check_plugin = _M.check_plugin_exists(params.plugins)

    if not check_plugin then
        return nil, err -- TODO 补充插件不存在错误信息
    end

    local service_id = uuid.seed()
    local service_body = {
        id        = service_id,
        name      = params.name,
        protocols = params.protocols or DEFAULT_PROTOCOLS,
        hosts     = params.hosts,
        ports     = params.ports or DEFAULT_PORT,
        plugins   = params.plugins or {},
        enabled   = params.enabled or true
    }
    
    local key = params.prefix or DEFAULT_SERVICE_PREFIX

    local res, err = consul:put_key( key .. service_id, service_body)

    if err ~= nil then
        return nil, err
    end

    if not res or res.status ~= 200 then
        return nil, err -- TODO 补充新增service失败的错误信息
    end


    -- TODO 以prefix + service_id 或 prefix + name

    -- local txn_payload = {
    --     {
    --         KV = {
    --             Verb  = "set",
    --             Key   = key .. service_id,
    --             Value = service_body,
    --         }
    --     },
    --     {
    --         KV = {
    --             Verb  = "set",
    --             Key   = key .. service_body.name,
    --             Value = service_body,
    --         }
    --     },
    -- }

    -- local res, err = consul.txn(txn_payload)

    -- if err ~= nil then
    --     return nil, err
    -- end

    -- if not res then
    --     ngx.say(err)
    --     return
    -- end

    return { id = service_id }, nil
end

function _M.updated(service_id, params)
    
    local key = params.prefix or DEFAULT_SERVICE_PREFIX

    local consul, err = pdk.consul.new()

    if err ~= nil then
        return nil, err
    end

    local old , err = consul:get_key(key .. service_id)

    if err ~= nil or old == nil or old.status ~= 200 then
        return nil, err -- TODO 补充服务不存在错误信息
    end

    local check_plugin = _M.check_plugin_exists(params.plugins)

    if not check_plugin then
        return nil, err -- TODO 补充插件不存在错误信息
    end

    local service_body = {
        id        = service_id,
        name      = params.name,
        protocols = params.protocols or DEFAULT_PROTOCOLS,
        hosts     = params.hosts,
        ports     = params.ports or DEFAULT_PORT,
        plugins   = params.plugins or {},
        enabled   = params.enabled or true
    }

    local res, err = consul:put_key( key .. service_id, service_body)

    if err ~= nil then
        return nil, err
    end

    if not res or res.status ~= 200 then
        return nil, err -- TODO 补充新增service失败的错误信息
    end
    
    return { id = service_id }, nil
    
end

function _M.lists(params)

    local consul, err = pdk.consul.new()

    if err ~= nil then
        return nil, err
    end

    local key = params.prefix or DEFAULT_SERVICE_PREFIX

    local keys, err = consul:list_keys(key)

    if err ~= nil then
        return nil, err
    end

    local res = {}

    for k, v in ipairs(keys.body) do

         local d, _ = consul:get_key(v)

        table.insert(res, pdk.json.decode(d.body[1].Value))
     end

    return {list = res}, nil
    -- return res, nil
end



return _M