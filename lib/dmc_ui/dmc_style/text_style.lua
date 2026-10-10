--====================================================================--
-- dmc_widget/theme_manager/background_style.lua
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
--== DMC Corona UI : Text Widget Style
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
--== DMC UI : newTextStyle
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


local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local Style = nil



--====================================================================--
--== Text Style Class
--====================================================================--

--- Text Style Class.
-- a style object for a Text widget.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.Text
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newTextStyle()

local TextStyle = newClass( BaseStyle, {name="Text Style"} )

--- Class Constants.
-- @section

--== Class Constants

TextStyle.TYPE = uiConst.TEXT

TextStyle.__base_style__ = nil

TextStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	align=true,
	fillColor=true,
	font=true,
	fontSize=true,
	fontSizeMinimum=true,
	marginX=true,
	marginY=true,
	textColor=true,

	strokeColor=true,
	strokeWidth=true,
}

TextStyle._EXCLUDE_PROPERTY_CHECK = {}

TextStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=0,
	height=0,
	anchorX=0.5,
	anchorY=0.5,

	align='center',
	fillColor={0,0,0,0},
	font=native.systemFont,
	fontSize=16,
	fontSizeMinimum=0,
	marginX=0,
	marginY=0,
	textColor={0,0,0,1},

	strokeColor={0,0,0,0},
	strokeWidth=0,
}

TextStyle._TEST_DEFAULTS = {
	debugOn=false,
	width=117,
	height=nil,
	anchorX=101,
	anchorY=102,

	align='test-center',
	fillColor={101,102,103,104},
	font=native.systemFont,
	fontSize=101,
	fontSizeMinimum=106,
	marginX=102,
	marginY=103,
	textColor={111,112,113,114},

	strokeColor={121,122,123,124},
	strokeWidth=111,
}

TextStyle.MODE = uiConst.RUN_MODE
TextStyle._DEFAULTS = TextStyle._STYLE_DEFAULTS

--== Event Constants

TextStyle.EVENT = 'text-style-event'


--======================================================--
-- Start: Setup DMC Objects

function TextStyle:__init__( params )
	-- print( "TextStyle:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Style Properties ==--

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
	self._fillColor = nil
	self._font = nil
	self._fontSize = nil
	self._fontSizeMinimum = nil
	self._marginX = nil
	self._marginY = nil
	self._strokeColor = nil
	self._strokeWidth = nil
	self._textColor = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function TextStyle.initialize( manager, params )
	-- print( "TextStyle.initialize", manager, params.mode )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		TextStyle.MODE = params.mode
		TextStyle._DEFAULTS = TextStyle._TEST_DEFAULTS
	end
	local defaults = TextStyle._DEFAULTS

	TextStyle._setDefaults( TextStyle, {defaults=defaults} )
end


function TextStyle.addMissingDestProperties( dest, src )
	-- print( "TextStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { TextStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.align==nil then dest.align=src.align end
		if dest.fillColor==nil then dest.fillColor=src.fillColor end
		if dest.font==nil then dest.font=src.font end
		if dest.fontSize==nil then dest.fontSize=src.fontSize end
		if dest.fontSizeMinimum==nil then dest.fontSizeMinimum=src.fontSizeMinimum end
		if dest.marginX==nil then dest.marginX=src.marginX end
		if dest.marginY==nil then dest.marginY=src.marginY end
		if dest.strokeColor==nil then dest.strokeColor=src.strokeColor end
		if dest.strokeWidth==nil then dest.strokeWidth=src.strokeWidth end
		if dest.textColor==nil then dest.textColor=src.textColor end

	end

	return dest
end


-- copyExistingSrcProperties()
--
function TextStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "TextStyle.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.align~=nil and dest.align==nil) or force then
		dest.align=src.align
	end
	if (src.fillColor~=nil and dest.fillColor==nil) or force then
		dest.fillColor=src.fillColor
	end
	if (src.font~=nil and dest.font==nil) or force then
		dest.font=src.font
	end
	if (src.fontSize~=nil and dest.fontSize==nil) or force then
		dest.fontSize=src.fontSize
	end
	if (src.fontSizeMinimum~=nil and dest.fontSizeMinimum==nil) or force then
		dest.fontSizeMinimum=src.fontSizeMinimum
	end
	if (src.marginX~=nil and dest.marginX==nil) or force then
		dest.marginX=src.marginX
	end
	if (src.marginY~=nil and dest.marginY==nil) or force then
		dest.marginY=src.marginY
	end
	if (src.strokeColor~=nil and dest.strokeColor==nil) or force then
		dest.strokeColor=src.strokeColor
	end
	if (src.strokeWidth~=nil and dest.strokeWidth==nil) or force then
		dest.strokeWidth=src.strokeWidth
	end
	if (src.textColor~=nil and dest.textColor==nil) or force then
		dest.textColor=src.textColor
	end

	return dest
end


-- _verifyStyleProperties()
--
function TextStyle._verifyStyleProperties( src )
	-- print( "TextStyle._verifyStyleProperties", src )
	local emsg = "Style (Text) requires property '%s'"

	-- exclude width/height because nil is valid value
	local is_valid = BaseStyle._verifyStyleProperties( src, {width=true, height=true} )

	if not src.align then
		print(sfmt(emsg,'align')) ; is_valid=false
	end
	if not src.fillColor then
		print(sfmt(emsg,'fillColor')) ; is_valid=false
	end
	if not src.font then
		print(sfmt(emsg,'font')) ; is_valid=false
	end
	if not src.fontSize then
		print(sfmt(emsg,'fontSize')) ; is_valid=false
	end
	if not src.fontSizeMinimum then
		print(sfmt(emsg,'fontSizeMinimum')) ; is_valid=false
	end
	if not src.marginX then
		print(sfmt(emsg,'marginX')) ; is_valid=false
	end
	if not src.marginY then
		print(sfmt(emsg,'marginY')) ; is_valid=false
	end
	if not src.strokeColor then
		print(sfmt(emsg,'strokeColor')) ; is_valid=false
	end
	if not src.strokeWidth then
		print(sfmt(emsg,'strokeWidth')) ; is_valid=false
	end
	if not src.textColor then
		print(sfmt(emsg,'textColor')) ; is_valid=false
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--== .align

--- [**style**] set/get Style value for Widget text alignment.
-- values are 'left', 'center', 'right'
--
-- @within Properties
-- @function .align
-- @usage widget.align = 'center'
-- @usage print( widget.align )

TextStyle.__getters.align = StyleHelp.__getters.align
TextStyle.__setters.align = StyleHelp.__setters.align

--== .fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage widget.fillColor = 'center'
-- @usage print( widget.fillColor )

TextStyle.__getters.fillColor = StyleHelp.__getters.fillColor
TextStyle.__setters.fillColor = StyleHelp.__setters.fillColor

--== .font

--- [**style**] set/get Style value for Widget font.
--
-- @within Properties
-- @function .font
-- @usage style.font = native.systemFontBold
-- @usage print( style.font )

TextStyle.__getters.font = StyleHelp.__getters.font
TextStyle.__setters.font = StyleHelp.__setters.font

--== .fontSize

--- [**style**] set/get Style value for Widget font size.
--
-- @within Properties
-- @function .fontSize
-- @usage style.fontSize = 12
-- @usage print( style.fontSize )

TextStyle.__getters.fontSize = StyleHelp.__getters.fontSize
TextStyle.__setters.fontSize = StyleHelp.__setters.fontSize


--== .fontSizeMinimum

--- [**style**] set/get Style value for Widget minimum font size.
--
-- @within Properties
-- @function .fontSizeMinimum
-- @usage style.fontSizeMinimum = 8
-- @usage print( style.fontSizeMinimum )

function TextStyle.__getters:fontSizeMinimum()
	-- print( "TextStyle.__getters:fontSizeMinimum", self )
	local value = self._fontSizeMinimum
	if value==nil and self._inherit then
		value = self._inherit.fontSizeMinimum
	end
	return value
end
function TextStyle.__setters:fontSizeMinimum( value )
	-- print( "TextStyle.__setters:fontSizeMinimum", self._fontSizeMinimum, value, self._isClearing )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	self._fontSizeMinimum = value
	self:_dispatchChangeEvent( 'fontSizeMinimum', value )
end


--== .marginX

--- [**style**] set/get Style value for Widget X-axis margin.
--
-- @within Properties
-- @function .marginX
-- @usage style.marginX = 10
-- @usage print( style.marginX )

TextStyle.__getters.marginX = StyleHelp.__getters.marginX
TextStyle.__setters.marginX = StyleHelp.__setters.marginX

--== .marginY

--- [**style**] set/get Style value for Widget Y-axis margin.
--
-- @within Properties
-- @function .marginY
-- @usage style.marginY = 10
-- @usage print( style.marginY )

TextStyle.__getters.marginY = StyleHelp.__getters.marginY
TextStyle.__setters.marginY = StyleHelp.__setters.marginY

--== .strokeColor

--- [**style**] set/get Style value for Widget border color.
--
-- @within Properties
-- @function .strokeColor
-- @usage style.strokeColor = {1,1,1,1}
-- @usage print( style.strokeColor )

TextStyle.__getters.strokeColor = StyleHelp.__getters.strokeColor
TextStyle.__setters.strokeColor = StyleHelp.__setters.strokeColor

--== .strokeWidth

--- [**style**] set/get Style value for Widget border thickness.
--
-- @within Properties
-- @function .strokeWidth
-- @usage style.strokeWidth = 2
-- @usage print( style.strokeWidth )

TextStyle.__getters.strokeWidth = StyleHelp.__getters.strokeWidth
TextStyle.__setters.strokeWidth = StyleHelp.__setters.strokeWidth

--== .textColor

--- [**style**] set/get Style value for Widget text color.
--
-- @within Properties
-- @function .textColor
-- @usage style.textColor = {0,0,1,0.5}
-- @usage print( style.textColor )

TextStyle.__getters.textColor = StyleHelp.__getters.textColor
TextStyle.__setters.textColor = StyleHelp.__setters.textColor


--== verifyProperties

function TextStyle:verifyProperties()
	-- print( "TextStyle:verifyProperties" )
	return TextStyle._verifyStyleProperties( self )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none



return TextStyle
