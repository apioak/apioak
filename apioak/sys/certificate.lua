local pdk        = require("apioak.pdk")
local dao        = require("apioak.dao")
local schema     = require("apioak.schema")
local oakrouting = require("resty.oakrouting")

local ssl_objects

local oakrouting_ssl_prefix = "oakrouting_ssl_prefix"
local oakrouting_ssl_method = "OPTIONS"

local _M = {}

_M.events_source_ssl   = "events_source_ssl"
_M.events_type_put_ssl = "events_type_put_ssl"


function _M.peel_certificate(oak_ctx)

    if not oak_ctx.config or type(oak_ctx.config) ~= "table" then
        pdk.log.error("peel_certificate: oak_ctx.config is empty or malformed: ["
                              .. pdk.json.encode(oak_ctx, true) .. "]")
        return
    end

    if not oak_ctx.config.cert_key or not next(oak_ctx.config.cert_key) then
        pdk.log.error("peel_certificate: the cert and key data of oak_ctx.config.cert_key are missing: ["
                              .. pdk.json.encode(oak_ctx, true) .. "]")
        return
    end

    -- @todo 这里需要补充验证剥离证书的逻辑 oak_ctx.config.cert_key 为本地证书信息表（table），字段为 cert 和 key。
    -- @todo oak_ctx 为流量请求时调用 dispatch 在 method 参数后面传入的第一个参数数据（table类型即可）。
    -- @todo 一般请求流量的具体数据在 oak_ctx.matched 的lua table 表中

    return
end

local function generate_ssl_data(ssl_data)

    if not ssl_data or type(ssl_data) ~= "table" then
        return nil, "generate_ssl_data: the data is empty or the data format is wrong["
                .. pdk.json.encode(ssl_data, true) .. "]"
    end

    if not ssl_data.sni or not ssl_data.cert or not ssl_data.key then
        return nil, "generate_ssl_data: Missing data required fields["
                .. pdk.json.encode(ssl_data, true) .. "]"
    end

    return {
        path    = oakrouting_ssl_prefix .. ":" .. ssl_data.sni,
        method  = oakrouting_ssl_method,
        handler = function(params, oak_ctx)

            oak_ctx.params = params

            oak_ctx.config = {}
            oak_ctx.config.cert_key = {
                sni  = ssl_data.sni,
                cert = ssl_data.cert,
                key  = ssl_data.key,
            }

            _M.peel_certificate(oak_ctx)
        end
    }, nil
end

_M.ssl_handler = function (data, event, source)

    if source ~= _M.events_source_ssl then
        return
    end

    if event ~= _M.events_type_put_ssl then
        return
    end

    if (type(data) ~= "table") or not next(data) then
        return
    end

    local oak_ssl_data = {}

    for i = 1, #data do

        repeat

            local ssl_data, ssl_data_err = generate_ssl_data(data[i])

            if ssl_data_err then
                pdk.log.error("ssl_handler: generate ssl data err: [" .. tostring(ssl_data_err) .. "]")
                break
            end

            table.insert(oak_ssl_data, ssl_data)

        until true
    end

    ssl_objects = oakrouting.new(oak_ssl_data)
end

function _M.sync_update_ssl_data()

    local ssl_list, ssl_list_err = dao.certificate.lists()

    if ssl_list_err then
        return nil, ssl_list_err
    end

    if not ssl_list.list then
        return nil, nil
    end

    local ssl_data = {}
    for i = 1, #ssl_list.list do

        repeat

            local _, err = pdk.schema.check(schema.certificate.sync_data_certificate, ssl_list.list[i])

            if err then
                pdk.log.error("sync_update_ssl_data: schema check err:[" .. err .. "]["
                                      .. pdk.json.encode(ssl_list.list[i], true) .. "]")
                break
            end

            for j = 1, #ssl_list.list[i].snis do
                table.insert(ssl_data, {
                    sni = ssl_list.list[i].snis[j],
                    key = ssl_list.list[i].key,
                    cert = ssl_list.list[i].cert,
                })
            end

        until true
    end

    if not next(ssl_data) then
        return nil, nil
    end

    return ssl_data, nil
end

function _M.ssl_match(oak_ctx)

    if not oak_ctx.matched or not oak_ctx.matched.host then
        pdk.log.error("ssl_match: oak_ctx data format err: [" .. pdk.json.encode(oak_ctx, true) .. "]")
        return false
    end

    local match_sni = oakrouting_ssl_prefix .. ":" .. oak_ctx.matched.host

    local match, err = ssl_objects:dispatch(match_sni, oakrouting_ssl_method, oak_ctx)

    if err then
        pdk.log.error("ssl_match: ssl_objects dispatch err: [" .. tostring(err) .. "]")
        return false
    end

    if not match then
        return false
    end

    return true
end


return _M