--====================================================================--
-- scene-game.lua
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
--====================================================================--

module(..., package.seeall)

--====================================================================--
-- Imports
--====================================================================--

local director = require( "director" )
local HUDFactory = require( "hud_objects" )
local GameEngine = require( "game_engine" )
local LevelMgr = require( "level_manager" )
local Utils = require( "dmc_utils" )


--====================================================================--
-- Setup, Constants
--====================================================================--

local app_token
local sceneGroup

local loadScreenHUD
local loadTimer

local level_data
local gameEngine

local gameOverHUD


--====================================================================--
-- Main
--====================================================================--


local startLoadingGame
local unloadGameEngine
local goHUDButtonEventHandler

local function unloadScene()

	unloadGameEngine()

	gameOverHUD = nil
	level_data = nil
	loadScreenHUD = nil
	if sceneGroup then
		sceneGroup:removeSelf()
		sceneGroup = nil
	end

end

local function unloadGameOverHUD()
	-- remove game over HUD
	gameOverHUD:removeEventListener( gameOverHUD.BUTTON_EVENT, goHUDButtonEventHandler )
	gameOverHUD:removeSelf()
	gameOverHUD = nil


end


local function startGame()
	gameEngine:startGamePlay()
end

goHUDButtonEventHandler = function( event )
	--print( "GameEngine:gameOverHUDButtonEvent" )
	local at = app_token

	unloadGameOverHUD()

	if event.id == "menu-button" then
		unloadScene()
		director:changeScene( at, "scene-menu" )

	elseif event.id == "restart-button" then
		startLoadingGame()

	elseif event.id == "nextlevel-button" then
		local newLD = LevelMgr:getNextLevelData( level_data.info.level )
		if newLD then
			level_data = newLD
		end
		startLoadingGame()

	end

end
local function gameExitEventHandler( event )
	local at = app_token
	unloadScene()
	director:changeScene( at, "scene-menu" )
end

local function gameOverEventHandler( event )
	-- create Game Over HUD
	gameOverHUD = HUDFactory.create( "gameover-hud" )
	sceneGroup:insert( gameOverHUD.display )
	gameOverHUD:addEventListener( gameOverHUD.BUTTON_EVENT, goHUDButtonEventHandler )
	gameOverHUD:show( event )
end

unloadGameEngine = function()
	if gameEngine then
		gameEngine:removeEventListener( gameEngine.GAME_OVER_EVENT, gameOverEventHandler )
		gameEngine:removeEventListener( gameEngine.GAME_EXIT_EVENT, gameExitEventHandler )
		gameEngine:removeSelf()
		for i=sceneGroup.numChildren, 1,-1 do
			sceneGroup[i]:removeSelf()
		end
		app_token.gameEngine = nil
		gameEngine = nil
	end
end

--== START: Loading Section ==--

local function loadCompleteHandler( event )
	--print("GameScene: loadCompleteHandler")

	local f = function()
		loadScreenHUD:removeEventListener( "complete", loadCompleteHandler )
		loadScreenHUD:hide()
		timer.cancel( loadTimer )
		loadTimer = nil

		startGame()
	end

	-- make it so we can see 100% load bar for a little bit
	loadScreenHUD.text = "Loading Complete"
	loadTimer = timer.performWithDelay( 200, f, 1 )

end

local function load_complete( percentComplete )
	--print("GameScene: load_complete")
	local contentToLoad = "Complete"

	loadScreenHUD:update( { percentComplete, contentToLoad } )

	if loadTimer then timer.cancel( loadTimer ) end
	loadTimer = nil
end

local function load_snailsAndTails( percentComplete )
	--print("GameScene: load_snailsAndTails")
	local contentToLoad = "Snails and Tails"
	local contentPercent = 30
	local loadNext = load_complete

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
	unloadGameEngine()

	local data = Utils.extend( level_data, {} )
	gameEngine = GameEngine:new( data )
	app_token.gameEngine = gameEngine
	gameEngine:addEventListener( gameEngine.GAME_OVER_EVENT, gameOverEventHandler )
	gameEngine:addEventListener( gameEngine.GAME_EXIT_EVENT, gameExitEventHandler )
	sceneGroup:insert( gameEngine.display )
	-- END LOAD


	-- fake loading function
	local f = function()
		loadScreenHUD.percentComplete = loadScreenHUD.percentComplete + contentPercent
	 	loadNext()
	end
	loadTimer = timer.performWithDelay( 500, f, 1 )
end


startLoadingGame = function()
	--print("GameScene: startLoadingGame")

	-- attach to loading screen
	loadScreenHUD = app_token.loadScreenHUD
	loadScreenHUD:addEventListener( "complete", loadCompleteHandler )
	loadScreenHUD:clear()
	loadScreenHUD:show()

	load_ghostsAndGhouls()
end

--== END: Loading Section ==--


-- new()
-- Director function
--
function new( params )
	print( "LOADING: Game Scene =============" )

	app_token = params
	level_data = app_token.data

	-- create the display group for our content
	sceneGroup = display.newGroup()
	app_token.mainGroup:insert( sceneGroup )
	startLoadingGame()

	-- Return group for Director
	return sceneGroup
end

