local get_headers = ngx.req.get_headers
local pdk = require("apioak.pdk")
local plugin_name = "key-auth"
local ipairs   = ipairs

local _M = {
    version = 0.1,
    type = 'auth',
    name = plugin_name,
}

--get headers
local function headers_key(oak_ctx, name)
    if not oak_ctx.headers then
        oak_ctx.headers = get_headers()
    end
    return oak_ctx.headers[name]
end

--check key exist
local function key_exist(keys, key)
    if not keys then
        return false
    end

    for _, key_value in ipairs(keys) do
        if (tostring(key) == tostring(key_value)) then
            return true
        end
    end

    return false
end


function _M.http_access(oak_ctx)
    --get key
    local key = headers_key(oak_ctx, "apikey")
    if not key then
        return 401, {message = "Missing API key found in request"}
    end

    --get etcd keys
    local etcd_cli = pdk.etcd.new()
    local keys_etcd = etcd_cli.get(_M.name)
    local keys_body = keys_etcd.body
    if (not keys_body.node) or (not keys_body.node.value) then
        return 401, {message = "API key no set"}
    end
    local keys = pdk.json.decode(keys_body.node.value)

    --check key exist
    local exist = key_exist(keys, key)
    if not exist then
        return 401, {message = "Invalid API key in request"}
    end
end

return _M



