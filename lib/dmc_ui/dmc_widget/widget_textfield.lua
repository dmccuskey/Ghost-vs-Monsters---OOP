--====================================================================--
-- dmc_ui/dmc_widget/widget_textfield.lua
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
--== DMC Corona UI : TextField Widget
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
--== DMC UI : newTextField
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local wUtils = require( ui_find( 'ui_utils' ) )

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )



--====================================================================--
--== Setup, Constants


local tcancel = timer.cancel
local tdelay = timer.performWithDelay

-- a tap on the widget stays with it: Solar2D sends 'tap' apart from
-- 'touch', and it would reach what lies behind the widget
local function tapBlock_handler( event )
	return true
end

--== To be set in initialize()
local dUI = nil
local Widget = nil



--====================================================================--
--== TextField Widget Class
--====================================================================--


--- TextField Widget Module.
-- a widget used to allow input from a user.
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- **Style Object:** <br>
-- * @{Style.TextField}
--
-- @classmod Widget.TextField
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newTextField()

local TextField = newClass( WidgetBase, {name="TextField"} )

--- Constants
-- @section

--== Class Constants

TextField._START_FOCUS_TIMER = nil
TextField._STOP_FOCUS_TIMER = nil
TextField._FOCUS_COUNT = 0


-- alignment
TextField.LEFT = 'left'
TextField.CENTER = 'center'
TextField.RIGHT = 'right'

-- background styles
TextField.BORDER_STYLE_NONE = 'border-style-none'
TextField.BORDER_STYLE_LINE = 'border-style-line'
TextField.BORDER_STYLE_ROUNDED = 'border-style-rounded'
TextField.BORDER_IMAGE = 'border-style-rounded'

-- keyboard

--- defines default Keyboard input type.
-- set input type using styles (inline, style, or direct)
-- @usage
-- widget.style.inputType = widget.INPUT_DEFAULT

TextField.INPUT_DEFAULT = 'default'

--- defines decimal Keyboard input type.
-- set input type using styles (inline, style, or direct)
-- @usage
-- widget.style.inputType = widget.INPUT_DECIMAL

TextField.INPUT_DECIMAL = 'decimal'

TextField.INPUT_EMAIL = 'email'
TextField.INPUT_NUMBER = 'number'
TextField.INPUT_PASSWORD = 'password'
TextField.INPUT_PHONE = 'phone'
TextField.INPUT_URL = 'url'

-- return key
TextField.RETURN_DEFAULT = 'default'
TextField.RETURN_DONE = 'done'
TextField.RETURN_EMERGENCY = 'emergencyCall'
TextField.RETURN_GO = 'go'
TextField.RETURN_JOIN = 'join'
TextField.RETURN_NEXT = 'next'
TextField.RETURN_NONE = 'none'
TextField.RETURN_ROUTE = 'route'
TextField.RETURN_SEARCH = 'search'
TextField.RETURN_SEND = 'send'

-- visual styles
TextField.STYLE_DEFAULT = 'default'
TextField.STYLE_DISABLED = 'disabled'
TextField.STYLE_INVALID = 'invalid'

TextField.TOP = 'top'
TextField.BOTTOM = 'bottom'

--== Style/Theme Constants

TextField.STYLE_CLASS = nil -- added later
TextField.STYLE_TYPE = uiConst.TEXTFIELD

-- TODO: hook up later
-- Text.DEFAULT = 'default'

-- Text.THEME_STATES = {
-- 	Text.DEFAULT,
-- }

--== Event Constants

TextField.EVENT = 'userInput'

TextField.BEGAN = 'began'
TextField.ENDED = 'ended'
TextField.SUBMITTED = 'submitted'
TextField.EDITING = 'editing'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function TextField:__init__( params )
	-- print( "TextField:__init__", params, self )
	params = params or {}
	if params.text==nil then params.text="" end
	if params.hintText==nil then params.hintText="" end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._displayText = params.text
	self._displayText_dirty=true
	self._hintText = params.hintText
	self._hintText_dirty=true

	self._isWidgetEnabled = true

	self._isEditActive = { state=false, setFocus=nil }
	self._isEditActive_dirty = true

	self._clearOnBeginEdit = false
	self._adjustFontToFit = false
	self._clearButtonMode = 'never'

	self._keyboardFocus=false
	self._keyboardFocus_dirty=true
	self._hasKeyboardFocus=false -- holds one of dUI's focus counts

	-- properties stored in Style

	self._align_dirty=true
	self._backgroundStyle_dirty=true
	self._inputType_dirty=true
	self._isHitActive_dirty=true
	self._isSecure_dirty=true
	self._marginX_dirty=true
	self._marginY_dirty=true
	self._returnKey_dirty=true

	-- "Virtual" properties

	self._widgetStyle_dirty=true
	self._wgtBgStyle_dirty=true

	self._wgtTextFont_dirty=true
	self._wgtTextFontSize_dirty=true
	self._wgtTextHeight_dirty=true
	self._wgtTextIsSecure_dirty=true
	self._wgtTextStyle_dirty=true
	self._wgtTextText_dirty=true

	self._inputFieldX_dirty=true
	self._inputFieldY_dirty=true
	self._inputFieldAlign_dirty=true
	self._inputFieldFont_dirty=true
	self._inputFieldFontSize_dirty=true
	self._inputFieldWidth_dirty=true
	self._inputFieldHeight_dirty=true
	self._inputFieldMarginX_dirty=true
	self._inputFieldIsSecure_dirty=true
	self._inputFieldStyle_dirty=true
	self._inputFieldText_dirty=true
	self._inputFieldTextColor_dirty=true

	--== Object References ==--

	self._rctHit = nil -- our rectangle hit area
	self._rctHit_f = nil

	self._wgtBg = nil -- background widget
	self._wgtBg_dirty=true

	self._wgtText = nil -- text widget (for both hint and value display)
	self._wgtText_f = nil -- widget handler
	self._wgtText_dirty=true

	self._inputField = nil -- textfield object
	self._inputField_f = nil -- textfield handler
	self._inputField_dirty=true
end

--[[
function TextField:__undoInit__()
	-- print( "TextField:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]


--== createView

function TextField:__createView__()
	-- print( "TextField:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o = display.newRect( 0,0,0,0 )
	o.anchorX, o.anchorY = 0.5,0.5
	o.isHitTestable=true
	self:insert( o )
	self._rctHit = o
end

function TextField:__undoCreateView__()
	-- print( "TextField:__undoCreateView__" )
	self._rctHit:removeSelf()
	self._rctHit=nil
	--==--
	self:superCall( '__undoCreateView__' )
end


--== initComplete

function TextField:__initComplete__()
	-- print( "TextField:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self._rctHit_f = self:createCallback( self._hitAreaTouch_handler )
	self._rctHit:addEventListener( 'touch', self._rctHit_f )
	self._rctHit:addEventListener( 'tap', tapBlock_handler )

	self._inputField_f = self:createCallback( self._textFieldEvent_handler )
	self._textStyle_f = self:createCallback( self.textStyleChange_handler )
	self._wgtText_f = self:createCallback( self._wgtTextWidgetUpdate_handler )

	self:_stopEdit(false)
end

function TextField:__undoInitComplete__()
	--print( "TextField:__undoInitComplete__" )
	self:_removeTextField()
	self:_removeText()
	self:_removeBackground()

	self:_stopKeyboardFocus()

	self._textStyle_f = nil
	self._inputField_f = nil

	self._rctHit:removeEventListener( 'tap', tapBlock_handler )
	self._rctHit:removeEventListener( 'touch', self._rctHit_f )
	self._rctHit_f = nil
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function TextField.initialize( manager )
	-- print( "TextField.initialize" )
	dUI = manager
	Widget = dUI.Widget

	local Style = dUI.Style
	TextField.STYLE_CLASS = Style.TextField

	Style.registerWidget( TextField )
end



--====================================================================--
--== Public Methods


--== .backgroundStyle

--- get a reference to Background Style object.
-- use this reference to change properties for the Background substyle
--
-- @within Properties
-- @function .backgroundStyle
--
-- @usage
-- style = widget.backgroundStyle
-- style.anchorX = 0.5

function TextField.__getters:backgroundStyle()
	return self.curr_style.background
end

--== .displayStyle

--- get a reference to the Display Text Style object.
-- use this reference to change properties for the Text substyle
--
-- @within Properties
-- @function .displayStyle
--
-- @usage
-- style = widget.displayStyle
-- style.anchorX = 0.5

function TextField.__getters:displayStyle()
	return self.curr_style.display
end

--== .hintStyle

--- get a reference to the Hint Text Style object.
-- use this reference to change properties for the Text substyle
--
-- @within Properties
-- @function .hintStyle
--
-- @usage
-- style = widget.hintStyle
-- style.anchorX = 0.5

function TextField.__getters:hintStyle()
	return self.curr_style.hint
end

--== .align

--- set/get align.
-- values are 'left', 'center', 'right'
--
-- @within Properties
-- @function .align
-- @usage widget.align = 'center'
-- @usage print( widget.align )

TextField.__getters.align = WidgetHelp.__getters.align
TextField.__setters.align = WidgetHelp.__setters.align

--== .delegate

--- set/get delegate for item.
--
-- @within Properties
-- @function .delegate
-- @usage widget.delegate = <delegate object>
-- @usage print( widget.delegate )

TextField.__getters.delegate = WidgetHelp.__getters.delegate
TextField.__setters.delegate = WidgetHelp.__setters.delegate

--== .hintText

--- set/get hintText.
-- set the text when the "hint" is visible.
--
-- @within Properties
-- @function .hintText
-- @usage widget.hintText = "Enter an email"
-- @usage print( widget.hintText )

function TextField.__getters:hintText()
	return self._hintText
end
function TextField.__setters:hintText( value )
	-- print( "TextField.__setters:hintText", value )
	if value == self._hintText then return end
	self._hintText = value
	self._hintText_dirty=true
	self:__invalidateProperties__()
end

--== .inputType

--- get editing state for TextField.
-- returns true if the TextField is currently displaying the input field.
--
-- @within Properties
-- @function .inputType
-- @treturn string
-- @usage widget.inputType = o.INPUT_EMAIL
-- @usage print( widget.inputType )

function TextField.__getters:inputType()
	return self.curr_style.inputType
end
function TextField.__setters:inputType( value, params )
	-- print( "TextField.__setters:inputType", value )
	self.curr_style.inputType = value
end

--== .isEditing

--- get editing state for TextField.
-- returns true if the TextField is currently displaying the input field.
--
-- @within Properties
-- @function .isEditing
-- @treturn bool
-- @usage print( widget.isEditing )

function TextField.__getters:isEditing()
	return self._isEditActive.state
end

--== .isHitActive

--- set state of touch-activity.
-- set true if the TextField editing is enabled.
--
-- @within Properties
-- @function .isHitActive
-- @usage widget.isHitActive = true

function TextField.__getters:isHitActive()
	return self.curr_style.isHitActive
end
function TextField.__setters:isHitActive( value, params )
	-- print( "TextField.__setters:isHitActive", value )
	self.curr_style.isHitActive = value
end

--== .isSecure

--- set/get password display.
-- set to true to change TextField to mask the text entered.
--
-- @within Properties
-- @function .isSecure
-- @usage widget.isSecure = true
-- @usage print( widget.isSecure )

function TextField.__getters:isSecure()
	return self.curr_style.isSecure
end
function TextField.__setters:isSecure( value )
	-- print( "TextField.__setters:isSecure", value )
	self.curr_style.isSecure = value
end

--== .marginX

--- set/get marginX.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginX
-- @usage widget.marginX = 18
-- @usage print( widget.marginX )

TextField.__getters.marginX = WidgetHelp.__getters.marginX
TextField.__setters.marginX = WidgetHelp.__setters.marginX

--== .marginY

--- set/get marginY.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginY
-- @usage widget.marginY = 18
-- @usage print( widget.marginY )

TextField.__getters.marginY = WidgetHelp.__getters.marginY
TextField.__setters.marginY = WidgetHelp.__setters.marginY

--== .text

--- set/get input text for TextWidget.
--
-- @within Properties
-- @function .text
-- @usage widget.text = "input field text"
-- @usage print( widget.text )

function TextField.__getters:text()
	-- while editing, the text in the native field
	if self._tmp_text~=nil then return self._tmp_text end
	return self._displayText
end
function TextField.__setters:text( value )
	-- print( "TextField.__setters:text", value )
	assert( type(value)=='string' )
	--==--
	if value == self._displayText then return end
	self._displayText = value
	self._displayText_dirty=true
	self:__invalidateProperties__()
end



--== :setEditActive()

--- activate editing mode for TextField.
--
-- @within Methods
-- @function :setEditActive
--
-- @tparam bool value true if
-- @tab[opt] params table of optional parameters
-- @tparam[opt=true] bool params.setFocus set focus on the text field
-- @usage widget:setEditActive( true, { setFocus=true })

function TextField:setEditActive( value, params )
	-- print( "TextField:setEditActive", value )
	params = params or {}
	if params.setFocus==nil then params.setFocus=true end
	assert( type(value)=='boolean' )
	--==--
	params.state=value
	self._isEditActive = params
	self._isEditActive_dirty=true
	self:__invalidateProperties__()
end

--== :setKeyboardFocus()

--- set keyboard cursor-focus on this TextField.
-- this starts editing and shows the keyboard.
--
-- @within Methods
-- @function :setKeyboardFocus
-- @usage widget:setKeyboardFocus()

function TextField:setKeyboardFocus()
	-- print( "TextField:setKeyboardFocus" )
	-- already editing: the native field has the focus (focusing it
	-- again ends and restarts the edit in the Simulator)
	if self._isEditActive.state then return end
	-- show the native field, which takes the focus
	self:_startEdit( true )
end

--== :unsetKeyboardFocus()

--- remove keyboard cursor-focus on this TextField.
-- this will hide the keyboard.
--
-- @within Methods
-- @function :unsetKeyboardFocus

function TextField:unsetKeyboardFocus()
	-- print( "TextField:unsetKeyboardFocus" )
	self._keyboardFocus = false
	self._keyboardFocus_dirty = true
	self:__invalidateProperties__()
end

--== setReturnKey()

--- set the keyboard's Return Key.
-- the same as setting the style's `returnKey`.
-- @within Methods
-- @function :setReturnKey

function TextField:setReturnKey( value )
	-- print( "TextField:setReturnKey", value )
	assert( type(value)=='string' )
	--==--
	self.curr_style.returnKey = value
end


--======================================================--
-- Hint Style Properties

-- .hintFont  TODO: move to style
--
function TextField.__setters:hintFont( value )
	-- print( "TextField.__setters:hintFont", value )
	self.curr_style.hint.font = value
end

-- .hintFontSize
--
function TextField.__setters:hintFontSize( value )
	-- print( "TextField.__setters:hintFontSize", value )
	self.curr_style.hint.fontSize = value
end

-- setHintTextColor()
--
function TextField:setHintTextColor( ... )
	-- print( "TextField:setHintTextColor" )
	self.curr_style.hintTextColor = {...}
end


--======================================================--
-- Display Style Properties

-- .displayFont -- TODO move to stlye
--
function TextField.__setters:displayFont( value )
	-- print( "TextField.__setters:displayFont", value )
	self.curr_style.displayFont = value
end

-- .displayFontSize
--
function TextField.__setters:displayFontSize( value )
	-- print( "TextField.__setters:displayFontSize", value )
	self.curr_style.displayFontSize = value
end

-- setDisplayTextColor()
--
function TextField:setDisplayTextColor( ... )
	-- print( "TextField:setDisplayTextColor" )
	self.curr_style.displayTextColor = {...}
end


--======================================================--
-- Delegate


--== :shouldChangeCharacters()

-- this is so TextField can answer Delegate questions
-- without assigned delegate
--
function TextField:shouldChangeCharacters( event )
	return true
end

-- on tap
function TextField:_delegateShouldChangeCharacters( event )
	-- print("TextField:_delegateShouldChangeCharacters")
	local delegate = self._delegate
	if not delegate or not delegate.shouldChangeCharacters then
		delegate = self
	end
	local evt = {
		target = self,
		startPosition=event.startPosition,
		newCharacters=event.newCharacters,
		numDeleted=event.numDeleted,
		text=event.text,
	}
	return delegate:shouldChangeCharacters( evt )
end


--== :shouldBeginEditing()

-- this is so TextField can answer Delegate questions
-- without assigned delegate
--
function TextField:shouldBeginEditing()
	return self._isWidgetEnabled
end

-- on tap
function TextField:_delegateShouldBeginEditing()
	local delegate = self._delegate
	if not delegate or not delegate.shouldBeginEditing then
		delegate = self
	end
	return delegate:shouldBeginEditing( self )
end


--== :shouldEndEditing()

-- this is so TextField can answer Delegate questions
-- without assigned delegate
--
function TextField:shouldEndEditing( event )
	return true
end

-- after end/submit
function TextField:_delegateShouldEndEditing()
	local delegate = self._delegate
	if not delegate or not delegate.shouldEndEditing then
		delegate = self
	end
	return delegate:shouldEndEditing( self )
end


--== :shouldClearTextField()

-- this is so TextField can answer Delegate questions
-- without assigned delegate
--
function TextField:shouldClearTextField()
	return true
end

-- on button press
function TextField:_delegateShouldClearTextField()
	local delegate = self._delegate
	if not delegate or not delegate.shouldClearTextField then
		delegate = self
	end
	return delegate:shouldClearTextField( self )
end



--======================================================--
-- Theme Methods

-- afterAddStyle()
--
function TextField:afterAddStyle()
	-- print( "TextField:afterAddStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end

-- beforeRemoveStyle()
--
function TextField:beforeRemoveStyle()
	-- print( "TextField:beforeRemoveStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end



--====================================================================--
--== Private Methods


function TextField:_makeTextSecure( text )
	if self.curr_style.isSecure then
		text = string.rep( '•', #text )
	end
	return text
end


--== Create/Destroy Background Widget

function TextField:_removeBackground()
	-- print( "TextField:_removeBackground" )
	local o = self._wgtBg
	if not o then return end
	o:removeSelf()
	self._wgtBg = nil
end

function TextField:_createBackground()
	-- print( "TextField:_createBackground" )

	self:_removeBackground()

	local o = Widget.newBackground{
		defaultStyle = self.defaultStyle.background
	}
	self:insert( o.view )
	self._wgtBg = o

	--== Reset properties

	self._wgtBgStyle_dirty=true
end


--== Create/Destroy Text Widget

function TextField:_removeText()
	-- print( "TextField:_removeText" )
	local o = self._wgtText
	if not o then return end
	o.onUpdate=nil
	o:removeSelf()
	self._wgtText = nil
end

function TextField:_createText()
	-- print( "TextField:_createText" )

	self:_removeText()

	local o = Widget.newText{
		defaultStyle = self.defaultStyle.display
	}
	o.onUpdate = self._wgtText_f
	self:insert( o.view )
	self._wgtText = o

	--== Reset properties

	self._wgtTextStyle_dirty=true
	self._isEditActive_dirty=true
end



function TextField:_removeTextField()
	-- print( "TextField:_removeTextField" )
	local o = self._inputField
	if not o then return end
	o:removeEventListener( 'userInput', self._inputField_f )
	o:removeSelf()
	self._inputField = nil
end

function TextField:_createTextField()
	-- print( "TextField:_createTextField" )
	local style = self.curr_style
	local text = self._wgtText
	local o -- object

	self:_removeTextField()

	local height = text:getTextHeight()
	if not height or height <=0 then
		height = style.height
	end
	local w, h = style.width, height
	w = w - style.marginX*2

	o = native.newTextField(0,0,w,h)
	self:insert( o )
	o.isFontSizeScaled=true
	o:addEventListener( 'userInput', self._inputField_f )
	self._inputField = o

	--== Reset properties

	self._hasBackground_dirty=true
	self._inputType_dirty=true
	self._isEditActive_dirty=true
	self._keyboardFocus_dirty=true
	self._returnKey_dirty=true

	self._inputFieldX_dirty=true
	self._inputFieldY_dirty=true
	self._inputFieldAlign_dirty=true
	self._inputFieldFont_dirty=true
	self._inputFieldFontSize_dirty=true
	self._inputFieldIsSecure_dirty=true
	self._inputFieldStyle_dirty=true
	self._inputFieldText_dirty=true
	self._inputFieldTextColor_dirty=true

end


function TextField:__commitProperties__()
	-- print( "TextField:__commitProperties__" )

	--== Update Widget Components ==--

	if self._wgtBg_dirty then
		self:_createBackground()
		self._wgtBg_dirty = false
	end

	if self._wgtText_dirty then
		self:_createText()
		self._wgtText_dirty=false

		self._inputFieldHeight_dirty=true
	end

	if self._inputField_dirty then
		self:_createTextField()
		self._inputField_dirty=false
	end


	--== Update Widget View ==--

	local style = self.curr_style
	local view = self.view
	local hit = self._rctHit
	local bg = self._wgtBg
	local text = self._wgtText
	local input = self._inputField

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
		local width = style.width
		hit.width = width
		self._width_dirty=false

		self._inputFieldX_dirty=true
		self._inputFieldWidth_dirty=true
	end
	if self._height_dirty then
		local height = style.height
		hit.height = height
		self._height_dirty=false

		self._inputFieldY_dirty=true
	end

	-- align

	if self._align_dirty then
		self._align_dirty = false

		self._inputFieldX_dirty=true
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		hit.anchorX = style.anchorX
		self._anchorX_dirty = false

		self._inputFieldX_dirty=true
	end
	if self._anchorY_dirty then
		hit.anchorY = style.anchorY
		self._anchorY_dirty = false

		self._inputFieldY_dirty=true
	end

	-- marginX/marginY

	if self._marginX_dirty then
		self._marginX_dirty = false

		self._inputFieldX_dirty=true
		self._inputFieldMarginX_dirty=true
	end
	if self._marginY_dirty then
		self._marginY_dirty = false
	end

	-- inputType

	if self._inputType_dirty then
		if style.inputType==TextField.INPUT_PASSWORD then
			input.inputType = TextField.INPUT_DEFAULT
			style.isSecure=true
		else
			input.inputType = style.inputType
		end

		self._isSecure_dirty=true
		self._inputType_dirty=false
	end

	-- returnKey

	if self._returnKey_dirty then
		if input.setReturnKey then input:setReturnKey( style.returnKey ) end
		self._returnKey_dirty=false
	end

	-- isSecure

	if self._isSecure_dirty then
		self._isSecure_dirty=false

		self._wgtTextIsSecure_dirty=true
		self._inputFieldIsSecure_dirty=true
	end

	--== Virtual

	if self._widgetStyle_dirty then
		self._widgetStyle_dirty=false

		self._wgtBgStyle_dirty=true
		self._wgtTextStyle_dirty=true
		self._inputFieldStyle_dirty=true
	end

	if self._displayText_dirty then
		self._displayText_dirty=false

		self._wgtTextText_dirty=true
		self._wgtTextStyle_dirty=true
		self._inputFieldText_dirty=true
	end

	if self._hintText_dirty then
		self._hintText_dirty=false

		self._wgtTextText_dirty=true
		self._wgtTextStyle_dirty=true
	end

	if self._inputFieldIsSecure_dirty then
		-- this next line makes simulator edit field
		input.isSecure = style.isSecure
		-- so we force to inactive
		self:setEditActive( false )
		self._inputFieldIsSecure_dirty=false
	end


	if self._isEditActive_dirty then
		local is_editing = self._isEditActive
		local edit, setFocus = is_editing.state, is_editing.setFocus
		text.isVisible=not edit
		input.isVisible=edit
		if setFocus then
			local focus = input
			if not edit then focus=nil end
			if focus then
				self:_startKeyboardFocus( focus )
			else
				self:_stopKeyboardFocus()
			end
			-- native.setKeyboardFocus( focus )
		end
		self._isEditActive_dirty=false
	end


	--== Set Styles

	if self._wgtBgStyle_dirty then
		bg:setActiveStyle( style.background, {copy=false} )
		self._wgtBgStyle_dirty=false
	end

	if self._wgtTextText_dirty or self._wgtTextStyle_dirty or self._wgtTextIsSecure_dirty then

		if self._displayText=="" then
			text.text=self._hintText
			text:setActiveStyle( style.hint, {copy=false} )
		else
			text.text=self:_makeTextSecure( self._displayText )
			text:setActiveStyle( style.display, {copy=false} )
		end
		-- draw it now, not on the next frame: at the end of an edit
		-- this update also shows the text again, and for a frame it
		-- would show what it held before (the hint)
		text:__validate__()

		self._wgtTextText_dirty=false
		self._wgtTextStyle_dirty=false
		self._wgtTextIsSecure_dirty=false
	end

	--== Hit

	if self._wgtTextHeight_dirty then
		self._wgtTextHeight_dirty=false

		self._inputFieldHeight_dirty=true
	end

	--== Input Widget

	-- style

	if self._inputFieldStyle_dirty then
		style.display.onPropertyChange = self._textStyle_f
		style.display:resetProperties()
		self._inputFieldStyle_dirty=false
	end

	if self._inputFieldWidth_dirty or self._inputFieldMarginX_dirty then
		local width = style.width
		local marginX = style.marginX
		input.width = width - marginX*2
		self._inputFieldWidth_dirty=false
		self._inputFieldMarginX_dirty=false
	end

	if self._inputFieldHeight_dirty then
		input.height = text:getTextHeight()
		self._inputFieldHeight_dirty=false
	end

	-- X/Y

	if self._inputFieldX_dirty then
		local align = style.align
		local marginX = style.marginX
		local offset
		if align==self.LEFT then
			input.anchorX = 0
			offset = -style.width*(style.anchorX)+marginX
			input.x=offset
		elseif align==self.RIGHT then
			input.anchorX = 1
			offset = style.width*(1-style.anchorX)-marginX
			input.x=offset
		else
			input.anchorX = 0.5
			offset = style.width*(0.5-style.anchorX)
			input.x=offset
		end
		self._inputFieldX_dirty = false
	end
	if self._inputFieldY_dirty then
		local height = style.height
		input.y=height/2+(-height*style.anchorY)
		self._inputFieldY_dirty=false
	end

	-- align

	if self._inputFieldAlign_dirty then
		input.align=style.align
		self._inputFieldAlign_dirty = false
	end

	-- font

	if self._inputFieldFont_dirty or self._inputFieldFontSize_dirty then
		local font = style.display.font
		local fontSize = style.display.fontSize
		local sFontSize = wUtils.getNativeFontSize( font, fontSize )
		input.font=native.newFont( font, sFontSize )
		self._inputFieldFont_dirty=false
		self._inputFieldFontSize_dirty=false
	end

	-- hasBackground

	if self._hasBackground_dirty then
		-- hard-code, no background
		-- TEST – false/(true)
		input.hasBackground=false
		self._hasBackground_dirty = false
	end

	-- keyboardFocus

	if self._keyboardFocus_dirty then
		local focus = nil
		if self._keyboardFocus==true then
			focus = input
		end
		if focus then
			self:_startKeyboardFocus( focus )
		else
			self:_stopKeyboardFocus()
		end
		self._keyboardFocus_dirty=false
	end

	-- text

	if self._inputFieldText_dirty then
		-- input.text=self:_makeTextSecure( self._displayText )
		input.text=self._displayText
		self._inputFieldText_dirty=false
	end

	-- textColor

	if self._inputFieldTextColor_dirty then
		input:setTextColor( unpack( style.display.textColor ) )
		self._inputFieldTextColor_dirty=false
	end

	-- debug on

	if self._debugOn_dirty then
		if style.debugOn==true then
			hit:setFillColor( 1,1,0,0.3 )
		else
			hit:setFillColor( 0,0,0,0 )
		end
		self._debugOn_dirty=false
	end

end


-- each field holds at most one of dUI's focus counts, and gives back only
-- its own: creating or removing a field leaves another one's edit alone
function TextField:_startKeyboardFocus( focus )
	-- print( "TextField:_startKeyboardFocus", self.id )
	if self._hasKeyboardFocus then
		native.setKeyboardFocus( focus )
		return
	end
	self._hasKeyboardFocus = true
	dUI.setKeyboardFocus( focus )
end

function TextField:_stopKeyboardFocus()
	-- print( "TextField:_stopKeyboardFocus", self.id )
	if not self._hasKeyboardFocus then return end
	self._hasKeyboardFocus = false
	dUI.unsetKeyboardFocus()
end


function TextField:_startEdit( setFocus )
	-- print( "TextField:_startEdit", setFocus, self.id )
	if setFocus==nil then setFocus=true end
	--==--
	self:setEditActive( true, {setFocus=setFocus} )
end

function TextField:_stopEdit( setFocus )
	-- print( "TextField:_stopEdit", setFocus, self.id )
	if setFocus==nil then setFocus=false end
	--==--
	self:setEditActive( false, {setFocus=setFocus} )
end


function TextField:_dispatchStateBegan( event )
	-- print( "TextField:_dispatchStateBegan", event )

	-- start last ok state: the native field's text (event.text is
	-- broken in the simulator)
	local text = event.target.text
	if text==nil then text=self._displayText end
	self._tmp_text = text

	event.target=self
	event.text=text
	self:dispatchEvent( event )
end

function TextField:_dispatchStateEditing( event )
	-- print( "TextField:_dispatchStateEditing", event )

	self._tmp_text = event.text -- save for last ok state

	event.target=self
	self:dispatchEvent( event )
end

function TextField:_dispatchStateEnded( event )
	-- print( "TextField:_dispatchStateEnded", event )
	self._tmp_text = nil

	event.target=self
	event.text=self._displayText
	self:dispatchEvent( event )
end



--====================================================================--
--== Event Handlers


function TextField:_hitAreaTouch_handler( e )
	-- print( "TextField:_hitAreaTouch_handler", e.phase, self.id )
	local phase = e.phase
	local background = e.target

	if not self.curr_style.isHitActive then return true end

	if phase=='began' then
		display.getCurrentStage():setFocus( background )
		self._has_focus = true
		return true
	end

	if not self._has_focus then return false end

	local bgCb = background.contentBounds
	local isWithinBounds =
		( bgCb.xMin <= e.x and bgCb.xMax >= e.x
			and bgCb.yMin <= e.y and bgCb.yMax >= e.y )

	if phase=='ended' or phase=='cancelled' then
		display.getCurrentStage():setFocus( nil )
		self._has_focus = false

		if isWithinBounds and self:_delegateShouldBeginEditing() then
			self:_startEdit()
		end
	end

	return true
end


-- _textFieldEvent_handler()
-- capture events from our Text Field object
--
function TextField:_textFieldEvent_handler( event )
	-- print( "TextField:_textFieldEvent_handler", event.phase )
	local phase = event.phase
	local textfield = event.target -- Corona TextField

	if phase==TextField.BEGAN then
		-- print( "text", event.text )
		self:_dispatchStateBegan( event )

	elseif phase==TextField.EDITING then
		--[[
		print( "start", event.startPosition )
		print( "delete", event.numDeleted )
		print( "new", event.newCharacters )
		print( "text", event.text )
		--]]
		if self:_delegateShouldChangeCharacters( event ) then
			self:_dispatchStateEditing( event )
		else
			textfield.text = self._tmp_text
		end

	elseif phase==TextField.ENDED or phase==TextField.SUBMITTED then
		if self:_delegateShouldEndEditing( event ) then
			self.text = textfield.text -- << Use Setter
			self:_stopEdit( false )
			self:unsetKeyboardFocus()
			self:_dispatchStateEnded( event )
		elseif phase==TextField.ENDED then
			-- keep editing: take back the focus it lost
			-- (on 'submitted' the field still has it)
			self:_startKeyboardFocus( textfield )
		end

	end
end


-- _wgtTextWidgetUpdate_handler()
-- the native field takes the height of the text widget
--
function TextField:_wgtTextWidgetUpdate_handler( event )
	-- print( "TextField:_wgtTextWidgetUpdate_handler", event.type )
	local widget = event.target
	local etype = event.type

	-- Utils.print( event )

	if etype==widget.LIFECYCLE_UPDATED then
		self._wgtTextHeight_dirty=true
		self:__invalidateProperties__()
	end
end


--[[
we set this one up because the style 'text' isn't handed
to another widget to handle, we are doing it ourselves
in this widget
--]]

-- textStyleChange_handler()
--
function TextField:textStyleChange_handler( event )
	-- print( "TextField:textStyleChange_handler", event.property )
	local style = event.target
	local etype = event.type
	local property = event.property
	local value = event.value

	-- print( "Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty = true

		self._inputFieldX_dirty=true
		self._inputFieldY_dirty=true

		-- self._inputFieldWidth_dirty=true
		-- self._inputFieldHeight_dirty=true

		self._inputFieldAlign_dirty=true
		-- self._inputFieldAnchorX_dirty=true
		-- self._inputFieldAnchorY_dirty=true
		self._inputFieldFont_dirty=true
		self._inputFieldFontSize_dirty=true
		-- self._inputFieldMarginX_dirty=true
		-- self._inputFieldMarginY_dirty=true
		self._inputFieldText_dirty=true --ok
		self._inputFieldTextColor_dirty=true --ok


		property = etype

	else
		if property=='debugOn' then
			self._debugOn_dirty=true

		elseif property=='width' then
			-- self._inputFieldWidth_dirty=true
		elseif property=='height' then
			-- self._inputFieldHeight_dirty=true

		elseif property=='align' then
			self._inputFieldAlign_dirty=true
		elseif property=='anchorX' then
			-- self._inputFieldAnchorX_dirty=true
		elseif property=='anchorY' then
			-- self._inputFieldAnchorY_dirty=true
		elseif property=='font' then
			self._inputFieldFont_dirty=true
		elseif property=='fontSize' then
			self._inputFieldFontSize_dirty=true
		elseif property=='marginX' then
			-- self._inputFieldMarginX_dirty=true
		elseif property=='marginY' then
			-- self._inputFieldMarginY_dirty=true
		elseif property=='text' then
			self._inputFieldText_dirty=true
		elseif property=='textColor' then
			self._inputFieldTextColor_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end


-- stylePropertyChangeHandler()
-- this is the standard property event handler
-- needed by any DMC Widget
-- it listens for changes in the Widget Style Object
-- and reponds with the appropriate message
--
function TextField:stylePropertyChangeHandler( event )
	-- print( "TextField:stylePropertyChangeHandler", event.property, event.value )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- Utils.print( event )

	-- print( "TF Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty = true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._align_dirty=true
		self._backgroundStyle_dirty=true
		self._inputType_dirty=true
		self._isHitActive_dirty=true
		self._isSecure_dirty=true
		self._marginX_dirty=true
		self._marginY_dirty=true
		self._returnKey_dirty=true

		self._wgtText_dirty=true
		-- self._wgtTextTextColor_dirty=true

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
		elseif property=='backgroundStyle' then
			self._backgroundStyle_dirty=true
		elseif property=='inputType' then
			self._inputType_dirty=true
		elseif property=='isHitActive' then
			self._isHitActive_dirty=true
		elseif property=='isSecure' then
			self._isSecure_dirty=true
		elseif property=='marginX' then
			self._marginX_dirty=true
		elseif property=='marginY' then
			self._marginY_dirty=true
		elseif property=='returnKey' then
			self._returnKey_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return TextField
