
local socket = require( "socket" )
local clientPulse
local notifierLib
local bufferLib

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
    notifierLib = notifie
    bufferLib = dataLib
    notifierLib.notifyOfClientConnected()

    local function cPulse()
        local allData = {}
        local data, err
        local buffer = bufferLib.fetchNextToGo()
 
        repeat
            data, err = sock:receive()
            if data then
                allData[#allData+1] = data
            end
            if ( err == "closed" and clientPulse ) then  --try again if connection closed
                C.connectToServer( ip, port )
                data, err = sock:receive()
                if data then
                    allData[#allData+1] = data
                end
            end
        until not data
 
        if ( #allData > 0 ) then
            for i, thisData in ipairs( allData ) do
                notifierLib.notifyOfDataRecieved(thisData)
            end
        end
        
        
        for i, msg in pairs( buffer ) do
            
            local data, err = sock:send(msg)
            
            if ( err == "closed" and clientPulse ) then  --try to reconnect and resend
                C.connectToServer( ip, port )
                data, err = sock:send( msg )
            end
        end
    end
 
    --pulse 10 times per second
    clientPulse = timer.performWithDelay( 100, cPulse, 0 )

end

C.stopClient = function()
        timer.cancel( clientPulse )  --cancel timer
        clientPulse = nil
        sock:close()
end

return C