


--====================================================================--
--== Imports


-- this require primes dmc_corona library for use
--
require 'dmc_corona_boot'

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
	timer.performWithDelay( time, function() obj:removeSelf() end )
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
-- Test: Level Screen

local function test_levelOverlay()
	print( "test_levelOverlay" )

	local LevelOverlay = require 'scene.menu.level_overlay'
	assert( type(LevelOverlay)=='table' )

	local o = LevelOverlay:new{
		width=W, height=H,
		level_mgr=ACI.level_mgr,
		sound_mgr=ACI.sound_mgr
	}

	o.x, o.y = 240, 0

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

	local LEVEL_MGR = ACI.level_mgr

	local GameView = require 'scene.game.game_view'
	assert( type(GameView)=='table', "ERROR: loading Menu View" )

	local o = GameView:new{
		width=W, height=H,
		sound_mgr=ACI.sound_mgr,
		level_data=LEVEL_MGR:getLevelData(1)
	}

	if create_only then return o end

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

	-- destroyObjIn( o )
end


--======================================================--
-- Test: Menu Main View

local function test_menuMainView()
	print( "test_menuMainView" )

	local MenuView = require 'scene.menu.menu_view'
	assert( type(MenuView)=='table', "ERROR: loading Menu View" )

	local o = MenuView:new{
		width=W, height=H,
		level_mgr=ACI.level_mgr,
		sound_mgr=ACI.sound_mgr
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


	--== Component Tests

	-- test_levelOverlay()
	-- test_loadOverlay()
	-- test_pauseOverlay()

	test_gameMainView()
	-- test_menuMainView()


	--== Scene Tests

	-- test_menuScene()

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
