local json = require("json")


local function tableLength(table)
  local count = 0

  for _ in pairs(table) do 
  	count = count + 1 
  end
  return count
end


zcrmmp = {}

-- Variables.
--Default values for options being sent in.
zcrmmp.numberOfPlayers = 2 --Number of players in a game.
zcrmmp.gameName = "AwesomeGame" --Name of game.
zcrmmp.serverName = "MyAwesomeServer" --Name of service.
zcrmmp.searchForLength = 5000 --Number of mili-seconds to search for players.

--Others
zcrmmp.searchTimer = nil -- variable to hold the search timer.
zcrmmp.serverFound = false -- set to true once we find a server.
zcrmmp.serverInfo = {} -- table to store the server information.
zcrmmp.amServer = false -- to know if I cam client or server.

--References
zcrmmp.zeroconf = require( "plugin.zeroconf" ) -- zeroconf plugin.
zcrmmp.server = require( "zeroconf_mp.server") -- rob miracle original server (with changes).
zcrmmp.client = require( "zeroconf_mp.client") -- rob miracle original client (with changes).
zcrmmp.notifier = require( "zeroconf_mp.notifier") -- notification lib.
zcrmmp.buffer = require( "zeroconf_mp.dataBuffer") -- copy and send buffer.


zcrmmp.zeroconfListener = function(event)
    
    if event.phase == "found" then -- Found a server.

        zcrmmp.serverFound = true -- Set variable to found so that timer doesn't start a server.

        local client = zcrmmp.client.connectToServer( event.addresses[1], event.port) -- Start the client.
        
        zcrmmp.client.createClientLoop( client, event.addresses[1], event.port, zcrmmp.notifier, zcrmmp.buffer ) --Start the client loop.

        zcrmmp.zeroconf.stopBrowseAll() -- Stop the browser.
    end
end

zcrmmp.onEvent = function( event )
     if event.phase == "playerAdded" then -- Found a server.
        local numberOfPlayers = tableLength(event.data)

        if numberOfPlayers == (zcrmmp.numberOfPlayers - 1 ) then -- If we have our number of players.
            zcrmmp.server.stopAccepts() -- Stop accepting new clients.
            zcrmmp.zeroconf.unpublishAll() -- Stop server publish. 
        end
     end
end

zcrmmp.onSearchTimerOver = function(event)
    if zcrmmp.serverFound == false then --Found nothing. Start a server.
        zcrmmp.amServer = true
        zcrmmp.zeroconf.stopBrowseAll() -- Stop the browswer.
       
        zcrmmp.serverInfo = zcrmmp.server.createServer(zcrmmp.notifier, zcrmmp.buffer) -- Create the server.

        zcrmmp.zeroconf.publish( {port = zcrmmp.server.port * 1, type="_corona._tcp", name=zcrmmp.serverName} ) -- Publish server.
    end
end

zcrmmp.init = function(eventListener, optionsTable)
   
    zcrmmp.notifier.eventDispatcher:addEventListener( "zeroconf_mp", eventListener)
    zcrmmp.notifier.eventDispatcher:addEventListener( "zeroconf_mp", zcrmmp.onEvent )
    zcrmmp.zeroconf.init( zcrmmp.zeroconfListener )

    -- Values from option table.
    zcrmmp.gameName = optionsTable["gameName"]
    zcrmmp.serverName = optionsTable["serverName"]
    zcrmmp.searchForLength = optionsTable["searchForLength"]
    zcrmmp.numberOfPlayers = optionsTable["numberOfPlayers"]
    
end

zcrmmp.startGame = function()
    -- Check for servers with zeroconf
    zcrmmp.amServer = false
    zcrmmp.serverFound = false
    zcrmmp.zeroconf.browse( {type="_corona._tcp"} )

    
    -- Create a timer to stop searching for server.
    if zcrmmp.searchForLength > 0 then
        zcrmmp.searchTimer = timer.performWithDelay(zcrmmp.searchForLength, zcrmmp.onSearchTimerOver)
    end

end

zcrmmp.endGame = function()
    if zcrmmp.amServer == true then
        zcrmmp.server.stopServer()
    else
        zcrmmp.client.stopClient()
    end
end

zcrmmp.sendData = function( tableOfData )
    zcrmmp.buffer.addDataToBuffer( tableOfData)
end


return zcrmmp
