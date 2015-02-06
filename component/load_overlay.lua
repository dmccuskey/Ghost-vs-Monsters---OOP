--====================================================================--
-- component/load_overlay.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Ghost vs Monsters : Load Overlay
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Imports


local Objects = require 'lib.dmc_corona.dmc_objects'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local LOCAL_DEBUG = false



--====================================================================--
--== Load Overlay class
--====================================================================--


local LoadOverlay = newClass( ComponentBase, {name="Load Overlay"} )

--== Class Constants

LoadOverlay.BAR_WIDTH = 300
LoadOverlay.BAR_HEIGHT = 10

--== Event Constants

LoadOverlay.EVENT = 'load-screen-event'

LoadOverlay.COMPLETE = 'loading-complete'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function LoadOverlay:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Sanity Check

	assert( params.width and params.height, "Load Overlay requires params 'width' & 'height'")

	--== Properties

	self._width = params.width
	self._height = params.height

	self._percent_complete = 0

	--== Display Objects

	self._primer = nil

	self._bg = nil
	self._load_bar = nil
	self._outline = nil
end

-- __undoInit__()
--
-- function LoadOverlay:__undoInit__()
-- 	--==--
-- 	self:superCall( '__undoInit__' )
-- end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function LoadOverlay:__createView__()
	self:superCall( '__createView__' )
	--==--

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local BAR_W, BAR_H = LoadOverlay.BAR_WIDTH, LoadOverlay.BAR_HEIGHT
	local BAR_Y = 270
	local o

	-- setup display primer

	o = display.newRect( 0, 0, W, 10)
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(1,0,0,0.75)
	end
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = 0, 0

	self:insert( o )
	self._primer = o


	-- create background

	o = display.newImageRect( 'assets/backgrounds/loading.png', W, H )
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = 0, 0

	self:insert( o )
	self._bg = o


	-- loading bar

	o = display.newRect( 0, 0, BAR_W, BAR_H )
	o.strokeWidth = 0
	o:setFillColor( 1, 1, 1 )
	o.anchorX, o.anchorY = 0, 0.5
	o.x, o.y = 0, BAR_Y

	self:insert( o )
	self._load_bar = o


	-- loading bar outline

	o = display.newRect( 0, 0, BAR_W, BAR_H )
	o.strokeWidth = 2
	o:setStrokeColor( 200/255, 200/255, 200/255, 1 )
	o:setFillColor( 0, 0, 0, 0 )
	o.anchorX, o.anchorY = 0.5, 0.5
	o.x, o.y = 0, BAR_Y

	self:insert( o )
	self._outline = o

end

-- __undoCreateView__()
--
function LoadOverlay:__undoCreateView__()
	local o

	o = self._outline
	o:removeSelf()
	self._outline = nil

	o = self._load_bar
	o:removeSelf()
	self._load_bar = nil

	o = self._bg
	o:removeSelf()
	self._bg = nil

	o = self._primer
	o:removeSelf()
	self._primer = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function LoadOverlay:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self:clear()
end

-- __undoInitComplete__()
--
-- function LoadOverlay:__undoInitComplete__()
--
-- 	--==--
-- 	self:superCall( '__undoCreateView__' )
-- end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function LoadOverlay.__getters:percent_complete()
	return self._percent_complete
end

function LoadOverlay.__setters:percent_complete( value )
	assert( type(value)=='number' )
	-- sanitize value
	if value < 0 then value = 0 end
	if value > 100 then value = 100 end
	--==--
	local bar = self._load_bar

	self._percent_complete = value

	-- calculate bar coords
	local width = LoadOverlay.BAR_WIDTH * ( value / 100 )

	if width == 0 then
		bar.isVisible = false
	else
		bar.isVisible = true
		bar.width = width

		bar.x = - (LoadOverlay.BAR_WIDTH / 2 ) -- - ( LoadOverlay.BAR_WIDTH - bar.width ) / 2
	end

	if self._percent_complete >= 100 then
		-- timer so that full bar is shown drawn
		timer.performWithDelay( 150, function()
			self:dispatchEvent( self.COMPLETE )
		end)
	end
end


-- clear()
--
-- initialize load screen to beginnings
--
function LoadOverlay:clear()
	self.percent_complete = 0 -- setter
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none




return LoadOverlay
