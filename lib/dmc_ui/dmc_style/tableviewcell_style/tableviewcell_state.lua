--====================================================================--
-- dmc_ui/dmc_style/tableviewcell_style/tableviewcell_state.lua
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
--== DMC Corona UI : TableViewCell State Style
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
--== DMC UI : newButtonStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local BaseStyle = require( ui_find( 'core.style' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local Style = nil



--====================================================================--
--== TableViewCell-State Style Class
--====================================================================--


--- TableViewCellState Style.
-- This style is not to be created directly. The @{Style.TableViewCell} creates them for you.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.TableViewCellState

local TableViewCellStateStyle = newClass( BaseStyle, {name="TableViewCell State Style"} )

--== Class Constants

TableViewCellStateStyle.TYPE = uiConst.TABLEVIEWCELL_STATE

TableViewCellStateStyle._CHILDREN = {
	label=true,
	detail=true,
	background=true
}

TableViewCellStateStyle.__base_style__ = nil

TableViewCellStateStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	-- taken from the TableViewCell Style when they change there
	accessory=true,
	cellLayout=true,
	cellMargin=true,
	contentMargin=true,

	-- Copyable properties
	font=native.systemFont
}

TableViewCellStateStyle._EXCLUDE_PROPERTY_CHECK = nil

TableViewCellStateStyle._STYLE_DEFAULTS = {
	name='tableviewcell-state-default-style',
	debugOn=false,
	width=100,
	height=40,
	anchorX=0,
	anchorY=1,

	accessory='no-accessory',
	cellLayout='default-layout',
	cellMargin=0,
	contentMargin=0,

	labelY=0,
	detailY=0,

	label={
		anchorY=1,
		textColor={0,0,0,1},
		font=native.systemFontBold,
		fontSize=10
	},
	detail={
		textColor={0,0,0,1},
		font=native.systemFontBold,
		fontSize=8
	},
	background={
		type='rectangle',
		view={
			fillColor={1,1,1,1},
			strokeWidth=1,
			strokeColor={0,0,0,1},
		}
	}

}

TableViewCellStateStyle._TEST_DEFAULTS = {
	name='button-state-test-style',
	debugOn=false,
	width=201,
	height=202,
	anchorX=204,
	anchorY=206,

	align='center-state',
	isHitActive=true,
	cellMargin=210,
	marginY=210,
	offsetX=212,
	offsetY=212,

	label={
		textColor={220,220,220,221},
		font=native.systemFontBold,
		fontSize=228
	},
	background={
		type='rounded',
		view={
			fillColor={230,230,230,231},
			strokeWidth=238,
			strokeColor={232,232,232,231},
		}
	}

}

TableViewCellStateStyle.MODE = uiConst.RUN_MODE
TableViewCellStateStyle._DEFAULTS = TableViewCellStateStyle._STYLE_DEFAULTS

--== Event Constants

TableViewCellStateStyle.EVENT = 'tableviewcell-state-style-event'


--======================================================--
-- Start: Setup DMC Objects

function TableViewCellStateStyle:__init__( params )
	-- print( "TableViewCellStateStyle:__init__", params )
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

	self._accessory = nil
	self._cellLayout = nil
	self._cellMargin = nil
	self._contentMargin = nil
	self._labelX = nil
	self._detailX = nil

	--== Object Refs ==--

	-- these are other style objects
	self._background = nil -- Background
	self._detail = nil -- Text
	self._label = nil -- Text

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


-- a Background structure without Background's default type ('rounded'):
-- a background with no type then inherits its type (the rectangle)
local function createBackgroundStructure( src )
	src = src or {}
	return {
		type=src.type,
		view={}
	}
end


function TableViewCellStateStyle.initialize( manager, params )
	-- print( "TableViewCellStateStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		TableViewCellStateStyle.MODE = params.mode
		TableViewCellStateStyle._DEFAULTS = TableViewCellStateStyle._TEST_DEFAULTS
	end
	local defaults = TableViewCellStateStyle._DEFAULTS

	TableViewCellStateStyle._setDefaults( TableViewCellStateStyle, {defaults=defaults} )
end


function TableViewCellStateStyle.createStyleStructure( src )
	-- print( "TableViewCellStateStyle.createStyleStructure", src )
	src = src or {}
	--==--
	return {
		detail=Style.Text.createStyleStructure( src.detail ),
		label=Style.Text.createStyleStructure( src.label ),
		background=createBackgroundStructure( src.background )
	}
end


function TableViewCellStateStyle.addMissingDestProperties( dest, src )
	-- print( "TableViewCellStateStyle.addMissingDestProperties", dest, src )
	assert( dest, "TableViewCellStateStyle.addMissingDestProperties missing arg 'dest'" )
	--==--
	local srcs = { TableViewCellStateStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.accessory==nil then dest.accessory=src.accessory end
		if dest.cellLayout==nil then dest.cellLayout=src.cellLayout end
		if dest.contentMargin==nil then dest.contentMargin=src.contentMargin end
		if dest.cellMargin==nil then dest.cellMargin=src.cellMargin end
		if dest.labelY==nil then dest.labelY=src.labelY end
		if dest.detailY==nil then dest.detailY=src.detailY end

		--== Additional properties to be handed down to children

		-- if dest.font==nil then dest.font=src.font end
		-- if dest.fontSize==nil then dest.fontSize=src.fontSize end

	end

	dest = TableViewCellStateStyle._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function TableViewCellStateStyle._addMissingChildProperties( dest, src )
	-- print( "TableViewCellStateStyle._addMissingChildProperties", dest, src )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style missing property '%s'"
	local StyleClass, child

	child = dest.detail
	assert( child, sfmt( eStr, 'detail' ) )
	StyleClass = Style.Text
	dest.detail = StyleClass.addMissingDestProperties( child, src )

	child = dest.label
	assert( child, sfmt( eStr, 'label' ) )
	StyleClass = Style.Text
	dest.label = StyleClass.addMissingDestProperties( child, src )

	child = dest.background
	assert( child, sfmt( eStr, 'background' ) )
	StyleClass = Style.Background
	dest.background = StyleClass.addMissingDestProperties( child, src )

	return dest
end


function TableViewCellStateStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "TableViewCellStateStyle.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.accessory~=nil and dest.accessory==nil) or force then
		dest.accessory=src.accessory
	end
	if (src.cellLayout~=nil and dest.cellLayout==nil) or force then
		dest.cellLayout=src.cellLayout
	end
	if (src.contentMargin~=nil and dest.contentMargin==nil) or force then
		dest.contentMargin=src.contentMargin
	end
	if (src.cellMargin~=nil and dest.cellMargin==nil) or force then
		dest.cellMargin=src.cellMargin
	end
	if (src.labelY~=nil and dest.labelY==nil) or force then
		dest.labelY=src.labelY
	end
	if (src.detailY~=nil and dest.detailY==nil) or force then
		dest.detailY=src.detailY
	end

	return dest
end


function TableViewCellStateStyle._verifyStyleProperties( src, exclude )
	-- print( "TableViewCellStateStyle._verifyStyleProperties", src, exclude )
	assert( src, "TableViewCellStateStyle:verifyStyleProperties requires source" )
	--==--
	local emsg = "Style (TableViewCellStateStyle) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	if not src.accessory then
		print(sfmt(emsg,'accessory')) ; is_valid=false
	end
	if not src.cellLayout then
		print(sfmt(emsg,'cellLayout')) ; is_valid=false
	end
	if not src.contentMargin then
		print(sfmt(emsg,'contentMargin')) ; is_valid=false
	end
	if not src.cellMargin then
		print(sfmt(emsg,'cellMargin')) ; is_valid=false
	end
	if not src.labelY then
		print(sfmt(emsg,'labelY')) ; is_valid=false
	end
	if not src.detailY then
		print(sfmt(emsg,'detailY')) ; is_valid=false
	end

	-- check sub-styles

	local StyleClass, child

	child = src.detail
	if not child then
		print( "TableViewCellStateStyle child test skipped for 'detail'" )
		is_valid=false
	else
		StyleClass = Style.Text
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.label
	if not child then
		print( "TableViewCellStateStyle child test skipped for 'label'" )
		is_valid=false
	else
		StyleClass = Style.Text
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.background
	if not child then
		print( "TableViewCellStateStyle child test skipped for 'background'" )
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

function TableViewCellStateStyle.__getters:background()
	-- print( "TableViewCellStateStyle.__getters:background", self._background )
	return self._background
end
function TableViewCellStateStyle.__setters:background( data )
	-- print( "TableViewCellStateStyle.__setters:background", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Background
	local inherit = self._inherit and self._inherit._background or self._inherit

	self._background = StyleClass:createStyleFrom{
		inherit=inherit,
		parent=self,
		data=data
	}

end


function TableViewCellStateStyle.__getters:detail()
	-- print( "TableViewCellStateStyle.__getters:detail", data )
	return self._detail
end
function TableViewCellStateStyle.__setters:detail( data )
	-- print( "TableViewCellStateStyle.__setters:detail", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Text
	local inherit = self._inherit and self._inherit._detail or self._inherit

	self._detail = StyleClass:createStyleFrom{
		inherit=inherit,
		parent=self,
		data=data
	}
end


function TableViewCellStateStyle.__getters:label()
	-- print( "TableViewCellStateStyle.__getters:label", data )
	return self._label
end
function TableViewCellStateStyle.__setters:label( data )
	-- print( "TableViewCellStateStyle.__setters:label", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Text
	local inherit = self._inherit and self._inherit._label or self._inherit

	self._label = StyleClass:createStyleFrom{
		inherit=inherit,
		parent=self,
		data=data
	}
end


--======================================================--
-- Access to style properties

--== accessory

function TableViewCellStateStyle.__getters:accessory()
	-- print( "TableViewCellStateStyle.__getters:accessory" )
	local value = self._accessory
	if value==nil and self._inherit then
		value = self._inherit.accessory
	end
	return value
end
function TableViewCellStateStyle.__setters:accessory( value )
	-- print( "TableViewCellStateStyle.__setters:accessory", value )
	assert( type(value)=='string' )
	--==--
	if value == self._accessory then return end
	self._accessory = value
	self:_dispatchChangeEvent( 'accessory', value )
end


--== cellLayout

function TableViewCellStateStyle.__getters:cellLayout()
	-- print( "TableViewCellStateStyle.__getters:cellLayout" )
	local value = self._cellLayout
	if value==nil and self._inherit then
		value = self._inherit.cellLayout
	end
	return value
end
function TableViewCellStateStyle.__setters:cellLayout( value )
	-- print( "TableViewCellStateStyle.__setters:cellLayout", value )
	assert( type(value)=='string' )
	--==--
	if value == self._cellLayout then return end
	self._cellLayout = value
	self:_dispatchChangeEvent( 'cellLayout', value )
end


--== contentMargin

function TableViewCellStateStyle.__getters:contentMargin()
	-- print( "TableViewCellStateStyle.__getters:contentMargin" )
	local value = self._contentMargin
	if value==nil and self._inherit then
		value = self._inherit.contentMargin
	end
	return value
end
function TableViewCellStateStyle.__setters:contentMargin( value )
	-- print( "TableViewCellStateStyle.__setters:contentMargin", value )
	assert( type(value)=='number' and value>=0 )
	--==--
	if value == self._contentMargin then return end
	self._contentMargin = value
	self:_dispatchChangeEvent( 'contentMargin', value )
end


--== cellMargin

function TableViewCellStateStyle.__getters:cellMargin()
	-- print( "TableViewCellStateStyle.__getters:cellMargin" )
	local value = self._cellMargin
	if value==nil and self._inherit then
		value = self._inherit.cellMargin
	end
	return value
end
function TableViewCellStateStyle.__setters:cellMargin( value )
	-- print( "TableViewCellStateStyle.__setters:cellMargin", value )
	assert( type(value)=='number' and value>=0 )
	--==--
	if value == self._cellMargin then return end
	self._cellMargin = value
	self:_dispatchChangeEvent( 'cellMargin', value )
end

--== labelY

function TableViewCellStateStyle.__getters:labelY()
	-- print( "TableViewCellStateStyle.__getters:labelY" )
	local value = self._labelY
	if value==nil and self._inherit then
		value = self._inherit.labelY
	end
	return value
end
function TableViewCellStateStyle.__setters:labelY( value )
	-- print( "TableViewCellStateStyle.__setters:labelY", value )
	assert( type(value)=='number' and value>=0 )
	--==--
	if value == self._labelY then return end
	self._labelY = value
	self:_dispatchChangeEvent( 'labelY', value )
end

--== detailY

function TableViewCellStateStyle.__getters:detailY()
	-- print( "TableViewCellStateStyle.__getters:detailY" )
	local value = self._detailY
	if value==nil and self._inherit then
		value = self._inherit.detailY
	end
	return value
end
function TableViewCellStateStyle.__setters:detailY( value )
	-- print( "TableViewCellStateStyle.__setters:detailY", value )
	assert( type(value)=='number' and value>=0 )
	--==--
	if value == self._detailY then return end
	self._detailY = value
	self:_dispatchChangeEvent( 'detailY', value )
end



--======================================================--
-- Misc

function TableViewCellStateStyle:_doChildrenInherit( value )
	-- print( "TableViewCellStateStyle", value, self )
	if not self._isInitialized then return end
	self._background.inherit = value and value.background or value
	self._detail.inherit = value and value.detail or value
	self._label.inherit = value and value.label or value
end


function TableViewCellStateStyle:_clearChildrenProperties( style, params )
	-- print( "TableViewCellStateStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(TableViewCellStateStyle) )
	end
	--==--
	local substyle

	substyle = style and style.background
	self._background:_clearProperties( substyle, params )

	substyle = style and style.detail
	self._detail:_clearProperties( substyle, params )

	substyle = style and style.label
	self._label:_clearProperties( substyle, params )
end



--====================================================================--
--== Private Methods


function TableViewCellStateStyle:_destroyChildren()
	-- print( 'TableViewCellStateStyle:_destroyChildren', self )

	self._background:removeSelf()
	self._background=nil

	self._detail:removeSelf()
	self._detail=nil

	self._label:removeSelf()
	self._label=nil
end



function TableViewCellStateStyle:_prepareData( data, dataSrc, params )
	-- print( "TableViewCellStateStyle:_prepareData", data )
	params = params or {}
	--==--
	local inherit = params.inherit
	local StyleClass
	local src, dest, tmp

	if not data then
		data = TableViewCellStateStyle.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	StyleClass = Style.Text
	if not src.detail then
		tmp = dataSrc and dataSrc.detail
		src.detail = StyleClass.createStyleStructure( tmp )
	end

	StyleClass = Style.Text
	if not src.label then
		tmp = dataSrc and dataSrc.label
		src.label = StyleClass.createStyleStructure( tmp )
	end

	StyleClass = Style.Background
	if not src.background then
		tmp = dataSrc and dataSrc.background
		src.background = createBackgroundStructure( tmp )
	end

	--== process children

	StyleClass = Style.Text
	dest = src.detail
	src.detail = StyleClass.copyExistingSrcProperties( dest, src )

	StyleClass = Style.Text
	dest = src.label
	src.label = StyleClass.copyExistingSrcProperties( dest, src )

	StyleClass = Style.Background
	dest = src.background
	src.background = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end



--====================================================================--
--== Event Handlers


-- none




return TableViewCellStateStyle
