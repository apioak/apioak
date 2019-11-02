--
-- Created by IntelliJ IDEA.
-- User: renyineng
-- Date: 17/11/8
-- Time: 下午12:28
-- To change this template use File | Settings | File Templates.
--
local tools = require('lib.tools.utils')
local cjson = require('cjson')
local request = require('lib.core.request')
local summary = require('module.summary')

local _M = {}

function _M.index()
    local data = summary.report();
--asdf
    ngx.say(data)
    ngx.exit(0)
end
return _M

