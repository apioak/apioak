local pdk        = require("apioak.pdk")
local dao        = require("apioak.dao")
local schema     = require("apioak.schema")
local oakrouting = require("resty.oakrouting")

local ssl_objects
local empty_table = {}

local oakrouting_ssl_prefix = "oakrouting_ssl_prefix"
local oakrouting_ssl_method = "OPTIONS"

local _M = {}

_M.events_source_ssl     = "events_source_ssl"
_M.events_type_put_ssl   = "events_type_put_ssl"


function _M.peel_certificate(ssl_table)

    if not ssl_table or type(ssl_table) ~= "table" then
        pdk.log.error("peel_certificate: ssl_table is empty or malformed: ["
                              .. pdk.json.encode(ssl_table, true) .. "]")
        return
    end

    if not ssl_table.cert_key then
        pdk.log.error("peel_certificate: The cert and key data of ssl_table are missing: ["
                              .. pdk.json.encode(ssl_table, true) .. "]")
        return
    end

    if not ssl_table.oak_ctx then
        pdk.log.error("peel_certificate: The oak_ctx data of ssl_table are missing: ["
                              .. pdk.json.encode(ssl_table, true) .. "]")
        return
    end

    -- @todo 这里需要补充验证剥离证书的逻辑 params.cert_key 为本地证书信息表（table），字段为 cert 和 key。
    -- @todo oak_ctx 为流量请求时调用 dispatch 在 method 参数后面传入的第一个参数数据（table类型即可）

    return
end

local function generate_ssl_data(params_data)

    if not params_data or type(params_data) ~= "table" then
        return nil, "generate_ssl_data: the data is empty or the data format is wrong["
                .. pdk.json.encode(params_data, true) .. "]"
    end

    if not params_data.sni or not params_data.cert or not params_data.key then
        return nil, "generate_ssl_data: Missing data required fields["
                .. pdk.json.encode(params_data, true) .. "]"
    end

    return {
        path    = oakrouting_ssl_prefix .. ":" .. params_data.sni,
        method  = oakrouting_ssl_method,
        handler = function(params, oak_ctx)

            local ssl_table = {}
            ssl_table.params = params
            ssl_table.cert_key = {
                cert = params_data.cert,
                key  = params_data.key,
            }
            ssl_table.oak_ctx = oak_ctx

            _M.peel_certificate(ssl_table)
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

    if (type(data) ~= "table") or (data == empty_table) then
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

    if ssl_data == empty_table then
        return nil, nil
    end

    return ssl_data, nil
end


return _M