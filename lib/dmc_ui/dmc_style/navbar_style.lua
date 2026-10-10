--====================================================================--
-- dmc_widget/widget_style/navbar_style.lua
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
--== DMC Corona UI : Nav Bar Widget Style
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
--== DMC UI : newNavBarStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local uiConst = require( ui_find( 'ui_constants' ) )

local BaseStyle = require( ui_find( 'core.style' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local dUI = nil
local Style = nil



--====================================================================--
--== NavBar Style Class
--====================================================================--


local NavBarStyle = newClass( BaseStyle, {name="NavBar Style"} )

--== Class Constants

NavBarStyle.TYPE = uiConst.NAVBAR

NavBarStyle.__base_style__ = nil

NavBarStyle._CHILDREN = {
	background=true
}

NavBarStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,
}

NavBarStyle._EXCLUDE_PROPERTY_CHECK = {
	background=true,
}

NavBarStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=nil, -- set in initialization()
	height=40,
	anchorX=0.5,
	anchorY=0.5,

	background={
		--[[
		Copied from NavBar
		* width
		* height
		* anchorX/Y
		--]]
		type='rectangle',
		view={
			fillColor={ 1,1,1,0.9},
			strokeWidth=0,
			strokeColor={0,0,0,0},
		}
	},
}


NavBarStyle._TEST_DEFAULTS = {
	name='navbar-test-style',
	debugOn=false,
	width=501,
	height=502,
	anchorX=503,
	anchorY=504,

	background={
		--[[
		Copied from NavBar
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
}

NavBarStyle.MODE = uiConst.RUN_MODE
NavBarStyle._DEFAULTS = NavBarStyle._STYLE_DEFAULTS

--== Event Constants

NavBarStyle.EVENT = 'navbar-style-event'


--======================================================--
-- Start: Setup DMC Objects

function NavBarStyle:__init__( params )
	-- print( "NavBarStyle:__init__", params )
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

	--== Object Refs ==--

	-- these are other style objects
	self._background = nil -- Background Style

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Support Functions


-- a Background structure without Background's default type ('rounded'):
-- a background with no type then inherits its type (the rectangle)
local function createBackgroundStructure( src )
	src = src or {}
	return {
		type=src.type,
		view={}
	}
end



--====================================================================--
--== Static Methods


function NavBarStyle.initialize( manager, params )
	-- print( "NavBarStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	dUI = manager
	Style = dUI.Style

	-- set width to screen default
	NavBarStyle._STYLE_DEFAULTS.width = dUI.WIDTH

	if params.mode==uiConst.TEST_MODE then
		NavBarStyle.MODE = params.mode
		NavBarStyle._DEFAULTS = NavBarStyle._TEST_DEFAULTS
	end
	local defaults = NavBarStyle._DEFAULTS

	NavBarStyle._setDefaults( NavBarStyle, {defaults=defaults} )

end


function NavBarStyle.createStyleStructure( src )
	-- print( "NavBarStyle.createStyleStructure", src )
	src = src or {}
	--==--
	return {
		background=createBackgroundStructure( src.background ),
	}
end


function NavBarStyle.addMissingDestProperties( dest, src )
	-- print( "NavBarStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { NavBarStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	-- for i=1,#srcs do
	-- 	local src = srcs[i]
	-- end

	dest = NavBarStyle._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function NavBarStyle._addMissingChildProperties( dest, src )
	-- print("NavBarStyle._addMissingChildProperties", dest, srcs )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style (NavBarStyle) missing property '%s'"
	local StyleClass, child

	child = dest.background
	-- assert( child, sfmt( eStr, 'background' ) )
	StyleClass = Style.Background
	dest.background = StyleClass.addMissingDestProperties( child, src )

	return dest
end


function NavBarStyle.copyExistingSrcProperties( dest, src, params)
	-- print( "NavBarStyle.copyMissingProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	return dest
end


function NavBarStyle._verifyStyleProperties( src, exclude )
	-- print("NavBarStyle._verifyStyleProperties", src, exclude )
	assert( src, "NavBarStyle:verifyStyleProperties requires source" )
	--==--
	local emsg = "Style (NavBarStyle) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	local child, StyleClass

	child = src.background
	if not child then
		print( "NavBarStyle child test skipped for 'background'" )
		is_valid=false
	else
		StyleClass = Style.Background
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

--== .background

--- get Style object for background.
-- the value will be one @{Style.Background}
--
-- @within Properties
-- @function .background
-- @usage print( style.background )

function NavBarStyle.__getters:background()
	-- print( 'NavBarStyle.__getters:background', self._background )
	return self._background
end
function NavBarStyle.__setters:background( data )
	-- print( 'NavBarStyle.__setters:background', data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Background
	local inherit = self._inherit and self._inherit._background or self._inherit

	self._background = StyleClass:createStyleFrom{
		name=NavBarStyle.BACKGROUND_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end



--======================================================--
-- Background Style Properties

--== fillColor

function NavBarStyle.__getters:backgroundFillColor()
	-- print( "NavBarStyle.__getters:backgroundFillColor" )
	return self._background.fillColor
end
function NavBarStyle.__setters:backgroundFillColor( value )
	-- print( "NavBarStyle.__setters:backgroundFillColor", value )
	self._background.fillColor = value
end

--== strokeColor

function NavBarStyle.__getters:backgroundStrokeColor()
	-- print( "NavBarStyle.__getters:backgroundStrokeColor" )
	return self._background.strokeColor
end
function NavBarStyle.__setters:backgroundStrokeColor( value )
	-- print( "NavBarStyle.__setters:backgroundStrokeColor", value )
	self._background.strokeColor = value
end

--== strokeWidth

function NavBarStyle.__getters:backgroundStrokeWidth()
	-- print( "NavBarStyle.__getters:backgroundStrokeWidth" )
	return self._background.strokeWidth
end
function NavBarStyle.__setters:backgroundStrokeWidth( value )
	-- print( "NavBarStyle.__setters:backgroundStrokeWidth", value )
	self._background.strokeWidth = value
end



--====================================================================--
--== Private Methods


function NavBarStyle:_doChildrenInherit( value )
	-- print( "NavBarStyle:_doChildrenInherit", value )
	if not self._isInitialized then return end

	self._background.inherit = value and value.background or value
end


function NavBarStyle:_clearChildrenProperties( style, params )
	-- print( "NavBarStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(NavBarStyle) )
	end
	--==--
	local substyle

	substyle = style and style.background
	self._background:_clearProperties( substyle, params )
end


function NavBarStyle:_destroyChildren()
	self._background:removeSelf()
	self._background=nil
end



-- TODO: more work when inheriting, etc (Background Style)
function NavBarStyle:_prepareData( data, dataSrc, params )
	-- print("NavBarStyle:_prepareData", data, self )
	params = params or {}
	--==--
	-- local inherit = params.inherit
	local StyleClass
	local src, dest, tmp

	if not data then
		data = NavBarStyle.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	StyleClass = Style.Background
	if not src.background then
		tmp = dataSrc and dataSrc.background
		src.background = createBackgroundStructure( tmp )
	end

	--== process children

	dest = src.background
	src.background = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end



--====================================================================--
--== Event Handlers


-- none




return NavBarStyle
