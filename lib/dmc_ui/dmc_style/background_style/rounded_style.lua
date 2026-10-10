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



--====================================================================--
--== DMC UI : newRoundedBackgroundStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local uiConst = require( ui_find( 'ui_constants' ) )

local ViewStyle = require( ui_find( 'dmc_style.background_style.base_view_style' ) )
local StyleHelp = require( ui_find( 'core.style_helper' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local Style = nil



--====================================================================--
--== Rounded Background Style Class
--====================================================================--


--- Rounded View Style Class.
-- a Style object for a Rounded Background View.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- **Child style of:** <br>
-- * @{Style.Background}
--
-- @classmod Style.BackgroundView.Rounded
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newBackgroundStyle{
--   type='rounded',
-- }
--
-- local widget = dUI.newRoundedBackgroundStyle()

local RoundedStyle = newClass( ViewStyle, {name="Rounded Background Style"} )

--- Class Constants.
-- @section

--== Class Constants

RoundedStyle.TYPE = uiConst.ROUNDED

RoundedStyle.__base_style__ = nil

RoundedStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	cornerRadius=true,
	fillColor=true,
	strokeColor=true,
	strokeWidth=true,
}

RoundedStyle._EXCLUDE_PROPERTY_CHECK = nil

RoundedStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=76,
	height=30,
	anchorX=0.5,
	anchorY=0.5,

	cornerRadius=6,
	fillColor={
		type='gradient',
		color1={ 1, 1, 1 },
		color2={ 0.90, 0.91, 0.93 },
		direction='down'
	},
	strokeColor={0.62,0.66,0.70,1},
	strokeWidth=1
}

RoundedStyle._TEST_DEFAULTS = {
	name='rounded-background-test-style',
	debugOn=false,
	width=301,
	height=302,
	anchorX=303,
	anchorY=304,

	cornerRadius=305,
	fillColor={301,302,303,304},
	strokeColor={311,312,313,314},
	strokeWidth=311
}

RoundedStyle.MODE = uiConst.RUN_MODE
RoundedStyle._DEFAULTS = RoundedStyle._STYLE_DEFAULTS


--== Event Constants

RoundedStyle.EVENT = 'rounded-background-style-event'


--======================================================--
-- Start: Setup DMC Objects

function RoundedStyle:__init__( params )
	-- print( "RoundedStyle:__init__", params )
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

	self._cornerRadius = nil
	self._fillColor = nil
	self._strokeColor = nil
	self._strokeWidth = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function RoundedStyle.initialize( manager, params )
	-- print( "RoundedStyle.initialize", manager, params )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		RoundedStyle.MODE = params.mode
		RoundedStyle._DEFAULTS = RoundedStyle._TEST_DEFAULTS
	end
	local defaults = RoundedStyle._DEFAULTS

	RoundedStyle._setDefaults( RoundedStyle, {defaults=defaults} )
end



function RoundedStyle.addMissingDestProperties( dest, src )
	-- print( "RoundedStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { RoundedStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = ViewStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.cornerRadius==nil then dest.cornerRadius=src.cornerRadius end
		if dest.fillColor==nil then dest.fillColor=src.fillColor end
		if dest.strokeColor==nil then dest.strokeColor=src.strokeColor end
		if dest.strokeWidth==nil then dest.strokeWidth=src.strokeWidth end

	end

	return dest
end


function RoundedStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "RoundedStyle.copyExistingSrcProperties", dest, src, params )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = ViewStyle.copyExistingSrcProperties( dest, src, params )

	if (src.cornerRadius~=nil and dest.cornerRadius==nil) or force then
		dest.cornerRadius=src.cornerRadius
	end
	if (src.fillColor~=nil and dest.fillColor==nil) or force then
		dest.fillColor=src.fillColor
	end
	if (src.strokeColor~=nil and dest.strokeColor==nil) or force then
		dest.strokeColor=src.strokeColor
	end
	if (src.strokeWidth~=nil and dest.strokeWidth==nil) or force then
		dest.strokeWidth=src.strokeWidth
	end

	return dest
end


function RoundedStyle._verifyStyleProperties( src, exclude )
	-- print( "RoundedStyle._verifyStyleProperties", src )
	assert( src, "RoundedStyle:verifyStyleProperties requires source")
	--==--
	local emsg = "Style (RoundedStyle) requires property '%s'"

	local is_valid = ViewStyle._verifyStyleProperties( src, exclude )

	if not src.cornerRadius then
		print(sfmt(emsg,'cornerRadius')) ; is_valid=false
	end
	if not src.fillColor then
		print(sfmt(emsg,'fillColor')) ; is_valid=false
	end
	if not src.strokeColor then
		print(sfmt(emsg,'strokeColor')) ; is_valid=false
	end
	if not src.strokeWidth then
		print(sfmt(emsg,'strokeWidth')) ; is_valid=false
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--======================================================--
-- Access to style properties

--== cornerRadius

function RoundedStyle.__getters:cornerRadius()
	-- print( "RoundedStyle.__getters:cornerRadius", self )
	local value = self._cornerRadius
	if value==nil and self._inherit then
		value = self._inherit.cornerRadius
	end
	return value
end
function RoundedStyle.__setters:cornerRadius( value )
	-- print( "RoundedStyle.__setters:cornerRadius", value )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self:_hasInherit() or self._isClearing) ) )
	--==--
	if value == self._cornerRadius then return end
	self._cornerRadius = value
	self:_dispatchChangeEvent( 'cornerRadius', value )
end

--== fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage widget.fillColor = 'center'
-- @usage print( widget.fillColor )

RoundedStyle.__getters.fillColor = StyleHelp.__getters.fillColor
RoundedStyle.__setters.fillColor = StyleHelp.__setters.fillColor

--== strokeColor

--- [**style**] set/get Style value for Widget border color.
--
-- @within Properties
-- @function .strokeColor
-- @usage style.strokeColor = {1,1,1,1}
-- @usage print( style.strokeColor )

RoundedStyle.__getters.strokeColor = StyleHelp.__getters.strokeColor
RoundedStyle.__setters.strokeColor = StyleHelp.__setters.strokeColor

--== strokeWidth

--- [**style**] set/get Style value for Widget border thickness.
--
-- @within Properties
-- @function .strokeWidth
-- @usage style.strokeWidth = 2
-- @usage print( style.strokeWidth )

RoundedStyle.__getters.strokeWidth = StyleHelp.__getters.strokeWidth
RoundedStyle.__setters.strokeWidth = StyleHelp.__setters.strokeWidth



--====================================================================--
--== Private Methods


--- method to set fill color
--

function RoundedStyle:setFillColor( ... )
	self.fillColor = {...}
end
function RoundedStyle:setStrokeColor( ... )
	self.strokeColor = {...}
end



--====================================================================--
--== Event Handlers


-- none




return RoundedStyle
