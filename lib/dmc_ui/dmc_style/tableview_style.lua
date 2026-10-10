--====================================================================--
-- dmc_ui/dmc_style/tableview_style.lua
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
--== DMC Corona UI : TableView Style
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
--== DMC UI : newTableView
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
--== TableView Style Class
--====================================================================--


--- TableView Style Class.
-- a style object for a TableView Widget.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.TableView
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newTableViewStyle()

local TableView = newClass( BaseStyle, {name="TableView Style"} )

--- Class Constants.
-- @section

--== Class Constants

TableView.TYPE = uiConst.TABLEVIEW

TableView.__base_style__ = nil

TableView._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	fillColor=true,
	indicatorColor=true,
	marginX=true,
	marginY=true,
}

TableView._EXCLUDE_PROPERTY_CHECK = {}

TableView._STYLE_DEFAULTS = {
	debugOn=false,
	width=nil,
	height=nil,
	anchorX=0.5,
	anchorY=0.5,

	fillColor={0,0,0,0},
	indicatorColor={0,0,0,0.4},
	marginX=0,
	marginY=0,
}

TableView._TEST_DEFAULTS = {
	debugOn=true,
	width=117,
	height=nil,
	anchorX=101,
	anchorY=102,

	fillColor={101,102,103,104},
	indicatorColor={105,106,107},
	marginX=102,
	marginY=103,
}

TableView.MODE = uiConst.RUN_MODE
TableView._DEFAULTS = TableView._STYLE_DEFAULTS

--== Event Constants

TableView.EVENT = 'tableview-style-event'


--======================================================--
-- Start: Setup DMC Objects

function TableView:__init__( params )
	-- print( "TableView:__init__", params )
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
	self._font = nil
	self._marginX = nil
	self._marginY = nil
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function TableView.initialize( manager, params )
	-- print( "TableView.initialize", manager, params.mode )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		TableView.MODE = params.mode
		TableView._DEFAULTS = TableView._TEST_DEFAULTS
	end
	local defaults = TableView._DEFAULTS

	TableView._setDefaults( TableView, {defaults=defaults} )
end


function TableView.addMissingDestProperties( dest, src )
	-- print( "TableView.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { TableView._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.fillColor==nil then dest.fillColor=src.fillColor end
		if dest.indicatorColor==nil then dest.indicatorColor=src.indicatorColor end
		if dest.marginX==nil then dest.marginX=src.marginX end
		if dest.marginY==nil then dest.marginY=src.marginY end

	end

	return dest
end


-- copyExistingSrcProperties()
--
function TableView.copyExistingSrcProperties( dest, src, params )
	-- print( "TableView.copyExistingSrcProperties", dest, src )
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
function TableView._verifyStyleProperties( src )
	-- print( "TableView._verifyStyleProperties", src )
	local emsg = "Style (TableView) requires property '%s'"

	-- exclude width/height because nil is valid value
	local is_valid = BaseStyle._verifyStyleProperties( src, {width=true, height=true} )

	if not src.fillColor then
		print(sfmt(emsg,'fillColor')) ; is_valid=false
	end
	if not src.indicatorColor then
		print(sfmt(emsg,'indicatorColor')) ; is_valid=false
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


--== .fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage style.fillColor = '#ff0000'
-- @usage print( style.fillColor )

TableView.__getters.fillColor = StyleHelp.__getters.fillColor
TableView.__setters.fillColor = StyleHelp.__setters.fillColor

--== .indicatorColor

--- [**style**] set/get Style value for the color of the scroll indicators.
--
-- @within Properties
-- @function .indicatorColor
-- @usage style.indicatorColor = { 1, 1, 1, 0.5 }
-- @usage print( style.indicatorColor )

TableView.__getters.indicatorColor = StyleHelp.__getters.indicatorColor
TableView.__setters.indicatorColor = StyleHelp.__setters.indicatorColor

--== .marginX

--- [**style**] set/get Style value for Widget X-axis margin.
--
-- @within Properties
-- @function .marginX
-- @usage style.marginX = 10
-- @usage print( style.marginX )

TableView.__getters.marginX = StyleHelp.__getters.marginX
TableView.__setters.marginX = StyleHelp.__setters.marginX

--== .marginY

--- [**style**] set/get Style value for Widget Y-axis margin.
--
-- @within Properties
-- @function .marginY
-- @usage style.marginY = 10
-- @usage print( style.marginY )

TableView.__getters.marginY = StyleHelp.__getters.marginY
TableView.__setters.marginY = StyleHelp.__setters.marginY

--== verifyProperties

function TableView:verifyProperties()
	-- print( "TableView:verifyProperties" )
	return TableView._verifyStyleProperties( self )
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- none



return TableView
