--====================================================================--
-- dmc_ui/dmc_widget/widget_scrollview/scale_motion.lua
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
--== DMC Corona UI : Scale Motion
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
local Patch = require 'dmc_patch'
local StatesMixModule = require 'dmc_states_mix'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )
local easingx = require( ui_find( 'dmc_widget.lib.easingx' ) )



--====================================================================--
--== Setup, Constants


Patch.addPatch( 'print-output' )

local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase

local mabs = math.abs
local mfloor = math.floor
local mmin = math.min
local sfmt = string.format
local tinsert = table.insert
local tremove = table.remove
local tstr = tostring



--====================================================================--
--== Scale Motion Class
--====================================================================--


local ScaleMotion = newClass( ObjectBase, {name="Scale Motion"} )

StatesMixModule.patch( ScaleMotion )

--== Class Constants

-- max number of items for velocity calculation
ScaleMotion.VELOCITY_STACK_LENGTH = 4
-- speed limit
ScaleMotion.VELOCITY_LIMIT = 1

ScaleMotion.DECELERATE_TRANS_TIME = 3000 -- test 1000 / def 1000
ScaleMotion.RESTORE_TRANS_TIME = 400 -- test 1000 / def 400
ScaleMotion.RESTRAINT_TRANS_TIME = 350  -- test 1000 / def 100
ScaleMotion.SCROLLTO_TRANS_TIME = 500  -- test 1000 / def 100

ScaleMotion.ZOOMBACK_FACTOR = 1/3

ScaleMotion.HIT_UPPER_LIMIT = 'upper_limit_hit'
ScaleMotion.HIT_LOWER_LIMIT = 'lower_limit_hit'

--== State Constants

ScaleMotion.STATE_CREATE = 'state_create'
ScaleMotion.STATE_AT_REST = 'state_at_rest'
ScaleMotion.STATE_DECELERATE = 'state_decelerate'
ScaleMotion.STATE_RESTORE = 'state_restore'
ScaleMotion.STATE_RESTRAINT = 'state_restraint'
ScaleMotion.STATE_TOUCH = 'state_touch'

--== Event Constants

ScaleMotion.WILL_ZOOM = 'will-zoom'
ScaleMotion.ZOOMING = 'zooming'
ScaleMotion.DID_ZOOM = 'did-zoom'


--======================================================--
-- Start: Setup DMC Objects

function ScaleMotion:__init__( params )
	-- print( "ScaleMotion:__init__" )
	params = params or {}
	if params.bounceIsActive==nil then params.bounceIsActive = true end
	if params.zoomScale==nil then params.zoomScale=1.0 end
	if params.zoomBackLimit==nil then params.zoomBackLimit = 0.8 end

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._sm_tmp_params = params -- tmp

	--== Create Properties ==--

	-- value is current scale
	self._scale = params.zoomScale
	self._scaleBase = 1.0 -- scale factor

	self._minZoom = nil
	self._maxZoom = nil
	self._isZooming = false

	-- are we scrolling
	self._isMoving = false
	self._zoomIsActive = false

	self._zoomBackLimit = -1 -- << test 1 / def 3
	-- self._zoomBackFactor = value

	self._callback = params.callback

	-- flag used during touch sequence
	self._didBegin = false

	--== Internal Properties

	-- eg, HIT_UPPER_LIMIT, HIT_LOWER_LIMIT
	self._scaleLimit = nil

	-- last Touch Event, used for calculating deltas
	self._tmpTouchEvt = nil

	-- last enterFrame event, used for calculating deltas
	self._tmpFrameEvent = nil

	-- self._touchEvtStack = {}
	self._velocityStack = {0,0}
	self._velocity = { value=0, vector=0 }

	self._enterFrameIterator = nil

	self._bounceIsActive = params.bounceIsActive
	self._alwaysBounce = false

	self:setState( ScaleMotion.STATE_CREATE )
end

--== createView

function ScaleMotion:__initComplete__()
	-- print( "ScaleMotion:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--

	local tmp = self._sm_tmp_params

	--== Use Setters
	self.bounceIsActive = tmp.bounceIsActive
	self.maximumZoom = tmp.maximumZoom
	self.minimumZoom = tmp.minimumZoom
	self.zoomBackLimit = tmp.zoomBackLimit

	self._sm_tmp_params = nil

	self:gotoState( ScaleMotion.STATE_AT_REST )
end

function ScaleMotion:__undoInitComplete__()
	-- print( "ScaleMotion:__undoInitComplete__" )
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


--======================================================--
-- Getters/Setters

-- whether to bounce on constraint
function ScaleMotion.__getters:bounceIsActive()
	return self._bounceIsActive
end
function ScaleMotion.__setters:bounceIsActive( value )
	assert( type(value)=='boolean' )
	--==--
	self._bounceIsActive = value
end


function ScaleMotion.__getters:maximumZoom()
	return self._maxZoom
end
function ScaleMotion.__setters:maximumZoom( value )
	assert( value==nil or (type(value)=='number' and value>0 ) )
	--==--
	self._maxZoom = value
	self:_updateZoomIsActive()
end


function ScaleMotion.__getters:minimumZoom()
	return self._minZoom
end
function ScaleMotion.__setters:minimumZoom( value )
	-- print("ScaleMotion.__setters:minimumZoom", value)
	assert( value==nil or (type(value)=='number' and value>0 ) )
	--==--
	self._minZoom = value
	self:_updateZoomIsActive()
end


-- decimal fraction (1/3)
-- function ScaleMotion.__setters:scrollbackFactor( value )
-- 	self._zoomBackFactor = value
-- 	self:_setZoomBackLimit()
-- end


function ScaleMotion.__setters:zoomBackLimit( value )
	-- print("ScaleMotion.__setters:zoomBackLimit", value)
	assert( type(value)=='number' )
	--==--
	self._zoomBackLimit = value
end


function ScaleMotion.__getters:zoomIsActive()
	return self._zoomIsActive
end


function ScaleMotion.__getters:zoomScale()
	-- print("ScaleMotion.__getters:zoomScale", self._scale)
	return self._scale
end


--======================================================--
-- Methods

function ScaleMotion:setZoomScale( scale, params )
	-- print( "ScaleMotion:setZoomScale", scale )
	assert( type(scale)=='number' )
	if not self._zoomIsActive then return end
	params = params or {}
	-- params.onComplete=params.onComplete
	if params.time==nil then params.time=ScaleMotion.SCROLLTO_TRANS_TIME end
	--==--
	if scale < self._minZoom then
		scale = self._minZoom
		pnotice( sfmt( "ScaleMotion:setZoomScale minimum scale being set to: %s", scale ) )
	elseif scale > self._maxZoom then
		scale = self._maxZoom
		pnotice( sfmt( "ScaleMotion:setZoomScale maximum scale being set to: %s", scale ) )
	end

	local eFI

	if params.time==0 then

		-- this will be run once
		eFI = function()
			self:_dispatchBeginZoom()
			self._scale = scale
			self._isMoving=false
			self._hasMoved=true
			self._enterFrameIterator=nil
			self:_dispatchEndZoom()
			if params.onComplete then params.onComplete() end
		end

	else
		local time = params.time
		local ease_f = easingx.easeOut
		local val = self._scale
		local delta = mmin( scale - val )
		local startEvt = {
			time=system.getTimer()
		}
		self._isMoving = true

		self:_dispatchBeginZoom()

		eFI = function( e )
			local deltaT = e.time - startEvt.time
			local deltaV = ease_f( deltaT, time, val, delta )

			if deltaT < time then
				self._scale = deltaV
			else
				self._isMoving = false
				self._hasMoved = true
				self._scale = scale
				self._enterFrameIterator=nil
				self:_dispatchEndZoom()

				if params.onComplete then params.onComplete() end
			end
		end

	end

	self._enterFrameIterator = eFI
	Runtime:addEventListener( 'enterFrame', self )

end



--====================================================================--
--== Private Methods


-- check if position is at a limit
--
function ScaleMotion:_checkScaleBounds( value )
	-- print( "ScaleMotion:_checkScaleBounds", value )
	local calcs = { min=1, max=1 }

	if self._zoomIsActive and value then
		local upper = self._maxZoom
		local lower = self._minZoom

		calcs.max=upper
		calcs.min=lower

		if value > upper then
			self._scaleLimit = ScaleMotion.HIT_UPPER_LIMIT
			calcs.overage=mabs(value-upper)
		elseif value < lower then
			self._scaleLimit = ScaleMotion.HIT_LOWER_LIMIT
			calcs.overage=mabs(value-lower)
		else
			self._scaleLimit = nil
			calcs.overage=0
		end

	end

	return calcs
end


-- ensure position stays within boundaries
--
function ScaleMotion:_constrainScale( value, delta )
	-- print( "ScaleMotion:_constrainScale", value, delta )
	local isBounceActive = self._bounceIsActive
	local LIMIT = self._zoomBackLimit
	local scaleLimit, calcs, factor, newVal, s

	newVal = value + delta
	calcs = self:_checkScaleBounds( newVal )
	scaleLimit = self._scaleLimit -- after check bounds

	if scaleLimit==ScaleMotion.HIT_UPPER_LIMIT then
		if not isBounceActive then
			newVal=calcs.max
		else
			local s = self._maxZoom/LIMIT
			factor = 1 - (newVal/s)
			if factor < 0 then factor = 0 end
			newVal = value + ( delta * factor )
			self:_checkScaleBounds( newVal )
		end

	elseif scaleLimit==ScaleMotion.HIT_LOWER_LIMIT then
		if not isBounceActive then
			newVal=calcs.min
		else
			s = self._minZoom*LIMIT
			factor = 1 - (s/newVal)
			if factor < 0 then factor = 0 end
			newVal = value + ( delta * factor )
			self:_checkScaleBounds( newVal )
		end

	end

	return newVal
end


-- set how far much view can be scaled against a boundary limit
--
-- function ScaleMotion:_setZoomBackLimit()
-- 	self._zoomBackLimit = self._length * self._zoomBackFactor
-- end


-- clamp max velocity, calculate average velocity
--
function ScaleMotion:_updateVelocity( value )
	-- print( "ScaleMotion:_updateVelocity", value )
	local VEL_STACK_LENGTH = ScaleMotion.VELOCITY_STACK_LENGTH
	local LIMIT = ScaleMotion.VELOCITY_LIMIT
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


function ScaleMotion:_updateZoomIsActive()
	self._zoomIsActive = (
		type(self._maxZoom)=='number' and
		self._maxZoom > 0 and
		type(self._minZoom)=='number' and
		self._minZoom > 0 and
		self._minZoom < self._maxZoom
	)
end


--======================================================--
-- Event Dispatch

function ScaleMotion:_dispatchBeginZoom()
	self._callback{
		id=self._id,
		target=self,
		state = ScaleMotion.WILL_ZOOM,
		scale = self._scale,
		velocity = 0
	}
end

function ScaleMotion:_dispatchEndZoom()
	if self._hasMoved then
		self._callback{
			id=self._id,
			target=self,
			state = ScaleMotion.DID_ZOOM,
			scale = self._scale,
			velocity = 0
		}
		self._hasMoved = false
	end
end



--====================================================================--
--== Event Handlers


function ScaleMotion:enterFrame( event )
	-- print( "ScaleMotion:enterFrame" )

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
				target=self,
				state=ScaleMotion.ZOOMING,
				scale=self._scale,
				velocity = vel.value * vel.vector,
			}
			self._hasMoved = true
		end

	end
end


function ScaleMotion:touch( event )
	-- print( "ScaleMotion:touch", event.phase, event.value )
	local phase = event.phase

	if not self._zoomIsActive then return end

	local evt = {
		-- make a "copy" of the event
		time=event.time,
		start=event.start,
		value=event.value
	}

	if phase=='began' then
		local vel = self._velocity
		local velStack = self._velocityStack

		-- @TODO, probably check to see state we're in
		vel.value, vel.vector = 0, 0

		if #velStack==0 then
			tinsert( velStack, 1, 0 )
		end

		self._tmpTouchEvt = evt
		self._didBegin = true
		self._scaleBase = self._scale
		self:gotoState( ScaleMotion.STATE_TOUCH )

		self:_dispatchBeginZoom()

	end

	if not self._didBegin then return end

	if phase == 'moved' then

		local tmpTouchEvt = self._tmpTouchEvt
		local constrain = ScaleMotion._constrainScale
		local scale = event.value

		local deltaVal = event.value - tmpTouchEvt.value
		local deltaT = event.time - tmpTouchEvt.time
		local oldVal, newVal

		self._isMoving = true

		--== Calculate new scale/velocity

		oldVal = self._scale
		newVal = constrain( self, self._scale, deltaVal*0.4 )
		self:_updateVelocity( (oldVal-newVal)/deltaT )

		self._scale = newVal
		self._tmpTouchEvt = evt

	elseif phase=='ended' or phase=='cancelled' then

		self._tmpTouchEvt = evt
		self._didBegin = false

		local next_state, next_params = self:_getNextState{ event=event }
		self:gotoState( next_state, next_params )

	end

end



--====================================================================--
--== State Machine


function ScaleMotion:_getNextState( params )
	-- print( "ScaleMotion:_getNextState" )
	params = params or {}
	--==--
	local scaleLimit = self._scaleLimit
	local velocity = self._velocity
	local isBounceActive = self._bounceIsActive
	local s, p -- state, params

	-- print( "gNS>>", velocity.value, scaleLimit, isBounceActive )

	if velocity.value > 0 and not scaleLimit then
		s = ScaleMotion.STATE_DECELERATE
		p = { event=params.event }

	elseif velocity.value <= 0 and scaleLimit and isBounceActive then
		s = ScaleMotion.STATE_RESTORE
		p = { event=params.event }

	elseif velocity.value > 0 and scaleLimit and isBounceActive then
		s = ScaleMotion.STATE_RESTRAINT
		p = { event=params.event }

	else
		s = ScaleMotion.STATE_AT_REST
		p = { event=params.event }

	end

	return s, p
end


--== State Create

function ScaleMotion:state_create( next_state, params )
	-- print( "ScaleMotion:state_create: >> ", next_state )

	if next_state == ScaleMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		pwarn( sfmt( "ScaleMotion:state_create unknown state transition '%s'", tstr( next_state )))
	end
end


--== State At-Rest

function ScaleMotion:do_state_at_rest( params )
	-- print( "ScaleMotion:do_state_at_rest", params )
	params = params or {}
	--==--
	local vel = self._velocity
	vel.value, vel.vector = 0, 0
	self._isMoving = false

	self._enterFrameIterator = nil
	Runtime:removeEventListener( 'enterFrame', self )

	self:setState( ScaleMotion.STATE_AT_REST )
	self:_dispatchEndZoom()
end

function ScaleMotion:state_at_rest( next_state, params )
	-- print( "ScaleMotion:state_at_rest: >> ", next_state )

	if next_state == ScaleMotion.STATE_TOUCH then
		self:do_state_touch( params )

	else
		pwarn( sfmt( "ScaleMotion:state_at_rest unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Touch

function ScaleMotion:do_state_touch( params )
	-- print( "ScaleMotion:do_state_touch" )
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
	self:setState( ScaleMotion.STATE_TOUCH )
end

function ScaleMotion:state_touch( next_state, params )
	-- print( "ScaleMotion:state_touch: >> ", next_state )

	if next_state == ScaleMotion.STATE_RESTORE then
		self:do_state_restore( params )

	elseif next_state == ScaleMotion.STATE_RESTRAINT then
		self:do_state_restraint( params )

	elseif next_state == ScaleMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == ScaleMotion.STATE_DECELERATE then
		self:do_state_decelerate( params )

	else
		pwarn( sfmt( "ScaleMotion:state_touch unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Decelerate

function ScaleMotion:do_state_decelerate( params )
	-- print( "ScaleMotion:do_state_decelerate" )
	params = params or {}
	--==--
	local TIME = ScaleMotion.DECELERATE_TRANS_TIME
	local constrain = ScaleMotion._constrainScale
	local ease_f = easingx.easeOutQuad
	local _mabs = mabs

	local startEvt = params.event
	local vel = self._velocity
	local velocity = vel.value
	local deltaVel = -velocity

	self._isMoving = true

	local enterFrameFunc = function( e )
		-- print( "ScaleMotion: enterFrameFunc: do_state_decelerate" )

		local frameEvt = self._tmpFrameEvent or startEvt -- none yet: ended in the frame it began
		local scrollLimit = self._scaleLimit

		local deltaStart = e.time - startEvt.time
		local deltaFrame = e.time - frameEvt.time
		local deltaVal, oldVal, newVal

		--== Calculation

		vel.value = ease_f( deltaStart, TIME, velocity, deltaVel )
		deltaVal = vel.value * vel.vector * deltaFrame

		--== Action

		oldVal = self._scale
		newVal = constrain( self, oldVal, deltaVal )
		self._scale = newVal

		if vel.value > 0 and scrollLimit then
			-- hit edge while moving
			self:gotoState( ScaleMotion.STATE_RESTRAINT, { event=e } )

		elseif deltaStart >= TIME or _mabs( newVal-oldVal ) < 1 then
			-- over time or movement too small to see (pixel)
			self:gotoState( ScaleMotion.STATE_AT_REST )

		end

	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( ScaleMotion.STATE_DECELERATE )

end

function ScaleMotion:state_decelerate( next_state, params )
	-- print( "ScaleMotion:state_decelerate: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == self.STATE_RESTRAINT then
		self:do_state_restraint( params )

	else
		pwarn( sfmt( "ScaleMotion:state_decelerate unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Restore

function ScaleMotion:do_state_restore( params )
	-- print( "ScaleMotion:do_state_restore" )
	params = params or {}
	--==--
	local TIME = ScaleMotion.RESTORE_TRANS_TIME
	local constrain = ScaleMotion._constrainScale
	local ease_f = easingx.easeOut

	local startEvt = params.event
	local val = self._scale
	local vel = self._velocity

	local delta, offset

	-- calculate restore distance
	if self._scaleLimit == ScaleMotion.HIT_UPPER_LIMIT then
		offset = self._maxZoom
	else
		offset = self._minZoom
	end
	delta = offset-val

	self._isMoving = true

	local enterFrameFunc = function( e )
		-- print( "ScaleMotion: enterFrameFunc: do_state_restore " )

		--== Calculation

		local deltaT = e.time - startEvt.time
		local deltaV = ease_f( deltaT, TIME, val, delta )

		--== Action

		if deltaT < TIME then
			self._scale = deltaV
		else
			self._scale = offset
			self:gotoState( ScaleMotion.STATE_AT_REST )
		end
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( ScaleMotion.STATE_RESTORE )
end

function ScaleMotion:state_restore( next_state, params )
	-- print( "ScaleMotion:state_restore: >> ", next_state )

	if next_state == ScaleMotion.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == ScaleMotion.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		pwarn( sfmt( "ScaleMotion:state_restore unknown state transition '%s'", tstr( next_state )))
	end

end


--== State Restraint

-- when object has velocity and hit limit
-- we constrain its motion away from limit
--
function ScaleMotion:do_state_restraint( params )
	-- print( "ScaleMotion:do_state_restraint" )
	params = params or {}
	--==--
	local TIME = ScaleMotion.RESTRAINT_TRANS_TIME
	local constrain = ScaleMotion._constrainScale
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
		-- print( "ScaleMotion: enterFrameFunc: do_state_restraint" )

		local frameEvt = self._tmpFrameEvent or startEvt -- none yet: ended in the frame it began

		local deltaStart = e.time - startEvt.time -- total
		local deltaFrame = e.time - frameEvt.time
		local deltaVal, oldVal, newVal

		--== Calculation

		vel.value = ease_f( deltaStart, TIME, velocity, deltaVel )
		deltaVal = vel.value * deltaFrame

		--== Action

		oldVal = self._scale
		newVal = constrain( self, oldVal, deltaVal )
		self._scale = newVal

		if deltaStart >= TIME or _mabs( newVal-oldVal ) < 1 then
			vel.value, vel.vector = 0, 0
			self:gotoState( ScaleMotion.STATE_RESTORE, { event=e } )

		end

	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( ScaleMotion.STATE_RESTRAINT )
end

function ScaleMotion:state_restraint( next_state, params )
	-- print( "ScaleMotion:state_restraint: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_RESTORE then
		self:do_state_restore( params )

	else
		pwarn( sfmt( "ScaleMotion:state_restraint unknown state transition '%s'", tstr( next_state )))
	end

end




return ScaleMotion
