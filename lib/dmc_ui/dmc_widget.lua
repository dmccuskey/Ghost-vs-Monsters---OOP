--====================================================================--
-- dmc_widget.lua
--
-- entry point into dmc-corona-widgets
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2013-2015 David McCuskey

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

--- A Lua module which creates UI widgets for the Corona SDK.
-- @module dmc-widget
-- @usage local dUI = require 'dmc_ui'
-- local g = dUI.newTableView( view )



--====================================================================--
--== DMC Corona UI : Widget Interface
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "2.0.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI : Widget Interface
--====================================================================--



--===================================================================--
--== Imports


local Kolor = require 'dmc_kolor'
local uiConst = require( ui_find( 'ui_constants' ) )

-- Widget.ButtonGroup = require( PATH .. '.' .. 'button_group' )
-- Widget.Formatter = require( PATH .. '.' .. 'data_formatters' )



--===================================================================--
--== Setup, Constants


-- local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

-- local sfmt = string.format

--== To be set in initialize()
local dUI = nil
local Style = nil



--===================================================================--
--== Support Functions


local initKolors = Kolor.initializeKolorSet



--====================================================================--
--== Widget Interface
--====================================================================--


local Widget = {}



--====================================================================--
--== Widget Static Functions



function Widget.initialize( manager, params )
	-- print( "Widget.initialize" )

	dUI = manager
	Style = dUI.Style

	--== Add API calls

	dUI.newBackground = Widget.newBackground
	dUI.new9SliceBackground = Widget.new9SliceBackground
	dUI.newImageBackground = Widget.newImageBackground
	dUI.newRectangleBackground = Widget.newRectangleBackground
	dUI.newRoundedBackground = Widget.newRoundedBackground
	dUI.newButton = Widget.newButton
	dUI.newPushButton = Widget.newPushButton
	dUI.newRadioButton = Widget.newRadioButton
	dUI.newToggleButton = Widget.newToggleButton
	dUI.newButtonGroup = Widget.newButtonGroup
	dUI.newFormatter = Widget.newFormatter
	dUI.newNavBar = Widget.newNavBar
	dUI.newNavItem = Widget.newNavItem
	dUI.newPageIndicator = Widget.newPageIndicator
	dUI.newScrollView = Widget.newScrollView
	dUI.newSlideView = Widget.newSlideView
	dUI.newTableView = Widget.newTableView
	dUI.newTableViewCell = Widget.newTableViewCell
	dUI.newText = Widget.newText
	dUI.newTextField = Widget.newTextField



	--== Load Components

	-- local FontMgr = require( PATH .. '.' .. 'font_manager' )
	-- Widget.FontMgr=FontMgr

	--== Initialize

	initKolors( function()
		-- FontMgr.initialize( Widget, params )
	end)


end


--====================================================================--
--== Widget Public Functions


--======================================================--
-- UI View Base Support

function Widget.loadViewSupport( params )
	-- print( "Widget.loadViewSupport" )
	if Widget.View then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Components

	local WidgetBase = require( ui_find( 'core.widget' ) )

	Widget.Base=WidgetBase

	WidgetBase.initialize( dUI, params )
end



--===================================================================--
--== Widget Methods

--[[
The following should be copied inside of dmc_ui.lua
--]]
--======================================================--
-- START: bogus methods, copied from super class

--- the gesture's id (string).
-- this is useful to differentiate between
-- different gestures attached to the same view object
--
-- @function .id
-- @usage print( gesture.id )
-- @usage gesture.id = "myid"
--

--- the gesture's target view (Display Object).
--
-- @function .view
-- @usage print( gesture.view )
-- @usage gesture.view = DisplayObject
--

--- the gesture's delegate (object/table)
--
-- @function .delegate
-- @usage print( gesture.delegate )
-- @usage gesture.delegate = DisplayObject
--

-- END: bogus methods, copied from super class
--======================================================--


--======================================================--
-- newBackground Support

function Widget._loadBackgroundSupport( params )
	-- print( "Widget._loadBackgroundSupport" )
	if Widget.Background then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style._loadBackgroundStyleSupport( params )

	Widget.loadViewSupport( params )

	--== Components

	local Background = require( ui_find( 'dmc_widget.widget_background' ) )
	local BackgroundViewFactory = require( ui_find( 'dmc_widget.widget_background.view_factory' ) )

	Widget.Background=Background
	Widget.BackgroundFactory=BackgroundViewFactory

	initKolors( function()
		BackgroundViewFactory.initialize( dUI, params )
		Background.initialize( dUI, params )
	end)
end

--- contructor for Background widgets.
--
-- @function newBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local uiBg = dUI.newBackground()
--
function Widget.newBackground( options )
	if not Widget.Background then Widget._loadBackgroundSupport() end
	return Widget.Background:new( options )
end


--- convenience function for Rectangle Background widgets.
--
-- @function new9SliceBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local uiBg = dUI.new9SliceBackground()

function Widget.new9SliceBackground( options )
	if not Widget.Background then Widget._loadBackgroundSupport() end
	options = options or {}
	options.viewType=uiConst.NINE_SLICE
	return Widget.Background:new( options )
end

--- convenience function for Rectangle Background widgets.
--
-- @function newRectangleBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local uiBg = dUI.newRectangleBackground()

function Widget.newRectangleBackground( options )
	if not Widget.Background then Widget._loadBackgroundSupport() end
	options = options or {}
	options.viewType=uiConst.RECTANGLE
	return Widget.Background:new( options )
end

--- convenience function for Rectangle Background widgets.
--
-- @function newImageBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local uiBg = dUI.newImageBackground()

function Widget.newImageBackground( options )
	if not Widget.Background then Widget._loadBackgroundSupport() end
	options = options or {}
	options.viewType=uiConst.IMAGE
	return Widget.Background:new( options )
end

--- convenience function for Rounded Background widgets.
--
-- @function newRoundedBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local uiBg = dUI.newRoundedBackground()

function Widget.newRoundedBackground( options )
	if not Widget.Background then Widget._loadBackgroundSupport() end
	options = options or {}
	options.viewType=uiConst.ROUNDED
	return Widget.Background:new( options )
end


--======================================================--
-- newButton Support

function Widget._loadButtonSupport( params )
	-- print( "Widget._loadButtonSupport" )
	if Widget.ButtonFactory then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style._loadButtonStyleSupport( params )

	Widget._loadBackgroundSupport( params )
	Widget._loadTextSupport( params )

	--== Components

	local ButtonFactory = require( ui_find( 'dmc_widget.widget_button' ) )

	Widget.ButtonFactory=ButtonFactory

	initKolors( function()
		ButtonFactory.initialize( dUI, params )
	end)
end

--- constructor for Button widgets.
--
-- @function newButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local uiBg = dUI.newButton()
--
function Widget.newButton( options )
	if not Widget.ButtonFactory then Widget._loadButtonSupport() end
	options = options or {}
	if options.action==nil then options.action = Widget.ButtonFactory.PushButton.TYPE end
	--==--
	return Widget.ButtonFactory.create( options )
end

--- convenience function for Push Buttons.
--
-- @function newPushButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local uiBg = dUI.newPushButton()
--
function Widget.newPushButton( options )
	if not Widget.ButtonFactory then Widget._loadButtonSupport() end
	options = options or {}
	options.action = Widget.ButtonFactory.PushButton.TYPE
	--==--
	return Widget.ButtonFactory.create( options )
end

--- convenience function for Radio Buttons.
--
-- @function newRadioButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local uiBg = dUI.newRadioButton()
--
function Widget.newRadioButton( options )
	if not Widget.ButtonFactory then Widget._loadButtonSupport() end
	options = options or {}
	options.action = Widget.ButtonFactory.RadioButton.TYPE
	--==--
	return Widget.ButtonFactory.create( options )
end

--- convenience function for Toggle Buttons.
--
-- @function newToggleButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local uiBg = dUI.newToggleButton()
--
function Widget.newToggleButton( options )
	if not Widget.ButtonFactory then Widget._loadButtonSupport() end
	options = options or {}
	options.action = Widget.ButtonFactory.ToggleButton.TYPE
	--==--
	return Widget.ButtonFactory.create( options )
end


--======================================================--
-- newButtonGroup Support

function Widget._loadButtonGroupSupport( params )
	-- print( "Widget._loadButtonGroupSupport" )
	if Widget.ButtonGroup then return end
	--==--
	Widget.ButtonGroup = require( ui_find( 'dmc_widget.button_group' ) )
end

--- constructor for Button Groups.
-- a group of Radio or Toggle Buttons, of which one at most is active.
--
-- @function newButtonGroup
-- @tab options parameters used to create Button Group: `type` ('radio' or 'toggle')
-- @treturn object Button Group
-- @usage local group = dUI.newButtonGroup{ type='radio' }
--
function Widget.newButtonGroup( options )
	if not Widget.ButtonGroup then Widget._loadButtonGroupSupport() end
	--==--
	return Widget.ButtonGroup.create( options )
end


--======================================================--
-- newFormatter Support

--- constructor for Field Formatter delegates.
-- formatting delegates for use with Text Field
--
-- @function newFormatter
-- @tab[opt] options parameters used to create a data Formatter
-- @treturn object @{Widget.Formatter}
-- @usage local uiBg = dUI.newFormatter()
--
function Widget.newFormatter( options )
	if type(options)=='string' then
		-- wrap option in a params table
		options = { type=options }
	end
	return Widget.Formatter.create( options )
end


--======================================================--
-- newNavBar Support

function Widget._loadNavBarSupport( params )
	-- print( "Widget._loadNavBarSupport" )
	if Widget.NavBar then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style._loadNavBarStyleSupport( params )

	Widget._loadBackgroundSupport( params )
	Widget._loadButtonSupport( params )

	--== Components

	local NavBar = require( ui_find( 'dmc_widget.widget_navbar' ) )
	local NavItem = require( ui_find( 'dmc_widget.widget_navitem' ) )

	Widget.NavBar=NavBar
	Widget.NavItem=NavItem

	initKolors( function()
		NavItem.initialize( dUI, params )
		NavBar.initialize( dUI, params )
	end)
end

--- constructor for Nav Bar widgets.
--
-- @function newNavBar
-- @tab[opt] options parameters used to create a Nav Bar
-- @treturn object @{Widget.NavBar}
-- @usage local uiBg = dUI.newNavBar()
--
function Widget.newNavBar( options )
	if not Widget.NavBar then Widget._loadNavBarSupport() end
	return Widget.NavBar:new( options )
end

--- constructor for Nav Bar Item.
--
-- @function newNavItem
-- @tab[opt] options parameters used to create a Nav Item
-- @treturn object @{Widget.NavItem}
-- @usage local uiBg = dUI.newNavItem()
--
function Widget.newNavItem( options )
	if not Widget.NavItem then Widget._loadNavBarSupport() end
	return Widget.NavItem:new( options )
end


--======================================================--
-- newPopover Support

-- function Widget.newPopover( options )
-- 	local theme = nil
-- 	local widget = Widget.Popover
-- 	return widget:new( options, theme )
-- end


--======================================================--
-- newScroller Support

-- function Widget.newScroller( options )
-- 	local theme = nil
-- 	local _library = require( PATH .. '.' .. 'widget_scroller' )
-- 	return _library:new( options, theme )
-- end


--======================================================--
-- newPageIndicator Support

function Widget.loadPageIndicatorSupport( params )
	-- print( "Widget.loadPageIndicatorSupport" )
	if Widget.PageIndicator then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style.loadPageIndicatorStyleSupport( params )

	Widget.loadViewSupport( params )

	--== Components

	local PageIndicator = require( ui_find( 'dmc_widget.widget_pageindicator' ) )

	Widget.PageIndicator=PageIndicator

	initKolors( function()
		PageIndicator.initialize( dUI, params )
	end)
end

--- constructor for a Page Indicator widget.
--
-- @function newPageIndicator
-- @tab[opt] options parameters used to create a Page Indicator
-- @treturn object @{Widget.PageIndicator}
-- @usage local widget = dUI.newPageIndicator{ numberOfPages=5 }
--
function Widget.newPageIndicator( options )
	-- print( "Widget.newPageIndicator" )
	if not Widget.PageIndicator then Widget.loadPageIndicatorSupport() end
	return Widget.PageIndicator:new( options )
end


--======================================================--
-- newScrollView Support

function Widget.loadScrollViewSupport( params )
	-- print( "Widget.loadScrollViewSupport" )
	if Widget.ScrollView then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style.loadScrollViewStyleSupport( params )

	Widget.loadViewSupport( params )

	--== Components

	local ScrollView = require( ui_find( 'dmc_widget.widget_scrollview' ) )

	Widget.ScrollView=ScrollView

	initKolors( function()
		ScrollView.initialize( dUI, params )
	end)
end

--- constructor for a Scroll View widget.
--
-- @function newScrollView
-- @tab[opt] options parameters used to create a Scroll View
-- @treturn object @{Widget.ScrollView}
-- @usage local uiBg = dUI.newScrollView()
--
function Widget.newScrollView( options )
	-- print( "Widget.newScrollView" )
	if not Widget.ScrollView then Widget.loadScrollViewSupport() end
	return Widget.ScrollView:new( options )
end


--======================================================--
-- newSlideView Support

function Widget.loadSlideViewSupport( params )
	-- print( "Widget.loadSlideViewSupport" )
	if Widget.SlideView then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Widget.loadScrollViewSupport( params )

	--== Components

	local SlideView = require( ui_find( 'dmc_widget.widget_slideview' ) )

	Widget.SlideView=SlideView

	initKolors( function()
		SlideView.initialize( dUI, params )
	end)
end

--- constructor for a Slide View widget.
--
-- @function newSlideView
-- @tab[opt] options parameters used to create a Slide View
-- @treturn object @{Widget.SlideView}
-- @usage local uiBg = dUI.newSlideView()
--
function Widget.newSlideView( options )
	-- print( "Widget.newSlideView" )
	if not Widget.SlideView then Widget.loadSlideViewSupport() end
	return Widget.SlideView:new( options )
end


--======================================================--
-- newTableView Support

function Widget.loadTableViewSupport( params )
	-- print( "Widget.loadTableViewSupport" )
	if Widget.TableView then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style.loadTableViewStyleSupport( params )

	Widget.loadScrollViewSupport( params )

	--== Components

	local TableView = require( ui_find( 'dmc_widget.widget_tableview' ) )

	Widget.TableView=TableView

	initKolors( function()
		TableView.initialize( dUI, params )
	end)
end

--- constructor for a Table View widget.
--
-- @function newTableView
-- @tab[opt] options parameters used to create a Table View
-- @treturn object @{Widget.TableView}
-- @usage local uiBg = dUI.newTableView()
--
function Widget.newTableView( options )
	-- print( "Widget.newTableView" )
	if not Widget.TableView then Widget.loadTableViewSupport() end
	return Widget.TableView:new( options )
end


--======================================================--
-- newTableViewCell Support

function Widget.loadTableViewCellSupport( params )
	-- print( "Widget.loadTableViewCellSupport" )
	if Widget.TableViewCell then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style.loadTableViewCellStyleSupport( params )

	Widget.loadViewSupport( params )

	--== Components

	local TableViewCell = require( ui_find( 'dmc_widget.widget_tableviewcell' ) )

	Widget.TableViewCell=TableViewCell

	initKolors( function()
		TableViewCell.initialize( dUI, params )
	end)
end

--- constructor for a Table View Cell widget.
--
-- @function newTableViewCell
-- @tab[opt] options parameters used to create a Table View Cell widget
-- @treturn object @{Widget.TableViewCell}
-- @usage local uiBg = dUI.newTableViewCell()
--
function Widget.newTableViewCell( options )
	-- print( "Widget.newTableViewCell" )
	if not Widget.TableViewCell then Widget.loadTableViewCellSupport() end
	return Widget.TableViewCell:new( options )
end


--======================================================--
-- newText Support

function Widget._loadTextSupport( params )
	-- print( "Widget._loadTextSupport" )
	if Widget.Text then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style._loadTextStyleSupport( params )

	Widget.loadViewSupport( params )

	--== Components

	local Text = require( ui_find( 'dmc_widget.widget_text' ) )

	Widget.Text=Text

	initKolors( function()
		Text.initialize( dUI, params )
	end)
end

--- constructor for a Text widget.
--
-- @function newText
-- @tab[opt] options parameters used to create a Text widget
-- @treturn object @{Widget.Text}
-- @usage local uiBg = dUI.newText()
--
function Widget.newText( options )
	-- print( "Widget.newText" )
	if not Widget.Text then Widget._loadTextSupport() end
	return Widget.Text:new( options )
end


--======================================================--
-- TextField Support

function Widget._loadTextFieldSupport( params )
	-- print( "Widget._loadTextFieldSupport" )
	if Widget.TextField then return end
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	--== Dependencies

	Style._loadTextFieldStyleSupport( params )

	Widget.loadViewSupport( params )
	Widget._loadBackgroundSupport( params )
	Widget._loadTextSupport( params )

	--== TextField Components

	local TextField = require( ui_find( 'dmc_widget.widget_textfield' ) )

	Widget.TextField=TextField

	initKolors( function()
		TextField.initialize( dUI, params )
	end)
end

--- constructor for a Text Field widget.
--
-- @function newTextField
-- @tab[opt] options parameters used to create a Text Field widget
-- @treturn object @{Widget.TextField}
-- @usage local uiBg = dUI.newTextField()
--
function Widget.newTextField( options )
	-- print( "Widget.newTextField" )
	if not Widget.TextField then Widget._loadTextFieldSupport() end
	return Widget.TextField:new( options )
end



--====================================================================--
--== Private Functions


-- none



--====================================================================--
--== Event Handlers


-- none



return Widget
