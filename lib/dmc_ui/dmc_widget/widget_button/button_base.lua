--====================================================================--
-- dmc_widget/widget_button.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
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
--== DMC Corona UI : Widget Button
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI : newButton
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local StatesMixModule = require 'dmc_states_mix'
-- local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )



--====================================================================--
--== Setup, Constants


-- a tap on the widget stays with it: Solar2D sends 'tap' apart from
-- 'touch', and it would reach what lies behind the widget
local function tapBlock_handler( event )
	return true
end

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Button Widget Class
--====================================================================--


--- Base Class for Button Widgets.
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- **Style Object:** <br>
-- * @{Style.Button}
--
-- @classmod Widget.Button.Base
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newButton()

local ButtonBase = newClass( WidgetBase, { name="Button Base" } )

StatesMixModule.patch( ButtonBase )

--- Class Constants.
-- @section

--== Class Constants

ButtonBase._SUPPORTED_VIEWS = { 'active', 'inactive', 'disabled' }

--== State Constants

ButtonBase.STATE_INIT = 'state_init'
ButtonBase.STATE_INACTIVE = 'state_inactive'
ButtonBase.STATE_ACTIVE = 'state_active'
ButtonBase.STATE_DISABLED = 'state_disabled'

ButtonBase.INACTIVE = ButtonBase.STATE_INACTIVE
ButtonBase.ACTIVE = ButtonBase.STATE_ACTIVE
ButtonBase.DISABLED = ButtonBase.STATE_DISABLED

--== Style/Theme Constants

ButtonBase.STYLE_CLASS = nil -- added later
ButtonBase.STYLE_TYPE = uiConst.BUTTON

--== Event Constants

ButtonBase.EVENT = 'button-event'

ButtonBase.PRESSED = 'pressed'
ButtonBase.RELEASED = 'released'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function ButtonBase:__init__( params )
	-- print( "ButtonBase:__init__", params )
	params = params or {}
	if params.id==nil then params.id="" end
	if params.labelText==nil then params.labelText="OK" end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._id = params.id
	self._id_dirty=true

	self._labelText = params.labelText
	self._labelText_dirty=true

	self._data = params.data

	-- properties stored in Style

	self._align_dirty=true
	self._hitMarginX_dirty=true
	self._hitMarginY_dirty=true
	self._isHitActive_dirty=true
	self._marginX_dirty=true
	self._marginY_dirty=true
	self._offsetX_dirty=true
	self._offsetY_dirty=true

	-- "Virtual" properties

	self._widgetState_dirty=true
	self._widgetViewState = nil
	self._widgetViewState_dirty=true

	self._hitAreaX_dirty=true
	self._hitAreaY_dirty=true
	self._hitAreaAnchorX_dirty=true
	self._hitAreaAnchorY_dirty=true
	self._hitAreaWidth_dirty=true
	self._hitAreaHeight_dirty=true
	self._hitAreaMarginX_dirty=true
	self._hitAreaMarginY_dirty=true

	self._displayText_dirty=true

	self._callbacks = {
		onPress = params.onPress,
		onRelease = params.onRelease,
		onEvent = params.onEvent,
	}

	--== Object References ==--

	self._rctHit = nil -- our rectangle hit area
	self._rctHit_f = nil

	self._wgtBg = nil -- background widget
	self._wgtBg_dirty=true

	self._wgtText = nil -- text widget (for both hint and value display)
	self._wgtText_f = nil -- widget handler
	self._wgtText_dirty=true

	-- set initial state
	self:setState( ButtonBase.STATE_INIT )

end

--[[
function ButtonBase:__undoInit__()
	-- print( "ButtonBase:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]


--== createView

function ButtonBase:__createView__()
	-- print( "ButtonBase:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o = display.newRect( 0,0,0,0 )
	o.anchorX, o.anchorY = 0.5,0.5
	o.isHitTestable=true
	self._dgBg:insert( o )
	self._rctHit = o
end

function ButtonBase:__undoCreateView__()
	-- print( "ButtonBase:__undoCreateView__" )
	self._rctHit:removeSelf()
	self._rctHit=nil
	--==--
	self:superCall( '__undoCreateView__' )
end


--== initComplete

function ButtonBase:__initComplete__()
	-- print( "ButtonBase:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self._rctHit_f = self:createCallback( self._hitAreaTouch_handler )
	self._rctHit:addEventListener( 'touch', self._rctHit_f )
	self._rctHit:addEventListener( 'tap', tapBlock_handler )

	-- self._textStyle_f = self:createCallback( self.textStyleChange_handler )
	-- self._wgtText_f = self:createCallback( self._wgtTextWidgetUpdate_handler )

	self.id = self._id
	self.labelText = self._labelText

	if self.isActive then
		self:gotoState( ButtonBase.STATE_ACTIVE )
	else
		self:gotoState( ButtonBase.STATE_INACTIVE )
	end
end

function ButtonBase:__undoInitComplete__()
	--print( "ButtonBase:__undoInitComplete__" )
	self:_removeBackground()
	self:_removeText()

	self._rctHit:removeEventListener( 'tap', tapBlock_handler )
	self._rctHit:removeEventListener( 'touch', self._rctHit_f )
	self._rctHit_f = nil
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Functions


function ButtonBase.initialize( manager )
	-- print( "ButtonBase.initialize", manager )
	dUI = manager

end


--====================================================================--
--== Public Methods


--== hitMarginX

--- set/get x-axis hit margin.
-- increases horizontal hit area for button, useful when button area is small. value must be greater or equal to 0.
--
-- @within Properties
-- @function .hitMarginX
-- @usage widget.hitMarginX = 5
-- @usage print( widget.hitMarginX )

function ButtonBase.__getters:hitMarginX()
	-- print( "ButtonBase.__getters:hitMarginX" )
	return self.curr_style.hitMarginX
end
function ButtonBase.__setters:hitMarginX( value )
	-- print( "ButtonBase.__setters:hitMarginX", value )
	self.curr_style.hitMarginX = value
end

--== hitMarginY

--- set/get y-axis hit margin.
-- increases vertical hit area for button, useful when button area is small. value must be greater or equal to 0.
--
-- @within Properties
-- @function .hitMarginY
-- @usage widget.hitMarginY = 5
-- @usage print( widget.hitMarginY )

function ButtonBase.__getters:hitMarginY()
	-- print( "ButtonBase.__getters:hitMarginY" )
	return self.curr_style.hitMarginY
end
function ButtonBase.__setters:hitMarginY( value )
	-- print( "ButtonBase.__setters:hitMarginY", value, self )
	self.curr_style.hitMarginY = value
end

--== .isHitActive

--- set/get button press *action*.
-- this gets the *action* of the button, whether a press is handled or not. a disabled button ignores presses whatever this value.
--
-- @within Properties
-- @function .isHitActive
-- @usage widget.isHitActive = false
-- @usage print( widget.isHitActive )

function ButtonBase.__getters:isHitActive()
	-- print( "ButtonBase.__getters:isHitActive" )
	return self.curr_style.isHitActive
end
function ButtonBase.__setters:isHitActive( value )
	-- print( "ButtonBase.__setters:isHitActive", value )
	self.curr_style.isHitActive = value
end

--== .labelText

--- set/get text for button label.
--
-- @within Properties
-- @function .labelText
-- @usage widget.labelText = "Press"
-- @usage print( widget.labelText )

function ButtonBase.__getters:labelText()
	return self._labelText
end
function ButtonBase.__setters:labelText( value )
	-- print( "ButtonBase.__setters:labelText", value )
	assert( type(value)=='string' )
	--==--
	if value == self._labelText then return end
	self._labelText = value
	self._labelText_dirty=true
	self:__invalidateProperties__()
end


--======================================================--
-- Children Style Accessors

--- get Style object for Active state.
--
-- @within Properties
-- @function .activeStyle
-- @usage print( widget.activeStyle )

function ButtonBase.__getters:activeStyle()
	return self.curr_style.active
end

--- get Style object for Disabled state.
--
-- @within Properties
-- @function .disabledStyle
-- @usage print( widget.disabledStyle )

function ButtonBase.__getters:disabledStyle()
	return self.curr_style.disabled
end

--- get Style object for Inactive state.
--
-- @within Properties
-- @function .inactiveStyle
-- @usage print( widget.inactiveStyle )

function ButtonBase.__getters:inactiveStyle()
	return self.curr_style.inactive
end


--== :setHitMargin

--- set hit margin for button.
-- this is a convenience method to set hit margins at same time. args can be two integers or a table as array. (there is no difference with this or the properties)
-- @within Methods
-- @function setHitMargin
-- @usage print( widget:setHitMargin( 5, 0 ) )
-- @usage print( widget:setHitMargin( { 2, 3 } ) )

function ButtonBase:setHitMargin( ... )
	-- print( 'ButtonBase:setHitMargin' )
	local args = {...}

	if type( args[1] ) == 'table' then
		self.hitMarginX, self.hitMarginY = unpack( args[1] )
	end
	if type( args[1] ) == 'number' then
		self.hitMarginX = args[1]
	end
	if type( args[2] ) == 'number' then
		self.hitMarginY = args[2]
	end
end


--======================================================--
-- Button Methods

--- set/get button id.
-- optional id value for button. this value is passed in during button events, making it easy to differentiate buttons.
-- @within Properties
-- @function .id
-- @usage widget.id = 'left-button'
-- @usage print( widget.id )

function ButtonBase.__getters:id()
	return self._id
end
function ButtonBase.__setters:id( value )
	assert( type(value)=='string' or type(value)=='nil', "Button.id expected string or nil for button id")
	self._id = value
end

--- get button 'active' state.
-- check whether button is in 'active' state.
-- @within Properties
-- @function .isActive
-- @usage print( widget.isActive )

function ButtonBase.__getters:isActive()
	return ( self:getState() == self.STATE_ACTIVE )
end

--- set/get whether button is 'disabled' or can be pressed/activated.
-- property to set button disabled state or to see if it's enabled. this sets both the *look* of the button and the button action; it leaves the style's .isHitActive as is.
-- @within Properties
-- @function .isEnabled
-- @usage widget.isEnabled = false
-- @usage print( widget.isEnabled )

function ButtonBase.__getters:isEnabled()
	return ( self:getState() ~= ButtonBase.STATE_DISABLED )
end
function ButtonBase.__setters:isEnabled( value )
	assert( type(value)=='boolean', "newButton: expected boolean for property 'enabled'")
	--==--
	if value == self.isEnabled then return end

	if value == true then
		self:gotoState( ButtonBase.STATE_INACTIVE, { isEnabled=value } )
	else
		self:gotoState( ButtonBase.STATE_DISABLED, { isEnabled=value } )
	end
end

--- set callback for onPress events.
--
-- @within Properties
-- @function .onPress
-- @usage widget.onPress = <function>

function ButtonBase.__setters:onPress( value )
	assert( type(value)=='function' or type(value)=='nil', "onPress expected function or nil")
	self._callbacks.onPress = value
end

--- set callback for onRelease events.
--
-- @within Properties
-- @function .onRelease
-- @usage widget.onRelease = <function>

function ButtonBase.__setters:onRelease( value )
	assert( type(value)=='function' or type(value)=='nil', "onRelease expected function or nil")
	self._callbacks.onRelease = value
end

--- set callback for onEvent events.
--
-- @within Properties
-- @function .onEvent
-- @usage widget.onEvent = <function>

function ButtonBase.__setters:onEvent( value )
	assert( type(value)=='function' or type(value)=='nil', "onEvent expected function or nil")
	self._callbacks.onEvent = value
end

--== .data

--- set/get user data for button.
-- convenient storage area for user data. this property is availble within button events.
-- @within Properties
-- @function .data
-- @usage widget.data = 5
-- @usage print( widget.data )

function ButtonBase.__getters:data()
	return self._data
end
function ButtonBase.__setters:data( value )
	self._data = value
end


--- programmatically "press" a button.
-- this will fire both 'began' and 'ended' events.
-- @within Methods
--
-- @function press
-- @usage widget:press()

function ButtonBase:press()
	local bounds = self.contentBounds
	-- setup fake touch event
	local evt = {
		target=self.view,
		x=bounds.xMin,
		y=bounds.yMin,
	}

	evt.phase = 'began'
	self:_hitAreaTouch_handler( evt )
	if not self.view then return end -- removed in a callback
	evt.phase = 'ended'
	self:_hitAreaTouch_handler( evt )
end


--======================================================--
-- Theme Methods

-- afterAddStyle()
--
function ButtonBase:afterAddStyle()
	-- print( "ButtonBase:afterAddStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end

-- beforeRemoveStyle()
--
function ButtonBase:beforeRemoveStyle()
	-- print( "ButtonBase:beforeRemoveStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end



--====================================================================--
--== Private Methods


-- presses are handled when the button is enabled and its style's
-- isHitActive is true
--
function ButtonBase:_isPressable()
	return ( self.isEnabled and self.curr_style.isHitActive==true )
end

-- release the touch focus, eg when a button is disabled while pressed
--
function ButtonBase:_dropFocus()
	if self._has_focus then
		display.getCurrentStage():setFocus( nil )
		self._has_focus = false
	end
	return true
end


-- show a state's look without entering the state, eg while a touch
-- is down: the button's own state changes when the touch ends on it
--
function ButtonBase:_showState( state )
	if self._widgetViewState==state then return end
	self._widgetViewState = state
	self._widgetViewState_dirty = true
	self:__invalidateProperties__()
end


-- dispatch 'press' events
--
-- a callback may remove the button (eg, one which closes its dialog):
-- the view is then gone, the rest isn't called and the focus is released
--
-- TODO: use create event
function ButtonBase:_doPressEventDispatch()
	-- print( "ButtonBase:_doPressEventDispatch" )

	if not self.isEnabled then return end

	local cb = self._callbacks
	local event = {
		name=self.EVENT,
		phase=self.PRESSED,
		target=self,
		id=self._id,
		data=self._data,
		state=self:getState()
	}

	if cb.onPress then cb.onPress( event ) end
	if not self.view then return self:_dropFocus() end
	if cb.onEvent then cb.onEvent( event ) end
	if not self.view then return self:_dropFocus() end
	self:dispatchEvent( event )
end

-- dispatch 'release' events
--
function ButtonBase:_doReleaseEventDispatch()
	-- print( "ButtonBase:_doReleaseEventDispatch" )

	if not self.isEnabled then return end

	local cb = self._callbacks
	local event = {
		name=self.EVENT,
		phase=self.RELEASED,
		target=self,
		id=self._id,
		data=self._data,
		state=self:getState()
	}

	if cb.onRelease then cb.onRelease( event ) end
	if not self.view then return self:_dropFocus() end
	if cb.onEvent then cb.onEvent( event ) end
	if not self.view then return self:_dropFocus() end
	self:dispatchEvent( event )
end


--== Create/Destroy Background Widget

function ButtonBase:_removeBackground()
	-- print( "ButtonBase:_removeBackground" )
	local o = self._wgtBg
	if not o then return end
	o:removeSelf()
	self._wgtBg = nil
end

function ButtonBase:_createBackground()
	-- print( "ButtonBase:_createBackground" )

	self:_removeBackground()

	local o = dUI.newBackground{
		defaultStyle = self.defaultStyle.background
	}
	self:insert( o.view )
	self._wgtBg = o

	--== Reset properties

	self._widgetViewState_dirty=true
end


--== Create/Destroy Text Widget

function ButtonBase:_removeText()
	-- print( "ButtonBase:_removeText" )
	local o = self._wgtText
	if not o then return end
	o.onUpdate=nil
	o:removeSelf()
	self._wgtText = nil
end

function ButtonBase:_createText()
	-- print( "ButtonBase:_createText" )

	self:_removeText()

	local o = dUI.newText{
		defaultStyle = self.defaultStyle.label
	}
	o.onUpdate = self._wgtText_f
	self:insert( o.view )
	self._wgtText = o

	--== Reset properties

	self._widgetStyle_dirty=true
	self._isEditActive_dirty=true
	self._labelText_dirty=true
end


function ButtonBase:__commitProperties__()
	-- print( 'ButtonBase:__commitProperties__' )

	--== Update Widget Components ==--

	if self._wgtBg_dirty then
		self:_createBackground()
		self._wgtBg_dirty = false
	end

	if self._wgtText_dirty then
		self:_createText()
		self._wgtText_dirty=false
	end


	--== Update Widget View ==--

	local style = self.curr_style
	-- local state = self:getState()
	local view = self.view
	local hit = self._rctHit
	local bg = self._wgtBg
	local text = self._wgtText

	-- x/y

	if self._x_dirty then
		view.x = self._x
		self._x_dirty=false
	end
	if self._y_dirty then
		view.y = self._y
		self._y_dirty=false
	end

	-- width/height

	if self._width_dirty then
		hit.width = style.width
		self._width_dirty=false

		self._anchorX_dirty=true
		self._hitAreaWidth_dirty=true
	end
	if self._height_dirty then
		hit.height = style.height
		self._height_dirty=false

		self._anchorY_dirty=true
		self._hitAreaHeight_dirty=true
	end

	if self._anchorX_dirty then
		self._anchorX_dirty=false

		self._hitAreaX_dirty=true
	end
	if self._anchorY_dirty then
		self._anchorY_dirty=false

		self._hitAreaY_dirty=true
	end

	if self._hitMarginX_dirty then
		self._hitMarginX_dirty=false

		self._hitAreaMarginX_dirty=true
	end
	if self._hitMarginY_dirty then
		self._hitMarginY_dirty=false

		self._hitAreaMarginY_dirty=true
	end

	if self._labelText_dirty then
		text.text = self._labelText
		self._labelText_dirty=false
	end

	--== Set Styles

	local state = self._widgetViewState
	local stateStyle
	if state==ButtonBase.INACTIVE then
		stateStyle = style.inactive
	elseif state==ButtonBase.ACTIVE then
		stateStyle = style.active
	else
		stateStyle = style.disabled
	end

	if self._widgetStyle_dirty or self._widgetViewState_dirty then
		text:setActiveStyle( stateStyle.label, {copy=false} )
		bg:setActiveStyle( stateStyle.background, {copy=false} )
		-- draw them now, not on the next frame: a state with another
		-- type of background would show no background for a frame
		text:__validate__()
		bg:__validate__()
		self._widgetStyle_dirty=false
		self._widgetViewState_dirty=false
		self._offsetX_dirty=true
		self._offsetY_dirty=true
	end

	-- the state's offset moves the label
	if self._offsetX_dirty then
		text.x = stateStyle.offsetX or 0
		self._offsetX_dirty=false
	end
	if self._offsetY_dirty then
		text.y = stateStyle.offsetY or 0
		self._offsetY_dirty=false
	end

	--== Hit

	if self._hitAreaX_dirty or self._hitAreaAnchorX_dirty then
		local width = style.width
		hit.x = width/2+(-width*style.anchorX)
		self._hitAreaX_dirty=false
		self._hitAreaAnchorX_dirty=false
	end
	if self._hitAreaY_dirty or self._hitAreaAnchorY_dirty then
		local height = style.height
		hit.y = height/2+(-height*style.anchorY)
		self._hitAreaY_dirty=false
		self._hitAreaAnchorY_dirty=false
	end

	if self._hitAreaWidth_dirty or self._hitAreaMarginX_dirty then
		hit.width=style.width+style.hitMarginX*2
		self._hitAreaWidth_dirty=false
		self._hitAreaMarginX_dirty=false
	end
	if self._hitAreaHeight_dirty or self._hitAreaMarginY_dirty then
		hit.height=style.height+style.hitMarginY*2
		self._hitAreaHeight_dirty=false
		self._hitAreaMarginY_dirty=false
	end

	-- debug on

	if self._debugOn_dirty then
		if style.debugOn then
			hit:setFillColor( 1,0,0,0.5 )
		else
			hit:setFillColor( 0,0,0,0 )
		end
		self._debugOn_dirty=false
	end

end



--====================================================================--
--== Event Handlers


-- stylePropertyChangeHandler()
-- this is the standard property event handler
-- needed by any DMC Widget
-- it listens for changes in the Widget Style Object
-- and reponds with the appropriate message
--
function ButtonBase:stylePropertyChangeHandler( event )
	-- print( "ButtonBase:stylePropertyChangeHandler", event.property, event.value )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- Utils.print( event )

	-- print( "Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty=true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._align_dirty=true
		self._hitMarginX_dirty=true
		self._hitMarginY_dirty=true
		self._isHitActive_dirty=true
		self._marginX_dirty=true
		self._marginY_dirty=true
		self._offsetX_dirty=true
		self._offsetY_dirty=true

		self._wgtText_dirty=true
		self._widgetViewState_dirty=true

		property = etype

	else
		if property=='debugOn' then
			self._debugOn_dirty=true
		elseif property=='width' then
			self._width_dirty=true
		elseif property=='height' then
			self._height_dirty=true
		elseif property=='anchorX' then
			self._anchorX_dirty=true
		elseif property=='anchorY' then
			self._anchorY_dirty=true

		elseif property=='align' then
			self._align_dirty=true
		elseif property=='hitMarginX' then
			self._hitMarginX_dirty=true
		elseif property=='hitMarginY' then
			self._hitMarginY_dirty=true
		elseif property=='isHitActive' then
			self._isHitActive_dirty=true
		elseif property=='marginX' then
			self._marginX_dirty=true
		elseif property=='marginY' then
			self._marginY_dirty=true
		elseif property=='offsetX' then
			self._offsetX_dirty=true
		elseif property=='offsetY' then
			self._offsetY_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end



--====================================================================--
--== State Machine


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
		print( "[WARNING] ButtonBase:state_init " .. tostring( next_state ) )
	end
end


--== State: Active

function ButtonBase:do_state_active( params )
	-- print( "ButtonBase:do_state_active" )
	params = params or {}
	params.set_state = params.set_state == nil and true or params.set_state
	--==--
	if params.set_state == true then
		self:setState( ButtonBase.STATE_ACTIVE )
	end
	self._widgetViewState=ButtonBase.STATE_ACTIVE
	self._widgetViewState_dirty=true
	self:__invalidateProperties__()
end

function ButtonBase:state_active( next_state, params )
	-- print( "ButtonBase:state_active >>", next_state )
	params = params or {}
	--==--
	if next_state == ButtonBase.STATE_ACTIVE then
		-- self:do_state_active( params )
	elseif next_state == ButtonBase.STATE_INACTIVE then
		self:do_state_inactive( params )
	elseif next_state == ButtonBase.STATE_DISABLED then
		self:do_state_disabled( params )
	else
		print( "[WARNING] ButtonBase:state_active " .. tostring( next_state ) )
	end
end


--== State: Inactive

function ButtonBase:do_state_inactive( params )
	-- print( "ButtonBase:do_state_inactive" )
	params = params or {}
	params.set_state = params.set_state == nil and true or params.set_state
	--==--
	if params.set_state == true then
		self:setState( ButtonBase.STATE_INACTIVE )
	end
	self._widgetViewState=ButtonBase.STATE_INACTIVE
	self._widgetViewState_dirty=true
	self:__invalidateProperties__()
end

function ButtonBase:state_inactive( next_state, params )
	-- print( "ButtonBase:state_inactive >>", next_state )
	params = params or {}
	--==--
	if next_state == ButtonBase.STATE_ACTIVE then
		self:do_state_active( params )
	elseif next_state == ButtonBase.STATE_INACTIVE then
		-- self:do_state_inactive( params )
	elseif next_state == ButtonBase.STATE_DISABLED then
		self:do_state_disabled( params )
	else
		print( "[WARNING] ButtonBase:state_inactive " .. tostring( next_state ) )
	end
end


--== State: Disabled

function ButtonBase:do_state_disabled( params )
	-- print( "ButtonBase:do_state_disabled" )
	params = params or {}
	--==--
	self:setState( ButtonBase.STATE_DISABLED )
	self._widgetViewState=ButtonBase.STATE_DISABLED
	self._widgetViewState_dirty=true
	self:__invalidateProperties__()
end

--[[
params.isEnabled is to make sure that we have been enabled
since someone else might ask us to change state eg, to ACTIVE
when we are disabled (like a button group)
--]]
function ButtonBase:state_disabled( next_state, params )
	-- print( "ButtonBase:state_disabled >>", next_state )
	params = params or {}
	params.isEnabled = params.isEnabled == nil and false or params.isEnabled
	--==--
	if next_state == ButtonBase.STATE_ACTIVE and params.isEnabled==true then
		self:do_state_active( params )
	elseif next_state == ButtonBase.STATE_INACTIVE and params.isEnabled==true then
		self:do_state_inactive( params )
	elseif next_state == ButtonBase.STATE_DISABLED then
		-- self:do_state_disabled( params )
	else
		print( "[WARNING] ButtonBase:state_disabled " .. tostring( next_state ) )
	end
end




return ButtonBase
