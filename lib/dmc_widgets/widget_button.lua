--====================================================================--
-- dmc_widgets/widget_button.lua
--
-- Documentation: http://docs.davidmccuskey.com/
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014-2015 David McCuskey

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
--== DMC Corona Widgets : Widget Button
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--


local dmc_widget_data, dmc_widget_func
dmc_widget_data = _G.__dmc_widget
dmc_widget_func = dmc_widget_data.func



--====================================================================--
--== DMC Widgets : newButton
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local StatesMixModule = require 'dmc_states_mix'

--== Components

local BaseView = require( dmc_widget_func.find( 'widget_button.view_base' ) )
local ImageView = require( dmc_widget_func.find( 'widget_button.view_image' ) )
local NineSliceView = require( dmc_widget_func.find( 'widget_button.view_9slice' ) )
local ShapeView = require( dmc_widget_func.find( 'widget_button.view_shape' ) )



--====================================================================--
--== Setup, Constants


local StatesMix = StatesMixModule.StatesMix

-- setup some aliases to make code cleaner
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local LOCAL_DEBUG = false



--====================================================================--
--== Support Functions


local function getViewTypeClass( params )
	-- print( "getViewTypeClass", params, params.view )
	params = params or {}
	--==--

	if type( params.view ) == 'table' and params.view.new then
		return params.view

	elseif params.view == NineSliceView.TYPE then
		return NineSliceView

	elseif params.view == ShapeView.TYPE then
		return ShapeView

	elseif params.view == ImageView.TYPE then
		return ImageView

	else -- text view
		return BaseView

	end
end



--====================================================================--
--== Button Widget Class
--====================================================================--


local ButtonBase = newClass( { ComponentBase, StatesMix }, {name="Button Base"}  )

--== Class Constants

ButtonBase._SUPPORTED_VIEWS = { 'active', 'inactive', 'disabled' }

--== Class States

ButtonBase.STATE_INIT = 'state_init'
ButtonBase.STATE_ACTIVE = 'state_active'
ButtonBase.STATE_INACTIVE = 'state_inactive'
ButtonBase.STATE_DISABLED = 'state_disabled'

ButtonBase.ACTIVE = ButtonBase.STATE_ACTIVE
ButtonBase.INACTIVE = ButtonBase.STATE_INACTIVE
ButtonBase.DISABLED = ButtonBase.STATE_DISABLED

--== Class events

ButtonBase.EVENT = 'button-event'

ButtonBase.PRESSED = 'pressed'
ButtonBase.RELEASED = 'released'


--======================================================--
-- Start: Setup DMC Objects

function ButtonBase:__init__( params )
	-- print( "ButtonBase:__init__", params )
	params = params or {}
	self:superCall( ComponentBase, '__init__', params )
	self:superCall( StatesMix, '__init__', params )
	--==--

	--== Sanity Check ==--

	if self.is_class then return end

	assert( params.width and params.height, "newButton: expected params 'width' and 'height'" )

	--== Create Properties ==--

	self._params = params -- save for view creation

	self._id = params.id
	self._value = params.value

	self._width = params.width
	self._height = params.height

	-- the hit area of the button
	self._hit_width = params.hit_width or params.width
	self._hit_height = params.hit_height or params.height

	self._class = getViewTypeClass( params )
	self._views = {} -- holds individual view objects

	self._callbacks = {
		onPress = params.onPress,
		onRelease = params.onRelease,
		onEvent = params.onEvent,
	}

	--== Display Groups ==--

	self._dg_views = nil -- to put button views in display hierarchy


	-- set initial state
	self:setState( ButtonBase.STATE_INIT )

end

function ButtonBase:__undoInit__()
	-- print( "ButtonBase:__undoInit__" )

	self._callbacks = nil
	self._views = nil

	--==--
	self:superCall( ComponentBase, '__undoInit__' )
	self:superCall( StatesMix, '__undoInit__' )
end


-- __createView__()
--
function ButtonBase:__createView__()
	-- print( "ButtonBase:__createView__" )
	self:superCall( ComponentBase, '__createView__' )
	--==--

	local o, p, dg  -- object, display group

	--== hit area
	o = display.newRect(0, 0, self._hit_width, self._hit_height)
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(0,0.3,0,0.5)
	end
	o.isHitTestable = true
	o.anchorX, o.anchorY = 0.5, 0.5

	self.view:insert( o )
	self._bg_hit = o

	--== display group for button views
	dg = display.newGroup()
	self.view:insert( dg )
	self._dg_views = dg

	--== create individual button views

	for _, name in ipairs( self._SUPPORTED_VIEWS ) do
		self._params.name = name
		o = self._class:new( self._params )
		dg:insert( o.view )
		self._views[ name ] = o
	end
	self._params.name = nil

end

function ButtonBase:__undoCreateView__()
	-- print( "ButtonBase:__undoCreateView__" )

	local o

	for name, view in pairs( self._views ) do
		view:removeSelf()
		self._views[ name ] = nil
	end

	o = self._dg_views
	o:removeSelf()
	self._dg_views = nil

	o = self._bg_hit
	o:removeSelf()
	self._bg_hit = nil

	--==--
	self:superCall( ComponentBase, '__undoCreateView__' )
end


-- __initComplete__()
--
function ButtonBase:__initComplete__()
	-- print( "ButtonBase:__initComplete__" )
	self:superCall( ComponentBase, '__initComplete__' )
	--==--

	local is_active = self._params.is_active == nil and false or self._params.is_active
	local o

	o = self._bg_hit
	o._f = self:createCallback( self._hitareaTouch_handler )
	o:addEventListener( 'touch', o._f )

	if is_active then
		self:gotoState( ButtonBase.STATE_ACTIVE )
	else
		self:gotoState( ButtonBase.STATE_INACTIVE )
	end

	self._params = nil -- get rid of temp structure
end

function ButtonBase:__undoInitComplete__()
	--print( "ButtonBase:__undoInitComplete__" )

	o = self._bg_hit
	o:removeEventListener( 'touch', o._f )
	o._f = nil

	--==--
	self:superCall( ComponentBase, '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function ButtonBase.__getters:is_enabled()
	return ( self:getState() ~= self.STATE_DISABLED )
end
function ButtonBase.__setters:is_enabled( value )
	assert( type(value)=='boolean', "newButton: expected boolean for property 'enabled'")
	--==--
	if self.is_enabled == value then return end

	if value == true then
		self:gotoState( ButtonBase.STATE_INACTIVE, { is_enabled=value } )
	else
		self:gotoState( ButtonBase.STATE_DISABLED, { is_enabled=value } )
	end
end

function ButtonBase.__getters:is_active()
	return ( self:getState() == self.STATE_ACTIVE )
end

function ButtonBase.__setters:is_active( value )
	print( "ButtonBase.__setters:is_active", value )
	if value then
		self:gotoState( self.STATE_ACTIVE )
	else
		self:gotoState( self.STATE_INACTIVE )
	end
end


function ButtonBase.__getters:id()
	return self._id
end
function ButtonBase.__setters:id( value )
	assert( type(value)=='string' or type(value)=='nil', "expected string or nil for button id")
	self._id = value
end


function ButtonBase.__setters:onPress( value )
	assert( type(value)=='function' or type(value)=='nil', "expected function or nil for onPress")
	self._callbacks.onPress = value
end
function ButtonBase.__setters:onRelease( value )
	assert( type(value)=='function' or type(value)=='nil', "expected function or nil for onRelease")
	self._callbacks.onRelease = value
end
function ButtonBase.__setters:onEvent( value )
	assert( type(value)=='function' or type(value)=='nil', "expected function or nil for onEvent")
	self._callbacks.onEvent = value
end


function ButtonBase.__getters:value()
	return self._value
end
function ButtonBase.__setters:value( value )
	self._value = value
end


function ButtonBase.__getters:views()
	return self._views
end

-- Method to programmatically press the button
--
function ButtonBase:press()
	local bounds = self.contentBounds
	-- setup fake touch event
	local evt = {
		target=self.view,
		x=bounds.xMin,
		y=bounds.yMin,
	}

	evt.phase = 'began'
	self:_hitareaTouch_handler( evt )
	evt.phase = 'ended'
	self:_hitareaTouch_handler( evt )
end



--====================================================================--
--== Private Methods


-- dispatch 'press' events
--
function ButtonBase:_doPressEventDispatch()
	-- print( "ButtonBase:_doPressEventDispatch" )

	if not self.is_enabled then return end

	local cb = self._callbacks
	local event = {
		name=self.EVENT,
		phase=self.PRESSED,
		target=self,
		id=self._id,
		value=self._value,
		state=self:getState()
	}

	if cb.onPress then cb.onPress( event ) end
	if cb.onEvent then cb.onEvent( event ) end
	self:dispatchEvent( event )
end

-- dispatch 'release' events
--
function ButtonBase:_doReleaseEventDispatch()
	-- print( "ButtonBase:_doReleaseEventDispatch" )

	if not self.is_enabled then return end

	local cb = self._callbacks
	local event = {
		name=self.EVENT,
		phase=self.RELEASED,
		target=self,
		id=self._id,
		value=self._value,
		state=self:getState()
	}

	if cb.onRelease then cb.onRelease( event ) end
	if cb.onEvent then cb.onEvent( event ) end
	self:dispatchEvent( event )
end


--======================================================--
-- START: State Machine

--== State: Init

function ButtonBase:state_init( next_state, params )
	-- print( "ButtonBase:state_init >>", next_state )
	params = params or {}
	--==--

	if next_state == ButtonBase.STATE_ACTIVE then
		self:do_state_active( params )

	elseif next_state == ButtonBase.STATE_INACTIVE then
		self:do_state_inactive( params )

	elseif next_state == ButtonBase.STATE_DISABLED then
		self:do_state_disabled( params )

	else
		print( "WARNING :: WebSocket:state_create " .. tostring( next_state ) )
	end
end

--== State: Active

function ButtonBase:do_state_active( params )
	-- print( "ButtonBase:do_state_active" )
	params = params or {}
	params.set_state = params.set_state == nil and true or params.set_state
	--==--
	local views = self._views

	views.inactive.isVisible = false
	views.active.isVisible = true
	views.disabled.isVisible = false

	if params.set_state == true then
		self:setState( ButtonBase.STATE_ACTIVE )
	end
end

function ButtonBase:state_active( next_state, params )
	-- print( "ButtonBase:state_active >>", next_state )
	params = params or {}
	--==--

	if next_state == ButtonBase.STATE_ACTIVE then
		self:do_state_active( params )

	elseif next_state == ButtonBase.STATE_INACTIVE then
		self:do_state_inactive( params )

	elseif next_state == ButtonBase.STATE_DISABLED then
		self:do_state_disabled( params )

	else
		print( "WARNING :: WebSocket:state_create " .. tostring( next_state ) )
	end
end

--== State: Inactive

function ButtonBase:do_state_inactive( params )
	-- print( "ButtonBase:do_state_inactive" )
	params = params or {}
	params.set_state = params.set_state == nil and true or params.set_state
	--==--
	local views = self._views

	views.inactive.isVisible = true
	views.active.isVisible = false
	views.disabled.isVisible = false

	if params.set_state == true then
		self:setState( ButtonBase.STATE_INACTIVE )
	end
end

function ButtonBase:state_inactive( next_state, params )
	-- print( "ButtonBase:state_inactive >>", next_state )
	params = params or {}
	--==--

	if next_state == ButtonBase.STATE_ACTIVE then
		self:do_state_active( params )

	elseif next_state == ButtonBase.STATE_INACTIVE then
		self:do_state_inactive( params )

	elseif next_state == ButtonBase.STATE_DISABLED then
		self:do_state_disabled( params )

	else
		print( "WARNING :: WebSocket:state_create " .. tostring( next_state ) )
	end
end

--== State: Disabled

function ButtonBase:do_state_disabled( params )
	-- print( "ButtonBase:do_state_disabled" )
	params = params or {}
	--==--
	local views = self._views

	views.inactive.isVisible = false
	views.active.isVisible = false
	views.disabled.isVisible = true

	self:setState( ButtonBase.STATE_DISABLED )
end

--[[
params.is_enabled is to make sure that we have been enabled
since someone else might ask us to change state eg, to ACTIVE
when we are disabled (like a button group)
--]]
function ButtonBase:state_disabled( next_state, params )
	-- print( "ButtonBase:state_disabled >>", next_state )
	params = params or {}
	params.is_enabled = params.is_enabled == nil and false or params.is_enabled
	--==--
	--

	if next_state == ButtonBase.STATE_ACTIVE and params.is_enabled == true then
		self:do_state_active( params )

	elseif next_state == ButtonBase.STATE_INACTIVE and params.is_enabled == true then
		self:do_state_inactive( params )

	elseif next_state == ButtonBase.STATE_DISABLED then
		self:do_state_disabled( params )

	else
		print( "WARNING :: WebSocket:state_create " .. tostring( next_state ) )
	end
end

-- END: State Machine
--======================================================--



--====================================================================--
--== Event Handlers


-- none



--===================================================================--
--== Push Button Class
--===================================================================--


local PushButton = newClass( ButtonBase, {name="Push Button"} )

PushButton.TYPE = 'push'


--======================================================--
-- Start: Setup DMC Objects

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function PushButton:_hitareaTouch_handler( event )
	-- print( "PushButton:_hitareaTouch_handler", event.phase )

	if not self.is_enabled then return true end

	local target = event.target
	local bounds = target.contentBounds
	local x,y = event.x,event.y
	local is_bounded =
		( x >= bounds.xMin and x <= bounds.xMax and
		y >= bounds.yMin and y <= bounds.yMax )

	if event.phase == 'began' then
		display.getCurrentStage():setFocus( target )
		self._has_focus = true
		self:gotoState( self.STATE_ACTIVE )
		self:_doPressEventDispatch()

		return true
	end

	if not self._has_focus then return end

	if event.phase == 'moved' then
		if is_bounded then
			self:gotoState( self.STATE_ACTIVE )
		else
			self:gotoState( self.STATE_INACTIVE )
		end

	elseif event.phase == 'ended' or event.phase == 'cancelled' then
		display.getCurrentStage():setFocus( nil )
		self._has_focus = false
		self:gotoState( self.STATE_INACTIVE )

		if is_bounded then
			self:_doReleaseEventDispatch()
		end
	end

	return true
end



--===================================================================--
--== Toggle Button Class
--===================================================================--


local ToggleButton = newClass( ButtonBase, {name="Toggle Button"}  )

ToggleButton.TYPE = 'toggle'


--======================================================--
-- Start: Setup DMC Objects

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


function ToggleButton:_getNextState()
	-- print( "ToggleButton:_getNextState" )
	if self:getState() == self.STATE_ACTIVE then
		return self.STATE_INACTIVE
	else
		return self.STATE_ACTIVE
	end
end



--====================================================================--
--== Event Handlers


function ToggleButton:_hitareaTouch_handler( event )
	-- print( "ToggleButton:_hitareaTouch_handler", event.phase )

	if not self.is_enabled then return true end

	local target = event.target
	local bounds = target.contentBounds
	local x,y = event.x,event.y
	local is_bounded =
		( x >= bounds.xMin and x <= bounds.xMax and
		y >= bounds.yMin and y <= bounds.yMax )
	local curr_state = self:getState()
	local next_state = self:_getNextState()

	if event.phase == 'began' then
		display.getCurrentStage():setFocus( target )
		self._has_focus = true
		self:gotoState( next_state, { set_state=false } )
		self:_doPressEventDispatch()

		return true
	end

	if not self._has_focus then return end

	if event.phase == 'moved' then
		if is_bounded then
			self:gotoState( next_state, { set_state=false } )
		else
			self:gotoState( curr_state, { set_state=false } )
		end

	elseif event.phase == 'ended' or event.phase == 'cancelled' then
		display.getCurrentStage():setFocus( nil )
		self._has_focus = false
		if is_bounded then
			self:gotoState( next_state )
			self:_doReleaseEventDispatch()
		else
			self:gotoState( curr_state )
		end

	end

	return true
end



--===================================================================--
--== Radio Button Class
--===================================================================--


local RadioButton = newClass( ToggleButton, {name="Radio Button"} )

RadioButton.TYPE = 'radio'


--======================================================--
-- Start: Setup DMC Objects

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


function RadioButton:_getNextState()
	-- print( "RadioButton:_getNextState" )
	return self.STATE_ACTIVE
end



--====================================================================--
--== Event Handlers


-- none



--===================================================================--
--== Button Factory
--===================================================================--


local Buttons = {}

-- export class instantiations for direct access
Buttons.ButtonBase = ButtonBase
Buttons.PushButton = PushButton
Buttons.ToggleButton = ToggleButton
Buttons.RadioButton = RadioButton

-- Button factory method

function Buttons.create( params )
	-- print( "Buttons.create", params.type )
	assert( params.type, "newButton: expected param 'type'" )
	--==--
	if params.type == PushButton.TYPE then
		return PushButton:new( params )

	elseif params.type == RadioButton.TYPE then
		return RadioButton:new( params )

	elseif params.type == ToggleButton.TYPE then
		return ToggleButton:new( params )

	else
		error( "newButton: unknown button type: " .. tostring( params.type ) )

	end
end


return Buttons

