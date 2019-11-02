-- lua-resty-rabbitmqstomp: Opinionated RabbitMQ (STOMP) client lib
-- Copyright (C) 2013 Rohit 'bhaisaab' Yadav, Wingify
-- Opensourced at Wingify in New Delhi under the MIT License

local byte = string.byte
local concat = table.concat
local error = error
local find = string.find
local gsub = string.gsub
local insert = table.insert
local len = string.len
local pairs = pairs
local setmetatable = setmetatable
local sub = string.sub
local tcp = ngx.socket.tcp

module(...)

_VERSION = "0.1"

local mt = { __index = _M }

local LF = "\x0a"
local EOL = "\x0d\x0a"
local NULL_BYTE = "\x00"
local STATE_CONNECTED = 1
local STATE_COMMAND_SENT = 2


function new(self, opts)
    local sock, err = tcp()
    if not sock then
        return nil, err
    end
    
    if opts == nil then
	opts = {username = "guest", password = "guest", vhost = "/", trailing_lf = true}
    end
     
    return setmetatable({ sock = sock, opts = opts}, mt)

end


function set_timeout(self, timeout)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:settimeout(timeout)
end


function _build_frame(self, command, headers, body)
    local frame = {command, EOL}

    if body then
        headers["content-length"] = len(body)
    end

    for key, value in pairs(headers) do
        insert(frame, key)
        insert(frame, ":")
        insert(frame, value)
        insert(frame, EOL)
    end

    insert(frame, EOL)

    if body then
        insert(frame, body)
    end

    insert(frame, NULL_BYTE)
    insert(frame, EOL)
    return concat(frame, "")
end


function _send_frame(self, frame)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    return sock:send(frame)
end


function _receive_frame(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    local resp = nil
    if self.opts.trailing_lf == nil or self.opts.trailing_lf == true then
        resp = sock:receiveuntil(NULL_BYTE .. LF, {inclusive = true})
    else
        resp = sock:receiveuntil(NULL_BYTE, {inclusive = true})
    end
    local data, err, partial = resp()
    return data, err
end


function _login(self)
    
    local headers = {}
    headers["accept-version"] = "1.2"
    headers["login"] = self.opts.username
    headers["passcode"] = self.opts.password
    headers["host"] = self.opts.vhost

    local ok, err = _send_frame(self, _build_frame(self, "CONNECT", headers, nil))
    if not ok then
        return nil, err
    end

    local frame, err = _receive_frame(self)
    if not frame then
        return nil, err
    end

    -- We successfully received a frame, but it was an ERROR frame
    if sub( frame, 1, len( 'ERROR' ) ) == 'ERROR' then
        return nil, frame
    end

    self.state = STATE_CONNECTED
    return frame
end


function _logout(self)
    local sock = self.sock
    if not sock then
	self.state = nil
        return nil, "not initialized"
    end

    if self.state == STATE_CONNECTED then
        -- Graceful shutdown
        local headers = {}
        headers["receipt"] = "disconnect"
        sock:send(_build_frame(self, "DISCONNECT", headers, nil))
        sock:receive("*a")
    end
    self.state = nil
    return sock:close()
end


function connect(self, ...)

    local sock = self.sock

    if not sock then
        return nil, "not initialized"
    end

    local ok, err = sock:connect(...)
    
    if not ok then
        return nil, "failed to connect: " .. err
    end
    
    local reused = sock:getreusedtimes()
    if reused and reused > 0 then
        self.state = STATE_CONNECTED
        return 1
    end
    
    return _login(self)

end


function send(self, msg, headers)
    local ok, err = _send_frame(self, _build_frame(self, "SEND", headers, msg))
    if not ok then
        return nil, err
    end

    if headers["receipt"] ~= nil then
        return _receive_frame(self)
    end
    return ok, err
end


function subscribe(self, headers)
    return _send_frame(self, _build_frame(self, "SUBSCRIBE", headers))
end


function unsubscribe(self, headers)
    return _send_frame(self, _build_frame(self, "UNSUBSCRIBE", headers))
end


function receive(self)
    local data, err = _receive_frame(self)
    if not data then
        return nil, err
    end
    local idx = find(data, "\n\n", 1)
    return sub(data, idx + 2)
end


function set_keepalive(self, ...)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    if self.state ~= STATE_CONNECTED then
        return nil, "cannot be reused in the current connection state: "
                    .. (self.state or "nil")
    end

    self.state = nil
    return sock:setkeepalive(...)
end


function get_reused_times(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:getreusedtimes()
end


function close(self)
    return _logout(self)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
      error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
