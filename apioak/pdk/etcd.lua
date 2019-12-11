local config = require("apioak.pdk.config")
local etcd   = require("resty.etcd")

local _M = {}

local function get_cli()
    local oak_conf = config.all()
    local etcd_conf = oak_conf.etcd

    local etcd_options = {}
    etcd_options.http_host  = etcd_conf.host
    etcd_options.timeout    = etcd_conf.timeout
    etcd_options.protocol   = "v2"
    etcd_options.key_prefix = "/v2/keys"
    local prefix = etcd_conf.prefix or ""

    local cli, err = etcd:new(etcd_options)

    if err then
        return nil, prefix, err
    end

    return cli, prefix, nil
end

function _M.query(key)
    local cli, prefix, cli_err = get_cli()
    if not cli then
        return nil, 500, cli_err
    end
    local res, err = cli:get(prefix .. key)
    if err then
        return nil, 500, err
    end

    if res.status ~= 200 then
        return nil, res.status, res.reason
    end

    return res.body.node, res.status, nil
end

function _M.update(key, value)
    local cli, prefix, cli_err = get_cli()
    if not cli then
        return nil, 500, cli_err
    end
    local res, err = cli:set(prefix .. key, value)
    if err then
        return nil, 500, err
    end

    if res.status ~= 200 and res.status ~= 201 then
        return nil, res.status, res.reason
    end

    return res.body.node, res.status, nil
end

function _M.create(key, value)
    local cli, prefix, cli_err = get_cli()
    if not cli then
        return nil, 500, cli_err
    end

    local res, err = cli:push(prefix .. key, value)
    if err then
        return nil, 500, err
    end

    if res.status ~= 201 then
        return nil, res.status, res.reason
    end

    return res.body.node, res.status, nil
end

function _M.delete(key)
    local cli, prefix, cli_err = get_cli()
    if not cli then
        return nil, 500, cli_err
    end

    local res, err = cli:delete(prefix .. key)
    if err then
        return nil, 500, err
    end

    if res.status ~= 200 then
        return nil, res.status, res.reason
    end

    return res.body.node, res.status, nil
end

return _M
