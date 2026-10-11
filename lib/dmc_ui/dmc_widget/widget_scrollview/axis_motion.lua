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

local VERSION = "0.2.0"



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
local mexp = math.exp
local mfloor = math.floor
local mlog = math.log
local sfmt = string.format
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

-- the fastest scrollToPosition() goes with 'limitIsActive'
AxisMotion.VELOCITY_LIMIT = uiConst.AXIS_VELOCITY_LIMIT

-- the speed of a touch (pixels per millisecond): the fastest it counts
-- for, the time over which it is measured, and the speed below which
-- a glide stops
AxisMotion.TOUCH_VELOCITY_LIMIT = uiConst.AXIS_TOUCH_VELOCITY_LIMIT
AxisMotion.TOUCH_VELOCITY_WINDOW = uiConst.AXIS_TOUCH_VELOCITY_WINDOW
AxisMotion.MIN_VELOCITY = uiConst.AXIS_MIN_VELOCITY

-- a drag past an edge: the part of the finger's travel which the
-- content follows at the edge (less the further it goes), and the
-- furthest it can go, as a part of the length of the view
AxisMotion.RUBBER_BAND_FACTOR = uiConst.AXIS_RUBBER_BAND_FACTOR
AxisMotion.RUBBER_BAND_LIMIT = uiConst.AXIS_RUBBER_BAND_LIMIT

-- the spring which brings the content back to an edge: its
-- angular frequency, per millisecond (critically damped)
AxisMotion.SPRING_FREQUENCY = uiConst.AXIS_SPRING_FREQUENCY

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
	if params.decelerationRate==nil then params.decelerationRate=uiConst.AXIS_DECELERATION_RATE end
	if params.restoreTransitionTime==nil then params.restoreTransitionTime=uiConst.AXIS_RESTORE_TIME end
	if params.scrollToTransitionTime==nil then params.scrollToTransitionTime=uiConst.AXIS_SCROLLTO_TIME end
	if params.length==nil then params.length=0 end
	if params.lowerOffset==nil then params.lowerOffset=0 end
	if params.pagingIsEnabled==nil then params.pagingIsEnabled=false end
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

	self._decelRate = 0
	self._restoreTransTime = 0
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

	-- block to make sure had a proper start
	-- to touch events, eg 'began'
	self._didBegin = false

	--== Internal Properties

	-- eg, HIT_UPPER_LIMIT, HIT_LOWER_LIMIT, etc
	self._scrollLimit = nil

	-- a drag past an edge: the position the last move gave,
	-- and where the finger was for it. see _constrainPosition()
	self._bandValue = nil
	self._bandTouch = nil

	-- previous Touch Event, used for calculating deltas
	self._tmpTouchEvt = nil

	-- previous enterFrame event, used for calculating deltas
	self._tmpFrameEvent = nil

	-- the positions of the touch in progress, each { time=, value= },
	-- over TOUCH_VELOCITY_WINDOW: its speed comes from them
	self._touchSamples = {}
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
	self.decelerationRate = tmp.decelerationRate
	self.length = tmp.length
	self.lowerOffset = tmp.lowerOffset
	self.pagingIsEnabled = tmp.pagingIsEnabled
	self.restoreTransitionTime = tmp.restoreTransitionTime
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


-- the part of its speed a glide keeps after each millisecond
function AxisMotion.__getters:decelerationRate()
	return self._decelRate
end
function AxisMotion.__setters:decelerationRate( value )
	assert( type(value)=='number' and value > 0 and value < 1, "ERROR: AxisMotion.decelerationRate expected number between 0 and 1" )
	--==--
	self._decelRate = value
end


-- this is the length of the view port
function AxisMotion.__getters:length()
	return self._length
end
function AxisMotion.__setters:length( value )
	assert( type(value)=='number' and value > 0 )
	--==--
	self._length = value
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


-- how long the slide to a page takes (paging)
function AxisMotion.__getters:restoreTransitionTime()
	return self._restoreTransTime
end
function AxisMotion.__setters:restoreTransitionTime( value )
	assert( type(value)=='number' and value > 0, "ERROR: AxisMotion.restoreTransitionTime expected number", value )
	--==--
	self._restoreTransTime = value
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


-- how far the content is past an edge when the finger has
-- travelled 'distance' past it, and the reverse. the content follows
-- by RUBBER_BAND_FACTOR at the edge and less the further it goes,
-- never further than RUBBER_BAND_LIMIT of the view (UIScrollView's
-- curve, which lets it go as far as the whole view)
--
function AxisMotion:_rubberBand( distance )
	local limit = self._length * AxisMotion.RUBBER_BAND_LIMIT
	local d = distance * AxisMotion.RUBBER_BAND_FACTOR
	if limit<=0 then return 0 end
	return d*limit / ( d+limit )
end

function AxisMotion:_rubberBandTravel( offset )
	local limit = self._length * AxisMotion.RUBBER_BAND_LIMIT
	if limit<=0 then return 0 end
	-- the spring can carry the content further than a finger could
	local MAX = limit*0.95
	if offset > MAX then offset = MAX end
	return offset*limit / ( AxisMotion.RUBBER_BAND_FACTOR * ( limit-offset ) )
end


-- ensure position stays within boundaries: the position after
-- the finger has moved by 'delta'
--
function AxisMotion:_constrainPosition( value, delta )
	-- print( "AxisMotion:_constrainPosition", value, delta )
	local isBounceActive = self._bounceIsActive
	local scrollLimit, newVal, calcs

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

	elseif not self._scrollEnabled then
		-- no limits to check

	else
		local upper, lower = calcs.min, calcs.max
		-- where the finger is: past an edge it is ahead of the content.
		-- known from the last move, or else worked out from the content
		local touch = value
		if value==self._bandValue then
			touch = self._bandTouch
		elseif value > upper then
			touch = upper + self:_rubberBandTravel( value-upper )
		elseif value < lower then
			touch = lower - self:_rubberBandTravel( lower-value )
		end
		touch = touch + delta

		if touch > upper then
			newVal = isBounceActive and upper + self:_rubberBand( touch-upper ) or upper
		elseif touch < lower then
			newVal = isBounceActive and lower - self:_rubberBand( lower-touch ) or lower
		else
			newVal = touch
		end
		-- without bounce the finger's way past an edge is forgotten
		self._bandValue, self._bandTouch = newVal, isBounceActive and touch or newVal
		-- check bounds again
		self:_checkScrollBounds( newVal )

	end

	return newVal
end


-- the speed of the touch at 'time', from its positions over
-- the last TOUCH_VELOCITY_WINDOW, in its last direction: a finger which
-- rests loses it.
-- 'value' is a new position, if there is one
--
function AxisMotion:_updateVelocity( time, value )
	-- print( "AxisMotion:_updateVelocity", time, value )
	local LIMIT = AxisMotion.TOUCH_VELOCITY_LIMIT
	local samples = self._touchSamples
	local first, last, deltaT, velocity

	if value~=nil then
		-- a touch which turns back is measured from where it turned
		local n = #samples
		if n > 1 and ( samples[n].value-samples[n-1].value ) * ( value-samples[n].value ) < 0 then
			samples = { samples[n] }
			self._touchSamples = samples
		end
		samples[ #samples+1 ] = { time=time, value=value }
	end
	-- keep the newest one, to measure from once the others are too old
	while #samples > 1 and samples[1].time < time-AxisMotion.TOUCH_VELOCITY_WINDOW do
		tremove( samples, 1 )
	end

	first, last = samples[1], samples[#samples]
	if first==nil then return end
	deltaT = time - first.time
	-- two events at the same time say nothing about speed
	if deltaT <= 0 then return end

	velocity = ( last.value-first.value ) / deltaT
	if velocity > LIMIT then
		velocity = LIMIT
	elseif velocity < -LIMIT then
		velocity = -LIMIT
	end
	self:_setVelocity( velocity )
end


-- 'velocity' has a direction: positive while the position grows
--
function AxisMotion:_setVelocity( velocity )
	local vel = self._velocity
	vel.value = mabs( velocity )
	if velocity > 0 then
		vel.vector = 1
	elseif velocity < 0 then
		vel.vector = -1
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

		-- a new touch starts without the speed of the last one
		vel.value, vel.vector = 0, 0
		self._touchSamples = { { time=evt.time, value=self._value } }

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
		local oldVal, newVal

		self._isMoving = true

		--== Calculate new position/velocity

		oldVal = self._value
		newVal = constrain( self, oldVal, deltaVal )
		self:_updateVelocity( evt.time, newVal )

		self._value = newVal
		self._tmpTouchEvt = evt

	elseif phase=='ended' or phase=='cancelled' then

		self._tmpTouchEvt = evt
		self._didBegin = false
		self._refPoint = nil
		self:_updateVelocity( evt.time )

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
	local velocity = self._velocity
	local isBounceActive = self._bounceIsActive
	local s, p -- state, params

	self:_checkScrollBounds( self._value )
	local scrollLimit = self._scrollLimit -- after check bounds

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

	elseif scrollLimit and isBounceActive then
		-- past an edge, with or without speed: the spring takes it
		s = AxisMotion.STATE_RESTORE
		p = { event=params.event }

	elseif velocity.value >= AxisMotion.MIN_VELOCITY and not scrollLimit then
		s = AxisMotion.STATE_DECELERATE
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
		-- a finger which rests loses its speed
		self:_updateVelocity( e.time )
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

	elseif next_state == AxisMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == AxisMotion.STATE_DECELERATE then
		self:do_state_decelerate( params )

	else
		pwarn( sfmt( "AxisMotion:state_touch unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Decelerate

-- a glide: after a touch which ended with speed, the content goes on
-- and loses a constant part of its speed with each millisecond
-- (decelerationRate), so a faster flick goes further and for longer
--
function AxisMotion:do_state_decelerate( params )
	-- print( "AxisMotion:do_state_decelerate" )
	params = params or {}
	--==--
	local MIN_VELOCITY = AxisMotion.MIN_VELOCITY
	-- the speed is v0*rate^t, written as v0*e^(-k*t)
	local k = -mlog( self._decelRate )

	-- startEvt could be Touch or enterFrame event
	-- of importance is the 'time' param
	local startEvt = params.event
	local vel = self._velocity
	local velocity = vel.value * vel.vector
	local val = self._value

	self._isMoving = true

	local enterFrameFunc = function( e )
		-- print( "AxisMotion: enterFrameFunc: do_state_decelerate" )

		local deltaT = e.time - startEvt.time
		if deltaT < 0 then deltaT = 0 end

		--== Calculation

		local decay = mexp( -k*deltaT )
		local newVel = velocity * decay
		local newVal = val + velocity * ( 1-decay ) / k
		local calcs = self:_checkScrollBounds( newVal )
		local scrollLimit = self._scrollLimit -- after check bounds

		--== Action

		self:_setVelocity( newVel )

		if scrollLimit and self._bounceIsActive then
			-- crossed an edge while moving: the spring takes its speed
			self._value = newVal
			self:gotoState( AxisMotion.STATE_RESTORE, { event=e } )

		elseif scrollLimit==AxisMotion.HIT_UPPER_LIMIT then
			self._value = calcs.min
			self:gotoState( AxisMotion.STATE_AT_REST )

		elseif scrollLimit==AxisMotion.HIT_LOWER_LIMIT then
			self._value = calcs.max
			self:gotoState( AxisMotion.STATE_AT_REST )

		elseif scrollLimit or vel.value < MIN_VELOCITY then
			-- too slow to see
			self._value = newVal
			self:gotoState( AxisMotion.STATE_AT_REST )

		else
			self._value = newVal

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

	elseif next_state == self.STATE_RESTORE then
		self:do_state_restore( params )

	else
		pwarn( sfmt( "AxisMotion:state_decelerate unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Restore

-- back to where the content rests: to an edge it is past, by
-- a spring, or to a page, as a timed slide (params.offset)
--
function AxisMotion:do_state_restore( params )
	-- print( "AxisMotion:do_state_restore" )
	params = params or {}
	--==--
	local enterFrameFunc
	if params.offset~=nil then
		enterFrameFunc = self:_getPageIterator( params )
	else
		enterFrameFunc = self:_getSpringIterator( params )
	end

	self._isMoving = true

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( AxisMotion.STATE_RESTORE )
end

-- paging: slide to the position of a page
--
function AxisMotion:_getPageIterator( params )
	local TIME = self._restoreTransTime
	local ease_f = easingx.easeOut

	local startEvt = params.event
	local offset = params.offset
	local val = self._value
	local vel = self._velocity
	local delta = offset-val

	vel.value, vel.vector = 0, 0

	return function( e )
		-- print( "AxisMotion: enterFrameFunc: do_state_restore, page" )

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
end

-- a critically damped spring, from where the content is and with the
-- speed it has, to the edge it is past. with x the distance past the
-- edge, v0 the speed and w the spring's frequency:
--   x(t) = ( x0 + (v0 + w*x0)*t ) * e^(-w*t)
-- one motion without a halt: a faster arrival overruns the edge by
-- more (v0/(e*w), at t=1/w) and takes about as long to settle; without
-- speed (let go of past the edge) it only comes back
--
function AxisMotion:_getSpringIterator( params )
	local W = AxisMotion.SPRING_FREQUENCY
	local MIN_VELOCITY = AxisMotion.MIN_VELOCITY
	local constrain = AxisMotion._constrainPosition

	-- startEvt could be Touch or enterFrame event
	-- of importance is the 'time' param
	local startEvt = params.event
	local val = self._value
	local vel = self._velocity
	local velocity = vel.value * vel.vector
	local offset

	self:_checkScrollBounds( val )
	local scrollLimit = self._scrollLimit
	if scrollLimit == AxisMotion.HIT_UPPER_LIMIT then
		offset = self._upperOffset
	elseif scrollLimit == AxisMotion.HIT_LOWER_LIMIT then
		offset = (self._length - self._scaledScrollLength - self._lowerOffset)
	else
		-- content shorter than the view: to its alignment
		offset = constrain( self, val, 0 )
		velocity = 0
	end

	local x0 = val - offset
	local b = velocity + W*x0

	return function( e )
		-- print( "AxisMotion: enterFrameFunc: do_state_restore, spring" )

		local deltaT = e.time - startEvt.time
		if deltaT < 0 then deltaT = 0 end

		--== Calculation

		local decay = mexp( -W*deltaT )
		local x = ( x0 + b*deltaT ) * decay
		local newVel = ( b - W*( x0 + b*deltaT ) ) * decay

		--== Action

		self:_setVelocity( newVel )

		if x*x0 < 0 then
			-- let go while moving back fast enough to pass the edge:
			-- the content goes on from there, as after a flick
			self._value = offset
			self:_checkScrollBounds( offset )
			self:gotoState( AxisMotion.STATE_DECELERATE, { event=e } )

		elseif mabs( x ) < 0.5 and vel.value < MIN_VELOCITY then
			-- too near and too slow to see
			self._value = offset
			self:_checkScrollBounds( offset )
			self:gotoState( AxisMotion.STATE_AT_REST )

		else
			self._value = offset + x
			self:_checkScrollBounds( offset + x )

		end
	end
end

function AxisMotion:state_restore( next_state, params )
	-- print( "AxisMotion:state_restore: >> ", next_state )

	if next_state == AxisMotion.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == AxisMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == AxisMotion.STATE_DECELERATE then
		self:do_state_decelerate( params )

	else
		pwarn( sfmt( "AxisMotion:state_restore unknown state transition '%s'", tstr( next_state )))
	end

end



return AxisMotion
