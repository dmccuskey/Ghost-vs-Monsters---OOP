--====================================================================--
-- dmc_ui/dmc_control/popover_control.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2015 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]


--====================================================================--
--== DMC Corona UI : Popover Control
--====================================================================--



-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.3.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI : newPopoverControl
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local uiConst = require( ui_find( 'ui_constants' ) )

local PresentationControl = require( ui_find( 'dmc_control.core.presentation_control' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

local mmax = math.max
local mmin = math.min

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Support Functions


local function eventBlock_handler( event )
	return true
end

local function clamp( value, low, high )
	if high<low then return ( low+high )*0.5 end
	return mmax( low, mmin( high, value ) )
end



--====================================================================--
--== Popover Control Class
--====================================================================--


--[[
A Presentation Control (see core/presentation_control.lua) whose panel
belongs to a display object, its 'buttonItem': the panel opens next to
it, on a side where there is room, with an arrow which points at it.
A tap anywhere else dismisses it.

A control makes its Popover Control itself when its 'modalStyle'
is set to dUI.POPOVER.
--]]

local PopControl = newClass( PresentationControl, {name="Popover Control"} )

--== Class Constants

PopControl.DEFAULT_TRANSITION = uiConst.FADE
PopControl.DEFAULT_DISMISS_ON_TAP_OUTSIDE = true
PopControl.DEFAULT_DIM_COLOR = uiConst.POPOVER_DIM_COLOR

PopControl.BORDER = 4 -- the panel's frame, which the arrow is part of
PopControl.MARGIN = 10 -- between the panel and the screen's edge
PopControl.ARROW_WIDTH = 24
PopControl.ARROW_LENGTH = 12

-- the order in which the sides are tried
PopControl.DIRECTIONS = {
	uiConst.ARROW_UP, uiConst.ARROW_DOWN, uiConst.ARROW_LEFT, uiConst.ARROW_RIGHT
}


--======================================================--
-- Start: Setup DMC Objects

--== init

function PopControl:__init__( params )
	-- print( "PopControl:__init__" )
	params = params or {}

	self:superCall( '__init__', params )
	--==--

	if self.is_class then return end

	--== Create Properties ==--

	-- permitted arrow directions, a lookup; nil is any
	self._arrowDirs = nil
	self._arrowDirs_value = nil
	self._arrowDirs_init = params.arrowDirections

	-- the direction in use, nil without an arrow
	self._arrowDir = nil

	-- the display object the popover belongs to
	self._buttonItem = params.buttonItem

	self._arrow = nil -- the arrow, a polygon
	-- the arrow's center, from the panel's center
	self._arrowOffset = nil

end

function PopControl:__undoInit__()
	-- print( "PopControl:__undoInit__" )
	self._buttonItem = nil
	--==--
	self:superCall( '__undoInit__' )
end

--== initComplete

function PopControl:__initComplete__()
	-- print( "PopControl:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local dirs = self._arrowDirs_init
	self._arrowDirs_init = nil
	if dirs~=nil then self.arrowDirections = dirs end
end

function PopControl:__undoInitComplete__()
	-- print( "PopControl:__undoInitComplete__" )
	self:_removeArrow()
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function PopControl.initialize( manager )
	-- print( "PopControl.initialize" )
	dUI = manager
end



--====================================================================--
--== Public Methods


--== .buttonItem

-- the display object (or component) the popover belongs to, eg the
-- button which opens it. the popover is placed for where the object
-- is when this is set: set it again after the object has moved.
-- without one the popover is in the middle of the screen, no arrow
--
function PopControl.__getters:buttonItem()
	return self._buttonItem
end
function PopControl.__setters:buttonItem( value )
	assert(
		value==nil or value.contentBounds,
		"[ERROR] PopoverControl.buttonItem expected a display object"
	)
	--==--
	self._buttonItem = value
	self:_layout()
end

--== .arrowDirections

-- the directions the arrow may point in: one of dUI.ARROW_UP (the
-- popover is below its button), dUI.ARROW_DOWN, dUI.ARROW_LEFT,
-- dUI.ARROW_RIGHT, a list of them, or dUI.ARROW_ANY (also nil)
--
function PopControl.__getters:arrowDirections()
	return self._arrowDirs_value
end
function PopControl.__setters:arrowDirections( value )
	local dirs = nil
	if value~=nil and value~=uiConst.ARROW_ANY then
		local list = value
		if type( list )~='table' then list = { list } end
		assert( #list>0, "[ERROR] PopoverControl.arrowDirections expected a direction" )
		dirs = {}
		for _, dir in ipairs( list ) do
			assert(
				dir==uiConst.ARROW_UP or dir==uiConst.ARROW_DOWN
				or dir==uiConst.ARROW_LEFT or dir==uiConst.ARROW_RIGHT,
				"[ERROR] PopoverControl.arrowDirections unknown direction '"..tostring( dir ).."'"
			)
			dirs[ dir ] = true
		end
	end
	self._arrowDirs = dirs
	self._arrowDirs_value = value
	self:_layout()
end

--== .arrowDirection

-- the direction the arrow points in (read only),
-- nil without a button item
--
function PopControl.__getters:arrowDirection()
	return self._arrowDir
end



--====================================================================--
--== Private Methods


-- a popover always has a size: the control's, and its frame around it
--
function PopControl:_getPreferredSize()
	local size = self._presentedControl.preferredContentSize or uiConst.POPOVER_PREFERRED_SIZE
	local border = PopControl.BORDER*2
	return { width=size.width+border, height=size.height+border }
end

-- the panel's frame: the control's preferred size next to the button,
-- on the first permitted side with room for it. without such a side,
-- the one with the most room, and the panel no larger than the room
--
function PopControl:_getPanelFrame( screen )
	local MARGIN, LENGTH = PopControl.MARGIN, PopControl.ARROW_LENGTH
	local HALF = PopControl.ARROW_WIDTH*0.5
	local frame = PresentationControl._getPanelFrame( self, screen )
	local o = self._buttonItem
	local b = o and o.contentBounds
	if not b then return frame end -- no button, or it was removed

	-- the screen less its margin, and the button
	local left, right = screen.x+MARGIN, screen.x+screen.width-MARGIN
	local top, bottom = screen.top+MARGIN, screen.y+screen.height-MARGIN
	local bX, bY = ( b.xMin+b.xMax )*0.5, ( b.yMin+b.yMax )*0.5

	-- the room on each side, named for the arrow which goes with it
	local room = {
		[uiConst.ARROW_UP]={ width=right-left, height=bottom-( b.yMax+LENGTH ) },
		[uiConst.ARROW_DOWN]={ width=right-left, height=( b.yMin-LENGTH )-top },
		[uiConst.ARROW_LEFT]={ width=right-( b.xMax+LENGTH ), height=bottom-top },
		[uiConst.ARROW_RIGHT]={ width=( b.xMin-LENGTH )-left, height=bottom-top },
	}

	local size = self:_getPreferredSize()
	local w, h = size.width, size.height
	local dirs = self._arrowDirs
	local dir, best = nil, -1
	for _, d in ipairs( PopControl.DIRECTIONS ) do
		if not dirs or dirs[ d ] then
			local r = room[ d ]
			local fit = mmin( 1, r.width/w, r.height/h )
			if fit>best then dir, best = d, fit end
		end
	end

	local r = room[ dir ]
	w, h = mmax( 0, mmin( w, r.width ) ), mmax( 0, mmin( h, r.height ) )

	-- x, y: the panel's top center. tip: where the arrow points,
	-- on the button's edge and clear of the panel's corners
	local x, y, tipX, tipY
	if dir==uiConst.ARROW_UP or dir==uiConst.ARROW_DOWN then
		x = clamp( bX, left+w*0.5, right-w*0.5 )
		tipX = clamp( bX, x-w*0.5+HALF, x+w*0.5-HALF )
		if dir==uiConst.ARROW_UP then
			tipY = b.yMax
			y = tipY+LENGTH
		else
			tipY = b.yMin
			y = tipY-LENGTH-h
		end
	else
		y = clamp( bY-h*0.5, top, bottom-h )
		tipY = clamp( bY, y+HALF, y+h-HALF )
		if dir==uiConst.ARROW_LEFT then
			tipX = b.xMax
			x = tipX+LENGTH+w*0.5
		else
			tipX = b.xMin
			x = tipX-LENGTH-w*0.5
		end
	end

	return {
		x=x, y=y, width=w, height=h,
		arrow={ direction=dir, x=tipX, y=tipY },
	}
end


function PopControl:_layout()
	-- print( "PopControl:_layout" )
	if not self._presentedControl then return end
	PresentationControl._layout( self )
	self:_createArrow()
	self:_setProgress( self._progress )
end

function PopControl:_setProgress( value )
	PresentationControl._setProgress( self, value )
	local o, offset = self._arrow, self._arrowOffset
	if not o then return end
	local panel = self._panel
	o.x, o.y = panel.x+offset.x, panel.y+offset.y
	o.alpha = panel.alpha
end

function PopControl:_panelColorChanged()
	local o = self._arrow
	if o then o:setFillColor( unpack( self._panelColor ) ) end
end


--======================================================--
-- Arrow

function PopControl:_removeArrow()
	local o = self._arrow
	if not o then return end
	o:removeEventListener( 'touch', eventBlock_handler )
	o:removeEventListener( 'tap', eventBlock_handler )
	o:removeSelf()
	self._arrow = nil
	self._arrowOffset = nil
end

-- make the arrow for the frame: a triangle in the panel's color
-- between the panel and the button
--
function PopControl:_createArrow()
	-- print( "PopControl:_createArrow" )
	local frame = self._frame
	local arrow = frame and frame.arrow

	self:_removeArrow()
	self._arrowDir = arrow and arrow.direction or nil
	if not arrow then return end

	local LENGTH, HALF = PopControl.ARROW_LENGTH, PopControl.ARROW_WIDTH*0.5
	local dir = arrow.direction
	local verts, cX, cY -- its shape, and its center from its tip

	if dir==uiConst.ARROW_UP then
		verts, cX, cY = { 0,-LENGTH, HALF,0, -HALF,0 }, 0, LENGTH*0.5
	elseif dir==uiConst.ARROW_DOWN then
		verts, cX, cY = { 0,LENGTH, -HALF,0, HALF,0 }, 0, -LENGTH*0.5
	elseif dir==uiConst.ARROW_LEFT then
		verts, cX, cY = { -LENGTH,0, 0,-HALF, 0,HALF }, LENGTH*0.5, 0
	else
		verts, cX, cY = { LENGTH,0, 0,HALF, 0,-HALF }, -LENGTH*0.5, 0
	end

	local o = display.newPolygon( 0, 0, verts )
	o:setFillColor( unpack( self._panelColor ) )
	o:addEventListener( 'touch', eventBlock_handler )
	o:addEventListener( 'tap', eventBlock_handler )
	self:insert( o )

	self._arrow = o
	self._arrowOffset = {
		x=arrow.x+cX - frame.x,
		y=arrow.y+cY - ( frame.y+frame.height*0.5 ),
	}
end



return PopControl
