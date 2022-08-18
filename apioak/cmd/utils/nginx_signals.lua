local common = require("apioak/cmd/utils/common")

local _M = {}

function _M.start()
    local cmd = common.openresty_launch
    os.execute(cmd)
end

function _M.stop()
    local cmd = common.openresty_launch .. [[ -s stop]]
    os.execute(cmd)
end

function _M.quit()
    local cmd = common.openresty_launch .. [[ -s quit]]
    os.execute(cmd)
end

function _M.test()
    local cmd = common.openresty_launch .. [[ -t]]
    os.execute(cmd)
end

function _M.reload()
    local cmd = common.openresty_launch .. [[ -s reload]]
    os.execute(cmd)
end


return _M