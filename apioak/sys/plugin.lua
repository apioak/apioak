local pdk         = require("apioak.pdk")
local dao         = require("apioak.dao")
local schema      = require("apioak.schema")
local events      = require("resty.worker.events")
local ngx_process = require("ngx.process")

local ngx_sleep          = ngx.sleep
local ngx_timer_at       = ngx.timer.at
local ngx_worker_exiting = ngx.worker.exiting

local plugin_objects = {}

local _M = {}

_M.events_source_plugin   = "events_source_plugin"
_M.events_type_put_plugin = "events_type_put_plugin"

local function plugins_handler_map_name()

    local plugin_handler_list = pdk.plugin.plugins_loading()

    if not plugin_handler_list then
        return nil
    end

    local plugins_handler_map = {}

    for i = 1, #plugin_handler_list do
        plugins_handler_map[plugin_handler_list[i].key] = plugin_handler_list[i].handler
    end

    if next(plugins_handler_map) then
        return plugins_handler_map
    end

    return nil

end

function _M.sync_update_plugin_data()

    local plugins_name_handler_map = plugins_handler_map_name()

    if not plugins_name_handler_map then
        pdk.log.error("plugins_list: valid plugins are empty!")
        return nil
    end

    local list, err = dao.common.list_keys(dao.common.PREFIX_MAP.plugins)

    if err then
        pdk.log.error("plugins_list: get plugin list FAIL [".. err .."]")
        return nil
    end

    if not list or not list.list or (#list.list == 0) then
        pdk.log.error("plugins_list: plugin list null!")
        return nil
    end

    local plugins_data_list = {}

    for i = 1, #list.list do

        repeat
            local _, err = pdk.schema.check(schema.plugin.plugin_data, list.list[i])

            if err then
                pdk.log.error("plugins_list: plugin schema check err:[" .. err .. "]["
                                      .. pdk.json.encode(list.list[i], true) .. "]")
                break
            end

            local plugin_key = list.list[i].key

            if not plugins_name_handler_map[plugin_key] then
                break
            end

            local plugin_object = require("apioak.plugin." .. plugin_key .. "." .. plugin_key)

            if plugin_object.schema_config then
                local err = plugin_object.schema_config(list.list[i].config)

                if err then
                    pdk.log.error("plugins_list: plugin config schema check err:[" .. err .. "]["
                                          .. pdk.json.encode(list.list[i], true) .. "]")
                    break
                end
            end

            pdk.table.insert(plugins_data_list, {
                id      = list.list[i].id,
                key     = list.list[i].key,
                config  = list.list[i].config,
            })

        until true

    end

    if #plugins_data_list == 0 then
        return nil
    end

    return plugins_data_list
end

local function automatic_sync_plugin()

    if ngx_process.type() ~= "privileged agent" then
        return
    end

    local i, limit = 0, 10

    while not ngx_worker_exiting() and i <= limit do
        i = i + 1

        repeat

            local plugin_list = plugins_list()

            if not plugin_list or #plugin_list == 0 then
                pdk.log.error("automatic_sync_plugin: the plugin and nodes list null")
                break
            end

            local _, post_plugin_err = events.post(events_source_plugin, events_type_put_plugin, plugin_list)

            if post_plugin_err then
                pdk.log.error("automatic_sync_plugin: sync plugin data post err:["
                                      .. i .."][" .. tostring(post_plugin_err) .. "]")
            end

        until true

        ngx_sleep(3)
    end

    if not ngx_worker_exiting() then
        ngx_timer_at(0, automatic_sync_plugin)
    end

end

local function worker_event_plugin_handler_register()

    local plugin_handler = function(data, event, source)

        if source ~= _M.events_source_plugin then
            return
        end

        if event ~= _M.events_type_put_plugin then
            return
        end

        if (type(data) ~= "table") or (#data == 0) then
            return
        end

        local plugins_name_handler_map = plugins_handler_map_name()

        for i = 1, #data do
            plugin_objects[data[i].id] = {
                key     = data[i].key,
                config  = data[i].config,
                handler = plugins_name_handler_map[data[i].key],
            }
        end

    end

    if ngx_process.type() ~= "privileged agent" then
        events.register(plugin_handler, _M.events_source_plugin, _M.events_type_put_plugin)
    end

end

function _M.init_worker()

    worker_event_plugin_handler_register()

    --ngx_timer_at(0, automatic_sync_plugin)

end

function _M.plugin_subjects()

    return plugin_objects

end

return _M
