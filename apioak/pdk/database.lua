local config = require("apioak.sys.config")
local mysql  = require("resty.mysql")

local _M = {}

function _M.new()
    local res, err = mysql:new()
    if not res then
        return nil, err
    end
    local db = res

    res, err = config.query("database")
    if err then
        return nil, err
    end
    local conf = res

    db:set_timeout(conf.timeout or 1000)

    res, err = db:connect({
        host     = conf.host     or "127.0.0.1",
        port     = conf.port     or 3306,
        database = conf.db_name  or "apioak",
        user     = conf.user     or "apioak",
        password = conf.password or ""
    })

    if not res then
        return nil, err
    end

    db.conf  = conf
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
    return sock:setkeepalive(self.conf.max_idle_timeout, self.conf.pool_size)
end


function _M.execute(sql)
    local my_cli = _M.new()
    local res, err = my_cli:query(sql)
    my_cli:close()
    return res, err
end

return _M
