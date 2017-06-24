# zcrmmp
Note:
This project and these files are not endorsed or sponsored in anyway by Corona Labs or Rob Miracle. There is 0 support implied or given by me or anybody at Corona if you use these files in your projects.

How to use:
1. Activate zero-conf: https://marketplace.coronalabs.com/plugin/zeroconf
2. Copy the folder "zeroconfrobmiraclemp" and file "zeroconfrobmiraclemp.lua" to your local project.
3. Reference the file:
local multiplayer = require("zeroconfrobmiraclemp")
4. Init the library:
local properties = {} 
properties.gameName = "TestGame" -- Game Name.
properties.serverName = "TestServer" -- Server Name.
properties.searchForLength = 2000 -- Miliseconds to search for server before starting one.
properties.numberOfPlayers = 2 -- Total number of players.

multiplayer.init(
onMultiplayerEvent, -- Event for callback.
properties -- Table just created above with the options.
)
5. Listen to possible callbacks:
When the client or server recieves data from another client.
eventData.name = "zeroconfrobmiraclemp"
eventData.phase = "dataRecieved"
eventData.isError = "false"
eventData.data = <table with the data recieved>

When a client connects to the server. Server only event.
eventData.name = "zeroconfrobmiraclemp"
eventData.phase = "playerAdded"
eventData.isError = "false"
eventData.data = <table of players>

When a client connects to the server. Client only event.
eventData.name = "zeroconfrobmiraclemp"
eventData.phase = "connected"
eventData.isError = "false"
6. To send data call this function:
multiplayer.sendData(testData) -- Table of data to send.
7. To clean things after the game is over:
multiplayer.endGame() 

Some notes:
1. Only tested on Android devices and my Macbook. iOS testing is next on my list, not sure if I'll ever test it on Windows.
2. Only tested with 2 devices but should work with more.
3. There is a very simple example app that you can compile (it also will run in the emulator for one of the client/servers) and run on 2 devices to play with. It requires that you activate toast here: https://marketplace.coronalabs.com/plugin/toast.
