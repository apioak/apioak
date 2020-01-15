local pdk = require("apioak.pdk")
local balancer = require("ngx.balancer")
local balancer_chash = require('resty.chash')
local balancer_round = require('resty.roundrobin')
local set_current_peer = balancer.set_current_peer
local get_last_failure = balancer.get_last_failure
local set_timeouts = balancer.set_timeouts
local set_more_tries = balancer.set_more_tries
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber

local _M = {}

function _M.go(oak_ctx)

    local ngx_ctx = ngx.ctx
    local upstream = oak_ctx.upstream or nil
    if not upstream or not upstream.nodes then
        pdk.log.error("[sys.balancer] upstream nodes not found")
        pdk.response.exit(500)
    end

    if not ngx_ctx.tries then
        ngx_ctx.tries = pdk.const.TRY_DEFAULT_NUMBER
    end
    if not ngx_ctx.down then
        ngx_ctx.down = {}
    end

    local nodes = upstream.nodes
    local address
    local try_number = tonumber(upstream.try_number) or pdk.const.TRY_MAX_NUMBER
    local servers = {}
    for _, server in ipairs(nodes) do
        local key = server.ip .. ":" .. tostring(server.port)
        if pdk.table.has(key, ngx_ctx.down) == false then
            servers[key] = server.weight
        end
    end

    if #servers == 0 then
        pdk.log.error("[sys.balancer] node all down")
        pdk.response.exit(500)
    end

    if ngx_ctx.tries == try_number then
        local state, code = get_last_failure()
        if ngx_ctx.host and ngx_ctx.port then
            local down = ngx_ctx.host .. ":" .. tostring(ngx_ctx.port)
            ngx_ctx.tries = pdk.const.TRY_DEFAULT_NUMBER
            pdk.table.insert(ngx_ctx.down, down)
        end
        pdk.log.error("[sys.balancer] node state " .. state .. " code " .. code)
    end

    local ok, err = set_timeouts(pdk.const.BALANCER_COMMECT_TIMEOUT, pdk.const.BALANCER_SEND_TIMEOUT, pdk.const.BALANCER_READ_TIMEOUT)
    if not ok then
        pdk.log.error("[sys.balancer] set timeouts error " .. err)
        pdk.response.exit(500)
    end

    local ok, err = set_more_tries(try_number)
    if not ok then
        pdk.log.error("[sys.balancer] set more tries error " .. err)
        pdk.response.exit(500)
    end
    ngx_ctx.tries = ngx_ctx.tries + pdk.const.TRY_INC_NUMBER

    local upstream_type = upstream.type or pdk.const.BALANCER_ROUNDROBIN
    if upstream_type == pdk.const.BALANCER_CHASH then
        local hash = balancer_chash:new(servers)
        address = hash:find(oak_ctx.request.client_ip or pdk.const.LOCAL_IP)
    end

    if upstream_type == pdk.const.BALANCER_ROUNDROBIN then
        local round = balancer_round:new(servers)
        address = round:find()
    end

    local server_info = pdk.string.split(address, ":")
    ngx_ctx.host = server_info[1]
    ngx_ctx.port = tonumber(server_info[2])
    local ok, err = set_current_peer(ngx_ctx.host, ngx_ctx.port)
    if not ok then
        pdk.log.error("[sys.balancer] " .. address .. " error " .. err)
        pdk.response.exit(500)
    end
end

return _M
