local balancer = require "ngx.balancer"
local pdk = require("apioak.pdk")
local resty_chash = require('resty.chash')
local resty_roundrobin = require('resty.roundrobin')
local set_current_peer = balancer.set_current_peer
local string = string

local _M = {}

function _M.init_worker()

end

function _M.go(oak_ctx)

    local upstream = oak_ctx.upstream or {}

    if next(upstream) == nil then
        pdk.log.error('upstream init is nil')
    end

    local nodes = upstream.nodes
    local server_list = {}
    local server = ''
    for _, serv in pairs(nodes) do
        local key = serv.ip .. ':' .. serv.port
        server_list[key] = serv.weight
    end

    if upstream.type == 'roundrobin' then
        local rr_up = resty_roundrobin:new(server_list)
        server = rr_up:find()
        assert(set_current_peer(server))
    end

    if upstream.type == 'chash' then
        local arg_key = oak_ctx.remote_addr or '0.0.0.1'
        local servers, nodes_list = {}, {}
        local str_null = string.char(0)
        for serv, weight in pairs(server_list) do
            local id = string.gsub(serv, ':', str_null)
            servers[id] = serv
            nodes_list[id] = weight
        end
        local chash_up = resty_chash:new(nodes_list)
        local id = chash_up:find(arg_key)
        server = servers[id]
        assert(set_current_peer(server))
    end
    pdk.log.error('balancer init errer')
end

return _M
