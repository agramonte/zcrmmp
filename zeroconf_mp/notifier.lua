local json = require("json")

local N = {}
N.eventDispatcher = system.newEventDispatcher()

--Will send all the events from here to keep all the logic together and
--the event format the same.
N.notifyOfDataRecieved = function(message)
    local messageTable = json.decode(message)
    
    local eventData = {}
    eventData.name = "zeroconf_mp"
    eventData.phase = "dataRecieved"
    eventData.isError = "false"
    eventData.data = messageTable
    
    N.eventDispatcher:dispatchEvent( eventData )
end

N.notifyOfPlayerAdded = function(players)
    local eventData = {}
    eventData.name = "zeroconf_mp"
    eventData.phase = "playerAdded"
    eventData.isError = "false"
    eventData.data = players

    N.eventDispatcher:dispatchEvent( eventData )
end

N.notifyOfClientConnected = function()
    local eventData = {}
    eventData.name = "zeroconf_mp"
    eventData.phase = "connected"
    eventData.isError = "false"
    eventData.data = ""

    N.eventDispatcher:dispatchEvent( eventData )
end

N.notifyOfServerStart = function()
    local eventData = {}
    eventData.name = "zeroconf_mp"
    eventData.phase = "serverStarted"
    eventData.isError = "false"
    eventData.data = ""

    N.eventDispatcher:dispatchEvent( eventData )
end

return N