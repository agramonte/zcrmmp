# zcrmmp
Note:
This project and these files are not endorsed or sponsored in anyway by Corona Labs. There is 0 support implied or given by me or anybody at Corona if you use these files in your projects.

Instructions:
1. Activate zero-conf: https://marketplace.coronalabs.com/plugin/zeroconf
2. Copy the folder "zeroconf_mp" and file "zeroconf_mp.lua" to your local project.
3. Reference the file:
```
local multiplayer = require("zeroconf_mp")
```
4. Init the library:
```
local properties = {} 
properties.gameName = "TestGame" -- Game Name.
properties.serverName = "TestServer" -- Server Name.
properties.searchForLength = 2000 -- Miliseconds to search for server before starting one.
properties.numberOfPlayers = 2 -- Total number of players.

multiplayer.init(
onMultiplayerEvent, -- Event for callback.
properties -- Table just created above with the options.
)
```
5. To start the game:
```
multiplayer.startGame()
```
6. To end the game:
``
multiplayer.endGame() 
``
7. To send data:
'''
multiplayer.sendData(testData) -- Table of data to send.
'''
8. Listening to events.

When the client or server recieves data from another client.
eventData.name = "zeroconf_mp"
eventData.phase = "dataRecieved"
eventData.isError = "false"
eventData.data = <table with the data recieved>

When a client connects to the server. Server only event.
eventData.name = "zeroconf_mp"
eventData.phase = "playerAdded"
eventData.isError = "false"
eventData.data = <table of players>

When a client connects to the server. Client only event.
eventData.name = "zeroconf_mp"
eventData.phase = "connected"
eventData.isError = "false"
