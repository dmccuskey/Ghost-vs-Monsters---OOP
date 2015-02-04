--====================================================================--
-- scene-menu.lua
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--

module(..., package.seeall)

--====================================================================--
-- Imports
--====================================================================--

local director = require( "director" )
local ui = require( "ui" )
local HUDFactory = require( "hud_objects" )
local levelMgr = require( "level_manager" )

--====================================================================--
-- Setup, Constants
--====================================================================--

local app_token
local sceneGroup

local loadScreenHUD
local loadTimer


local ghostTween
local ofTween
local playTween

local tapSound = audio.loadSound( "assets/sounds/tapsound.wav" )


--====================================================================--
-- Main
--====================================================================--

local drawScreen

local startLoadingMenu


local function unloadScene()


	if ghostTween then transition.cancel( ghostTween ); end
	if ofTween then transition.cancel( ofTween ); end
	if playTween then transition.cancel( playTween ); end

	if sceneGroup then
		sceneGroup:removeSelf()
		sceneGroup = nil
	end

	loadScreenHUD = nil

end



--== Event and Button Handlers ==--



local function openFeintButtonTouchHandler( event )
	if event.phase == "release" then

		audio.play( tapSound )

		print( "OpenFeint Button Pressed." )
		-- Will display OpenFeint dashboard when uncommented (if OpenFeint was properly initialized in main.lua)
		--app_token.openfeint.launchDashboard()

	end

	return true
end

local function levelSelectHandler( event )

	levelMgr:hide()
	levelMgr:removeEventListener( "level", levelSelectHandler )

	if event.type == "selected" then
		unloadScene()
		app_token.data = event.data
		director:changeScene( app_token, "scene-game" )
	end

	return true
end


local function playButtonTouchHandler( event )
	if event.phase == "release" then
		audio.play( tapSound )
		levelMgr:show()
		levelMgr:toFront()
		levelMgr:addEventListener( "level", levelSelectHandler )
	end

	return true
end




drawScreen = function()


	-- BACKGROUND IMAGE
	local backgroundImage = display.newImageRect( "assets/backgrounds/mainmenu.png", 480, 320 )
	backgroundImage.x = 240; backgroundImage.y = 160

	sceneGroup:insert( backgroundImage )


	-- GHOST
	local menuGhost = display.newImageRect( "assets/characters/menughost.png", 50, 62 )
	menuGhost.x = 240; menuGhost.y = 188

	sceneGroup:insert( menuGhost )


	-- GHOST ANIMATION
	if ghostTween then
		transition.cancel( ghostTween )
	end

	local function ghostAnimation()
		local animUp = function()
			ghostTween = transition.to( menuGhost, { time=400, y=193, onComplete=ghostAnimation })
		end

		ghostTween = transition.to( menuGhost, { time=400, y=183, onComplete=animUp })
	end

	ghostAnimation()
	-- END GHOST ANIMATION


	-- OPENFEINT BUTTON
	local ofBtn = ui.newButton{
		defaultSrc = "assets/buttons/menuofbtn.png",
		defaultX = 118,
		defaultY = 88,
		overSrc = "assets/buttons/menuofbtn-over.png",
		overX = 118,
		overY = 88,
		onEvent = openFeintButtonTouchHandler,
		id = "OpenfeintButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 16,
		emboss = false
	}

	ofBtn:setReferencePoint( display.BottomCenterReferencePoint )
	ofBtn.x = 281 ofBtn.y = 410

	sceneGroup:insert( ofBtn )


	-- PLAY BUTTON
	local playBtn = ui.newButton{
		defaultSrc = "assets/buttons/playbtn.png",
		defaultX = 146,
		defaultY = 116,
		overSrc = "assets/buttons/playbtn-over.png",
		overX = 146,
		overY = 116,
		onEvent = playButtonTouchHandler,
		id = "PlayButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 16,
		emboss = false
	}

	playBtn:setReferencePoint( display.BottomCenterReferencePoint )
	playBtn.x = 365 playBtn.y = 440

	sceneGroup:insert( playBtn )


	-- SLIDE PLAY AND OPENFEINT BUTTON FROM THE BOTTOM:
	local setPlayBtn = function()
		playTween = transition.to( playBtn, { time=100, x=378, y=325 } )

		local setOfBtn = function()
			ofTween = transition.to( ofBtn, { time=100, x=268, y=325 } )
		end

		ofTween = transition.to( ofBtn, { time=500, y=320, onComplete=setOfBtn, transition=easing.inOutExpo } )
	end

	playTween = transition.to( playBtn, { time=500, y=320, onComplete=setPlayBtn, transition=easing.inOutExpo } )

end



--== START: Loading Section ==--

local function loadCompleteHandler( event )

	local f = function()
		loadScreenHUD:removeEventListener( "complete", loadCompleteHandler )
		loadScreenHUD:hide()
		timer.cancel( loadTimer )
		loadTimer = nil

		drawScreen()
	end

	-- make it so we can see 100% load bar for a little bit
	loadScreenHUD.text = "Loading Complete"
	loadTimer = timer.performWithDelay( 200, f, 1 )

end

-- load_snailsAndTails
--
local function load_snailsAndTails()
	--print("GameScene: load_snailsAndTails")
	local contentToLoad = "Snails and Tails"
	local contentPercent = 30

	loadScreenHUD.text = contentToLoad

	-- START LOAD
	-- put stuff here to load
	-- END LOAD

	-- fake loading function
	local f = function()
		loadScreenHUD.percentComplete = loadScreenHUD.percentComplete + contentPercent
	end

	loadTimer = timer.performWithDelay( 500, f, 1 )
end
-- load_gatheringStoneAndWood
--
local function load_gatheringStoneAndWood()
	--print("GameScene: load_gatheringStoneAndWood")

	local contentToLoad = "Gathering Stone and Wood"
	local contentPercent = 30
	local loadNext = load_snailsAndTails

	loadScreenHUD.text = contentToLoad

	-- START LOAD
	-- put stuff here to load
	-- END LOAD

	-- fake loading function
	local f = function()
		loadScreenHUD.percentComplete = loadScreenHUD.percentComplete + contentPercent
	 	loadNext()
	end
	loadTimer = timer.performWithDelay( 500, f, 1 )
end
-- load_ghostsAndGhouls
--
local function load_ghostsAndGhouls()
	--print("GameScene: load_ghostsAndGhouls")

	local contentToLoad = "Ghosts and Ghouls"
	local contentPercent = 40
	local loadNext = load_gatheringStoneAndWood

	loadScreenHUD.text = contentToLoad

	-- START LOAD
	-- put stuff here to load
	-- END LOAD

	-- fake loading function
	local f = function()
		loadScreenHUD.percentComplete = loadScreenHUD.percentComplete + contentPercent
	 	loadNext()
	end
	loadTimer = timer.performWithDelay( 500, f, 1 )
end



startLoadingMenu = function()

	-- setup loading screen
	loadScreenHUD = app_token.loadScreenHUD
	loadScreenHUD:addEventListener( "complete", loadCompleteHandler )
	loadScreenHUD:clear()
	loadScreenHUD:show()

	-- start loading
	load_ghostsAndGhouls()
end

--== END: Loading Section ==--




-- new()
-- Director function
--
function new( params )
	print( "LOADING: Game Menu =============" )

	app_token = params

	-- create the display group for our content
	sceneGroup = display.newGroup()
	app_token.mainGroup:insert( sceneGroup )
	startLoadingMenu()


	--[[
	local monitorMem = function()
		collectgarbage()
	  	print( "\nMemUsage: " .. collectgarbage("count") )

	  	local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
	  	print( "TexMem:   " .. textMem )
	end

	Runtime:addEventListener( "enterFrame", monitorMem )
	]]--

	-- MUST return a display.newGroup()
	return sceneGroup
end

