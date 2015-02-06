


--====================================================================--
--== Imports


-- this require primes dmc_corona library for use
--
require 'dmc_corona_boot'

local composer = require 'composer'

local Utils = require 'lib.dmc_corona.dmc_utils'

-- AppController gives us access to main controller and its components
-- so we don't have to re-create in the test_controller
--
local AppController = require 'app_controller'



--====================================================================--
--== Setup, Constants


-- Test Controller, will be setup later
--
local TestController = nil

-- App Controller / Instance
-- 'ACI' will be set later once ACI is instantiated
--
local ACI = nil

local W, H = display.contentWidth, display.contentHeight
local H_CENTER, V_CENTER = W*0.5, H*0.5

local DESTROY_DELAY_TIME = 10000


-- forward declares
local test_gameMainView


--====================================================================--
--== Support Functions


local function destroyObjIn( obj, time )
	if time == nil then time = DESTROY_DELAY_TIME end
	timer.performWithDelay( time, function()
		print( "Test: destroying object" )
		obj:removeSelf()
	end )
end


--======================================================--
-- Test: Level Screen

local function test_levelScreen()
	print( "test_levelScreen" )

	local LevelScreen = require 'component.level_screen'

	local o = LevelScreen:new()

	o.x, o.y = 240, 160

	local f = function( e )
		print( "test_levelScreen:" )

		if e.type == o.ACTIVE then
			print( "is active:", e.is_active )
		elseif e.type == o.MENU then
			print( "menu selected" )
		else
			print( "unknown event", e.type )
		end
	end
	o:addEventListener( o.EVENT, f )

	destroyObjIn( o )
end



--====================================================================--
--== Module Tests
--====================================================================--


--======================================================--
-- Test: Ghost Character

local function test_ghostCharacter()
	print( "test_ghostCharacter" )

	local GameView = require 'scene.game.game_view'
	local ObjectFactory = require 'component.object_factory'
	assert( type(ObjectFactory)=='table', "ERROR: loading Object Factory" )

	local ge = test_gameMainView( true )
	local o = ObjectFactory.create( 'ghost', {game_engine=ge} )
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "MenuView Event" )

		if e.type == o.SELECTED then
			local data = e.data
			local level = data.level
			print( "level info:", level.info.name, level )
		else
			print( "unknown event" )
		end
	end
	o:addEventListener( o.EVENT, f )

	ge:startGamePlay()

	destroyObjIn( o )
end


--======================================================--
-- Test: Monster Character

local function test_monsterCharacter()
	print( "test_monsterCharacter" )

	local GameView = require 'scene.game.game_view'
	local ObjectFactory = require 'component.object_factory'
	assert( type(ObjectFactory)=='table', "ERROR: loading Object Factory" )

	local ge = test_gameMainView( true )
	local o = ObjectFactory.create( ObjectFactory.MONSTER, {game_engine=ge} )
	o.x, o.y = H_CENTER, V_CENTER

	local f = function( event )
		print( "Monster Event", event.type )

		if event.type == o.STATE_DEAD then
			print( "Monster is dead", event.force )
		else
			print( "unknown event" )
		end
	end
	o:addEventListener( o.EVENT, f )

	-- test collisions
	timer.performWithDelay( 500, function() o:postCollision( {force=1.2} ) end)
	timer.performWithDelay( 1000, function() o:postCollision( {force=2} ) end)

	destroyObjIn( o )
end


--======================================================--
-- Test: Game Over Overlay

local function test_gameOverOverlay()
	print( "test_gameOverOverlay" )

	local GameOverOverlay = require 'scene.game.gameover_overlay'
	assert( type(GameOverOverlay)=='table' )

	local o = GameOverOverlay:new{
		width=W, height=H,
	}
	o.x, o.y = H_CENTER, 0

	local f = function( event )
		print( "GameOverOverlay Event" )

		if event.type == o.FACEBOOK then
			print( "facebook selected" )
		elseif event.type == o.MENU then
			print( "menu selected" )
		elseif event.type == o.NEXT then
			local result = event.data
			print( "next level selected", result.name, result.level )
		elseif event.type == o.OPEN_FEINT then
			print( "open feint selected" )
		elseif event.type == o.RESTART then
			print( "restart selected" )
		else
			print( "unknown event", e.type )
		end
	end
	o:addEventListener( o.EVENT, f )

	timer.performWithDelay( 1, function()
		o:hide()
	end )

	timer.performWithDelay( 1000, function()
		o:show({outcome='win',score=122233244,bestscore=204342223})
	end )

	timer.performWithDelay( 3000, function()
		o:hide()
	end )

	timer.performWithDelay( 5000, function()
		o:show({outcome='lose',score=100,bestscore=204343})
	end )

	timer.performWithDelay( 8000, function()
		o:hide()
	end )

	destroyObjIn( o )
end


--======================================================--
-- Test: Level Screen

local function test_levelOverlay()
	print( "test_levelOverlay" )

	local LevelOverlay = require 'scene.menu.level_overlay'
	assert( type(LevelOverlay)=='table' )

	local o = LevelOverlay:new{
		width=W, height=H,
	}
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "LevelOverlay Event" )

		if e.type == o.CANCELED then
			print( "selection canceled" )
		elseif e.type == o.SELECTED then
			local result = e.data
			print( "level selected", result.name, result.level )
		else
			print( "unknown event", e.type )
		end
	end
	o:addEventListener( o.EVENT, f )

	destroyObjIn( o )
end



--======================================================--
-- Test: Load Screen

local function test_loadOverlay()
	print( "test_loadOverlay" )

	local LoadOverlay = require 'component.load_overlay'
	assert( type(LoadOverlay)=='table' )

	local o = LoadOverlay:new{
		width=W, height=H
	}
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "LoadOverlay Event" )
		if e.type == o.COMPLETE then
			print( "100% complete" )
		else
			print( "unknown event", e.type )
		end
	end
	o:addEventListener( o.EVENT, f )

	-- test loading
	timer.performWithDelay( 1000, function() o.percent_complete=10 end )
	timer.performWithDelay( 2000, function() o.percent_complete=40 end )
	timer.performWithDelay( 3000, function() o.percent_complete=60 end )
	timer.performWithDelay( 4000, function() o.percent_complete=40 end )
	timer.performWithDelay( 5000, function() o.percent_complete=100 end )

	destroyObjIn( o )
end


--======================================================--
-- Test: Pause Screen

local function test_pauseOverlay()
	print( "test_pauseOverlay" )

	local PauseOverlay = require 'component.pause_overlay'
	assert( type(PauseOverlay)=='table' )

	local o = PauseOverlay:new{
		width=W, height=H
	}
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "PauseOverlay Event" )

		if e.type == o.ACTIVE then
			print( "is active:", e.is_active )
		elseif e.type == o.MENU then
			print( "menu selected" )
		else
			print( "unknown event" )
		end
	end
	o:addEventListener( o.EVENT, f )

	destroyObjIn( o )
end


--======================================================--
-- Test: Game Main View

test_gameMainView = function( create_only )
	print( "test_gameMainView" )
	if create_only==nil then create_only = false end
	--==--

	local GameView = require 'scene.game.game_view'
	assert( type(GameView)=='table', "ERROR: loading Menu View" )

	local o = GameView:new{
		width=W, height=H,
		level_data=gService.level_mgr:getLevelData(1)
	}

	if create_only then return o end

	-- note this one is aligned on left
	o.x, o.y = 0, 0

	local f = function( event )
		print( "GameView Event" )
		local target = event.target

		if event.type == target.GAME_OVER_EVENT then
			print( "game results:", event.best_score, event.score, event.outcome )
		elseif event.type == target.GAME_EXIT_EVENT then
			print( "game exit" )
		else
			print( "unknown event" )
		end
	end
	o:addEventListener( o.EVENT, f )

	o:startGamePlay()

	destroyObjIn( o )
end


--======================================================--
-- Test: Menu Main View

local function test_menuMainView()
	print( "test_menuMainView" )

	local MenuView = require 'scene.menu.menu_view'
	assert( type(MenuView)=='table', "ERROR: loading Menu View" )

	local o = MenuView:new{
		width=W, height=H
	}
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "MenuView Event" )

		if e.type == o.SELECTED then
			local data = e.data
			local level = data.level
			print( "level info:", level.info.name, level )
		else
			print( "unknown event" )
		end
	end
	o:addEventListener( o.EVENT, f )

	destroyObjIn( o )
end


--======================================================--
-- Test: Menu Main View

local function test_gameScene()
	print( "test_gameScene" )

	local o = composer.getScene( name )

	local scene_options = {
		params = {
			width=W, height=H,
			level_data=gService.level_mgr:getLevelData(1)
		}
	}

	composer.gotoScene( 'scene.game', scene_options )
	o = composer.getScene( name )

	-- local f = function( e )
	-- 	print( "Game Scene Event" )

	-- 	if e.type == o.SELECTED then
	-- 		local data = e.data
	-- 		local level = data.level
	-- 		print( "level info:", level.info.name, level )
	-- 	else
	-- 		print( "unknown event" )
	-- 	end
	-- end
	-- o:addEventListener( o.EVENT, f )

end



--====================================================================--
--== Test Controller Setup
--====================================================================--


local TestController = {}


function TestController.runTests()
	print( "TestController.runTests" )

	--[[
	uncomment test to run
	--]]

	--== Game Objects

	-- test_ghostCharacter()
	-- test_monsterCharacter()


	--== Component Tests

	-- test_gameOverOverlay()
	-- test_levelOverlay()
	-- test_loadOverlay()
	-- test_pauseOverlay()

	-- test_gameMainView()
	-- test_menuMainView()


	--== Scene Tests

	test_gameScene()

end

function TestController.run( params )
	-- print( "TestController.run", params )
	params = params or {}
	params.mode = params.mode==nil and AppController.TEST_MODE or params.mode
	--==--
	AppController.run( params )
	ACI = AppController.instance()
	TestController.runTests()
end


return TestController
