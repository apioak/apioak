local yaml = require "tinyyaml"

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
    local split_arr =  split(key, ".");
    for k, v in ipairs(split_arr) do
        res = res[v]
    end
    return res
end

-- 切分字符串
function split(split_string, separator)
    local index = 1
    local split_key = 1
    local split_arr = {}
    while true do
        local find_index = string.find(split_string, separator, index, true)
        if not find_index then
            split_arr[split_key] = string.sub(split_string, index, string.len(split_string))
            break
        end
        split_arr[split_key] = string.sub(split_string, index, find_index -1)
        index = find_index + string.len(separator)
        split_key = split_key + 1
    end
    return split_arr
end

return _M
