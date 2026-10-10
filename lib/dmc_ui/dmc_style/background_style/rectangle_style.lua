--====================================================================--
-- dmc_widget/widget_background/rectangle_style.lua
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
--== DMC Corona UI : Rectangle Background Style
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
--== DMC UI : newRectangleBackgroundStyle
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
--== Rectangle Background Style Class
--====================================================================--


--- Rectangle View Style Class.
-- a style object for a Rectangle Background View.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- **Child style of:** <br>
-- * @{Style.Background}
--
-- @classmod Style.BackgroundView.Rectangle
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newBackgroundStyle{
--   type='rectangle',
-- }
--
-- local widget = dUI.newRectangleBackgroundStyle()

local RectangleStyle = newClass( ViewStyle, {name="Rectangle Background Style"} )

--- Class Constants.
-- @section

--== Class Constants

RectangleStyle.TYPE = uiConst.RECTANGLE

RectangleStyle.__base_style__ = nil -- set in initialize()

RectangleStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	fillColor=true,
	strokeColor=true,
	strokeWidth=true,
}

RectangleStyle._EXCLUDE_PROPERTY_CHECK = nil

RectangleStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=76,
	height=30,
	anchorX=0.5,
	anchorY=0.5,

	fillColor={
		type='gradient',
		color1={ 1, 1, 1 },
		color2={ 0.90, 0.91, 0.93 },
		direction='down'
	},
	strokeColor={0.62,0.66,0.70,1},
	strokeWidth=1
}

RectangleStyle._TEST_DEFAULTS = {
	name='rectangle-background-test-style',
	debugOn=false,
	width=201,
	height=202,
	anchorX=203,
	anchorY=204,

	fillColor={201,202,203,204},
	strokeColor={211,212,213,214},
	strokeWidth=211
}

RectangleStyle.MODE = uiConst.RUN_MODE
RectangleStyle._DEFAULTS = RectangleStyle._STYLE_DEFAULTS

--== Event Constants

RectangleStyle.EVENT = 'rectangle-background-style-event'


--======================================================--
-- Start: Setup DMC Objects

function RectangleStyle:__init__( params )
	-- print( "RectangleStyle:__init__", params )
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

	self._fillColor = nil
	self._strokeColor = nil
	self._strokeWidth = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function RectangleStyle.initialize( manager, params )
	-- print( "RectangleStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		RectangleStyle.MODE = params.mode
		RectangleStyle._DEFAULTS = RectangleStyle._TEST_DEFAULTS
	end
	local defaults = RectangleStyle._DEFAULTS

	RectangleStyle._setDefaults( RectangleStyle, {defaults=defaults} )
end


function RectangleStyle.addMissingDestProperties( dest, src )
	-- print( "RectangleStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { RectangleStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = ViewStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.fillColor==nil then dest.fillColor=src.fillColor end
		if dest.strokeColor==nil then dest.strokeColor=src.strokeColor end
		if dest.strokeWidth==nil then dest.strokeWidth=src.strokeWidth end

	end

	return dest
end


function RectangleStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "RectangleStyle.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	ViewStyle.copyExistingSrcProperties( dest, src, params )

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


function RectangleStyle._verifyStyleProperties( src, exclude )
	-- print( "RectangleStyle._verifyStyleProperties", src )
	assert( src, "RectangleStyle:verifyStyleProperties requires source")
	--==--
	local emsg = "Style (RectangleStyle) requires property '%s'"

	local is_valid = ViewStyle._verifyStyleProperties( src, exclude )

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

--== fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage widget.fillColor = 'center'
-- @usage print( widget.fillColor )

RectangleStyle.__getters.fillColor = StyleHelp.__getters.fillColor
RectangleStyle.__setters.fillColor = StyleHelp.__setters.fillColor

--== strokeColor

--- [**style**] set/get Style value for Widget border color.
--
-- @within Properties
-- @function .strokeColor
-- @usage style.strokeColor = {1,1,1,1}
-- @usage print( style.strokeColor )

RectangleStyle.__getters.strokeColor = StyleHelp.__getters.strokeColor
RectangleStyle.__setters.strokeColor = StyleHelp.__setters.strokeColor

--== strokeWidth

--- [**style**] set/get Style value for Widget border thickness.
--
-- @within Properties
-- @function .strokeWidth
-- @usage style.strokeWidth = 2
-- @usage print( style.strokeWidth )

RectangleStyle.__getters.strokeWidth = StyleHelp.__getters.strokeWidth
RectangleStyle.__setters.strokeWidth = StyleHelp.__setters.strokeWidth




function RectangleStyle:setFillColor( ... )
	self.fillColor = {...}
end
function RectangleStyle:setStrokeColor( ... )
	self.strokeColor = {...}
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none




return RectangleStyle
