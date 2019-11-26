local ngx       = ngx
local yaml      = require("tinyyaml")
local io_open   = io.open
local conf_path = ngx.config.prefix() .. "conf/apioak.yaml"

local _M = {}

function _M.all()
    local file, err = io_open(conf_path, "r")
    if err then
        return nil, err
    end

    local content = file:read("*a")
    file:close()

    local config = yaml.parse(content)
    if not config then
        return nil, "config format failure"
    end

    return config, nil
end

return _M
