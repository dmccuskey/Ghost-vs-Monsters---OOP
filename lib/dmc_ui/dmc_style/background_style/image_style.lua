--====================================================================--
-- dmc_widget/background_style/image_style.lua
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
--== DMC Corona UI : Image Background Style
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
--== DMC UI : newImageBackgroundStyle
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
--== Image Background Style Class
--====================================================================--


--- Image View Style Class.
-- a style object for a Image Background View.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- **Child style of:** <br>
-- * @{Style.Background}
--
-- @classmod Style.BackgroundView.Image
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newBackgroundStyle{
--   type='Image',
-- }
--
-- local widget = dUI.newImageBackgroundStyle()

local ImageStyle = newClass( ViewStyle, {name="Image Background Style"} )

--- Class Constants.
-- @section

--== Class Constants

ImageStyle.TYPE = uiConst.IMAGE

ImageStyle.__base_style__ = nil

ImageStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	imagePath=true,
	offsetBottom=true,
	offsetLeft=true,
	offsetRight=true,
	offsetTop=true,
}

ImageStyle._EXCLUDE_PROPERTY_CHECK = nil

ImageStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=0,
	height=0,
	anchorX=0,
	anchorY=0,

	imagePath=ui_file('theme/default/background/background.png'),

	offsetBottom=0,
	offsetLeft=0,
	offsetRight=0,
	offsetTop=0,
}

ImageStyle._TEST_DEFAULTS = {
	name='image-background-test-style',
	debugOn=false,
	width=301,
	height=302,
	anchorX=303,
	anchorY=304,

	imagePath='image-306.png',

	offsetBottom=303,
	offsetLeft=300,
	offsetRight=301,
	offsetTop=302,
}

ImageStyle.MODE = uiConst.RUN_MODE
ImageStyle._DEFAULTS = ImageStyle._STYLE_DEFAULTS


--== Event Constants

ImageStyle.EVENT = 'image-background-style-event'


--======================================================--
-- Start: Setup DMC Objects

function ImageStyle:__init__( params )
	-- print( "ImageStyle:__init__", params )
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

	self._imagePath = nil
	self._offsetBottom = nil
	self._offsetLeft = nil
	self._offsetRight = nil
	self._offsetTop = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ImageStyle.initialize( manager, params )
	-- print( "ImageStyle.initialize", manager, params )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		ImageStyle.MODE = params.mode
		ImageStyle._DEFAULTS = ImageStyle._TEST_DEFAULTS
	end
	local defaults = ImageStyle._DEFAULTS

	ImageStyle._setDefaults( ImageStyle, {defaults=defaults} )
end



function ImageStyle.addMissingDestProperties( dest, src )
	-- print( "ImageStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { ImageStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = ViewStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.imagePath==nil then dest.imagePath=src.imagePath end
		if dest.offsetBottom==nil then dest.offsetBottom=src.offsetBottom end
		if dest.offsetLeft==nil then dest.offsetLeft=src.offsetLeft end
		if dest.offsetRight==nil then dest.offsetRight=src.offsetRight end
		if dest.offsetTop==nil then dest.offsetTop=src.offsetTop end

	end

	return dest
end


function ImageStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "ImageStyle.copyExistingSrcProperties", dest, src, params )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = ViewStyle.copyExistingSrcProperties( dest, src, params )

	if (src.imagePath~=nil and dest.imagePath==nil) or force then
		dest.imagePath=src.imagePath
	end
	if (src.offsetBottom~=nil and dest.offsetBottom==nil) or force then
		dest.offsetBottom=src.offsetBottom
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

	return dest
end


function ImageStyle._verifyStyleProperties( src, exclude )
	-- print( "ImageStyle._verifyStyleProperties", src )
	assert( src, "ImageStyle:verifyStyleProperties requires source")
	--==--
	local emsg = "Style (ImageStyle) requires property '%s'"

	local is_valid = ViewStyle._verifyStyleProperties( src, exclude )

	if not src.imagePath then
		print(sfmt(emsg,'imagePath')) ; is_valid=false
	end
	if not src.offsetBottom then
		print(sfmt(emsg,'offsetBottom')) ; is_valid=false
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

	return is_valid
end



--====================================================================--
--== Public Methods


--======================================================--
-- Access to style properties

--== .imagePath

function ImageStyle.__getters:imagePath()
	-- print( "ImageStyle.__getters:imagePath", self )
	local value = self._imagePath
	if value==nil and self._inherit then
		value = self._inherit.imagePath
	end
	return value
end
function ImageStyle.__setters:imagePath( value )
	-- print( "ImageStyle.__setters:imagePath", value )
	assert( type(value)=='string' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._imagePath then return end
	self._imagePath = value
	self:_dispatchChangeEvent( 'imagePath', value )
end

--== .offsetBottom

function ImageStyle.__getters:offsetBottom()
	-- print( "ImageStyle.__getters:offsetBottom", self )
	local value = self._offsetBottom
	if value==nil and self._inherit then
		value = self._inherit.offsetBottom
	end
	return value
end
function ImageStyle.__setters:offsetBottom( value )
	-- print( "ImageStyle.__setters:offsetBottom", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetBottom then return end
	self._offsetBottom = value
	self:_dispatchChangeEvent( 'offsetBottom', value )
end

--== .offsetLeft

function ImageStyle.__getters:offsetLeft()
	-- print( "ImageStyle.__getters:offsetLeft", self )
	local value = self._offsetLeft
	if value==nil and self._inherit then
		value = self._inherit.offsetLeft
	end
	return value
end
function ImageStyle.__setters:offsetLeft( value )
	-- print( "ImageStyle.__setters:offsetLeft", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetLeft then return end
	self._offsetLeft = value
	self:_dispatchChangeEvent( 'offsetLeft', value )
end

--== .offsetRight

function ImageStyle.__getters:offsetRight()
	-- print( "ImageStyle.__getters:offsetRight", self )
	local value = self._offsetRight
	if value==nil and self._inherit then
		value = self._inherit.offsetRight
	end
	return value
end
function ImageStyle.__setters:offsetRight( value )
	-- print( "ImageStyle.__setters:offsetRight", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetRight then return end
	self._offsetRight = value
	self:_dispatchChangeEvent( 'offsetRight', value )
end

--== .offsetTop

function ImageStyle.__getters:offsetTop()
	-- print( "ImageStyle.__getters:offsetTop", self )
	local value = self._offsetTop
	if value==nil and self._inherit then
		value = self._inherit.offsetTop
	end
	return value
end
function ImageStyle.__setters:offsetTop( value )
	-- print( "ImageStyle.__setters:offsetTop", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._offsetTop then return end
	self._offsetTop = value
	self:_dispatchChangeEvent( 'offsetTop', value )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none




return ImageStyle
