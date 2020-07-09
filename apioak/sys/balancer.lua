local pdk = require("apioak.pdk")
local db  = require("apioak.db")
local ngx_sleep          = ngx.sleep
local ngx_timer_at       = ngx.timer.at
local ngx_worker_exiting = ngx.worker.exiting
local ngx_var            = ngx.var
local ngx_re_match       = ngx.re.match
local balancer           = require("ngx.balancer")
local balancer_chash     = require('resty.chash')
local balancer_round     = require('resty.roundrobin')
local set_current_peer   = balancer.set_current_peer
local get_last_failure   = balancer.get_last_failure
local set_more_tries     = balancer.set_more_tries
local set_timeouts       = balancer.set_timeouts

local upstream_objects = {}
local checker
local upstream_latest_hash_id
local upstream_cached_hash_id

local checks_conf = {
    active = {
        healthy = {
            interval = 0.1,
            successes = 1,
        },
        unhealthy = {
            interval = 5,
            http_failures = 2,
        }
    },
}

local _M = {}

local function loading_upstreams()
    local res, err = db.upstream.all()
    if err then
        pdk.log.error("[sys.balancer] loading upstreams failure, ", err)
    end

    for i = 1, #res do
        local nodes       = res[i].nodes
        local type        = res[i].type

        local servers = pdk.table.new(10, 0)
        for s = 1, #nodes do
            local node_res = ngx_re_match(nodes[s].ip, "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$")
            if not node_res then
                nodes[s].ip = pdk.string.format("[%s]", nodes[s].ip)
            end

            local node    = pdk.string.format("%s:%s", nodes[s].ip, nodes[s].port)
            servers[node] = nodes[s].weight

            local host, port = pdk.string.parse_address(node)
            --local ok, err = checker:add_target(host, port)
            --if not ok then
            --    pdk.log.error("[sys.balancer] health check add target: ", "ip: ", nodes[s].ip, "port:", nodes[s].port, "err:", err)
            --end
        end

        local balancer_handle
        if type == pdk.const.BALANCER_ROUNDROBIN then
            balancer_handle = balancer_round:new(servers)
        end

        if type == pdk.const.BALANCER_CHASH then
            balancer_handle = balancer_chash:new(servers)
        end

        local upstream_id = tonumber(res[i].id)
        upstream_objects[upstream_id] = {
            handler  = balancer_handle,
            timeouts = res[i].timeouts,
            type     = type
        }
    end
end

local function create_health_checker(premature)

    if premature then
        return
    end

    loading_upstreams()
    return
end

local function get_health_nodes(upstream_id)

    for _, nodes in ipairs(upstream_objects[upstream_id].handler.ids) do

        local host, port = pdk.string.parse_address(nodes)
        --local ok, err = checker:get_target_status(host, port)
        --
        --if not ok then
        --    upstream_objects[upstream_id].handler:delete(nodes)
        --    pdk.log.error("[sys.balancer] health check down target: ", "ip: ", host, "port: ", port, "err:", err)
        --end
    end
    return upstream_objects[upstream_id]
end

local function automatic_sync_hash_id(premature)
    if premature then
        return
    end

    local i = 1
    while not ngx_worker_exiting() and i <= 10 do

        i = i + 1

        local res, err = db.upstream.query_last_updated_hid()
        if err then
            pdk.log.error("[sys.balancer] automatic sync upstreams last updated timestamp reading failure ", err)
            break
        end
        upstream_latest_hash_id = res.hash_id
        ngx_sleep(10)
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_hash_id)
    end
end

function _M.init_worker()
    ngx_timer_at(0, create_health_checker)
    ngx_timer_at(0, automatic_sync_hash_id)
end

function _M.init_worker_event()

    local worker_events = require "resty.worker.events"
    local health_check = require("resty.healthcheck")

    local ok, err = worker_events.configure {
        shm = "upstream_worker_event",
        timeout = 5,
        interval = 1,
    }

    if not ok then
        pdk.log.error("[sys.balancer] failed to configure worker events err: ", err)
    end
    checker = health_check.new({
        name = "health_check",
        shm_name = "upstream_health_check",
        checks = checks_conf
    })
    return
end

function _M.loading()
    if not upstream_cached_hash_id or upstream_cached_hash_id ~= upstream_latest_hash_id then
        loading_upstreams()
        upstream_cached_hash_id = upstream_latest_hash_id
    end
end

function _M.gogogo(oak_ctx)
    local router   = oak_ctx.router
    local upstream = router.upstream

    if not upstream then
        pdk.log.error("[sys.balancer] upstream undefined")
        pdk.response.exit(500)
    end

    local upstream_id = upstream.id or nil
    if not upstream_id then
        pdk.log.error("[sys.balancer] upstream undefined")
        pdk.response.exit(500)
    end

    upstream = get_health_nodes(upstream_id)
    local state, code = get_last_failure()
    if state == "failed" then
        pdk.log.error("[sys.balancer] connection failure state: " .. state .. " code: " .. code)
    end

    set_more_tries(0)

    local timeout = upstream.timeouts
    if timeout then
        local connect_timout = timeout.connect or 0
        local send_timeout = timeout.send or 0
        local read_timeout = timeout.read or 0
        local ok, err = set_timeouts(connect_timout / 1000, send_timeout / 1000, read_timeout / 1000)
        if not ok then
            pdk.log.error("[sys.balancer] could not set upstream timeouts: ", err)
        end
    end

    local handler = upstream.handler
    local address
    if upstream.type == pdk.const.BALANCER_CHASH then
        local request_address = ngx_var.remote_addr
        address = handler:find(request_address)
    end

    if upstream.type == pdk.const.BALANCER_ROUNDROBIN then
        address = handler:find()
    end

    if not address then
        pdk.log.error("[sys.balancer] active upstream.nodes number is 0")
        pdk.response.exit(500)
    end

    local host, port = pdk.string.parse_address(address)
    local ok, err = set_current_peer(host, port)
    if not ok then
        pdk.log.error("[sys.balancer] failed to set the current peer: ", err)
        pdk.response.exit(500)
    end
end

return _M
