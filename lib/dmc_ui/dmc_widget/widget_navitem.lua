--====================================================================--
-- dmc_ui/dmc_widget/widget_navitem.lua
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
--== DMC Corona UI : NavItem Widget
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
--== DMC UI : newNavItem
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local LifecycleMixModule = require 'dmc_lifecycle_mix'
local StyleMixModule = require( ui_find( 'dmc_style.style_mix' ) )
local uiConst = require( ui_find( 'ui_constants' ) )



--====================================================================--
--== Setup, Constants


local ObjectBase = Objects.ObjectBase

local LifecycleMix = LifecycleMixModule.LifecycleMix
local StyleMix = StyleMixModule.StyleMix

local tinsert = table.insert
local tremove = table.remove

--== To be set in initialize()
local dUI = nil
local Widget = nil



--====================================================================--
--== Nav Item Widget Class
--====================================================================--

--- Nav Item Module.
-- a navigation component used with a NavBar widget. this is essentially a container of items to show in a NavBar.
--
-- @classmod Widget.NavItem
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newNavItem()

local NavItem = newClass(
	{ StyleMix, ObjectBase, LifecycleMix }, {name="Nav Item"}
)

--== Style/Theme Constants

NavItem.STYLE_CLASS = nil -- added later
NavItem.STYLE_TYPE = uiConst.NAVITEM


--======================================================--
-- Start: Setup DMC Objects

--== Init

function NavItem:__init__( params )
	-- print( "NavItem:__init__" )
	params = params or {}
	if params.titleText==nil then params.titleText="" end

	self:superCall( LifecycleMix, '__init__', params )
	self:superCall( ObjectBase, '__init__', params )
	self:superCall( StyleMix, '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._titleText = ''

	-- properties stored in Style

	self._debugOn_dirty=true
	self._width_dirty=true
	self._height_dirty=true
	self._anchorX_dirty=true
	self._anchorY_dirty=true

	-- "Virtual" properties

	self._widgetStyle_dirty=true

	--== Object References ==--


	self._wgtBtnBack = nil -- Back button widget
	self._wgtBtnBack_dirty=true
	self._wgtBtnBackStyle_dirty=true

	self._wgtText = nil -- text widget (for title)
	self._wgtText_f = nil -- widget handler
	self._wgtText_dirty=true
	self._wgtTextStyle_dirty=true
	self._wgtTextText_dirty=true

	self._btnLeft = nil
	self._btnLeftStyle_dirty=true

	self._btnRight = nil
	self._btnRightStyle_dirty=true

	self._ni_tmp_params = params -- save

end

--[[
function NavItem:_undoInit()
	-- print( "NavItem:_undoInit" )
	--==--
	self:superCall( "_undoInit" )
end
--]]


-- __initComplete__()
--
function NavItem:__initComplete__()
	--print( "NavItem:__initComplete__" )
	self:superCall( StyleMix, '__initComplete__' )
	self:superCall( ObjectBase, '__initComplete__' )
	--==--
	local tmp = self._ni_tmp_params

	self.style = tmp.style

	self.rightButton = tmp.rightButton -- setter
	self.leftButton = tmp.leftButton -- setter

	self:_createText()
	self:_createBackButton()

	self.titleText = tmp.titleText

	self._ni_tmp_params = nil

end

function NavItem:__undoInitComplete__()
	-- print( "NavItem:__undoInitComplete__" )
	self:_removeBackButton()
	self:_removeText()

	--== Though not default, check them

	local o = self._btnLeft
	if o then
		o:removeSelf()
		self._btnLeft = nil
	end

	o = self._btnRight
	if o then
		o:removeSelf()
		self._btnRight = nil
	end

	--==--
	self:superCall( ObjectBase, '__undoInitComplete__' )
	self:superCall( StyleMix, '__undoInitComplete__' )
end


-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function NavItem.initialize( manager )
	-- print( "NavItem.initialize" )
	dUI = manager
	Widget = dUI.Widget

	local Style = dUI.Style
	NavItem.STYLE_CLASS = Style.NavItem

	Style.registerWidget( NavItem )
end



--====================================================================--
--== Public Methods


--- get backButton object.
--
-- @within Properties
-- @function .backButton
-- @usage print( widget.backButton )

function NavItem.__getters:backButton()
	-- print( "NavItem.__getters:backButton" )
	return self._wgtBtnBack
end


--- set/get leftButton object.
--
-- @within Properties
-- @function .leftButton
-- @usage widget.leftButton = <DMC PushButton>
-- @usage print( widget.leftButton )

function NavItem.__getters:leftButton()
	-- print( "NavItem.__getters:leftButton" )
	return self._btnLeft
end
function NavItem.__setters:leftButton( button )
	-- print( "NavItem.__setters:leftButton", button )
	local bType = type(button)
	assert( bType=='nil' or bType=='table', "wrong type for button" )
	--==--
	if bType=='table' then
		assert( button.isa and button:isa( Widget.ButtonFactory.Base ), "button not object" )
		-- shown by the Nav Bar
		button.isVisible = false
	end
	self._btnLeft = button
	self._btnLeftStyle_dirty=true
	self:__invalidateProperties__()
end


--- set/get rightButton object.
--
-- @within Properties
-- @function .rightButton
-- @usage widget.rightButton = <DMC PushButton>
-- @usage print( widget.rightButton )

function NavItem.__getters:rightButton()
	-- print( "NavItem.__getters:rightButton" )
	return self._btnRight
end
function NavItem.__setters:rightButton( button )
	-- print( "NavItem.__setters:rightButton", button )
	local bType = type(button)
	assert( bType=='nil' or bType=='table', "wrong type for button" )
	--==--
	if bType=='table' then
		assert( button.isa and button:isa( Widget.ButtonFactory.Base ), "button not object" )
		-- shown by the Nav Bar
		button.isVisible = false
	end
	self._btnRight = button
	self._btnRightStyle_dirty=true
	self:__invalidateProperties__()
end


--- get title Text Widget of Nav Item.
--
-- @within Properties
-- @function .title
-- @usage print( widget.title )

function NavItem.__getters:title()
	-- print( "NavItem.__getters:title" )
	return self._wgtText
end


--- set/get title of Nav Item.
-- value should be string
--
-- @within Properties
-- @function .titleText
-- @usage widget.titleText = "My Title"
-- @usage print( widget.titleText )

function NavItem.__getters:titleText()
	-- print( "NavItem.__getters:titleText" )
	return self._titleText
end
function NavItem.__setters:titleText( value )
	-- print( "NavItem.__setters:titleText", button )
	assert( type(value)=='string', "title must be a string" )
	--==--
	self._titleText = value
	self._wgtTextText_dirty=true
	self:__invalidateProperties__()
end


--======================================================--
-- Theme Methods

-- afterAddStyle()
--
function NavItem:afterAddStyle()
	-- print( "NavItem:afterAddStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end

-- beforeRemoveStyle()
--
function NavItem:beforeRemoveStyle()
	-- print( "NavItem:beforeRemoveStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end



--====================================================================--
--== Private Methods


--== Create/Destroy Text Widget

function NavItem:_removeBackButton()
	-- print( "NavItem:_removeBackButton" )
	local o = self._wgtBtnBack
	if not o then return end
	o:removeSelf()
	self._wgtBtnBack = nil
end

function NavItem:_createBackButton()
	-- print( "NavItem:_createBackButton" )

	self:_removeBackButton()

	local o = Widget.newButton{
		labelText="< Back",
		defaultStyle = self.defaultStyle.backButton
	}
	-- shown by the Nav Bar
	o.isVisible = false
	self._wgtBtnBack = o

	--== Reset properties

	self._wgtBtnBackStyle_dirty=true
end


--== Create/Destroy Text Widget

function NavItem:_removeText()
	-- print( "NavItem:_removeText" )
	local o = self._wgtText
	if not o then return end
	o.onUpdate=nil
	o:removeSelf()
	self._wgtText = nil
end

function NavItem:_createText()
	-- print( "NavItem:_createText" )

	self:_removeText()

	local o = Widget.newText{
		defaultStyle = self.defaultStyle.title
	}
	-- shown by the Nav Bar
	o.isVisible = false
	self._wgtText = o

	--== Reset properties

	self._wgtTextStyle_dirty=true
	self._wgtTextText_dirty=true
end


function NavItem:__commitProperties__()
	-- print( 'NavItem:__commitProperties__' )

	--== Update Widget View ==--

	local style = self.curr_style
	local view = self.view
	local text = self._wgtText
	local back = self._wgtBtnBack
	local left = self._btnLeft
	local right = self._btnRight

	-- removed with a change still waiting
	if not text or not back then return end

	--== Set Styles

	if self._wgtBtnBackStyle_dirty then
		back:setActiveStyle( style.backButton, {copy=false} )
		self._wgtBtnBackStyle_dirty=false
	end

	-- TODO: check widget type (apply style if Widget)
	if left and self._btnLeftStyle_dirty then
		left:setActiveStyle( style.leftButton, {copy=false} )
		self._btnLeftStyle_dirty=false
	end

	-- TODO: check widget type (apply style if Widget)
	if right and self._btnRightStyle_dirty then
		right:setActiveStyle( style.rightButton, {copy=false} )
		self._btnRightStyle_dirty=false
	end

	if self._wgtTextText_dirty then
		text.text=self._titleText
		self._wgtTextText_dirty=false
	end
	if self._wgtTextStyle_dirty then
		text:setActiveStyle( style.title, {copy=false} )
		self._wgtTextStyle_dirty=false
	end

end



--====================================================================--
--== Event Handlers


function NavItem:stylePropertyChangeHandler( event )
	-- print( "NavItem:stylePropertyChangeHandler", event.property, event.value )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- Utils.print( event )

	-- print( "Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty = true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._wgtBtnBackStyle_dirty=true
		self._btnLeftStyle_dirty=true
		self._btnRightStyle_dirty=true
		self._wgtTextStyle_dirty=true

		property = etype

	else
		if property=='debugOn' then
			self._debugOn_dirty=true
		elseif property=='width' then
			self._width_dirty=true
		elseif property=='height' then
			self._height_dirty=true
		elseif property=='anchorX' then
			self._anchorX_dirty=true
		elseif property=='anchorY' then
			self._anchorY_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return NavItem
