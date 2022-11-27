local pdk = require("apioak.pdk")

local _M = {}

function _M.peel_certificate(ssl_table)

    pdk.log.error("##############[", type(ssl_table), "][", pdk.json.encode(ssl_table, true), "]################")

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

return _M