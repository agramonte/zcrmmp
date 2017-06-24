
local socket = require( "socket" )
local clientList = {}
local tcp, err
local serverIp
local serverPulse
local notifierLib
local acceptClients = true

local S = {}

S.port = 0

S.getIP = function()
    local s = socket.udp()
    s:setpeername( "74.125.115.104", 80 )
    local ip, sock = s:getsockname()
    return ip
end

S.createServer = function(notifie, buffer)

    notifierLib = notifie -- Assign the notifier the one that came in.
    bufferLib = buffer

    tcp, err = socket.bind( S.getIP(), 0 ) -- Let it bind to any port.

    serverIp, S.port = tcp:getsockname()
    tcp:settimeout( 0 )
  
    local function sPulse()
        
        local clientBuffer = {}

        --if acceptClients == true then
        repeat
            local client = tcp:accept()
            if client then
                
                client:settimeout( 0 )  --just check the socket and keep going.
                local name = client:getpeername() -- get peer name to use as key.
                clientList[#clientList+1] = client

                notifierLib.notifyOfPlayerAdded(clientList) -- send a notification when we get a client.
            end
        until not client
        --end
        
        local ready, writeReady, err = socket.select( clientList, clientList, 0 )

        if err == nil then 
          local dataRecieved = false
          
          for i = 1, #ready do
                local allData = {}
                local client = ready[i]

                repeat
                    local data, err = client:receive()
                    if data then
                        allData[#allData+1] = data
                        notifierLib.notifyOfDataRecieved(data)
                    end
                until not data
                
                if ( #allData > 0 ) then  --figure out what the client said to the server
                    clientBuffer[client] = allData -- Saving the data from the clients in the client buffer.
                end
            end
         end
         
         
         for i = 1, #writeReady do
            local client = writeReady[i]
             
            for sock, buffer in pairs( clientBuffer ) do  
                if sock:getpeername() ~= client:getpeername() then -- not the same client.
                        for _, msg in pairs( buffer ) do
                            local data, err = client:send( msg )
                        end
                    end
            end 
            
            -- Send the local instance data.
            local serverClientBuffer = bufferLib.fetchNextToGo()
            for _, msg in pairs( serverClientBuffer ) do
                local data, err = client:send( msg )
            end  
        end
    end

    serverPulse = timer.performWithDelay( 100, sPulse, 0 )

    local serverInfo = {}
    serverInfo.port = serverPort
    serverInfo.serverIp = serverIp
    
    return serverInfo
end

S.stopAccepts = function()
    acceptClients = false
end

S.stopServer = function()
    timer.cancel( serverPulse )  --cancel timer
    tcp:close()
    for i, v in pairs( clientList ) do
        v:close()
    end
end

return S