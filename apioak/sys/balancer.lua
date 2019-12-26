local pdk              = require("apioak.pdk")
local ipairs           = ipairs
local tostring         = tostring
local tonumber         = tonumber
local balancer         = require("ngx.balancer")
local balancer_chash   = require('resty.chash')
local balancer_round   = require('resty.roundrobin')
local set_current_peer = balancer.set_current_peer

local _M = {}

function _M.go(oak_ctx)
    local upstream = oak_ctx.upstream or nil
    if not upstream or not upstream.nodes then
        pdk.log.error("[sys.balancer] upstream nodes not found")
        pdk.response.exit(500)
    end

    local nodes = upstream.nodes
    local servers = {}
    for _, server in ipairs(nodes) do
        servers[server.ip .. ":" .. tostring(server.port)] = server.weight
    end

    local server
    local upstream_type = upstream.type or pdk.const.BALANCER_ROUNDROBIN
    if upstream_type == pdk.const.BALANCER_CHASH then
        local hash = balancer_chash:new(servers)
        server = hash:find(oak_ctx.request.client_ip or pdk.const.LOCAL_IP)
    end

    if upstream_type == pdk.const.BALANCER_ROUNDROBIN then
        local round = balancer_round:new(servers)
        server = round:find()
    end

    local server_info = pdk.string.split(server, ":")
    local ok, err = set_current_peer(server_info[1], tonumber(server_info[2]))
    if not ok then
        pdk.log.error("[sys.balancer] " .. server .. "error, " .. err)
        pdk.response.exit(500)
    end
end

return _M
