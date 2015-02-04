


--====================================================================--
--== Imports


-- this require primes dmc_corona library for use
--
require 'dmc_corona_boot'

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



--====================================================================--
--== Support Functions


local function destroyObjIn( obj, time )
	if time == nil then time = DESTROY_DELAY_TIME end
	timer.performWithDelay( time, function() obj:removeSelf() end )
end



--====================================================================--
--== Module Tests
--====================================================================--


--======================================================--
-- Test: Level Screen

local function test_levelOverlay()
	print( "test_levelOverlay" )

	local LevelOverlay = require 'scene.menu.level_overlay'
	assert( type(LevelOverlay)=='table' )

	local o = LevelOverlay:new{
		width=W, height=H,
		levelMgr=ACI.level_mgr,
		soundMgr=ACI.sound_mgr
	}

	o.x, o.y = 240, 0

	local f = function( e )
		print( "LevelOverlay Event" )

		if e.type == o.CANCELED then
			print( "selection canceled" )
		elseif e.type == o.SELECTED then
			local level = e.data
			print( "level selected", level.name, level.data )
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

	local PauseScreen = require 'component.pause_overlay'
	assert( type(PauseScreen)=='table' )

	local o = PauseScreen:new{
		width=W, height=H
	}
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "PauseScreen Event" )

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
-- Test: Menu Main View

local function test_menuMainView()
	print( "test_menuMainView" )

	local MenuView = require 'scene.menu.main_view'
	assert( type(MenuView)=='table' )

	local o = MenuView:new()
	o.x, o.y = H_CENTER, 0

	local f = function( e )
		print( "MenuView Event" )

		if e.type == o.SELECTED then
			print( "is active:", e.is_active )
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

	--== Component Tests

	-- test_levelOverlay()
	-- test_loadOverlay()
	-- test_pauseOverlay()

	test_menuMainView()

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
