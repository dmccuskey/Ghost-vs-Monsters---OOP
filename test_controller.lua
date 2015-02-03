


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

local function test_pauseOverlay()
	print( "test_pauseOverlay" )

	local PauseScreen = require 'component.pause_overlay'

	local o = PauseScreen:new()
	o.x, o.y = 240, 5

	local f = function( e )
		print( "test_pauseOverlay:" )

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

	-- test_loadScreen()
	test_pauseOverlay()


end 


return TestController
