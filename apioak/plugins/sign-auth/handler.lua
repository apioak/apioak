local ngx_HTTP_UNAUTHORIZED = ngx.HTTP_UNAUTHORIZED
local ngx_log       = ngx.log
local ngx_timer_at  = ngx.timer.at
local ngx_ERR       = ngx.ERR
local response      = require "lib.response"
local cjson         = require "cjson"
local pairs         = pairs
local next          = next
local type          = type
local pcall         = pcall
local tostring      = tostring
local table_insert  = table.insert
local table_sort    = table.sort
local table_concat  = table.concat
local string_upper  = string.upper
local string_len    = string.len
local ngx_encode_base64 = ngx.encode_base64
local ngx_md5       = ngx.md5
local hmac          = require "resty.hmac"
local sign_auth     = require "plugins.sign-auth.service"
local plugin        = require "plugins.base_plugin"

local SignAuthService   = sign_auth:new()
local SignAuthHandler   = plugin:extend()

-- 获取参数拼接的字符串
local function get_params_to_string(method)
    local paramstr
    if method == "GET" then
        local querys = ngx.req.get_uri_args()
        if type(querys) == "table" and next(querys) then
            local getparams = {}
            for key, value in pairs(querys) do
                table_insert(getparams, tostring(key) .. tostring(value))
            end
            if #getparams > 0 then
                table_sort(getparams)
                paramstr = table_concat(getparams, "")
            end
        end
    else
        local sign_body
        --获取body体
        local bodys = ngx.req.get_body_data()
        if type(bodys) == "string" and string_len(bodys) > 0 then
            local ok, postparams = pcall(cjson.decode, bodys)
            if ok and next(postparams) ~= nil then
                local md5 = ngx_md5(bodys)
                paramstr = ngx_encode_base64(string_upper(md5))
            end
        end
    end
    return paramstr
end

-- 校验签名
local function verify_sign(sign_str, app_secret, sign)
    local result = ngx_encode_base64(hmac.digest("sha256", sign_str, app_secret, rawequal))
    if result == sign then
        return true
    else
        return false
    end
end

function SignAuthHandler:new()
    SignAuthHandler.super.new(self, "sign-auth")
end

function SignAuthHandler:init_worker()
    if ngx.worker.id() == 0 then
        local ok, err = ngx_timer_at(0, function(premature)
            -- 初始化插件配置
            SignAuthService:init_config()
        end)
        if not ok then
            ngx_log(ngx_ERR, "failed to create the timer: ", err)
            return
        end
    end
end

function SignAuthHandler:access(ctx)
    if ctx.api.is_sign == 1 then
        local headers = ngx.req.get_headers()
        local var     = ngx.var
        -- 初始化校验参数
        local params = {
            app_key      = headers.k_key,
            sign         = headers.k_sign,
            timestamp    = headers.k_timestamp,
            product_line = headers.k_product_line,
            nonce        = headers.k_nonce,
            method       = var.request_method,
            gateway_path = var.uri,
            version      = headers.k_version,
            platform     = headers.k_platform,
            app_version  = headers.k_app_version,
            network      = headers.k_network,
        }
        -- 签名参数完整性校验
        if not params.app_key or
           not params.sign or
           not params.timestamp or
           not params.nonce or
           not params.method or
           params.gateway_path == '/'
        then
            return response:error(ngx_HTTP_UNAUTHORIZED, "Incomplete Signature Parameters"):response()
        end
        -- 业务参数完整性校验
        if not params.version or
           not params.product_line or
           not params.platform or
           not params.app_version or
           not params.network
        then
            return response:error(ngx_HTTP_UNAUTHORIZED, "Incomplete Business Parameters"):response()
        end
        -- 获取App秘钥
        local appkey = params.app_key .. "_" .. params.platform
        local appsecret = SignAuthService:get_config_by_appkey(appkey)
        if not appsecret then
            return response:error(ngx_HTTP_UNAUTHORIZED, "App Secret Undefined"):response()
        end
        -- 获取参数拼接的字符串
        local parstr = get_params_to_string(params.method)
        if not parstr then
            return response:error(ngx_HTTP_UNAUTHORIZED, "Signature Parameters Undefined"):response()
        end
        local signstr = params.timestamp..params.nonce..params.gateway_path..params.method..parstr..params.app_key
        -- 校验签名
        local succ = verify_sign(signstr, appsecret, params.sign)
        if not succ then
            return response:error(ngx_HTTP_UNAUTHORIZED, "Signature Authentication Failed"):response()
        end
    end
end

return SignAuthHandler
