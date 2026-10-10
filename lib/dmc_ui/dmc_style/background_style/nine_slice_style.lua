--====================================================================--
-- dmc_widget/widget_background/rounded_style.lua
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
--== DMC Corona UI : Rounded Background Style
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
--== DMC UI : newRoundedBackgroundStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local uiConst = require( ui_find( 'ui_constants' ) )

local ViewStyle = require( ui_find( 'dmc_style.background_style.base_view_style' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local Style = nil



--====================================================================--
--== 9-Slice Background Style Class
--====================================================================--


--- 9-Slice View Style Class.
-- a style object for a 9-Slice Background View.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- **Child style of:** <br>
-- * @{Style.Background}
--
-- @classmod Style.BackgroundView.9Slice
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newBackgroundStyle{
--   type='9-slice',
-- }
--
-- local widget = dUI.new9SliceBackgroundStyle()

local NineSliceStyle = newClass( ViewStyle, {name="9-Slice Background Style"} )

--- Class Constants.
-- @section

--== Class Constants

NineSliceStyle.TYPE = uiConst.NINE_SLICE

NineSliceStyle.__base_style__ = nil

NineSliceStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	spriteFrames=true,
	offsetLeft=true,
	offsetRight=true,
	offsetTop=true,
	offsetBottom=true,
	sheetInfo=true,
	sheetImage=true,
}

NineSliceStyle._EXCLUDE_PROPERTY_CHECK = nil

NineSliceStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=76,
	height=30,
	anchorX=0.1,
	anchorY=0.1,

	spriteFrames = {
		topLeft=1,
		topMiddle=2,
		topRight=3,
		middleLeft=4,
		middleMiddle=5,
		middleRight=6,
		bottomLeft=7,
		bottomMiddle=8,
		bottomRight=9,
	},
	offsetLeft=0,
	offsetRight=0,
	offsetTop=0,
	offsetBottom=0,

	sheetInfo=ui_find('theme.default.background.nine-slice-sheet'),
	sheetImage=ui_file('theme/default/background/nine-slice-sheet.png'),
}

NineSliceStyle._TEST_DEFAULTS = {
	name='nice-slice-background-test-style',
	debugOn=false,
	width=301,
	height=302,
	anchorX=303,
	anchorY=304,

	spriteFrames = {
		topLeft=10,
		topMiddle=12,
		topRight=13,
		middleLeft=14,
		middleMiddle=15,
		middleRight=16,
		bottomLeft=17,
		bottomMiddle=18,
		bottomRight=19,
	},
	offsetLeft=300,
	offsetRight=301,
	offsetTop=302,
	offsetBottom=303,

	sheetInfo='sheet',
	sheetImage='sheet.png'
}

NineSliceStyle.MODE = uiConst.RUN_MODE
NineSliceStyle._DEFAULTS = NineSliceStyle._STYLE_DEFAULTS


--== Event Constants

NineSliceStyle.EVENT = '9-slice-background-style-event'


--======================================================--
-- Start: Setup DMC Objects

function NineSliceStyle:__init__( params )
	-- print( "NineSliceStyle:__init__", params )
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

	self._spriteFrames = nil
	self._offsetLeft = nil
	self._offsetRight = nil
	self._offsetTop = nil
	self._offsetBottom = nil
	self._sheetInfo = nil
	self._sheetImage = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function NineSliceStyle.initialize( manager, params )
	-- print( "NineSliceStyle.initialize", manager, params )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		NineSliceStyle.MODE = params.mode
		NineSliceStyle._DEFAULTS = NineSliceStyle._TEST_DEFAULTS
	end
	local defaults = NineSliceStyle._DEFAULTS

	NineSliceStyle._setDefaults( NineSliceStyle, {defaults=defaults} )
end



function NineSliceStyle.addMissingDestProperties( dest, src )
	-- print( "NineSliceStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { NineSliceStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = ViewStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.spriteFrames==nil then dest.spriteFrames=src.spriteFrames end
		if dest.offsetLeft==nil then dest.offsetLeft=src.offsetLeft end
		if dest.offsetRight==nil then dest.offsetRight=src.offsetRight end
		if dest.offsetTop==nil then dest.offsetTop=src.offsetTop end
		if dest.offsetBottom==nil then dest.offsetBottom=src.offsetBottom end
		if dest.sheetInfo==nil then dest.sheetInfo=src.sheetInfo end
		if dest.sheetImage==nil then dest.sheetImage=src.sheetImage end

	end

	return dest
end


function NineSliceStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "NineSliceStyle.copyExistingSrcProperties", dest, src, params )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = ViewStyle.copyExistingSrcProperties( dest, src, params )

	if (src.spriteFrames~=nil and dest.spriteFrames==nil) or force then
		dest.spriteFrames=src.spriteFrames
	end
	if (src.offsetLeft~=nil and dest.offsetLeft==nil) or force then
		dest.offsetLeft=src.offsetLeft
	end
	if (src.offsetRight~=nil and dest.offsetRight==nil) or force then
		dest.offsetRight=src.offsetRight
	end
	if (src.offsetTop~=nil and dest.offsetTop==nil) or force then
		dest.offsetTop=src.offsetTop
	end
	if (src.offsetBottom~=nil and dest.offsetBottom==nil) or force then
		dest.offsetBottom=src.offsetBottom
	end
	if (src.sheetInfo~=nil and dest.sheetInfo==nil) or force then
		dest.sheetInfo=src.sheetInfo
	end
	if (src.sheetImage~=nil and dest.sheetImage==nil) or force then
		dest.sheetImage=src.sheetImage
	end

	return dest
end


function NineSliceStyle._verifyStyleProperties( src, exclude )
	-- print( "NineSliceStyle._verifyStyleProperties", src )
	assert( src, "NineSliceStyle:verifyStyleProperties requires source")
	--==--
	local emsg = "Style (NineSliceStyle) requires property '%s'"

	local is_valid = ViewStyle._verifyStyleProperties( src, exclude )

	if not src.spriteFrames then
		print(sfmt(emsg,'spriteFrames')) ; is_valid=false
	end
	if not src.offsetLeft then
		print(sfmt(emsg,'offsetLeft')) ; is_valid=false
	end
	if not src.offsetRight then
		print(sfmt(emsg,'offsetRight')) ; is_valid=false
	end
	if not src.offsetTop then
		print(sfmt(emsg,'offsetTop')) ; is_valid=false
	end
	if not src.offsetBottom then
		print(sfmt(emsg,'offsetBottom')) ; is_valid=false
	end
	if not src.sheetInfo then
		print(sfmt(emsg,'sheetInfo')) ; is_valid=false
	end
	if not src.sheetImage then
		print(sfmt(emsg,'sheetImage')) ; is_valid=false
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--======================================================--
-- Access to style properties

--== spriteFrames

function NineSliceStyle.__getters:spriteFrames()
	-- print( "NineSliceStyle.__getters:spriteFrames", self )
	local value = self._spriteFrames
	if value==nil and self._inherit then
		value = self._inherit.spriteFrames
	end
	return value
end
function NineSliceStyle.__setters:spriteFrames( value )
	-- print( "NineSliceStyle.__setters:spriteFrames", value )
	assert( type(value)=='table' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._spriteFrames then return end
	self._spriteFrames = value
	self:_dispatchChangeEvent( 'spriteFrames', value )
end

--== offsetLeft

function NineSliceStyle.__getters:offsetLeft()
	-- print( "NineSliceStyle.__getters:offsetLeft", self )
	local value = self._offsetLeft
	if value==nil and self._inherit then
		value = self._inherit.offsetLeft
	end
	return value
end
function NineSliceStyle.__setters:offsetLeft( value )
	-- print( "NineSliceStyle.__setters:offsetLeft", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetLeft then return end
	self._offsetLeft = value
	self:_dispatchChangeEvent( 'offsetLeft', value )
end

--== offsetRight

function NineSliceStyle.__getters:offsetRight()
	-- print( "NineSliceStyle.__getters:offsetRight", self )
	local value = self._offsetRight
	if value==nil and self._inherit then
		value = self._inherit.offsetRight
	end
	return value
end
function NineSliceStyle.__setters:offsetRight( value )
	-- print( "NineSliceStyle.__setters:offsetRight", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetRight then return end
	self._offsetRight = value
	self:_dispatchChangeEvent( 'offsetRight', value )
end

--== offsetTop

function NineSliceStyle.__getters:offsetTop()
	-- print( "NineSliceStyle.__getters:offsetTop", self )
	local value = self._offsetTop
	if value==nil and self._inherit then
		value = self._inherit.offsetTop
	end
	return value
end
function NineSliceStyle.__setters:offsetTop( value )
	-- print( "NineSliceStyle.__setters:offsetTop", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetTop then return end
	self._offsetTop = value
	self:_dispatchChangeEvent( 'offsetTop', value )
end

--== offsetBottom

function NineSliceStyle.__getters:offsetBottom()
	-- print( "NineSliceStyle.__getters:offsetBottom", self )
	local value = self._offsetBottom
	if value==nil and self._inherit then
		value = self._inherit.offsetBottom
	end
	return value
end
function NineSliceStyle.__setters:offsetBottom( value )
	-- print( "NineSliceStyle.__setters:offsetBottom", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetBottom then return end
	self._offsetBottom = value
	self:_dispatchChangeEvent( 'offsetBottom', value )
end

--== sheetInfo

function NineSliceStyle.__getters:sheetInfo()
	-- print( "NineSliceStyle.__getters:sheetInfo", self )
	local value = self._sheetInfo
	if value==nil and self._inherit then
		value = self._inherit.sheetInfo
	end
	return value
end
function NineSliceStyle.__setters:sheetInfo( value )
	-- print( "NineSliceStyle.__setters:sheetInfo", value )
	assert( type(value)=='string' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._sheetInfo then return end
	self._sheetInfo = value
	self:_dispatchChangeEvent( 'sheetInfo', value )
end

--== sheetImage

function NineSliceStyle.__getters:sheetImage()
	-- print( "NineSliceStyle.__getters:sheetImage", self )
	local value = self._sheetImage
	if value==nil and self._inherit then
		value = self._inherit.sheetImage
	end
	return value
end
function NineSliceStyle.__setters:sheetImage( value )
	-- print( "NineSliceStyle.__setters:sheetImage", value )
	assert( type(value)=='string' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._sheetImage then return end
	self._sheetImage = value
	self:_dispatchChangeEvent( 'sheetImage', value )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none




return NineSliceStyle
