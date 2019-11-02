local pool = require "lib.core.db"

local _M = {}

function _M.get_audit(project_id, env)
    local db = pool:new()
    if env == nil then
        env = 'prod'
    end
    local audits = db:query("select name,value,versions,remark from audit_configs where project_id=? and env=?", {project_id, env})
    return audits
end

function _M.update_audit(project_id, versions)
    local db = pool:new()
    local audits = db:query("update audit_configs set versions = '".. versions .. "' where project_id="..project_id)
    return audits
end

return _M
