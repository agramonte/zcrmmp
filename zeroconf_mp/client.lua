
local socket = require( "socket" )
local clientPulse
local notifierLib
local bufferLib
local _sock

local C = {}
C.connectToServer = function( ip, port )
    local sock, err = socket.connect( ip, port )
    if sock == nil then
        return false
    end

    sock:settimeout( 0 )
    sock:setoption( "tcp-nodelay", true )  --disable Nagle's algorithm
    return sock
end

C.createClientLoop = function( sock, ip, port, notifie, dataLib)
    _sock = sock
    notifierLib = notifie
    bufferLib = dataLib
    notifierLib.notifyOfClientConnected()

    local function cPulse()
        local allData = {}
        local data, err
        local buffer = bufferLib.fetchNextToGo()
 
        repeat
            if _sock then
                data, err = _sock:receive()
            
            
                if data then
                    allData[#allData+1] = data
                end

                if ( err == "closed" and clientPulse ) then  --try again if connection closed
                    _sock = C.connectToServer( ip, port )

                    if _sock then
                        data, err = _sock:receive()
                        if data then
                            allData[#allData+1] = data
                        end
                    end
                end
            end
        until not data
 
        if ( #allData > 0 ) then
            for i, thisData in ipairs( allData ) do
                notifierLib.notifyOfDataRecieved(thisData)
            end
        end
        
        
        for i, msg in pairs( buffer ) do
            
            if _sock then
                local data, err = _sock:send(msg)
            
            
                if ( err == "closed" and clientPulse ) then  --try to reconnect and resend
                    _sock = C.connectToServer( ip, port )
                    if _sock then
                        data, err = _sock:send( msg )
                    end
                end
            end
        end
    end
 
    --pulse 10 times per second
    clientPulse = timer.performWithDelay( 100, cPulse, 0 )

end

C.stopClient = function()
        if clientPulse ~= nil then
            timer.cancel( clientPulse )  --cancel timer
            clientPulse = nil
        end

end

return C
