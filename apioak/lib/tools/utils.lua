local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local string_find = string.find
local pl_stringx = require "pl.stringx"
local json = require "cjson"
local string_gsub = string.gsub
local ngx_re_find = ngx.re.find
local _M = {}
_M.split = pl_stringx.split

function _M.trim_all(str)
    if not str or str == "" then return "" end
    local result = string_gsub(str, " ", "")
    return result
end

function _M.strip(str)
    if not str or str == "" then return "" end
    local result = string_gsub(str, "^ *", "")
    result = string_gsub(result, "( *)$", "")
    return result
end

-- 检查插件是否存在和是否可以正常加载
function _M.load_module(moduleName)
    ngx.log(ngx.DEBUG, moduleName)
    local status, res = pcall(require, moduleName)
    if status then
        return true, res
        -- Here we match any character because if a module has a dash '-' in its name, we would need to escape it.
    elseif type(res) == "string" and string_find(res, "module '" .. moduleName .. "' not found", nil, true) then
        return false, res
    else
        error(res)
    end
end

-- Table转Json
function _M.json_encode(data, empty_table_as_object)
    local json_value
    if json.encode_empty_table_as_object then
        -- empty table encoded as array default
        json.encode_empty_table_as_object(empty_table_as_object or false)
    end
    pcall(function(d) json_value = json.encode(d) end, data)
    return json_value
end

-- Json转Table
function _M.json_decode(str)
    local ok, data = pcall(json.decode, str)
    if ok then
        return data
    end
end

--- Merges two table together.
-- A new table is created with a non-recursive copy of the provided tables
-- @param t1 The first table
-- @param t2 The second table
-- @return The (new) merged table
function _M.table_merge(t1, t2)
    local res = {}
    for k, v in pairs(t1) do res[k] = v end
    for k, v in pairs(t2) do res[k] = v end
    return res
end

--- Merges two array together.
-- A new table is created with a non-recursive copy of the provided tables
-- @param t1 The first table
-- @param t2 The second table
-- @return The (new) merged table
function _M.array_merge(t1, t2)
    local res = {}
    for _, v in ipairs(t1) do tinsert(res, v) end
    for _, v in ipairs(t2) do tinsert(res, v) end
    return res
end

function _M.table_unique(t)
    local check = {};
    local n = {};
    for key, value in pairs(t) do
        if not check[value] then
            n[key] = value
            check[value] = value
        end
    end
    return n
end

function _M.array_unique(t)
    local check = {};
    local n = {};
    for _, value in ipairs(t) do
        if not check[value] then
            tinsert(n, value)
            check[value] = value
        end
    end
    return n
end

--- Checks if a value exists in a table.
-- @param arr The table to use
-- @param val The value to check
-- @return Returns `true` if the table contains the value, `false` otherwise
function _M.table_contains(arr, val)
    if arr then
        for _, v in pairs(arr) do
            if v == val then
                return true
            end
        end
    end
    return false
end


function _M.table_is_array(t)
    if type(t) ~= "table" then return false end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function _M.compose(t, params)
    if t == nil or params == nil or type(t) ~= "table" or type(params) ~= "table" or #t ~= #params + 1 or #t == 0 then
        return nil
    else
        local result = t[1]
        for i = 1, #params do
            result = result .. params[i] .. t[i + 1]
        end
        return result
    end
end

--- Calculates a table size.
-- All entries both in array and hash part.
-- @param t The table to use
-- @return number The size
function _M.table_size(t)
    local res = 0
    if t then
        for _ in pairs(t) do
            res = res + 1
        end
    end
    return res
end

function _M.is_addr(hostname)
    return ngx_re_find(hostname, [[\d+?\.\d+?\.\d+?\.\d+$]], "jo")
end

-- 获取客户端IP地
function _M.get_client_ip()
    local clientIp = ngx.var.http_x_forwarded_for
    if clientIp then
        clientIp = _M.split(clientIp, ',')[1]
    else
        clientIp = ngx.var.remote_addr
    end
    return clientIp
end

return _M
