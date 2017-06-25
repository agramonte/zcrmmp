-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local toast = require('plugin.toast')
local startGameText
local buttonTouched = false
local whatAmI = system.getInfo( "deviceID" )

--- 1. Add the file.
local multiplayer = require("zeroconf_mp")


local function onButtonTouched(event)
	 if event.phase == "ended" and buttonTouched == false then
		-- 3. Start the game.
		multiplayer.startGame()
		buttonTouched = true
		startGameText.text = "Looking..."
	end
end

local function onDataTick(event)
	-- 4. Send some data.
		local testData = {}
		testData.justPlayed = whatAmI.." played: "..math.random(1, 10)
		multiplayer.sendData(testData)
end

--------------------------------------------
function onMultiplayerEvent(event)
	local json = require("json")
	local eventJson = json.encode(event)

	if eventJson ~= nil then
    	print(json.prettify(eventJson))
	end

	if event.phase == "dataRecieved" then
		startGameText.text = "Recieving Data."
		toast.show("Data recieved: "..event.data["justPlayed"])
	end

	if event.phase == "playerAdded" or event.phase == "connected" then
		print("--Player added. ")
		toast.show("player added")
		startGameText.text = "Game ready."

		timer.performWithDelay( 5000, onDataTick, 0)
	end

end



function scene:create( event )
	local sceneGroup = self.view

	--- 2. Init library.
	local properties = {}
	properties.gameName = "TestGame"
	properties.serverName = "TestServer"
	properties.searchForLength = 2000
	properties.numberOfPlayers = 2
	multiplayer.init(onMultiplayerEvent, properties)

	-- UI for the test app.
	local startGame = display.newRect( sceneGroup, display.contentWidth/2, display.contentHeight/2, math.floor(display.contentWidth * .70), math.floor(display.contentHeight * .08))
    startGame:setFillColor( 1 )
    startGame:addEventListener( "touch", onButtonTouched )

	startGameText = display.newText( "start game", startGame.x, startGame.y, native.systemFontBold, 20 )
    sceneGroup:insert(startGameText)
    startGameText:setFillColor(0)

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene