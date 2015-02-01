
local DELAY_TIME = 10000


local function destroyObjIn( obj, time )
	if time == nil then time = DELAY_TIME end
	timer.performWithDelay( time, function() obj:removeSelf() end )
end


local function test_loadScreen()

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


local TestController = {}


TestController.run = function( params )

	test_loadScreen()

end 

return TestController