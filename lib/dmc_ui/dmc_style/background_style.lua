--====================================================================--
-- dmc_widget/widget_style/background_style.lua
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
--== DMC Corona UI : Background Widget Style
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
--== DMC UI : newBackgroundStyle
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
local StyleFactory = nil



--====================================================================--
--== Background Style Class
--====================================================================--

--- Background Style Class.
-- a style object for a Background Widget.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.Background
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newBackgroundStyle()

local BackgroundStyle = newClass( BaseStyle, {name="Background Style"} )

--- Class Constants.
-- @section

--== Class Constants

BackgroundStyle.TYPE = uiConst.BACKGROUND

BackgroundStyle.__base_style__ = nil

BackgroundStyle._DEFAULT_VIEWTYPE = nil -- set later

-- create multiple base-styles for Background class
-- one for each available view
--
BackgroundStyle._BASE_STYLES = {}

BackgroundStyle._CHILDREN = {
	view=true
}

BackgroundStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,
	type=true
}

BackgroundStyle._EXCLUDE_PROPERTY_CHECK = {
	type=true,
	view=true
}

BackgroundStyle._STYLE_DEFAULTS = {
	debugOn=false,
	width=76,
	height=30,
	anchorX=0.5,
	anchorY=0.5,

	-- these values can change
	type=nil,
	view=nil
}

BackgroundStyle._TEST_DEFAULTS = {
	name='background-test-style',
	debugOn=true,
	width=301,
	height=302,
	anchorX=303,
	anchorY=304,

	-- these values can change
	type=nil,
	view=nil
}


-- create multiple style structures for Background class
-- one for each available view
--
BackgroundStyle._BASE_DEFAULTS = {}

BackgroundStyle.MODE = uiConst.RUN_MODE
BackgroundStyle._DEFAULTS = BackgroundStyle._STYLE_DEFAULTS

--== Event Constants

BackgroundStyle.EVENT = 'background-style-event'

BackgroundStyle.ADDED_VIEW = 'background-added-view-event'
BackgroundStyle.REMOVING_VIEW = 'background-removing-style-event'


--======================================================--
-- Start: Setup DMC Objects

function BackgroundStyle:__init__( params )
	-- print( "BackgroundStyle:__init__", params )
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

	self._type = nil

	--== Object Refs ==--

	self._view = nil -- Background View Style

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function BackgroundStyle.initialize( manager, params )
	-- print( "BackgroundStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager
	StyleFactory = Style.BackgroundFactory

	if params.mode==uiConst.TEST_MODE then
		BackgroundStyle.MODE = params.mode
		BackgroundStyle._DEFAULTS = BackgroundStyle._TEST_DEFAULTS
	end
	local defaults = BackgroundStyle._DEFAULTS

	-- set LOCAL defaults before creating classes next
	BackgroundStyle._DEFAULT_VIEWTYPE = uiConst.ROUNDED

	BackgroundStyle._setDefaults( BackgroundStyle, {defaults=defaults} )
end


-- create empty Background Style structure
function BackgroundStyle.createStyleStructure( src )
	-- print( "BackgroundStyle.createStyleStructure", src )
	src = src or {}
	if src.type==nil then src.type = BackgroundStyle._DEFAULT_VIEWTYPE end
	--==--
	return {
		type=src.type,
		view={}
	}
end


function BackgroundStyle.addMissingDestProperties( dest, src )
	-- print( "BackgroundStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { BackgroundStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.type==nil then dest.type=src.type end

	end

	dest = BackgroundStyle._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function BackgroundStyle._addMissingChildProperties( dest, src )
	-- print( "BackgroundStyle._addMissingChildProperties", dest, src )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style (BackgroundStyle) missing property '%s'"
	local StyleClass, child

	child = dest.view
	-- assert( child, sfmt( eStr, 'view' ) )
	StyleClass = StyleFactory.getClass( dest.type )
	dest.view = StyleClass.addMissingDestProperties( child, src )

	return dest
end


-- to a new stucture
function BackgroundStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "BackgroundStyle.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.type~=nil and dest.type==nil) or force then
		dest.type=src.type
	end

	return dest
end


function BackgroundStyle._verifyStyleProperties( src, exclude )
	-- print( "BackgroundStyle._verifyStyleProperties", src, exclude )
	local emsg = "Style (BackgroundStyle) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	if not src.type then
		print(sfmt(emsg,'type')) ; is_valid=false
	end

	local StyleClass, child

	child = src.view
	if not src.type or not child then
		print( "BackgroundStyle child test skipped for 'view'" )
		is_valid=false
	else
		StyleClass = StyleFactory.getClass( src.type )
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	return is_valid
end


-- _setDefaults()
-- create one of each style
--
function BackgroundStyle._setDefaults( StyleClass, params )
	-- print( "BackgroundStyle._setDefaults", StyleClass )
	params = params or {}
	if params.defaults==nil then params.defaults=StyleClass._STYLE_DEFAULTS end
	--==--
	local BASE_STYLES = StyleClass._BASE_STYLES
	local defaults = params.defaults

	local classes = StyleFactory.getStyleClasses()

	StyleClass._BASE_DEFAULTS = {}

	for _, Cls in ipairs( classes ) do
		local cls_type = Cls.TYPE
		local struct = BackgroundStyle.createStyleStructure( {type=cls_type} )
		local def = Utils.extend( defaults, struct )
		StyleClass._addMissingChildProperties( def )
		local style = StyleClass:new{
			data=def,
			inherit=BaseStyle.NO_INHERIT
		}
		BASE_STYLES[ cls_type ] = style
		StyleClass._BASE_DEFAULTS[ cls_type ] = def
	end

end



--====================================================================--
--== Public Methods


function BackgroundStyle:getBaseStyle( data )
	-- print( "BackgroundStyle:getBaseStyle", self, data )
	local BASE_STYLES = self._BASE_STYLES
	local viewType, style

	if data==nil then
		viewType = self._DEFAULT_VIEWTYPE
	elseif type(data)=='string' then
		viewType = data
	elseif data.isa and data:isa( BackgroundStyle ) then
		--== Instance
		viewType = data.type
	else
		--== Lua structure
		viewType = data.type
	end

	style = BASE_STYLES[ viewType ]
	if not style then
		style = BASE_STYLES[ self._DEFAULT_VIEWTYPE ]
	end

	return style
end


function BackgroundStyle:getDefaultStyleValues( data )
	local BASE_DEFAULTS = self._BASE_DEFAULTS
	local viewType, style

	if data==nil then
		viewType = self._DEFAULT_VIEWTYPE
	elseif type(data)=='string' then
		viewType = data
	elseif data.isa and data:isa( BackgroundStyle ) then
		--== Instance
		viewType = data.type
	else
		--== Lua structure
		viewType = data.type
	end

	style = BASE_DEFAULTS[ viewType ]
	if not style then
		style = BASE_DEFAULTS[ self._DEFAULT_VIEWTYPE ]
	end

	return style
end


-- copyProperties()
-- copy properties from a source
-- if no source, then copy from Base Style
--
function BackgroundStyle:copyProperties( src, params )
	-- print( "BackgroundStyle:copyProperties", src, self )
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local StyleClass = self.class
	if not src then src=StyleClass:getBaseStyle( self.type ) end
	StyleClass.copyExistingSrcProperties( self, src, params )
end


--======================================================--
-- Access to sub-styles


--== .view

--- get Style object for view.
-- the value will be one of @{Style.BackgroundView.Rounded}, @{Style.BackgroundView.Rounded}, @{Style.BackgroundView.9Slice}
--
-- @within Properties
-- @function .view
-- @usage print( style.view )

function BackgroundStyle.__getters:view()
	-- print( 'BackgroundStyle.__getters:view', self._view )
	return self._view
end
function BackgroundStyle.__setters:view( data )
	-- print( 'BackgroundStyle.__setters:view', data )
	assert( data==nil or type(data)=='string' or type( data )=='table' )
	--==--
	local inherit = self._inherit and self._inherit._view or self._inherit

	--== check to see if our view type is compatible with style type

	if inherit~=BaseStyle.NO_INHERIT then
		local iType = inherit.type
		local dType, dVal = type(data), nil
		if dType=='string' then
			dVal = data
		elseif dType=='table' then
			dVal = self.type
		else
			dVal=iType -- TODO: check this
		end
		if iType~=dVal then
			local tmp = self:getBaseStyle( dVal )
			inherit=tmp and tmp.view
		end
	end

	self._view = self:_createView{
		name=BackgroundStyle.VIEW_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end


--======================================================--
-- Misc

function BackgroundStyle:_doChildrenInherit( value, params )
	-- print( "BackgroundStyle_doChildrenInherit", value, self )
	assert( params )
	--==--
	if not self._isInitialized then return end
	local cType = self._type
	local iType = nil
	local cActiveInherit = (self._type==nil)
	self:_updateViewStyle{
		delta='inherit',
		cInherit=params.curr,
		nInherit=params.next,
		cType=cType,
		iType=iType,
		cActiveInherit=cActiveInherit,
		clearProperties=false
	}
end


function BackgroundStyle:_doClearPropertiesInherit( reset, params )
	-- print( "BackgroundStyle:_doClearPropertiesInherit", self, reset, self._isInitialized )
	-- pass, we do everthing inside up updateView
	if self._isInitialized then return end

	BaseStyle._doClearPropertiesInherit( self, reset, params )
end


function BackgroundStyle:_clearChildrenProperties( style, params )
	-- print( "BackgroundStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa( BackgroundStyle ) )
	end
	--==--
	local substyle

	substyle = style and style.view or style
	self._view:_clearProperties( substyle, params )
end


-- createStyleFromType()
-- method processes data from the 'view' setter
-- looks for style class based on type
-- then calls to create the style
--
function BackgroundStyle:createStyleFromType( params )
	-- print( "BackgroundStyle:createStyleFromType", params )
	params = params or {}
	--==--
	local data = params.data
	local style_type, StyleClass

	-- look around for our style 'type'
	if data==nil then
		style_type = self._DEFAULT_VIEWTYPE
	elseif type(data)=='string' then
		-- we have type already
		style_type = data
		params.data=nil
	elseif type(data)=='table' then
		-- Lua structure, of View
		style_type = self.type
	end
	assert( style_type and type(style_type)=='string', "Style: missing style property 'type'" )

	StyleClass = StyleFactory.getClass( style_type )

	return StyleClass:createStyleFrom( params )
end


-- checks to make sure parent/view type are equal, etc
-- two entrances to this method, via:
-- 'type' setter
-- 'inherit' setter
--
function BackgroundStyle:_updateViewStyle( params )
	-- print( "BackgroundStyle:_updateViewStyle", params, self )
	params = params or {}
	params.delta = params.delta
	params.cType = params.cType
	params.nType = params.nType
	params.cInherit = params.cInherit
	params.nInherit = params.nInherit
	params.clearProperties = params.clearProperties
	--==--
	local actionInherit = (params.delta=='inherit')
	local actionType = (params.delta=='type')
	local viewStyle = self._view
	local viewType = viewStyle.type
	local viewInherit = viewStyle._inherit
	local StyleClass, StyleBase
	local delta = params.delta
	local cActiveInherit = params.cActiveInherit
	local cInherit, nInherit = params.cInherit, params.nInherit
	local iType, iInherit = params.iType, params.iInherit
	local cType, nType = params.cType, params.nType
	local bgType, bgInherit, bgData
	local bgType_dirty, bgInherit_dirty, bgData_dirty = false, false, false
	local vType, vInherit, vData
	local vType_dirty, vInherit_dirty, vData_dirty = false, false, false
	local sView_dirty = false
	local doClear = params.clearProperties
	local doReset = false
	local cView, nView = nil, nil

	--== Sanity Check ==--

	if self.__isUpdatingView==true then
		-- protect against other entrances to updateViewStyle
		-- eg, like setting 'type' property
		return
	end
	self.__isUpdatingView = true

	-- print( "UPDATE ", delta, cInherit, nInherit )
	-- print( "UPDATE ", cType, iType, nType, cActiveInherit )

	--== Process Matrix

	-- local properties are kept on an inherit change
	-- (a new view type starts empty, its properties are type specific)
	if delta=='inherit' and nInherit~=BaseStyle.NO_INHERIT then
		if nInherit.type==viewType then
			-- new Inherit is of SAME type as current View
			-- bgType_dirty=false ; bgType = nil -- no change
			bgInherit_dirty=true ; bgInherit = nInherit
			-- vType_dirty=false ; vType = viewType -- no change
			vInherit_dirty=true ; vInherit = nInherit.view

		elseif not cActiveInherit then
			-- new Inherit is of DIFFERENT type, local type kept
			-- view inherits from the base of its type
			bgInherit_dirty=true ; bgInherit = nInherit
			StyleBase = self:getBaseStyle( viewType )
			vInherit_dirty=true ; vInherit = StyleBase.view

		else
			-- new Inherit is of DIFFERENT type as current View
			bgType_dirty=true ; bgType = nil
			bgInherit_dirty=true ; bgInherit = nInherit
			vType_dirty=true ; vType = nInherit.type
			vInherit_dirty=true ; vInherit = nInherit.view
			vData_dirty=true ; vData = {src={}, force=true, clearChildren=false}
		end

	elseif delta=='inherit' and nInherit==BaseStyle.NO_INHERIT then
		if not cInherit then
			print( sfmt( "[NOTICE] Inherit is already set to '%s'", tostring(nInherit) ))

		elseif cActiveInherit then
			-- have full-inheritance, ie, inherited and no local type
			bgType_dirty=true ; bgType = cInherit.type
			-- bgInherit_dirty=false ; bgInherit = nil -- already done
			bgData_dirty=true ; bgData = {src=cInherit, force=false, clearChildren=false}
			-- vType_dirty=false ; vType = viewType -- no change
			vInherit_dirty=true ; vInherit = BaseStyle.NO_INHERIT
			vData_dirty=true ; vData = {src=cInherit.view, force=false, clearChildren=false}

		else
			-- have inheritance, but not full. ie, have local type
			-- bgType_dirty=false ; bgType = cType -- no change
			bgInherit_dirty=true ; bgInherit = BaseStyle.NO_INHERIT
			bgData_dirty=true ; bgData = {src=cInherit, force=false, clearChildren=false}
			-- vType_dirty=false ; vType = viewType -- no change
			-- vInherit_dirty=false ; vInherit = nil -- no change
			-- vData_dirty=false ; vData = nil -- no change
		end

	elseif delta=='type' and cInherit==BaseStyle.NO_INHERIT then
		if iType then
			-- nothing to do, inheritance is not active
			-- not sure how you got here

		elseif nType==nil then
			print( sfmt( "[WARNING] Setting uninherited Style type to 'nil' is not permitted" ) )
			-- not a valid state

		elseif cType==nType then
			print( sfmt( "[NOTICE] Type is already set to '%s'", tostring(nType) ))
			-- nothing to do

		else
			-- new Type is DIFFERENT than current Background
			-- 'rect' to 'rounded'
			StyleBase = self:getBaseStyle( nType )

			bgType_dirty=true ; bgType = nType
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			-- bgData_dirty=false ; bgData = {src=StyleBase, force=false, clearChildren=false}
			vType_dirty=true ; vType = nType
			-- vInherit_dirty=false ; vInherit = nil -- no change
			vData_dirty=true ; vData = {src=StyleBase.view, force=true, clearChildren=false}
		end

	elseif delta=='type' and cInherit~=BaseStyle.NO_INHERIT then
		if iType and not cActiveInherit then
			-- this is coming from an inherited type change
			-- but inactive inherit action so nothing to do

		elseif iType and viewType~=iType then
			-- this is coming from an inherited type change
			-- local type is already unset, view is incorrect
			--
			-- bgType_dirty=false ; bgType = nil -- no change
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			-- bgData_dirty=true ; bgData = nil -- no change
			vType_dirty=true ; vType = iType
			vInherit_dirty=true ; vInherit = iInherit
			vData_dirty=true ; vData = {src={}, force=true, clearChildren=false}

		elseif cType==nType then
			print( sfmt( "[NOTICE] Type is already set to '%s'", tostring(nType) ))
			-- new Type is SAME as current Background
			-- nothing to do

		elseif nType==nil and cInherit.type==viewType then
			-- unset type, view is correct
			bgType_dirty=true ; bgType = nType
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			bgData_dirty=true ; bgData = {src={}, force=true, clearChildren=false}
			-- vType_dirty=false ; vType = viewType -- no change
			vInherit_dirty=true ; vInherit = cInherit.view
			vData_dirty=true ; vData = {src={}, force=true, clearChildren=false}

		elseif nType==nil and cInherit.type~=viewType then
			-- unset type, view is incorrect
			bgType_dirty=true ; bgType = nType
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			bgData_dirty=true ; bgData = {src={}, force=true, clearChildren=false}
			vType_dirty=true ; vType = cInherit.type
			vInherit_dirty=true ; vInherit = cInherit.view
			vData_dirty=true ; vData = {src={}, force=true, clearChildren=false}

		elseif cType==nil and nType==viewType then
			-- new Type is SAME as inheritance
			StyleBase = self:getBaseStyle( nType )

			bgType_dirty=true ; bgType = nType
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			bgData_dirty=true ; bgData = {src=cInherit, force=false, clearChildren=false}
			-- vType_dirty=false ; vType = nType -- no change
			vInherit_dirty=true ; vInherit = StyleBase.view -- stop direct inheritance
			vData_dirty=true ; vData = {src=cInherit.view, force=true, clearChildren=false}

		elseif cType==nil and nType~=viewType then
			-- new Type is DIFFERENT than inheritance
			StyleBase = self:getBaseStyle( nType )

			bgType_dirty=true ; bgType = nType
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			bgData_dirty=true ; bgData = {src=StyleBase, force=false, clearChildren=false}
			vType_dirty=true ; vType = nType
			vInherit_dirty=true ; vInherit = StyleBase.view -- stop direct inheritance
			vData_dirty=true ; vData = {src=StyleBase.view, force=true, clearChildren=false}

		else
			-- new Type is DIFFERENT than current Background, eg
			-- 'rect' to 'rounded'
			StyleBase = self:getBaseStyle( nType )

			bgType_dirty=true ; bgType = nType
			-- bgInherit_dirty=false ; bgInherit = nil -- no change
			-- bgData_dirty=false ; bgData = {src=StyleBase, force=false, clearChildren=false}
			vType_dirty=true ; vType = nType
			vInherit_dirty=true ; vInherit = StyleBase.view -- no change
			vData_dirty=true ; vData = {src=StyleBase.view, force=true, clearChildren=false}
		end

	end

	-- print( "BG T, I, D", bgType_dirty, bgInherit_dirty, bgData_dirty )
	-- print( "VIEW T, I, D", vType_dirty, vInherit_dirty, vData_dirty )

	--== Do Work

	if vType_dirty then
		-- print(">2 Create View")
		-- save current view, delete later
		-- create new one
		cView = self._view
		nView = self:_createView{
			name=nil,
			inherit=nil,
			parent=self,
			data=vType
		}
		self._view = nView
		viewStyle = nView
		vType_dirty=false

		sView_dirty=true
		doReset=true
	end
	if vInherit_dirty then
		-- print(">2 Change Inherit")
		viewStyle.inherit = vInherit
		vInherit_dirty=false

		doReset=true
	end
	if vData_dirty then
		-- print(">2 Clear Inherit", vData.src, vData.force )
		viewStyle:_clearProperties( vData.src, vData )
		vData_dirty=false

		doReset=true
	end

	if bgInherit_dirty and not actionInherit then
		-- print(">1 Change Inherit")
		self.inherit = bgInherit
		bgInherit_dirty=false

		doReset=true
	end
	if bgData_dirty then
		-- print(">1 Clear background")
		self:_clearProperties( bgData.src, bgData )
		bgData_dirty=false

		doReset=true
	end
	if bgType_dirty then
		-- print(">1 Set Type", bgType )
		self._type = bgType
		bgType_dirty=false
	end
	if sView_dirty then
		local data = {curr=cView, next=nView}
		self:_dispatchChangeEvent( 'type', viewStyle.type, data )
		self:_destroyView( cView )
		sView_dirty=false
	end
	-- print("\n\n\n finishing up \n\n\n")

	if doReset then
		-- print(">3 Sending Reset")
		self:_dispatchResetEvent()
	end

	self.__isUpdatingView = nil
end


--== .inheritIsActive

function BackgroundStyle.__getters:inheritIsActive()
	return (self._inherit~=nil and self._type==nil)
end

--== type

function BackgroundStyle.__getters:type()
	-- print( "BackgroundStyle.__getters:type", self._inherit )
	local value = self._type
	if value==nil and self.inheritIsActive then
		value = self._inherit.type
	end
	return value
end
function BackgroundStyle.__setters:type( value )
	-- print( "BackgroundStyle.__setters:type", value, self, self._type )
	assert( (value==nil and self._inherit) or type(value)=='string' )
	--==--
	local cType, nType = self._type, value
	local cActiveInherit, nActiveInherit = (self._type==nil), (value==nil)
	local iType = nil

	self._type = value
	if not self._isInitialized then return end

	self:_updateViewStyle{
		delta='type',
		cType=cType,
		iType=iType,
		nType=nType,
		cInherit=self._inherit,
		cActiveInherit=cActiveInherit,
		nActiveInherit=nActiveInherit,
		clearProperties=true
	}
end



function BackgroundStyle:_handleTypeChangeEvent( event )
	-- print( "BackgroundStyle:_handleTypeChangeEvent", self )
	local value = event.value
	local data = event.data

	local cType, nType = self._type, nil
	local cActiveInherit, nActiveInherit = (self._type==nil), (value==nil)

	local iType = value
	local iInherit = data.next

	self:_updateViewStyle{
		delta='type',
		cType=cType,
		iType=iType,
		iInherit=iInherit,
		nType=nType,
		cInherit=self._inherit,
		cActiveInherit=cActiveInherit,
		nActiveInherit=nActiveInherit,
		clearProperties=true
	}
end




--====================================================================--
--== Private Methods

function BackgroundStyle:_createView( params )
	-- print( 'BackgroundStyle:_createView' )
	return self:createStyleFromType( params )
end

function BackgroundStyle:_destroyView( view )
	-- print( 'BackgroundStyle:_destroyView', view )
	if not view then return end
	view:removeSelf()
	return nil
end

function BackgroundStyle:_destroyChildren()
	-- print( 'BackgroundStyle:_destroyChildren', self )
	self:_destroyView( self._view )
end


--[[
Prepare Data
we could have nil, Lua structure, or Instance

no data, no inherit - create structure, set default type
no data, inherit - create structure, use inherit value, unset type
data, inherit - inherit.type (unset) or data.type (set) or default (set)
--]]
-- _prepareData()
--
function BackgroundStyle:_prepareData( data, dataSrc, params )
	-- print( "BackgroundStyle:_prepareData", data, dataSrc, self )
	params = params or {}
	--==--
	local inherit = params.inherit
	local StyleClass
	local src, dest, sType, tmp
	local vInherit=false

	if not data then
		-- create basic structure if missing
		data = BackgroundStyle.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	-- see which view type we have
	if inherit~=BaseStyle.NO_INHERIT then
		if not src.type then
			vInherit=true
			sType = inherit.type
		elseif src.type == inherit.type then
			vInherit=true
			sType = inherit.type
		else
			vInherit=false
			sType = src.type
		end
	elseif src.type then
		sType = src.type
	else
		sType = self._DEFAULT_VIEWTYPE
	end

	StyleClass = StyleFactory.getClass( sType )
	if not src.view then
		tmp = dataSrc and dataSrc.view
		src.view = StyleClass.createStyleStructure( tmp )
	end

	if vInherit==false then
		src.type = sType -- set to block
	elseif vInherit==true then
		src.type = nil -- unset for inheritance
	end
	dest = src.view
	dest = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end



--====================================================================--
--== Event Handlers


-- _inheritedStyleEvent_handler()
-- handle inherited style-events
--
function BackgroundStyle:_inheritedStyleEvent_handler( event )
	-- print( "BackgroundStyle:_inheritedStyleEvent_handler", event, event.type, self )
	local style = event.target
	local etype = event.type
	local eprop = event.property

	if etype==style.PROPERTY_CHANGED and eprop=='type' then
		self:_handleTypeChangeEvent( event )
	else
		BaseStyle._inheritedStyleEvent_handler( self, event )
	end

end




return BackgroundStyle
