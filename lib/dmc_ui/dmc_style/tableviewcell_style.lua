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
--== DMC Corona UI : TableViewCell Style
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
--== DMC UI : newTableViewCell
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
local Style = nil



--====================================================================--
--== TableViewCell Style Class
--====================================================================--

--- TableViewCell Style.
-- A style object for a TableViewCell.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.TableViewCell
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newTableViewCellStyle()

local TableViewCell = newClass( BaseStyle, {name="TableViewCell Style"} )

--== Class Constants

TableViewCell.TYPE = uiConst.TABLEVIEWCELL

TableViewCell.__base_style__ = nil

TableViewCell._CHILDREN = {
	inactive=true,
	active=true
}

TableViewCell._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	accessory=true,
	cellLayout=true,
	cellMargin=true,
	contentMargin=true,
}

TableViewCell._EXCLUDE_PROPERTY_CHECK = nil

TableViewCell._STYLE_DEFAULTS = {
	name='tableviewcell-default-style',
	debugOn=false,
	width=100,
	height=30,
	anchorX=0,
	anchorY=1,

	accessory=uiConst.TABLEVIEWCELL_DISCLOSURE_INDICATOR,
	cellLayout=uiConst.TABLEVIEWCELL_SUBTITLE_LAYOUT,
	cellMargin=5,
	contentMargin=5,

	inactive={ -- << this is a TableViewCell State Style State
		--[[
		Can be copied from TableViewCell
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* accessory
		* cellLayout
		* cellMargin/marginY
		* contentMargin
		--]]
		labelY=10,
		detailY=22,

		label={
			-- anchorY=0.5,
			align='left',
			textColor={0,0,0,1},
			font=native.systemFontBold,
			fontSize=11
		},
		detail={
			-- anchorY=0.5,
			align='left',
			textColor={0.5,0.5,0.5,1},
			font=native.systemFont,
			fontSize=9
		},
		background={
			type='rectangle',
			view={
				fillColor={1,1,1,1},
				strokeWidth=0,
				strokeColor={0,0,0,1},
			}
		}
	},

	active={ -- << this is a TableViewCell State Style State
		--[[
		Can be copied from TableViewCell
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* accessory
		* cellLayout
		* cellMargin/marginY
		* contentMargin
		--]]
		labelY=10,
		detailY=22,
		label={
			align='left',
			textColor={0.1,0.4,0.1,1},
			font=native.systemFontBold,
			fontSize=11
		},
		detail={
			align='left',
			textColor={0.6,0.8,0.6,1},
			font=native.systemFont,
			fontSize=9
		},
		background={
			type='rectangle',
			view={
				fillColor={0.9,0.9,0.9,1},
				strokeWidth=0,
				strokeColor={0,0,0,1},
			}
		}
	},

}

TableViewCell._TEST_DEFAULTS = {
	debugOn=true,
	width=117,
	height=nil,
	anchorX=101,
	anchorY=102,

	align='test-center',
	fillColor={101,102,103,104},
	font=native.systemFont,
	fontSize=101,
	cellMargin=102,
	marginY=103,
	textColor={111,112,113,114},

	strokeColor={121,122,123,124},
	strokeWidth=111,
}

TableViewCell.MODE = uiConst.RUN_MODE
TableViewCell._DEFAULTS = TableViewCell._STYLE_DEFAULTS

--== Event Constants

TableViewCell.EVENT = 'tableviewcell-style-event'


--======================================================--
-- Start: Setup DMC Objects

function TableViewCell:__init__( params )
	-- print( "TableViewCell:__init__", params )
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

	--== Object Refs ==--

	-- these are other style objects
	-- TableViewCellState
	self._active = nil
	self._inactive = nil

	self._accessory = nil
	self._cellLayout = nil
	self._cellMargin = nil
	self._contentMargin = nil

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function TableViewCell.initialize( manager, params )
	-- print( "TableViewCell.initialize", manager, params.mode )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		TableViewCell.MODE = params.mode
		TableViewCell._DEFAULTS = TableViewCell._TEST_DEFAULTS
	end
	local defaults = TableViewCell._DEFAULTS

	TableViewCell._setDefaults( TableViewCell, {defaults=defaults} )
end


function TableViewCell.createStyleStructure( src )
	-- print( "TableViewCell.createStyleStructure", src )
	src = src or {}
	--==--
	local StyleClass = Style.TableViewCellState
	return {
		inactive=StyleClass.createStyleStructure( src.inactive ),
		active=StyleClass.createStyleStructure( src.active ),
	}
end


function TableViewCell.addMissingDestProperties( dest, src )
	-- print( "TableViewCell.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { TableViewCell._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		--== Additional properties to be handed down to children

		if dest.anchorX==nil then dest.anchorX=src.anchorX end
		if dest.anchorY==nil then dest.anchorY=src.anchorY end

		if dest.accessory==nil then dest.accessory=src.accessory end
		if dest.cellLayout==nil then dest.cellLayout=src.cellLayout end
		if dest.contentMargin==nil then dest.contentMargin=src.contentMargin end
		if dest.cellMargin==nil then dest.cellMargin=src.cellMargin end

	end

	dest = TableViewCell._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function TableViewCell._addMissingChildProperties( dest, src )
	-- print( "TableViewCell._addMissingChildProperties", dest, src )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style missing property '%s'"
	local StyleClass = Style.TableViewCellState
	local child

	child = dest.inactive
	assert( child, sfmt( eStr, 'inactive' ) )
	dest.inactive = StyleClass.addMissingDestProperties( child, src )

	child = dest.active
	assert( child, sfmt( eStr, 'active' ) )
	dest.active = StyleClass.addMissingDestProperties( child, src )

	return dest
end


-- copyExistingSrcProperties()
--
function TableViewCell.copyExistingSrcProperties( dest, src, params )
	-- print( "TableViewCell.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	BaseStyle.copyExistingSrcProperties( dest, src, params )

	return dest
end


-- _verifyStyleProperties()
--
function TableViewCell._verifyStyleProperties( src )
	-- print( "TableViewCell._verifyStyleProperties", src )
	local emsg = "Style (TableViewCell) requires property '%s'"

	-- exclude width/height because nil is valid value
	local is_valid = BaseStyle._verifyStyleProperties( src, {width=true, height=true} )

	local StyleClass = Style.TableViewCellState
	local child

	child = src.inactive
	if not child then
		print( "ButtonStyle child test skipped for 'inactive'" )
		is_valid=false
	else
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.active
	if not child then
		print( "ButtonStyle child test skipped for 'active'" )
		is_valid=false
	else
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

--== .active

function TableViewCell.__getters:active()
	-- print( "TableViewCell.__getters:active", self._active )
	return self._active
end
function TableViewCell.__setters:active( data )
	-- print( "TableViewCell.__setters:active", data )
	assert( data==nil or type(data)=='string' or type( data )=='table' )
	--==--
	local StyleClass = Style.TableViewCellState
	local inherit = self._inherit and self._inherit._active

	self._active = StyleClass:createStyleFrom{
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== .inactive

function TableViewCell.__getters:inactive()
	-- print( "TableViewCell.__getters:inactive", self._inactive )
	return self._inactive
end
function TableViewCell.__setters:inactive( data )
	-- print( "TableViewCell.__setters:inactive", data )
	assert( data==nil or type(data)=='string' or type( data )=='table' )
	--==--
	local StyleClass = Style.TableViewCellState
	local inherit = self._inherit and self._inherit._inactive

	self._inactive = StyleClass:createStyleFrom{
		inherit=inherit,
		parent=self,
		data=data
	}
end


--======================================================--
-- Access to style properties

-- the states ('inactive', 'active') take these when they change here

--== .accessory

function TableViewCell.__getters:accessory()
	local value = self._accessory
	if value==nil and self._inherit then
		value = self._inherit.accessory
	end
	return value
end
function TableViewCell.__setters:accessory( value )
	assert( (type(value)=='string') or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._accessory then return end
	self._accessory = value
	self:_dispatchChangeEvent( 'accessory', value )
end

--== .cellLayout

function TableViewCell.__getters:cellLayout()
	local value = self._cellLayout
	if value==nil and self._inherit then
		value = self._inherit.cellLayout
	end
	return value
end
function TableViewCell.__setters:cellLayout( value )
	assert( (type(value)=='string') or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._cellLayout then return end
	self._cellLayout = value
	self:_dispatchChangeEvent( 'cellLayout', value )
end

--== .cellMargin

function TableViewCell.__getters:cellMargin()
	local value = self._cellMargin
	if value==nil and self._inherit then
		value = self._inherit.cellMargin
	end
	return value
end
function TableViewCell.__setters:cellMargin( value )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._cellMargin then return end
	self._cellMargin = value
	self:_dispatchChangeEvent( 'cellMargin', value )
end

--== .contentMargin

function TableViewCell.__getters:contentMargin()
	local value = self._contentMargin
	if value==nil and self._inherit then
		value = self._inherit.contentMargin
	end
	return value
end
function TableViewCell.__setters:contentMargin( value )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._contentMargin then return end
	self._contentMargin = value
	self:_dispatchChangeEvent( 'contentMargin', value )
end

--== verifyProperties

function TableViewCell:verifyProperties()
	-- print( "TableViewCell:verifyProperties" )
	return TableViewCell._verifyStyleProperties( self )
end



--====================================================================--
--== Private Methods


function TableViewCell:_doChildrenInherit( value )
	-- print( "TableViewCell:_doChildrenInherit", value, self )
	if not self._isInitialized then return end

	self._inactive.inherit = value and value.inactive or value
	self._active.inherit = value and value.active or value
end


function TableViewCell:_clearChildrenProperties( style, params )
	-- print( "TableViewCell:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(TableViewCell) )
	end
	--==--
	local substyle

	substyle = style and style.active
	self._inactive:_clearProperties( substyle, params )

	substyle = style and style.inactive
	self._active:_clearProperties( substyle, params )

end

function TableViewCell:_destroyChildren()
	-- print( 'TableViewCell:_destroyChildren', self )

	self._active:removeSelf()
	self._active=nil

	self._inactive:removeSelf()
	self._inactive=nil
end



-- we could have nil, Lua structure, or Instance
--
-- TODO: more work when inheriting, etc (Background Style)
function TableViewCell:_prepareData( data, dataSrc, params )
	-- print("TableViewCell:_prepareData", data, self )
	params = params or {}
	--==--

	-- local inherit = params.inherit
	local StyleClass
	local src, dest, tmp

	if not data then
		data = TableViewCell.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	StyleClass = Style.TableViewCellState
	if not src.active then
		tmp = dataSrc and dataSrc.active
		src.active = StyleClass.createStyleStructure( tmp )
	end
	if not src.inactive then
		tmp = dataSrc and dataSrc.inactive
		src.inactive = StyleClass.createStyleStructure( tmp )
	end

	--== process children

	dest = src.active
	src.active = StyleClass.copyExistingSrcProperties( dest, src )

	dest = src.inactive
	src.inactive = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end


--====================================================================--
--== Event Handlers


-- none



return TableViewCell
