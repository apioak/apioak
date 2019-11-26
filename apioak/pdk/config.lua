local yaml = require "tinyyaml"
local pl_stringx = require "pl.stringx"

local _M = {}

function _M.get(yaml_key)
    local file = io.open("conf/apioak.yaml", "r")
    local yaml_str = file:read("*a")
    file:close()

    local yaml_res = yaml.parse(yaml_str)
    if (yaml_key ~= nil)
    then
        return get_val(yaml_res, yaml_key);
    end
    return yaml_res
end

-- 获取指定key的值
function get_val(res, key)
    local split_arr =  pl_stringx.split(key, ".");
    for k, v in ipairs(split_arr) do
        res = res[v]
    end
    return res
end

return _M
