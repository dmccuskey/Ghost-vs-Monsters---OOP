--====================================================================--
-- dmc_widget/widget_style/textfield_style.lua
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
--== DMC Corona UI : TextField Widget Style
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find
local ui_file = dmc_ui_func.file



--====================================================================--
--== DMC UI : newTextFieldStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local BaseStyle = require( ui_find( 'core.style' ) )
local StyleHelp = require( ui_find( 'core.style_helper' ) )



--====================================================================--
--== Setup, Constants


local assert = assert
local sfmt = string.format
local tinsert = table.insert
local type = type

--== To be set in initialize()
local Style = nil



--====================================================================--
--== TextField Style Class
--====================================================================--


--- TextField Style Class.
-- a style object for a TextField View.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.TextField
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newTextFieldStyle()

local TextFieldStyle = newClass( BaseStyle, {name="TextField Style"} )

--- Class Constants.
-- @section

--== Class Constants

TextFieldStyle.TYPE = uiConst.TEXTFIELD

TextFieldStyle.__base_style__ = nil

TextFieldStyle._CHILDREN = {
	background=true,
	hint=true,
	display=true
}

TextFieldStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	align=true,
	backgroundStyle=true,
	inputType=true,
	isHitActive=true,
	isHitTestable=true,
	isSecure=true,
	marginX=true,
	marginY=true,
	returnKey=true,
}

TextFieldStyle._EXCLUDE_PROPERTY_CHECK = {
	background=true,
	hint=true,
	display=true
}

TextFieldStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=300,
	height=40,
	anchorX=0.5,
	anchorY=0.5,

	align='center',
	backgroundStyle='none',
	inputType='default',
	isHitActive=true,
	isSecure=false,
	marginX=10,
	marginY=5,
	returnKey='done',

	background={
		--[[
		Copied from TextField
		* width
		* height
		* anchorX/Y
		--]]
		type='9-slice',
		view={
			sheetInfo=ui_find('theme.default.textfield.textfield-sheet'),
			sheetImage=ui_file('theme/default/textfield/textfield-sheet.png'),
		}
	},
	hint={
		--[[
		Copied from TextField
		* width
		* height
		* align
		* anchorX/Y
		* marginX/Y
		--]]
		fillColor={0,0,0,0},
		font=native.systemFont,
		fontSize=18,
		fontSizeMinimum=0,
		marginX=15,
		textColor={0.47,0.51,0.55,1},
	},
	display={
		--[[
		Copied from TextField
		* width
		* height
		* align
		* anchorX/Y
		* marginX/Y
		--]]
		fillColor={0,0,0,0},
		font=native.systemFont,
		fontSize=18,
		fontSizeMinimum=0,
		marginX=15,
		textColor={0.1,0.1,0.1,1},
	},

}


TextFieldStyle._TEST_DEFAULTS = {
	name='textfield-test-style',
	debugOn=false,
	width=501,
	height=502,
	anchorX=503,
	anchorY=504,

	align='textf-center',
	backgroundStyle='textf-none',
	inputType='textf-default',
	isHitActive=true,
	isSecure=false,
	marginX=510,
	marginY=511,
	returnKey='done',

	background={
		--[[
		Copied from TextField
		* width
		* height
		* anchorX/Y
		--]]
		type='rectangle',
		view={
			fillColor={501,502,503,504},
			strokeWidth=505,
			strokeColor={511,512,513,514},
		}
	},
	hint={
		--[[
		Copied from TextField
		* width
		* height
		* align
		* anchorX/Y
		* marginX/Y
		--]]
		fillColor={521,522,523,524},
		font=native.systemFont,
		fontSize=524,
		fontSizeMinimum=520,
		textColor={523,524,525,526},
	},
	display={
		--[[
		Copied from TextField
		* width
		* height
		* align
		* anchorX/Y
		* marginX/Y
		--]]
		fillColor={531,532,533,534},
		font=native.systemFontBold,
		fontSize=534,
		fontSizeMinimum=523,
		textColor={533,534,535,536},
	},

}

TextFieldStyle.MODE = uiConst.RUN_MODE
TextFieldStyle._DEFAULTS = TextFieldStyle._STYLE_DEFAULTS

--== Event Constants

TextFieldStyle.EVENT = 'textfield-style-event'


--======================================================--
-- Start: Setup DMC Objects

function TextFieldStyle:__init__( params )
	-- print( "TextFieldStyle:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Style Properties ==--

	-- self._data
	-- self._inherit
	-- self._widget
	-- self._parent
	-- self._onProperty

	-- self._name
	-- self._debugOn
	-- self._width
	-- self._height
	-- self._anchorX
	-- self._anchorY

	self._align = nil
	self._bgStyle = nil
	self._inputType = nil
	self._isHitActive = nil
	self._isSecure = nil
	self._marginX = nil
	self._marginY = nil
	self._returnKey = nil

	--== Object Refs ==--

	-- these are other style objects
	self._background = nil -- Background Style
	self._display = nil  -- Text Style
	self._hint = nil  -- Text Style

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Support Functions


-- a Background structure without Background's default type ('rounded'):
-- a background with no type then inherits its type (the 9-slice)
local function createBackgroundStructure( src )
	src = src or {}
	return {
		type=src.type,
		view={}
	}
end



--====================================================================--
--== Static Methods


function TextFieldStyle.initialize( manager, params )
	-- print( "TextFieldStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		TextFieldStyle.MODE = params.mode
		TextFieldStyle._DEFAULTS = TextFieldStyle._TEST_DEFAULTS
	end
	local defaults = TextFieldStyle._DEFAULTS

	TextFieldStyle._setDefaults( TextFieldStyle, {defaults=defaults} )

end


function TextFieldStyle.createStyleStructure( src )
	-- print( "TextFieldStyle.createStyleStructure", src )
	src = src or {}
	--==--
	return {
		background=createBackgroundStructure( src.background ),
		hint=Style.Text.createStyleStructure( src.hint ),
		display=Style.Text.createStyleStructure( src.display ),
	}
end


function TextFieldStyle.addMissingDestProperties( dest, src )
	-- print( "TextFieldStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { TextFieldStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.align==nil then dest.align=src.align end
		if dest.backgroundStyle==nil then dest.backgroundStyle=src.backgroundStyle end
		if dest.inputType==nil then dest.inputType=src.inputType end
		if dest.isHitActive==nil then dest.isHitActive=src.isHitActive end
		if dest.isSecure==nil then dest.isSecure=src.isSecure end
		if dest.marginX==nil then dest.marginX=src.marginX end
		if dest.marginY==nil then dest.marginY=src.marginY end
		if dest.returnKey==nil then dest.returnKey=src.returnKey end

	end

	dest = TextFieldStyle._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function TextFieldStyle._addMissingChildProperties( dest, src )
	-- print("TextFieldStyle._addMissingChildProperties", dest, srcs )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style (BackgroundStyle) missing property '%s'"
	local StyleClass, child

	child = dest.background
	-- assert( child, sfmt( eStr, 'background' ) )
	StyleClass = Style.Background
	dest.background = StyleClass.addMissingDestProperties( child, src )

	child = dest.hint
	-- assert( child, sfmt( eStr, 'hint' ) )
	StyleClass = Style.Text
	dest.hint = StyleClass.addMissingDestProperties( child, src )

	child = dest.display
	-- assert( child, sfmt( eStr, 'display' ) )
	StyleClass = Style.Text
	dest.display = StyleClass.addMissingDestProperties( child, src )

	return dest
end


function TextFieldStyle.copyExistingSrcProperties( dest, src, params)
	-- print( "TextFieldStyle.copyMissingProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.align~=nil and dest.align==nil) or force then
		dest.align=src.align
	end
	if (src.backgroundStyle~=nil and dest.backgroundStyle==nil) or force then
		dest.backgroundStyle=src.backgroundStyle
	end
	if (src.inputType~=nil and dest.inputType==nil) or force then
		dest.inputType=src.inputType
	end
	if (src.isHitActive~=nil and dest.isHitActive==nil) or force then
		dest.isHitActive=src.isHitActive
	end
	if (src.isSecure~=nil and dest.isSecure==nil) or force then
		dest.isSecure=src.isSecure
	end
	if (src.marginX~=nil and dest.marginX==nil) or force then
		dest.marginX=src.marginX
	end
	if (src.marginY~=nil and dest.marginY==nil) or force then
		dest.marginY=src.marginY
	end
	if (src.returnKey~=nil and dest.returnKey==nil) or force then
		dest.returnKey=src.returnKey
	end

	return dest
end


function TextFieldStyle._verifyStyleProperties( src, exclude )
	-- print("TextFieldStyle._verifyStyleProperties", src, exclude )
	assert( src, "TextFieldStyle:verifyStyleProperties requires source" )
	--==--
	local emsg = "Style (TextFieldStyle) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	if not src.align then
		print(sfmt(emsg,'align')) ; is_valid=false
	end
	if not src.backgroundStyle then
		print(sfmt(emsg,'backgroundStyle')) ; is_valid=false
	end
	if not src.inputType then
		print(sfmt(emsg,'inputType')) ; is_valid=false
	end
	if src.isHitActive==nil then
		print(sfmt(emsg,'isHitActive')) ; is_valid=false
	end
	if src.isSecure==nil then
		print(sfmt(emsg,'isSecure')) ; is_valid=false
	end
	if not src.marginX then
		print(sfmt(emsg,'marginX')) ; is_valid=false
	end
	if not src.marginY then
		print(sfmt(emsg,'marginY')) ; is_valid=false
	end
	if not src.returnKey then
		print(sfmt(emsg,'returnKey')) ; is_valid=false
	end

	local child, StyleClass

	child = src.background
	if not child then
		print( "TextFieldStyle child test skipped for 'background'" )
		is_valid=false
	else
		StyleClass = Style.Background
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.hint
	if not child then
		print( "TextFieldStyle child test skipped for 'hint'" )
		is_valid=false
	else
		StyleClass = Style.Text
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.display
	if not child then
		print( "TextFieldStyle child test skipped for 'display'" )
		is_valid=false
	else
		StyleClass = Style.Text
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--======================================================--
-- Access to sub-styles

--== Background

function TextFieldStyle.__getters:background()
	-- print( 'TextFieldStyle.__getters:background', self._background )
	return self._background
end
function TextFieldStyle.__setters:background( data )
	-- print( 'TextFieldStyle.__setters:background', data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Background
	local inherit = self._inherit and self._inherit._background or self._inherit

	self._background = StyleClass:createStyleFrom{
		name=TextFieldStyle.BACKGROUND_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== Display

function TextFieldStyle.__getters:display()
	return self._display
end
function TextFieldStyle.__setters:display( data )
	-- print( 'TextFieldStyle.__setters:display', data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Text
	local inherit = self._inherit and self._inherit._display or self._inherit

	self._display = StyleClass:createStyleFrom{
		name=TextFieldStyle.DISPLAY_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== Hint

function TextFieldStyle.__getters:hint()
	-- print( "TextFieldStyle.__getters:hint", data )
	return self._hint
end
function TextFieldStyle.__setters:hint( data )
	-- print( "TextFieldStyle.__setters:hint", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Text
	local inherit = self._inherit and self._inherit._hint or self._inherit

	self._hint = StyleClass:createStyleFrom{
		name=TextFieldStyle.HINT_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end


--======================================================--
-- Hint Style Properties

--== .hintFont

--- [**style**] set/get Style value for Widget's Hint font.
--
-- @within Style-Helpers
-- @function .hintFont
-- @usage style.hintFont = 'helvetica-bold'
-- @usage print( style.hintFont )

function TextFieldStyle.__getters:hintFont()
	-- print( "TextFieldStyle.__getters:hintFont" )
	return self._hint.font
end
function TextFieldStyle.__setters:hintFont( value )
	-- print( "TextFieldStyle.__setters:hintFont", value )
	self._hint.font = value
end

--== .hintFontSize

--- [**style**] set/get Style value for Widget's Hint font size.
--
-- @within Style-Helpers
-- @function .hintFontSize
-- @usage style.hintFontSize = 12
-- @usage print( style.hintFontSize )

function TextFieldStyle.__getters:hintFontSize()
	-- print( "TextFieldStyle.__getters:hintFontSize" )
	return self._hint.fontSize
end
function TextFieldStyle.__setters:hintFontSize( value )
	-- print( "TextFieldStyle.__setters:hintFontSize", value )
	self._hint.fontSize = value
end

--== .hintTextColor

--- [**style**] set/get Style value for Widget's Hint text color.
--
-- @within Style-Helpers
-- @function .hintTextColor
-- @usage style.hintTextColor = {1,0.5,1,0.25}
-- @usage print( style.hintTextColor )

function TextFieldStyle.__getters:hintTextColor()
	-- print( "TextFieldStyle.__getters:hintTextColor" )
	return self._hint.textColor
end
function TextFieldStyle.__setters:hintTextColor( value )
	-- print( "TextFieldStyle.__setters:hintTextColor", value )
	self._hint.textColor = value
end


--======================================================--
-- Display Style Properties

--== .displayFont

--- [**style**] set/get Style value for Widget's Display font.
--
-- @within Style-Helpers
-- @function .displayFont
-- @usage style.displayFont = 'helvetica-bold'
-- @usage print( style.displayFont )

function TextFieldStyle.__getters:displayFont()
	-- print( "TextFieldStyle.__getters:displayFont" )
	return self._display.font
end
function TextFieldStyle.__setters:displayFont( value )
	-- print( "TextFieldStyle.__setters:displayFont", value )
	self._display.font = value
end

--== .displayFontSize

--- [**style**] set/get Style value for Widget's Display font size.
--
-- @within Style-Helpers
-- @function .displayFontSize
-- @usage style.displayFontSize = 12
-- @usage print( style.displayFontSize )

function TextFieldStyle.__getters:displayFontSize()
	-- print( "TextFieldStyle.__getters:displayFontSize" )
	return self._display.fontSize
end
function TextFieldStyle.__setters:displayFontSize( value )
	-- print( "TextFieldStyle.__setters:displayFontSize", value )
	self._display.fontSize = value
end

--== .displayTextColor

--- [**style**] set/get Style value for Widget's Display text color.
--
-- @within Style-Helpers
-- @function .displayTextColor
-- @usage style.displayTextColor = {1,0.5,1,0.25}
-- @usage print( style.displayTextColor )

function TextFieldStyle.__getters:displayTextColor()
	-- print( "TextFieldStyle.__getters:displayTextColor" )
	return self._display.textColor
end
function TextFieldStyle.__setters:displayTextColor( value )
	-- print( "TextFieldStyle.__setters:displayTextColor", value )
	self._display.textColor = value
end


--======================================================--
-- Access to style properties


--== .align

--- [**style**] set/get Style value for Widget text alignment.
-- values are 'left', 'center', 'right'
--
-- @within Properties
-- @function .align
-- @usage style.align = 'center'
-- @usage print( style.align )

TextFieldStyle.__getters.align = StyleHelp.__getters.align
TextFieldStyle.__setters.align = StyleHelp.__setters.align

--== .backgroundStyle

-- [**style**] set/get Style value for Widget background style.
-- values are 'none', ...
--
-- @within Properties
-- @function .backgroundStyle
-- @usage style.backgroundStyle = 'none'
-- @usage print( style.backgroundStyle )

function TextFieldStyle.__getters:backgroundStyle()
	-- print( "TextFieldStyle.__getters:backgroundStyle" )
	local value = self._bgStyle
	if value==nil and self._inherit then
		value = self._inherit.backgroundStyle
	end
	return value
end
function TextFieldStyle.__setters:backgroundStyle( value )
	-- print( "TextFieldStyle.__setters:backgroundStyle", value )
	assert( type(value)=='string' or (value==nil and (self:_hasInherit() or self._isClearing))  )
	--==--
	if value == self._bgStyle then return end
	self._bgStyle = value
	self:_dispatchChangeEvent( 'backgroundStyle', value )
end

--== .inputType

function TextFieldStyle.__getters:inputType()
	-- print( "TextFieldStyle.__getters:inputType" )
	local value = self._inputType
	if value==nil and self._inherit then
		value = self._inherit.inputType
	end
	return value
end
function TextFieldStyle.__setters:inputType( value )
	-- print( "TextFieldStyle.__setters:inputType", value )
	assert( type(value)=='string' or (value==nil and (self:_hasInherit() or self._isClearing))  )
	--==--
	if value == self._inputType then return end
	self._inputType = value
	self:_dispatchChangeEvent( 'inputType', value )
end

--== .isHitActive

function TextFieldStyle.__getters:isHitActive()
	-- print( "TextFieldStyle.__getters:isHitActive" )
	local value = self._isHitActive
	if value==nil and self._inherit then
		value = self._inherit.isHitActive
	end
	return value
end
function TextFieldStyle.__setters:isHitActive( value )
	-- print( "TextFieldStyle.__setters:isHitActive", value )
	assert( type(value)=='boolean' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value == self._isHitActive then return end
	self._isHitActive = value
	self:_dispatchChangeEvent( 'isHitActive', value )
end

--== .isSecure

function TextFieldStyle.__getters:isSecure()
	-- print( "TextFieldStyle.__getters:isSecure" )
	local value = self._isSecure
	if value==nil and self._inherit then
		value = self._inherit.isSecure
	end
	return value
end
function TextFieldStyle.__setters:isSecure( value )
	-- print( "TextFieldStyle.__setters:isSecure", value )
	assert( type(value)=='boolean' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._isSecure then return end
	self._isSecure = value
	self:_dispatchChangeEvent( 'isSecure', value )
end

--== .marginX

--- [**style**] set/get Style value for Widget X-axis margin.
--
-- @within Properties
-- @function .marginX
-- @usage style.marginX = 10
-- @usage print( style.marginX )

TextFieldStyle.__getters.marginX = StyleHelp.__getters.marginX
TextFieldStyle.__setters.marginX = StyleHelp.__setters.marginX

--== .marginY

--- [**style**] set/get Style value for Widget Y-axis margin.
--
-- @within Properties
-- @function .marginY
-- @usage style.marginY = 10
-- @usage print( style.marginY )

TextFieldStyle.__getters.marginY = StyleHelp.__getters.marginY
TextFieldStyle.__setters.marginY = StyleHelp.__setters.marginY


--== .returnKey

function TextFieldStyle.__getters:returnKey()
	-- print( "TextFieldStyle.__getters:returnKey" )
	local value = self._returnKey
	if value==nil and self._inherit then
		value = self._inherit.returnKey
	end
	return value
end
function TextFieldStyle.__setters:returnKey( value )
	-- print( "TextFieldStyle.__setters:returnKey", value )
	assert( (value==nil and (self:_hasInherit() or self._isClearing)) or type(value)=='string' )
	--==--
	if value == self._returnKey then return end
	self._returnKey = value
	self:_dispatchChangeEvent( 'returnKey', value )
end


--======================================================--
-- Misc



--====================================================================--
--== Private Methods


function TextFieldStyle:_doChildrenInherit( value )
	-- print( "TextFieldStyle:_doChildrenInherit", value )
	if not self._isInitialized then return end

	self._background.inherit = value and value.background or value
	self._hint.inherit = value and value.hint or value
	self._display.inherit = value and value.display or value
end


function TextFieldStyle:_clearChildrenProperties( style, params )
	-- print( "TextFieldStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(TextFieldStyle) )
	end
	--==--
	local substyle

	substyle = style and style.background
	self._background:_clearProperties( substyle, params )

	substyle = style and style.hint
	self._hint:_clearProperties( substyle, params )

	substyle = style and style.display
	self._display:_clearProperties( substyle, params )
end


function TextFieldStyle:_destroyChildren()
	self._background:removeSelf()
	self._background=nil

	self._display:removeSelf()
	self._display=nil

	self._hint:removeSelf()
	self._hint=nil
end



-- TODO: more work when inheriting, etc (Background Style)
function TextFieldStyle:_prepareData( data, dataSrc, params )
	-- print("TextFieldStyle:_prepareData", data, self )
	params = params or {}
	--==--
	-- local inherit = params.inherit
	local StyleClass
	local src, dest, tmp

	if not data then
		data = TextFieldStyle.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	if not src.background then
		tmp = dataSrc and dataSrc.background
		src.background = createBackgroundStructure( tmp )
	end

	StyleClass = Style.Text
	if not src.display then
		tmp = dataSrc and dataSrc.display
		src.display = StyleClass.createStyleStructure( tmp )
	end
	if not src.hint then
		tmp = dataSrc and dataSrc.hint
		src.hint = StyleClass.createStyleStructure( tmp )
	end

	--== process children

	dest = src.background
	src.background = Style.Background.copyExistingSrcProperties( dest, src )

	dest = src.display
	src.display = StyleClass.copyExistingSrcProperties( dest, src )

	dest = src.hint
	src.hint = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end



--====================================================================--
--== Event Handlers


-- none




return TextFieldStyle
