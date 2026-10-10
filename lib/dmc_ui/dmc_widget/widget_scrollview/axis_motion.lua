--====================================================================--
-- dmc_ui/dmc_widget/widget_scrollview/axis_motion.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (C) 2015 David McCuskey. All Rights Reserved.

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
--== DMC Corona UI : Axis Motion
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Corona UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI :
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local StatesMixModule = require 'dmc_states_mix'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )
local easingx = require( ui_find( 'dmc_widget.lib.easingx' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase

local mabs = math.abs
local mceil = math.ceil
local mfloor = math.floor
local sfmt = string.format
local tinsert = table.insert
local tremove = table.remove
local tstr = tostring



--====================================================================--
--== Axis Motion Class
--====================================================================--


local AxisMotion = newClass( ObjectBase, {name="Axis Motion"} )

StatesMixModule.patch( AxisMotion )

--== Class Constants

AxisMotion.HIT_UPPER_LIMIT = 'upper-limit-hit'
AxisMotion.HIT_LOWER_LIMIT = 'lower-limit-hit'
AxisMotion.HIT_SIZE_LIMIT = 'size-limit-hit'

AxisMotion.SCROLLBACK_FACTOR = 1/3

AxisMotion.VELOCITY_STACK_LENGTH = uiConst.AXIS_VELOCITY_STACK_LENGTH
AxisMotion.VELOCITY_LIMIT = uiConst.AXIS_VELOCITY_LIMIT

-- with paging, the speed (pixels per millisecond) at the end of
-- a touch from which it is a flick, which goes to the next page
AxisMotion.PAGE_FLICK_VELOCITY = uiConst.AXIS_PAGE_FLICK_VELOCITY

AxisMotion.UPPER = 'upper-alignment'
AxisMotion.MIDDLE = 'middle-aligment'
AxisMotion.LOWER = 'lower-alignment'
AxisMotion._VALID_ALIGNMENT = {
	AxisMotion.UPPER,
	AxisMotion.MIDDLE,
	AxisMotion.LOWER
}

--== State Constants

AxisMotion.STATE_CREATE = 'state_create'
AxisMotion.STATE_AT_REST = 'state_at_rest'
AxisMotion.STATE_DECELERATE = 'state_decelerate'
AxisMotion.STATE_RESTORE = 'state_restore'
AxisMotion.STATE_RESTRAINT = 'state_restraint'
AxisMotion.STATE_TOUCH = 'state_touch'

--== Event Constants

AxisMotion.SCROLLING = 'scrolling'
AxisMotion.SCROLLED = 'scrolled'


--======================================================--
-- Start: Setup DMC Objects

function AxisMotion:__init__( params )
	-- print( "AxisMotion:__init__" )
	params = params or {}
	if params.bounceIsActive==nil then params.bounceIsActive=true end
	if params.autoAlign==nil then params.autoAlign=AxisMotion.MIDDLE end
	if params.decelerateTransitionTime==nil then params.decelerateTransitionTime=uiConst.AXIS_DECELERATE_TIME end
	if params.restoreTransitionTime==nil then params.restoreTransitionTime=uiConst.AXIS_RESTORE_TIME end
	if params.restraintTransitionTime==nil then params.restraintTransitionTime=uiConst.AXIS_RESTRAINT_TIME end
	if params.scrollToTransitionTime==nil then params.scrollToTransitionTime=uiConst.AXIS_SCROLLTO_TIME end
	if params.length==nil then params.length=0 end
	if params.lowerOffset==nil then params.lowerOffset=0 end
	if params.pagingIsEnabled==nil then params.pagingIsEnabled=false end
	if params.scrollbackFactor==nil then params.scrollbackFactor=AxisMotion.SCROLLBACK_FACTOR end
	if params.scrollIsEnabled==nil then params.scrollIsEnabled=true end
	if params.scrollLength==nil then params.scrollLength=0 end
	if params.upperOffset==nil then params.upperOffset=0 end

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._ax_tmp_params = params -- tmp

	assert( params.callback )

	--== Create Properties ==--

	self._id = params.id
	self._callback = params.callback

	self._autoAlign = nil

	self._decelTransTime = 0
	self._restoreTransTime = 0
	self._restraintTransTime = 0
	self._scrollToTransTime = 0

	-- value is current position, eg x/y
	self._value = 0

	-- view port size
	self._length = 0
	-- actual scroller size (at 1.0)
	self._scrollLength = 0
	-- current scale
	self._scale = 1.0
	-- scroller size at scale
	self._scaledScrollLength = 0
	-- reference point at scale 1.0 (eg, x,y)
	self._refPoint = nil
	self._location = 0 -- x/y position, used for offset

	self._lowerOffset = 0
	self._upperOffset = 0

	self._scrollbackFactor = 0
	self._scrollbackLimit = 0

	-- block to make sure had a proper start
	-- to touch events, eg 'began'
	self._didBegin = false

	--== Internal Properties

	-- eg, HIT_UPPER_LIMIT, HIT_LOWER_LIMIT, etc
	self._scrollLimit = nil

	-- previous Touch Event, used for calculating deltas
	self._tmpTouchEvt = nil

	-- previous enterFrame event, used for calculating deltas
	self._tmpFrameEvent = nil

	self._velocityStack = {0,0}
	self._velocity = { value=0, vector=0 }

	self._enterFrameIterator = nil
	self._checkPosition_f = nil -- see _checkScaledPosition()

	self._bounceIsActive = false
	self._alwaysBounce = false
	self._scrollEnabled = false

	-- paging: a touch ends on a page, each as long as the view
	self._pagingEnabled = false
	-- the page showing when the touch began (0 is the first)
	self._touchPage = 0

	self:setState( AxisMotion.STATE_CREATE )
end

--== createView

function AxisMotion:__initComplete__()
	-- print( "AxisMotion:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--

	local tmp = self._ax_tmp_params

	--== Use Setters
	self.alignment = tmp.alignment
	self.autoAlign = tmp.autoAlign
	self.bounceIsActive = tmp.bounceIsActive
	self.decelerateTransitionTime = tmp.decelerateTransitionTime
	self.length = tmp.length
	self.lowerOffset = tmp.lowerOffset
	self.pagingIsEnabled = tmp.pagingIsEnabled
	self.restoreTransitionTime = tmp.restoreTransitionTime
	self.restraintTransitionTime = tmp.restraintTransitionTime
	self.scrollbackFactor = tmp.scrollbackFactor
	self.scrollIsEnabled = tmp.scrollIsEnabled
	self.scrollLength = tmp.scrollLength
	self.scrollToTransitionTime = tmp.scrollToTransitionTime
	self.upperOffset = tmp.upperOffset

	self._ax_tmp_params = nil

	self:gotoState( AxisMotion.STATE_AT_REST )
end

function AxisMotion:__undoInitComplete__()
	-- print( "AxisMotion:__undoInitComplete__" )
	-- stop any motion in progress
	self._enterFrameIterator = nil
	self._isMoving = false
	self._hasMoved = false
	Runtime:removeEventListener( 'enterFrame', self )
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- whether to bounce on constraint
function AxisMotion.__getters:autoAlign()
	return self._autoAlign
end
function AxisMotion.__setters:autoAlign( value )
	assert( value==nil or type(value)=='string' )
	if value~=nil then
		if not Utils.propertyIn( AxisMotion._VALID_ALIGNMENT, value ) then
			error( "AxisMotion.alignment expected a valid value" )
		end
	end
	--==--
	self._autoAlign = value
end


-- whether to bounce on constraint
function AxisMotion.__getters:bounceIsActive()
	return self._bounceIsActive
end
function AxisMotion.__setters:bounceIsActive( value )
	assert( type(value)=='boolean' )
	--==--
	self._bounceIsActive = value
end


function AxisMotion.__getters:decelerateTransitionTime()
	return self._decelTransTime
end
function AxisMotion.__setters:decelerateTransitionTime( value )
	assert( type(value)=='number' and value > 0, "ERROR: AxisMotion.decelerateTransitionTime expected number", value )
	--==--
	self._decelTransTime = value
end


-- this is the length of the view port
function AxisMotion.__getters:length()
	return self._length
end
function AxisMotion.__setters:length( value )
	assert( type(value)=='number' and value > 0 )
	--==--
	self._length = value
	self:_setScrollbackLimit()
	self:_checkScaledPosition()
end


function AxisMotion.__setters:location( value )
	assert( type(value)=='number' )
	--==--
	self._location = value
end


function AxisMotion.__getters:lowerOffset()
	return self._lowerOffset
end
function AxisMotion.__setters:lowerOffset( value )
	assert( type(value)=='number' )
	--==--
	self._lowerOffset = value
	self:_checkScaledPosition()
end


-- whether a touch ends on a page. a page is as long as the view,
-- and the first one starts at the upper offset
function AxisMotion.__getters:pagingIsEnabled()
	return self._pagingEnabled
end
function AxisMotion.__setters:pagingIsEnabled( value )
	assert( type(value)=='boolean' )
	--==--
	self._pagingEnabled = value
end


function AxisMotion.__getters:restoreTransitionTime()
	return self._restoreTransTime
end
function AxisMotion.__setters:restoreTransitionTime( value )
	assert( type(value)=='number' and value > 0, "ERROR: AxisMotion.restoreTransitionTime expected number", value )
	--==--
	self._restoreTransTime = value
end

function AxisMotion.__getters:restraintTransitionTime()
	return self._restraintTransTime
end
function AxisMotion.__setters:restraintTransitionTime( value )
	assert( type(value)=='number' and value > 0, "ERROR: AxisMotion.restraintTransitionTime expected number", value )
	--==--
	self._restraintTransTime = value
end



function AxisMotion.__setters:scale( value )
	-- print("AxisMotion.__setters:scale", value )
	self._scale = value
	local refPoint = self._refPoint
	self:_setScaledScrollLength()
	if refPoint~=nil then
		self._value = self._tmpTouchEvt.value - refPoint*value
	end
	self:_checkScaledPosition()
end


-- decimal fraction (1/3)
function AxisMotion.__setters:scrollbackFactor( value )
	self._scrollbackFactor = value
	self:_setScrollbackLimit()
end


function AxisMotion.__getters:scrollIsEnabled()
	return self._scrollEnabled
end
function AxisMotion.__setters:scrollIsEnabled( value )
	assert( type(value)=='boolean' )
	--==--
	self._scrollEnabled = value
end


function AxisMotion.__getters:scrollToTransitionTime()
	return self._scrollToTransTime
end
function AxisMotion.__setters:scrollToTransitionTime( value )
	assert( type(value)=='number' and value > 0, "ERROR: AxisMotion.scrollToTransitionTime expected number", value )
	--==--
	self._scrollToTransTime = value
end


-- this is the maximum dimension of the scroller
function AxisMotion.__getters:scaledScrollLength()
	return self._scaledScrollLength
end

function AxisMotion:_setScaledScrollLength()
	self._scaledScrollLength = mfloor( self._scrollLength * self._scale )
end


-- this is the maximum dimension of the scroller
function AxisMotion.__getters:scrollLength()
	return self._scrollLength
end
function AxisMotion.__setters:scrollLength( value )
	assert( type(value)=='number' and value >= 0 )
	--==--
	self._scrollLength = value
	self:_setScaledScrollLength()
	self:_checkScaledPosition()
end


function AxisMotion.__getters:upperOffset()
	return self._upperOffset
end
function AxisMotion.__setters:upperOffset( value )
	assert( type(value)=='number' )
	--==--
	self._upperOffset = value
	self:_checkScaledPosition()
end


-- current position/location
function AxisMotion.__getters:value()
	return self._value
end


function AxisMotion:scrollToPosition( pos, params )
	-- print( "AxisMotion:scrollToPosition", pos )
	params = params or {}
	-- params.onComplete=params.onComplete
	if params.time==nil then params.time=self._scrollToTransTime end
	if params.limitIsActive==nil then params.limitIsActive=false end
	--==--
	local eFI

	if params.time==0 then

		eFI = function()
			self._value = pos
			self._isMoving=false
			self._hasMoved=true
			self._enterFrameIterator=nil
			if params.onComplete then params.onComplete() end
		end

	else
		local time = params.time
		local ease_f = easingx.easeOut
		local val = self._value
		local startEvt = {
			time=system.getTimer()
		}
		self._isMoving = true
		local delta = pos - val
		if params.limitIsActive then
			local velocity = mabs( delta/time )
			if velocity > AxisMotion.VELOCITY_LIMIT then
				time = mfloor( mabs(delta/AxisMotion.VELOCITY_LIMIT) )
			end
		end

		eFI = function( e )
			local deltaT = e.time - startEvt.time
			local deltaV = ease_f( deltaT, time, val, delta )

			if deltaT < time then
				self._value = deltaV
			else
				self._isMoving = false
				self._hasMoved = true
				self._value = pos
				self._enterFrameIterator=nil
				if params.onComplete then params.onComplete() end
			end
		end

	end

	self._enterFrameIterator = eFI
	Runtime:addEventListener( 'enterFrame', self )

end



--====================================================================--
--== Private Methods


-- set how far table can be scrolled against a boundary limit
--
function AxisMotion:_setScrollbackLimit()
	self._scrollbackLimit = self._length * self._scrollbackFactor
end


-- the position to rest at: inside the scroll limits, without the
-- allowance for bounce, or aligned if the content is shorter than the view
--
function AxisMotion:_getRestPosition( value )
	-- print( "AxisMotion:_getRestPosition", value )
	if not self._scrollEnabled then return value end
	local length, scrollLength = self._length, self._scaledScrollLength
	-- no scroll area yet (it is set after creation)
	if scrollLength<=0 then return value end

	if scrollLength < length then
		local align = self._autoAlign
		if align==nil then
			return value
		elseif align==AxisMotion.MIDDLE then
			return length*0.5 - scrollLength*0.5
		elseif align==AxisMotion.LOWER then
			return length - scrollLength
		else
			return 0
		end
	end

	local upper = self._upperOffset
	local lower = (length-scrollLength) - self._lowerOffset
	if value > upper then
		return upper
	elseif value < lower then
		return lower
	end
	return value
end

-- the number of the page nearest to a position (0 is the first),
-- and the number of the last page. nil if there is nothing to page
--
function AxisMotion:_getPage( value )
	local length = self._length
	local upper = self._upperOffset
	local lower = (length-self._scaledScrollLength) - self._lowerOffset
	if not self._scrollEnabled or length<=0 or lower>=upper then return nil end

	-- a last page shorter than the view counts, if it is more than a pixel
	local last = mceil( (upper-lower-1)/length )
	local page = mfloor( (upper-value)/length + 0.5 )
	if page < 0 then page = 0 elseif page > last then page = last end
	return page, last
end

-- the position of a page: the last one stops at the scroll limit
--
function AxisMotion:_getPagePosition( page )
	local upper = self._upperOffset
	local lower = (self._length-self._scaledScrollLength) - self._lowerOffset
	local pos = upper - page*self._length
	if pos < lower then pos = lower end
	return pos
end

-- with paging, where a touch which just ended comes to rest: the page
-- next to the one it began on for a flick, otherwise the nearest one.
-- nil if there is nothing to page
--
function AxisMotion:_getPageRestPosition()
	local value = self._value
	local page, last = self:_getPage( value )
	if page==nil then return nil end

	local vel = self._velocity
	if vel.value >= AxisMotion.PAGE_FLICK_VELOCITY and vel.vector~=0 then
		-- the first page boundary in the direction of the flick: a drag
		-- one way which ends in a flick back stays on its page
		local pages = (self._upperOffset-value)/self._length
		if vel.vector < 0 then
			page = mceil( pages )
		else
			page = mfloor( pages )
		end
	end

	-- one page for each touch
	local first = self._touchPage
	if page > first+1 then page = first+1 elseif page < first-1 then page = first-1 end
	if page < 0 then page = 0 elseif page > last then page = last end

	return self:_getPagePosition( page )
end


-- after a change in size or scale while at rest,
-- bring the position back inside the scroll limits
--
function AxisMotion:_checkScaledPosition()
	-- print( "AxisMotion:_checkScaledPosition" )
	if self:getState() ~= AxisMotion.STATE_AT_REST then return end
	local check_f = self._checkPosition_f
	local eFI = self._enterFrameIterator
	if eFI~=nil then
		-- either a check is pending, or scrollToPosition() is running
		return
	end
	if self._value==self:_getRestPosition( self._value ) then return end

	-- done on the next frame, when all of the changes are in
	-- (eg, a new length and a new scroll length)
	if check_f==nil then
		check_f = function()
			local value = self._value
			local newVal = self:_getRestPosition( value )
			self._enterFrameIterator = nil
			if newVal~=value then
				self._value = newVal
				self._hasMoved = true
			end
		end
		self._checkPosition_f = check_f
	end
	self._enterFrameIterator = check_f
	Runtime:addEventListener( 'enterFrame', self )
end


-- check if position is at a limit
--
function AxisMotion:_checkScrollBounds( value )
	-- print( "AxisMotion:_checkScrollBounds", value )
	local calcs = { min=0, max=0 }

	if self._scrollEnabled and value then
		local upper = 0 + self._upperOffset
		local lower = (self._length-self._scaledScrollLength) - self._lowerOffset

		calcs.min=upper
		calcs.max=lower

		if self._scaledScrollLength < self._length then
			self._scrollLimit = AxisMotion.HIT_SIZE_LIMIT
		elseif value > upper then
			self._scrollLimit = AxisMotion.HIT_UPPER_LIMIT
		elseif value < lower then
			self._scrollLimit = AxisMotion.HIT_LOWER_LIMIT
		else
			self._scrollLimit = nil
		end
	end

	return calcs
end


-- ensure position stays within boundaries
--
function AxisMotion:_constrainPosition( value, delta )
	if self._id=='y' then
		-- print( "AxisMotion:_constrainPosition", value, delta )
	end

	local isBounceActive = self._bounceIsActive
	local LIMIT = self._scrollbackLimit
	local scrollLimit, newVal, calcs, s, factor

	newVal = value + delta
	calcs = self:_checkScrollBounds( newVal )
	scrollLimit = self._scrollLimit -- after check bounds

	if scrollLimit==AxisMotion.HIT_SIZE_LIMIT then
		local align = self._autoAlign
		if align==nil then
			-- no alignment, leave as is
		elseif align==AxisMotion.MIDDLE then
			newVal = self._length*0.5 - self._scaledScrollLength*0.5
		elseif align==AxisMotion.LOWER then
			newVal = self._length - self._scaledScrollLength
		else
			newVal = 0
		end

	elseif scrollLimit==AxisMotion.HIT_UPPER_LIMIT then
		if not isBounceActive then
			newVal=calcs.min
		else
			s = newVal-self._upperOffset
			factor = 1 - (s/LIMIT)
			if factor < 0 then factor = 0 end
			newVal = value + ( delta * factor )
			-- check bounds again
			self:_checkScrollBounds( newVal )
		end

	elseif scrollLimit==AxisMotion.HIT_LOWER_LIMIT then
		if not isBounceActive then
			newVal=calcs.max
		else
			s = (self._length - self._scaledScrollLength) - newVal - self._lowerOffset
			factor = 1 - (s/LIMIT)
			if factor < 0 then factor = 0 end
			newVal = value + ( delta * factor )
			-- check bounds again
			self:_checkScrollBounds( newVal )
		end

	end

	if self._id=='y' then
		-- print( "constain", self._scrollLimit )
	end

	return newVal
end


-- clamp max velocity, calculate average velocity
--
function AxisMotion:_updateVelocity( value )
	-- print( "AxisMotion:_updateVelocity", value )
	local VEL_STACK_LENGTH = AxisMotion.VELOCITY_STACK_LENGTH
	local LIMIT = AxisMotion.VELOCITY_LIMIT
	local _mabs = mabs
	local velStack = self._velocityStack
	local vel = self._velocity
	local vector, aveVel = 0,0

	if _mabs(value) > LIMIT then
		-- clamp velocity
		vector = (value>=0) and 1 or -1
		value = LIMIT*vector
	end

	tinsert( velStack, 1, value )

	for i = #velStack, 1, -1 do
		-- calculate average velocity and
		-- clean off velocity stack at same time
		if i > VEL_STACK_LENGTH then
			tremove( velStack, i )
		else
			aveVel = aveVel + velStack[i]
		end
	end
	aveVel = aveVel / #velStack

	vel.value = _mabs( aveVel )
	if aveVel~=0 then
		vel.vector = (aveVel>0) and -1 or 1
	else
		vel.vector = 0
	end

end



--====================================================================--
--== Event Handlers


function AxisMotion:enterFrame( event )
	-- print( "AxisMotion:enterFrame" )

	local f = self._enterFrameIterator

	if not f then
		Runtime:removeEventListener( 'enterFrame', self )

	else
		f( event )
		self._tmpFrameEvent = event

		if self._isMoving then
			local vel = self._velocity
			self._callback{
				id=self._id,
				state=AxisMotion.SCROLLING,
				value=self._value,
				velocity = vel.value * vel.vector,
			}
			self._hasMoved = true
		end

		-- look at "full" 'enterFrameIterator' in case value
		-- was changed during last call to interator
		if not self._enterFrameIterator and self._hasMoved then
			self._callback{
				id=self._id,
				state = AxisMotion.SCROLLED,
				value = self._value,
				velocity = 0
			}
			self._hasMoved = false
		end

	end
end


function AxisMotion:touch( event )
	-- print( "AxisMotion:touch", event.phase, event.value )
	local phase = event.phase

	if not self._scrollEnabled then return end

	local evt = {
		-- make a "copy" of the event
		time=event.time,
		start=event.start,
		-- make relative position, without using globalToContent
		value=event.value-self._location
	}

	if phase=='began' then
		local vel = self._velocity

		-- @TODO, probably check to see state we're in
		vel.value, vel.vector = 0, 0
		-- a new touch starts without the speeds of the last one
		self._velocityStack = { 0 }

		-- get our initial reference point
		self._refPoint = (evt.value - self._value)/self._scale

		self._touchPage = self:_getPage( self._value ) or 0

		self._tmpTouchEvt = evt
		self._didBegin = true
		self:gotoState( AxisMotion.STATE_TOUCH )

	end

	if not self._didBegin then return end

	if phase == 'moved' then

		local tmpTouchEvt = self._tmpTouchEvt
		local constrain = AxisMotion._constrainPosition

		local deltaVal = evt.value - tmpTouchEvt.value
		local deltaT = evt.time - tmpTouchEvt.time
		local oldVal, newVal

		self._isMoving = true

		--== Calculate new position/velocity

		oldVal = self._value
		newVal = constrain( self, oldVal, deltaVal )
		self:_updateVelocity( (oldVal-newVal)/deltaT )

		self._value = newVal
		self._tmpTouchEvt = evt

	elseif phase=='ended' or phase=='cancelled' then

		self._tmpTouchEvt = evt
		self._didBegin = false
		self._refPoint = nil

		local next_state, next_params = self:_getNextState{ event=evt }
		self:gotoState( next_state, next_params )

	end

end



--====================================================================--
--== State Machine


function AxisMotion:_getNextState( params )
	-- print( "AxisMotion:_getNextState" )
	params = params or {}
	--==--
	local scrollLimit = self._scrollLimit
	local velocity = self._velocity
	local isBounceActive = self._bounceIsActive
	local s, p -- state, params

	-- print( "gNS>>", velocity.value, scrollLimit, isBounceActive )

	local pagePos
	if self._pagingEnabled then
		pagePos = self:_getPageRestPosition()
	end

	if pagePos~=nil then
		if pagePos==self._value then
			s = AxisMotion.STATE_AT_REST
			p = { event=params.event }
		else
			-- slide to the page, as to a scroll limit
			s = AxisMotion.STATE_RESTORE
			p = { event=params.event, offset=pagePos }
		end

	elseif velocity.value > 0 and not scrollLimit then
		s = AxisMotion.STATE_DECELERATE
		p = { event=params.event }

	elseif velocity.value <= 0 and scrollLimit and isBounceActive then
		s = AxisMotion.STATE_RESTORE
		p = { event=params.event }

	elseif velocity.value > 0 and scrollLimit and isBounceActive then
		s = AxisMotion.STATE_RESTRAINT
		p = { event=params.event }

	else
		s = AxisMotion.STATE_AT_REST
		p = { event=params.event }

	end

	return s, p
end


--== State Create

function AxisMotion:state_create( next_state, params )
	-- print( "AxisMotion:state_create: >> ", next_state )

	if next_state == AxisMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		pwarn( sfmt( "AxisMotion:state_create unknown transition '%s'", tstr( next_state )))
	end
end


--== State At-Rest

function AxisMotion:do_state_at_rest( params )
	-- print( "AxisMotion:do_state_at_rest", params )
	params = params or {}
	--==--
	local vel = self._velocity
	vel.value, vel.vector = 0, 0
	self._isMoving = false

	self._enterFrameIterator = nil
	Runtime:removeEventListener( 'enterFrame', self )

	self:setState( AxisMotion.STATE_AT_REST )

	-- coming to rest outside of enterFrame (eg, a touch which ends
	-- without speed) gets its 'scrolled' here
	if self._hasMoved then
		self._hasMoved = false
		self._callback{
			id=self._id,
			state=AxisMotion.SCROLLED,
			value=self._value,
			velocity=0
		}
	end
end

function AxisMotion:state_at_rest( next_state, params )
	-- print( "AxisMotion:state_at_rest: >> ", next_state )

	if next_state == AxisMotion.STATE_TOUCH then
		self:do_state_touch( params )

	else
		pwarn( sfmt( "AxisMotion:state_at_rest unknown transition '%s'", tstr( next_state )))
	end

end


--== State Touch

function AxisMotion:do_state_touch( params )
	-- print( "AxisMotion:do_state_touch" )
	-- params = params or {}
	-- --==--

	local enterFrameFunc1 = function( e )
		-- print( "enterFrameFunc: enterFrameFunc1 state touch " )
		self:_updateVelocity( 0 )
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc1

	-- set current state
	self:setState( AxisMotion.STATE_TOUCH )
end

function AxisMotion:state_touch( next_state, params )
	-- print( "AxisMotion:state_touch: >> ", next_state )

	if next_state == AxisMotion.STATE_RESTORE then
		self:do_state_restore( params )

	elseif next_state == AxisMotion.STATE_RESTRAINT then
		self:do_state_restraint( params )

	elseif next_state == AxisMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == AxisMotion.STATE_DECELERATE then
		self:do_state_decelerate( params )

	else
		pwarn( sfmt( "AxisMotion:state_touch unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Decelerate

function AxisMotion:do_state_decelerate( params )
	-- print( "AxisMotion:do_state_decelerate" )
	params = params or {}
	--==--
	local TIME = self._decelTransTime
	local constrain = AxisMotion._constrainPosition
	local ease_f = easingx.easeOutQuad
	local _mabs = mabs

	local startEvt = params.event
	local vel = self._velocity
	local velocity = vel.value
	local deltaVel = -velocity

	self._isMoving = true

	local enterFrameFunc = function( e )
		-- print( "AxisMotion: enterFrameFunc: do_state_decelerate" )

		local frameEvt = self._tmpFrameEvent or startEvt -- none yet: ended in the frame it began
		local scrollLimit = self._scrollLimit

		local deltaStart = e.time - startEvt.time
		local deltaFrame = e.time - frameEvt.time
		local deltaVal, oldVal, newVal

		--== Calculation

		vel.value = ease_f( deltaStart, TIME, velocity, deltaVel )
		deltaVal = vel.value * vel.vector * deltaFrame

		--== Action

		oldVal = self._value
		newVal = constrain( self, oldVal, deltaVal )
		self._value = newVal

		if vel.value > 0 and scrollLimit then
			-- hit edge while moving
			self:gotoState( AxisMotion.STATE_RESTRAINT, { event=e } )

		elseif deltaStart >= TIME or _mabs( newVal-oldVal ) < 1 then
			-- over time or movement too small to see (pixel)
			self:gotoState( AxisMotion.STATE_AT_REST )

		end

	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( AxisMotion.STATE_DECELERATE )

end

function AxisMotion:state_decelerate( next_state, params )
	-- print( "AxisMotion:state_decelerate: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == self.STATE_RESTRAINT then
		self:do_state_restraint( params )

	else
		pwarn( sfmt( "AxisMotion:state_decelerate unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Restore

function AxisMotion:do_state_restore( params )
	-- print( "AxisMotion:do_state_restore" )
	params = params or {}
	--==--
	local TIME = self._restoreTransTime
	local constrain = AxisMotion._constrainPosition
	local ease_f = easingx.easeOut

	local startEvt = params.event
	local val = self._value
	local vel = self._velocity

	local delta, offset

	-- calculate restore distance
	local scrollLimit = self._scrollLimit
	if params.offset~=nil then
		-- paging: the position of a page
		offset = params.offset
		vel.value, vel.vector = 0, 0
	elseif scrollLimit == AxisMotion.HIT_SIZE_LIMIT then
		offset = constrain( self, val, 0 )
	elseif scrollLimit == AxisMotion.HIT_UPPER_LIMIT then
		offset = self._upperOffset
	else
		offset = (self._length - self._scaledScrollLength - self._lowerOffset)
	end
	delta = offset-val

	self._isMoving = true

	local enterFrameFunc = function( e )
		-- print( "AxisMotion: enterFrameFunc: do_state_restore " )

		--== Calculation

		local deltaT = e.time - startEvt.time
		local deltaV = ease_f( deltaT, TIME, val, delta )

		--== Action

		if deltaT < TIME then
			self._value = deltaV
		else
			self._value = offset
			self:gotoState( AxisMotion.STATE_AT_REST )
		end
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( AxisMotion.STATE_RESTORE )
end

function AxisMotion:state_restore( next_state, params )
	-- print( "AxisMotion:state_restore: >> ", next_state )

	if next_state == AxisMotion.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == AxisMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		pwarn( sfmt( "AxisMotion:state_restore unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Restraint

-- when object has velocity and hit limit
-- we constrain its motion away from limit
--
function AxisMotion:do_state_restraint( params )
	-- print( "AxisMotion:do_state_restraint" )
	params = params or {}
	--==--
	local TIME = self._restraintTransTime
	local constrain = AxisMotion._constrainPosition
	local ease_f = easingx.easeOut
	local _mabs = mabs

	-- startEvt could be Touch or enterFrame event
	-- of importance is the 'time' param
	local startEvt = params.event

	local vel = self._velocity
	local velocity = vel.value * vel.vector
	local deltaVel = -velocity

	self._isMoving = true

	local enterFrameFunc = function( e )
		-- print( "AxisMotion: enterFrameFunc: do_state_restraint" )

		local frameEvt = self._tmpFrameEvent or startEvt -- none yet: ended in the frame it began

		local deltaStart = e.time - startEvt.time -- total
		local deltaFrame = e.time - frameEvt.time
		local deltaVal, oldVal, newVal

		--== Calculation

		vel.value = ease_f( deltaStart, TIME, velocity, deltaVel )
		deltaVal = vel.value * deltaFrame

		--== Action

		oldVal = self._value
		newVal = constrain( self, oldVal, deltaVal )
		self._value = newVal

		if deltaStart >= TIME or _mabs( newVal-oldVal ) < 1 then
			vel.value, vel.vector = 0, 0
			self:gotoState( AxisMotion.STATE_RESTORE, { event=e } )

		end

	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( AxisMotion.STATE_RESTRAINT )
end

function AxisMotion:state_restraint( next_state, params )
	-- print( "AxisMotion:state_restraint: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_RESTORE then
		self:do_state_restore( params )

	else
		pwarn( sfmt( "AxisMotion:state_restraint unknown state transition '%s'", tstr( next_state )))
	end

end




return AxisMotion
