local _M = {}

_M.format = string.format

_M.lower  = string.lower

_M.upper  = string.upper

_M.find   = string.find

function _M.autocomplete_id(id)
    if not id then
        return nil
    end
    local complete_len = 20  - string.len(id);
    local etcd_id = tostring(id)
    for i = 1, complete_len do
        etcd_id = '0' .. etcd_id
    end
    return etcd_id
end

return _M
