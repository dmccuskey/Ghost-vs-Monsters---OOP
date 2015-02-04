


--====================================================================--
--== Imports


local Utils = require 'lib.dmc_corona.dmc_utils'

local LevelMgr = require 'service.level_manager'
local SoundMgr = require 'service.sound_manager'



--====================================================================--
--== Setup, Constants


local DELAY_TIME = 10000


local levelMgr = LevelMgr:new()
local soundMgr = SoundMgr:new()



--====================================================================--
--== Support Functions


local function destroyObjIn( obj, time )
	if time == nil then time = DELAY_TIME end
	timer.performWithDelay( time, function() obj:removeSelf() end )
end



--====================================================================--
--== Module Tests
--====================================================================--


--======================================================--
-- Test: Level Screen

local function test_levelOverlay()
	print( "test_levelOverlay" )

	local LevelOverlay = require 'component.level_overlay'
	assert( type(LevelOverlay)=='table' )

	local o = LevelOverlay:new{
		levelMgr=levelMgr,
		soundMgr=soundMgr
	}

	o.x, o.y = 240, 0

	local f = function( e )
		print( "test_levelOverlay Event" )

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

	local o = LoadOverlay:new()

	o.x, o.y = 240, 0

	local f = function( e )
		print( "test_loadOverlay Event" )
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

	local o = PauseScreen:new()
	o.x, o.y = 240, 0

	local f = function( e )
		print( "test_pauseOverlay Event" )

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



--====================================================================--
--== Test Controller Setup
--====================================================================--


local TestController = {}


TestController.run = function( params )
	print( "TestController.run", params )

	--[[
	uncomment test to run
	--]]

	--== Component Tests

	-- test_levelOverlay()
	test_loadOverlay()
	-- test_pauseOverlay()

	--== Scene Tests

end


return TestController
