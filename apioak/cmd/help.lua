local function execute()
    print([[
    Usage: apioak [action] <argument>
    help:       show this message, then exit
    start:      start the apioak server
    quit:       quit the apioak server
    stop:       stop the apioak server
    restart:    restart the apioak server
    reload:     reload the apioak server
    test:       test the apioak nginx config
    env:        check apioak running environment
    version:    print apioak's version
    ]])
end

local lapp = [[
Usage: apioak help
]]


return {
    lapp = lapp,
    execute = execute
}