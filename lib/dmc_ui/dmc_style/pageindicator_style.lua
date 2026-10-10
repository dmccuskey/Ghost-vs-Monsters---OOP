--====================================================================--
-- dmc_ui/dmc_style/pageindicator_style.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2026 David McCuskey

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
--== DMC Corona UI : PageIndicator Style
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
--== DMC UI : newPageIndicatorStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local uiConst = require( ui_find( 'ui_constants' ) )

local BaseStyle = require( ui_find( 'core.style' ) )
local StyleHelp = require( ui_find( 'core.style_helper' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

local sfmt = string.format
local tinsert = table.insert
local type = type

--== To be set in initialize()
local Style = nil



--====================================================================--
--== PageIndicator Style Class
--====================================================================--


--- PageIndicator Style Class.
-- a Style object for a PageIndicator Widget.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.PageIndicator
-- @usage
-- local dUI = require 'dmc_ui'
-- local style = dUI.newPageIndicatorStyle()

local PageIndicator = newClass( BaseStyle, {name="PageIndicator Style"} )

--== Class Constants

PageIndicator.TYPE = uiConst.PAGEINDICATOR

PageIndicator.__base_style__ = nil

PageIndicator._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,
	currentDotColor=true,
	dotColor=true,
	dotSize=true,
	dotSpacing=true,
	marginX=true,
	marginY=true,
}

PageIndicator._EXCLUDE_PROPERTY_CHECK = {}

-- width, height: 0 is the size of the row of dots with its margins
PageIndicator._STYLE_DEFAULTS = {
	debugOn=false,
	width=0,
	height=0,
	anchorX=0.5,
	anchorY=0.5,
	currentDotColor={0,0,0,0.8},
	dotColor={0,0,0,0.25},
	dotSize=7,
	dotSpacing=9,
	marginX=12,
	marginY=12,
}

PageIndicator._TEST_DEFAULTS = {
	debugOn=true,
	width=117,
	height=118,
	anchorX=101,
	anchorY=102,
	currentDotColor={102,103,104},
	dotColor={105,106,107},
	dotSize=108,
	dotSpacing=109,
	marginX=110,
	marginY=111,
}

PageIndicator.MODE = uiConst.RUN_MODE
PageIndicator._DEFAULTS = PageIndicator._STYLE_DEFAULTS

--== Event Constants

PageIndicator.EVENT = 'pageindicator-style-event'


--======================================================--
-- Start: Setup DMC Objects

function PageIndicator:__init__( params )
	-- print( "PageIndicator:__init__", params )
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

	self._currentDotColor = nil
	self._dotColor = nil
	self._dotSize = nil
	self._dotSpacing = nil
	self._marginX = nil
	self._marginY = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function PageIndicator.initialize( manager, params )
	-- print( "PageIndicator.initialize", manager, params.mode )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		PageIndicator.MODE = params.mode
		PageIndicator._DEFAULTS = PageIndicator._TEST_DEFAULTS
	end
	local defaults = PageIndicator._DEFAULTS

	PageIndicator._setDefaults( PageIndicator, {defaults=defaults} )
end


function PageIndicator.addMissingDestProperties( dest, src )
	-- print( "PageIndicator.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { PageIndicator._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]
		if dest.currentDotColor==nil then dest.currentDotColor=src.currentDotColor end
		if dest.dotColor==nil then dest.dotColor=src.dotColor end
		if dest.dotSize==nil then dest.dotSize=src.dotSize end
		if dest.dotSpacing==nil then dest.dotSpacing=src.dotSpacing end
		if dest.marginX==nil then dest.marginX=src.marginX end
		if dest.marginY==nil then dest.marginY=src.marginY end
	end

	return dest
end


-- copyExistingSrcProperties()
--
function PageIndicator.copyExistingSrcProperties( dest, src, params )
	-- print( "PageIndicator.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.currentDotColor~=nil and dest.currentDotColor==nil) or force then
		dest.currentDotColor=src.currentDotColor
	end
	if (src.dotColor~=nil and dest.dotColor==nil) or force then
		dest.dotColor=src.dotColor
	end
	if (src.dotSize~=nil and dest.dotSize==nil) or force then
		dest.dotSize=src.dotSize
	end
	if (src.dotSpacing~=nil and dest.dotSpacing==nil) or force then
		dest.dotSpacing=src.dotSpacing
	end
	if (src.marginX~=nil and dest.marginX==nil) or force then
		dest.marginX=src.marginX
	end
	if (src.marginY~=nil and dest.marginY==nil) or force then
		dest.marginY=src.marginY
	end

	return dest
end


-- _verifyStyleProperties()
--
function PageIndicator._verifyStyleProperties( src )
	-- print( "PageIndicator._verifyStyleProperties", src )
	local emsg = "Style (PageIndicator) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src )

	if not src.currentDotColor then
		print(sfmt(emsg,'currentDotColor')) ; is_valid=false
	end
	if not src.dotColor then
		print(sfmt(emsg,'dotColor')) ; is_valid=false
	end
	if not src.dotSize then
		print(sfmt(emsg,'dotSize')) ; is_valid=false
	end
	if not src.dotSpacing then
		print(sfmt(emsg,'dotSpacing')) ; is_valid=false
	end
	if not src.marginX then
		print(sfmt(emsg,'marginX')) ; is_valid=false
	end
	if not src.marginY then
		print(sfmt(emsg,'marginY')) ; is_valid=false
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--== .currentDotColor

--- [**style**] set/get Style value for the color of the dot of the current page.
--
-- @within Properties
-- @function .currentDotColor
-- @usage style.currentDotColor = { 1, 1, 1, 1 }
-- @usage print( style.currentDotColor )

PageIndicator.__getters.currentDotColor = StyleHelp.__getters.currentDotColor
PageIndicator.__setters.currentDotColor = StyleHelp.__setters.currentDotColor

--== .dotColor

--- [**style**] set/get Style value for the color of the dots of the other pages.
--
-- @within Properties
-- @function .dotColor
-- @usage style.dotColor = { 1, 1, 1, 0.4 }
-- @usage print( style.dotColor )

PageIndicator.__getters.dotColor = StyleHelp.__getters.dotColor
PageIndicator.__setters.dotColor = StyleHelp.__setters.dotColor

--== .dotSize

--- [**style**] set/get Style value for the diameter of a dot.
--
-- @within Properties
-- @function .dotSize
-- @usage style.dotSize = 10
-- @usage print( style.dotSize )

function PageIndicator.__getters:dotSize()
	local value = self._dotSize
	if value==nil and self._inherit then
		value = self._inherit.dotSize
	end
	return value
end
function PageIndicator.__setters:dotSize( value )
	-- print( "PageIndicator.__setters:dotSize", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._dotSize then return end
	self._dotSize = value
	self:_dispatchChangeEvent( 'dotSize', value )
end

--== .dotSpacing

--- [**style**] set/get Style value for the space between two dots.
--
-- @within Properties
-- @function .dotSpacing
-- @usage style.dotSpacing = 12
-- @usage print( style.dotSpacing )

function PageIndicator.__getters:dotSpacing()
	local value = self._dotSpacing
	if value==nil and self._inherit then
		value = self._inherit.dotSpacing
	end
	return value
end
function PageIndicator.__setters:dotSpacing( value )
	-- print( "PageIndicator.__setters:dotSpacing", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._dotSpacing then return end
	self._dotSpacing = value
	self:_dispatchChangeEvent( 'dotSpacing', value )
end

--== .marginX

--- [**style**] set/get Style value for the space left and right of the row of dots.
--
-- @within Properties
-- @function .marginX
-- @usage style.marginX = 20
-- @usage print( style.marginX )

PageIndicator.__getters.marginX = StyleHelp.__getters.marginX
PageIndicator.__setters.marginX = StyleHelp.__setters.marginX

--== .marginY

--- [**style**] set/get Style value for the space above and below the row of dots.
--
-- @within Properties
-- @function .marginY
-- @usage style.marginY = 20
-- @usage print( style.marginY )

PageIndicator.__getters.marginY = StyleHelp.__getters.marginY
PageIndicator.__setters.marginY = StyleHelp.__setters.marginY


--== verifyProperties

function PageIndicator:verifyProperties()
	-- print( "PageIndicator:verifyProperties" )
	return PageIndicator._verifyStyleProperties( self )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none



return PageIndicator
