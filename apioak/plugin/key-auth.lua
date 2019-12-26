local pdk      = require("apioak.pdk")
local ipairs   = ipairs
local tostring = tostring

local _M = {
    type  = 'Authentication',
    name  = "Key Auth",
    desc  = "Add a key authentication to your APIs.",
    key   = "key-auth",
    order = 1201
}

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
    if not oak_ctx['plugins'] then
        return false, nil
    end

    if not oak_ctx.plugins[_M.key] then
        return false, nil
    end
    --get key
    local key = pdk.request.header('apikey')
    if not key then
        pdk.response.exit(401, { err_message = "Missing API key found in request" })
    end

    --get etcd keys
    local etcd_cli = pdk.etcd.new()
    local keys_etcd = etcd_cli.get(_M.name)
    local keys_body = keys_etcd.body
    if (not keys_body.node) or (not keys_body.node.value) then
        pdk.response.exit(401, { err_message = "API key no set" })
    end
    local keys = pdk.json.decode(keys_body.node.value)

    --check key exist
    local exist = key_exist(keys, key)
    if not exist then
        pdk.response.exit(401, { err_message = "Invalid API key in request" })
    end
end

return _M



