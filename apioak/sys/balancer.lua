local pdk            = require("apioak.pdk")
local balancer       = require("ngx.balancer")
local balancer_chash = require('resty.chash')
local balancer_round = require('resty.roundrobin')
local set_current_peer = balancer.set_current_peer
local get_last_failure = balancer.get_last_failure
local set_more_tries   = balancer.set_more_tries
local set_timeouts     = balancer.set_timeouts

local _M = {}

function _M.go(oak_ctx)
    local router   = oak_ctx.router
    local upstream = router.upstream
    -- default enable tries
    upstream.enable_tries = 1

    if not upstream then
        pdk.log.error("[sys.balancer] upstream undefined")
        pdk.response.exit(500)
    end

    local try_nodes = upstream.try_nodes or pdk.table.new(10, 0)

    local state, code = get_last_failure()
    if state == "failed" then
        pdk.log.error("[sys.balancer] connection " .. try_nodes[#try_nodes], " state: ", state, " code: ", code)
    end

    local nodes   = upstream.nodes
    local servers = pdk.table.new(10, 0)
    for i = 1, #nodes do
        local node = pdk.string.format("%s:%s", nodes[i].ip, nodes[i].port)
        if pdk.table.has(node, try_nodes) then
            pdk.table.remove(nodes, i)
        else
            servers[node] = nodes[i].weight
        end
    end

    if not servers or #nodes == 0 then
        pdk.log.error("[sys.balancer] upstream.nodes undefined")
        pdk.response.exit(500)
    end

    upstream.tries = #nodes - 1
    if upstream.enable_tries == 0 or upstream.tries <= 1 then
        upstream.tries = 0
    end

    set_more_tries(upstream.tries)

    local timeout = upstream.timeout
    if timeout then
        local ok, err = set_timeouts(timeout.connect, timeout.send, timeout.read)
        if not ok then
            pdk.log.error("[sys.balancer] could not set upstream timeouts: ", err)
        end
    end

    local address
    if upstream.type == pdk.const.BALANCER_CHASH then
        local chash_up = balancer_chash:new(servers)
        address = chash_up:find(oak_ctx.matched.variable.remote_addr or pdk.const.LOCAL_IP)
    end

    if upstream.type == pdk.const.BALANCER_ROUNDROBIN then
        local round_up = balancer_round:new(servers)
        address = round_up:find()
    end

    if not address then
        pdk.log.error("[sys.balancer] active upstream.nodes number is 0")
        pdk.response.exit(500)
    end

    address = pdk.string.split(address, ":")
    local ok, err = set_current_peer(address[1], pdk.string.tonumber(address[2]))
    if not ok then
        pdk.log.error("[sys.balancer] failed to set the current peer: ", err)
        pdk.response.exit(500)
    end

    pdk.table.insert(try_nodes, address)
    oak_ctx.router.upstream.try_nodes = try_nodes
end

return _M
