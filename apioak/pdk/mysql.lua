local config = require("apioak.pdk.config")
local mysql  = require("resty.mysql")

local oak_conf = config.all()
local my_conf = oak_conf.mysql

local _M = {}

function _M.new()
    local db
    local ok
    local err

    db, err = mysql:new()
    if not db then
        return nil, err
    end

    db:set_timeout(my_conf.timeout or 1000)

    ok, err = db:connect({
        host     = my_conf.host     or "127.0.0.1",
        port     = my_conf.port     or 3306,
        database = my_conf.database or "apioak",
        user     = my_conf.user     or "apioak",
        password = my_conf.password or ""
    })

    if not ok then
        return nil, err
    end

    db.close = close
    return db, nil
end

function close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    if self.subscribed then
        return nil, "subscribed state"
    end
    return sock:setkeepalive(my_conf.max_idle_timeout, my_conf.pool_size)
end


function _M.execute(sql)
    local my_cli = _M.new()
    local res, err = my_cli:query(sql)
    my_cli:close()
    return res, err
end

return _M
