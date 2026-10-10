--====================================================================--
-- dmc_ui/dmc_style/scrollview_style.lua
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
--== DMC Corona UI : ScrollView Style
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
--== DMC UI : newScrollView
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

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
--== ScrollView Style Class
--====================================================================--


--- ScrollView Style Class.
-- a Style object for a ScrollView Widget.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.ScrollView
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newScrollViewStyle()

local ScrollView = newClass( BaseStyle, {name="ScrollView Style"} )

--== Class Constants

ScrollView.TYPE = uiConst.SCROLLVIEW

ScrollView.__base_style__ = nil

ScrollView._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,
	fillColor=true,
	indicatorColor=true,
}

ScrollView._EXCLUDE_PROPERTY_CHECK = {}

ScrollView._STYLE_DEFAULTS = {
	debugOn=false,
	width=nil,
	height=nil,
	anchorX=0.5,
	anchorY=0.5,
	fillColor={1,1,1,1},
	indicatorColor={0,0,0,0.4},
}

ScrollView._TEST_DEFAULTS = {
	debugOn=true,
	width=117,
	height=nil,
	anchorX=101,
	anchorY=102,
	fillColor={102,103,104},
	indicatorColor={105,106,107},
}

ScrollView.MODE = uiConst.RUN_MODE
ScrollView._DEFAULTS = ScrollView._STYLE_DEFAULTS

--== Event Constants

ScrollView.EVENT = 'scrollview-style-event'


--======================================================--
-- Start: Setup DMC Objects

function ScrollView:__init__( params )
	-- print( "ScrollView:__init__", params )
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

	self._fillColor = nil
	self._indicatorColor = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ScrollView.initialize( manager, params )
	-- print( "ScrollView.initialize", manager, params.mode )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		ScrollView.MODE = params.mode
		ScrollView._DEFAULTS = ScrollView._TEST_DEFAULTS
	end
	local defaults = ScrollView._DEFAULTS

	ScrollView._setDefaults( ScrollView, {defaults=defaults} )
end


function ScrollView.addMissingDestProperties( dest, src )
	-- print( "ScrollView.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { ScrollView._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]
		if dest.fillColor==nil then dest.fillColor=src.fillColor end
		if dest.indicatorColor==nil then dest.indicatorColor=src.indicatorColor end
	end

	return dest
end


-- copyExistingSrcProperties()
--
function ScrollView.copyExistingSrcProperties( dest, src, params )
	-- print( "ScrollView.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.fillColor~=nil and dest.fillColor==nil) or force then
		dest.fillColor=src.fillColor
	end
	if (src.indicatorColor~=nil and dest.indicatorColor==nil) or force then
		dest.indicatorColor=src.indicatorColor
	end

	return dest
end


-- _verifyStyleProperties()
--
function ScrollView._verifyStyleProperties( src )
	-- print( "ScrollView._verifyStyleProperties", src )
	local emsg = "Style (ScrollView) requires property '%s'"

	-- exclude width/height because nil is valid value
	local is_valid = BaseStyle._verifyStyleProperties( src, {width=true, height=true} )

	if not src.fillColor then
		print(sfmt(emsg,'fillColor')) ; is_valid=false
	end
	if not src.indicatorColor then
		print(sfmt(emsg,'indicatorColor')) ; is_valid=false
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--== .fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage widget.fillColor = 'center'
-- @usage print( widget.fillColor )

ScrollView.__getters.fillColor = StyleHelp.__getters.fillColor
ScrollView.__setters.fillColor = StyleHelp.__setters.fillColor

--== .indicatorColor

--- [**style**] set/get Style value for the color of the scroll indicators.
--
-- @within Properties
-- @function .indicatorColor
-- @usage style.indicatorColor = { 1, 1, 1, 0.5 }
-- @usage print( style.indicatorColor )

ScrollView.__getters.indicatorColor = StyleHelp.__getters.indicatorColor
ScrollView.__setters.indicatorColor = StyleHelp.__setters.indicatorColor


--== verifyProperties

function ScrollView:verifyProperties()
	-- print( "ScrollView:verifyProperties" )
	return ScrollView._verifyStyleProperties( self )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none



return ScrollView
