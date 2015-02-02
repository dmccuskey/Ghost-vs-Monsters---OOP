


--====================================================================--
--== Imports


local Utils = require 'dmc_utils'



--====================================================================--
--== Setup, Constants


local DELAY_TIME = 10000



--====================================================================--
--== Support Functions


local function destroyObjIn( obj, time )
	if time == nil then time = DELAY_TIME end
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



--======================================================--
-- Test: Load Screen

local function test_loadScreen()
	print( "test_loadScreen" )

	local LoadScreen = require 'component.load_screen'

	local o = LoadScreen:new()

	o.x, o.y = 240, 160

	local f = function( e )
		print( "test_loadScreen: 100% complete" )
	end
	o:addEventListener( o.EVENT, f )

	-- tests
	timer.performWithDelay( 1000, function() o.percent_complete=10 end )
	timer.performWithDelay( 2000, function() o.percent_complete=40 end )
	timer.performWithDelay( 3000, function() o.percent_complete=100 end )

	destroyObjIn( o )
end 


--======================================================--
-- Test: Pause Screen

local function test_pauseScreen()
	print( "test_pauseScreen" )

	local PauseScreen = require 'component.pause_screen'

	local o = PauseScreen:new()
	o.x, o.y = 240, 160

	local f = function( e )
		print( "test_pauseScreen:" )

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

	--[[
	uncomment test to run
	--]]

	test_levelScreen()
	-- test_loadScreen()
	-- test_pauseScreen()

end 


return TestController
