--====================================================================--
-- widget_popover.lua
--
-- Documentation: http://docs.davidmccuskey.com/display/docs/newPopover.lua
--====================================================================--

--[[

Copyright (C) 2013-2014 David McCuskey. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in the
Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

--]]


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "1.0.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--

local dmc_widget_data, dmc_widget_func
dmc_widget_data = _G.__dmc_widget
dmc_widget_func = dmc_widget_data.func



--====================================================================--
--== DMC Widgets : newPopover
--====================================================================--



--====================================================================--
--== Imports

local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'


--====================================================================--
--== Setup, Constants

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local CoronaBase = Objects.CoronaBase

local LOCAL_DEBUG = false



--====================================================================--
--== Popover Widget Class
--====================================================================--


local Popover = inheritsFrom( CoronaBase )
Popover.NAME = "Popover"

Popover.TOUCH_NONE = 'none'
Popover.TOUCH_DONE = 'done'
Popover.TOUCH_CANCEL = 'cancel'


--======================================================--
-- Start: Setup DMC Objects

function Popover:_init( params )
	-- print( "Popover:_init" )
	params = params or { }
	self:superCall( "_init", params )
	--==--

	--== Sanity Check ==--

	if self.is_intermediate then return end

	--== Create Properties ==--

	self._outsideTouchAction = params.outsideTouchAction or Popover.TOUCH_CANCEL

	self._onDone = params.onDone
	self._onCancel = params.onCancel

	--== Display Groups ==--

	-- group for popover background elements
	self._dg_bg = nil

	-- group for all main elements
	self._dg_main = nil

	--== Object References ==--

	-- visual
	self._bg_touch = nil  -- main background
	self._bg_main = nil  -- main background
	self._pointer = nil -- pointer element

end

-- function Popover:_undoInit()
-- 	-- print( "Popover:_undoInit" )
-- 	--==--
-- 	self:superCall( "_undoInit" )
-- end


-- _createView()
--
function Popover:_createView()
	-- print( "Popover:_createView" )
	self:superCall( "_createView" )
	--==--

	local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

	local W,H = self._width, self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, dg, tmp  -- object, display group, tmp

	--== setup background

	o = display.newRect(0, 0, WIDTH, HEIGHT)
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(0,255,0,255)
	end
	o.isHitTestable = true
	o.anchorX, o.anchorY = 0,0
	o.x, o.y = 0,0

	self.view:insert( o )
	self._bg_touch = o


	dg = display.newGroup()
	self.view:insert( dg )
	self._dg_bg = dg

	-- viewable background

	o = display.newRect(0, 0, W, H)
	o:setFillColor(1,1,1,0.8)
	if LOCAL_DEBUG then
		o:setFillColor(0,255,0,255)
	end
	o.anchorX, o.anchorY = 0,0
	o.x, o.y = 0,0

	dg:insert( o )
	self._bg_main = o

	--== setup main group

	dg = display.newGroup()
	self.view:insert( dg )
	self._dg_main = dg

end

function Popover:_undoCreateView()
	-- print( "Popover:_undoCreateView" )

	local o

	--==--
	self:superCall( "_undoCreateView" )
end


-- _initComplete()
--
function Popover:_initComplete()
	--print( "Popover:_initComplete" )

	local o, f

	o = self._bg_touch
	o._f = self:createCallback( self._bgTouchEvent_handler )
	o:addEventListener( 'touch', o._f )

	self:_updateView()
	--==--
	self:superCall( "_initComplete" )
end

function Popover:_undoInitComplete()
	--print( "Popover:_undoInitComplete" )

	o = self._bg_touch
	o:removeEventListener( 'touch', o._f )
	o._f = nil

	--==--
	self:superCall( "_undoInitComplete" )
end


--== END: Setup DMC Objects





--====================================================================--
--== Public Methods

-- we only want items inserted into proper layer
function Popover:insert( ... )
	print( "Popover:insert" )
	self._dg_main:insert( ... )
end

function Popover:show()
	-- print( "Popover:show" )
	self.view.isVisible = true
	self._bg_touch.isHitTestable = true
end
function Popover:hide()
	-- print( "Popover:hide" )
	self.view.isVisible = false
	self._bg_touch.isHitTestable = false
end

function Popover.__setters:x( value )
	self._dg_bg.x = value
	self._dg_main.x = value
end
function Popover.__setters:y( value )
	self._dg_bg.y = value
	self._dg_main.y = value
end


--====================================================================--
--== Private Methods

function Popover:_updateView()
	print( "Popover:_updateView" )
end

function Popover:_doCancelCallback()
	print( "Popover:_doCancelCallback" )
	if type(self._onCancel)~='function' then return end
	local event = {}
	self._onCancel( event )
end

function Popover:_doDoneCallback()
	print( "Popover:_doDoneCallback" )
	if type(self._onDone)~='function' then return end
	local event = {}
	self._onDone( event )
end


--====================================================================--
--== Event Handlers

function Popover:_bgTouchEvent_handler( event )
	print( "Popover:_bgTouchEvent_handler", event.phase )
	local target = event.target

	if event.phase == 'began' then
		display.getCurrentStage():setFocus( target )
		self._has_focus = true
	end

	if not self._has_focus then return end

	if event.phase == 'ended' or event.phase == 'canceled' then
		if self._outsideTouchAction == Popover.TOUCH_DONE then
			self:_doDoneCallback()
		elseif self._outsideTouchAction == Popover.TOUCH_CANCEL then
			self:_doCancelCallback()
		else
			-- pass
		end
		self._has_focus = false
	end

end



return Popover
