--====================================================================--
-- dmc_ui.lua
--
-- entry point into dmc-corona-ui
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


--- A Lua module which creates UI widgets for the Corona SDK.
-- @module dmc-ui
-- @usage local dUI = require 'dmc_ui'
-- local widget = dUI.newPushButton()


--====================================================================--
--== DMC UI
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "1.16.1"



--====================================================================--
--== DMC UI Config
--====================================================================--


local ssub = string.sub
local tinsert = table.insert
local tremove = table.remove
local tconcat = table.concat

local args = { ... }
local PATH = args[1]
local DPATH = nil
local SEP = nil
local split = nil

local dmc_ui_data, dmc_ui_func

if _G.__dmc_ui == nil then

	_G.__dmc_ui = {}
	dmc_ui_data = _G.__dmc_ui

	dmc_ui_data.func = {}
	dmc_ui_func = dmc_ui_data.func
	dmc_ui_func.find = function( name )
		local loc = ''
		if PATH then loc = PATH end
		if loc ~= '' and ssub( loc, -1 ) ~= '.' then
			loc = loc .. '.'
		end
		return loc .. name
	end
	dmc_ui_func.file = function( name )
		local path = {}
		if DPATH then tinsert( path, DPATH ) end
		local parts = split( name, '\\/')
		if parts[1] =='.' then tremove(parts, 1) end
		tinsert( path, tconcat( parts, SEP ) )
		return tconcat( path, SEP )
	end

end



--====================================================================--
--== DMC Corona Library Config
--====================================================================--


-- boot dmc_corona with boot script or
-- setup basic defaults if not available
--
if false == pcall( function() require 'dmc_corona_boot' end ) then
	_G.__dmc_corona = {
		dmc_corona={},
	}
end



--===================================================================--
--== Imports


local uiConst = require( PATH .. '.' .. 'ui_constants' )
local uiPalette = require( PATH .. '.' .. 'ui_palette' )
local UIUtils = require( PATH .. '.' .. 'ui_utils' )
local EventsMixin = require 'dmc_events_mix'
local Utils = require 'dmc_utils'


--===================================================================--
--== Setup, Constants


local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

local sfmt = string.format
local sgsub = string.gsub
local LOCAL_DEBUG = false

SEP = uiConst.getSystemSeparator()
DPATH = sgsub( PATH, '%.', SEP )
split = Utils.split


local UI = {}

UI.EVENT = 'dmc-ui-event' -- before patch

EventsMixin.patch( UI )

UI.stage = nil


--===================================================================--
--== Support Functions


local function createUIStage()
	local W, H = WIDTH, HEIGHT
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	-- create main layer
	local dg = display.newGroup()
	dg.x, dg.y = H_CENTER, 0
	UI.stage = dg
end

local function initialize( params )
	-- print( "UI.initialize" )

	local KeyboardMgr = require( PATH .. '.' .. 'manager.keyboard_mgr' )
	local Style = require( PATH .. '.' .. 'dmc_style' )
	local Widget = require( PATH .. '.' .. 'dmc_widget' )
	local Control = require( PATH .. '.' .. 'dmc_control' )

	UI.Keyboard = KeyboardMgr
	UI.Style = Style
	UI.Widget = Widget
	UI.Control = Control

	--== Initialize

	KeyboardMgr.initialize( UI, params )
	Style.initialize( UI, params )
	Widget.initialize( UI, params )
	Control.initialize( UI, params )

	KeyboardMgr:addEventListener( KeyboardMgr.EVENT, UI._keyboardMgr_handler )


	--== Set UI/UX

	if uiConst.IS_ANDROID then
		UI.setOS( uiConst.ANDROID )
	elseif uiConst.IS_WINDOWS then
		UI.setOS( uiConst.WINDOWS )
	elseif uiConst.IS_IOS then
		UI.setOS( uiConst.IOS )
	else
		UI.setOS( uiConst.IOS )
	end

	createUIStage()
end




--====================================================================--
--== UI Manager
--====================================================================--


--== Class Constants

UI.VERSION = VERSION
UI.WIDTH = WIDTH
UI.HEIGHT = HEIGHT

UI.__os__ = nil -- 'iOS', 'android'
UI.__osVersion__ = nil -- 'iOS'-'8.0', 'android'-'2.1'

UI._VALID_OS = {
	[uiConst.IOS]=uiConst.IOS,
	[uiConst.ANDROID]=uiConst.ANDROID,
	default=uiConst.IOS,
	-- [uiConst.WINDOWS]=uiConst.WINDOWS
}

UI._VALID_OS_VERSION = {

	[uiConst.IOS]={
		default=uiConst.IOS_8x,
		[uiConst.IOS_8x]=uiConst.IOS_8x
	},

	[uiConst.ANDROID]={
		default=uiConst.ANDROID_21,
		[uiConst.ANDROID_20]=uiConst.ANDROID_20,
		[uiConst.ANDROID_21]=uiConst.ANDROID_21
	},
	-- [uiConst.WINDOWS]=true
}

-- colors for an app's styles, see ui_palette.lua

UI.Palette = uiPalette

UI.RUN_MODE = uiConst.RUN_MODE
UI.TEST_MODE = uiConst.TEST_MODE

-- background types

UI.IMAGE = uiConst.IMAGE
UI.NINE_SLICE = uiConst.NINE_SLICE
UI.RECTANGLE = uiConst.RECTANGLE
UI.ROUNDED = uiConst.ROUNDED

-- Control Modal Types

UI.MODAL = uiConst.MODAL
UI.POPOVER = uiConst.POPOVER

-- Popover Arrow Directions

UI.ARROW_UP = uiConst.ARROW_UP
UI.ARROW_DOWN = uiConst.ARROW_DOWN
UI.ARROW_LEFT = uiConst.ARROW_LEFT
UI.ARROW_RIGHT = uiConst.ARROW_RIGHT
UI.ARROW_ANY = uiConst.ARROW_ANY

-- Control Modal Transitions

UI.SLIDE_UP = uiConst.SLIDE_UP
UI.FADE = uiConst.FADE
UI.NO_TRANSITION = uiConst.NO_TRANSITION



--===================================================================--
--== Interface Functions

--[[
Each of the sections (Style, Widget, Control) add their
functions to this UI object
All methods are available with easier maintenance.
Documentation items should be copied in manually
--]]


--- Widget Constructors
-- @section Widgets

--== Background

--- contructor for Background widgets.
--
-- @function newBackground
-- @tab[opt] options params @{newBackgroundParams}
-- @treturn object @{Widget.Background}
-- @usage local widget = dUI.newBackground()
--

--- Optional parameters for newBackground()
-- @int x minimum number of taps, default 1
-- @int y maximum number of taps, default 1
-- @string type a name for the gesture, available in events
-- @object style a delegate object to control this gesture
-- @table newBackgroundParams


--- convenience function for 9-Slice Background widgets.
--
-- @function new9SliceBackground
-- @tab options parameters used to create Background
-- @param options.sheet newImageSheet the image sheet
-- @param options.frames table of frames
-- @treturn object @{Widget.Background}
-- @usage local widget = dUI.new9SliceBackground()

--- convenience function for Image Background widgets.
--
-- @function newImageBackground
-- @tab options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local widget = dUI.newImageBackground()

--- convenience function for Rectangle Background widgets.
--
-- @function newRectangleBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local widget = dUI.newRectangleBackground()

--- convenience function for Rounded Background widgets.
--
-- @function newRoundedBackground
-- @tab[opt] options parameters used to create Background
-- @treturn object @{Widget.Background}
-- @usage local widget = dUI.newRoundedBackground()
--

--== Button

--- constructor for Button widgets.
-- the default button type is a Push Button widget.
--
-- @function newButton
-- @tab[opt] options parameters used to create Button widget
-- @treturn object @{Widget.Button}
-- @usage local widget = dUI.newButton()
--

--- convenience function for Push Buttons.
--
-- @function newPushButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local widget = dUI.newPushButton()

--- convenience function for Radio Buttons.
--
-- @function newRadioButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local widget = dUI.newRadioButton()
--

--- convenience function for Toggle Buttons.
--
-- @function newToggleButton
-- @tab[opt] options parameters used to create Button
-- @treturn object @{Widget.Button}
-- @usage local widget = dUI.newToggleButton()
--

--== Button Group

--- constructor for Button Groups.
-- a group of Radio or Toggle Buttons, of which one at most is active.
--
-- @function newButtonGroup
-- @tab options parameters used to create Button Group: `type` ('radio' or 'toggle')
-- @treturn object Button Group
-- @usage local group = dUI.newButtonGroup{ type='radio' }
--

--== Nav Bar

--- constructor for Nav Bar widgets.
--
-- @function newNavBar
-- @tab[opt] options parameters used to create a Nav Bar
-- @treturn object @{Widget.NavBar}
-- @usage local widget = dUI.newNavBar()
--

--- constructor for Nav Bar Item.
--
-- @function newNavItem
-- @tab[opt] options parameters used to create a Nav Item
-- @treturn object @{Widget.NavItem}
-- @usage local widget = dUI.newNavItem()
--

--== Scroll View

--- constructor for a Scroll View widget.
--
-- @function newScrollView
-- @tab[opt] options parameters used to create a Scroll View
-- @treturn object @{Widget.ScrollView}
-- @usage local widget = dUI.newScrollView()
--

--== Table View / Cell

--- constructor for a Table View widget.
--
-- @function newTableView
-- @tab[opt] options parameters used to create a Table View
-- @treturn object @{Widget.TableView}
-- @usage local widget = dUI.newTableView()
--

--- constructor for a Table View Cell widget.
--
-- @function newTableViewCell
-- @tab[opt] options parameters used to create a Table View Cell
-- @treturn object @{Widget.TableViewCell}
-- @usage local widget = dUI.newTableViewCell()
--

--== Text / Text Field

--- constructor for a Text widget.
--
-- @function newText
-- @tab[opt] options parameters used to create a Text widget
-- @treturn object @{Widget.Text}
-- @usage local widget = dUI.newText()
--

--- constructor for a Text Field widget.
--
-- @function newTextField
-- @tab[opt] options parameters used to create a Text Field widget
-- @treturn object @{Widget.TextField}
-- @usage local widget = dUI.newTextField()
--


--== Nav Bar


--- Style Constructors
-- @section Styles


--- the gesture's delegate (object/table)
--
-- @function newBackgroundStyle
-- @usage print( gesture.delegate )
-- @usage gesture.delegate = DisplayObject
--


--- Control Constructors
-- @section Controls

--- the gesture's delegate (object/table)
--
-- @function newTableViewControl
-- @usage print( gesture.delegate )
-- @usage gesture.delegate = DisplayObject
--



--===================================================================--
--== Misc Functions



function UI._keyboardMgr_handler( event )
	-- print( "UI._keyboardMgr_handler", event )

	-- Utils.print( event )
	event.name=UI.EVENT

	UI:dispatchRawEvent( event )
end


function UI.setOS( platform, version )
	-- print( "UI.setOS", platform, version )

	--== Set OS

	local os = UI._VALID_OS[ platform ]
	if not os then
		os = UI._VALID_OS.default
		print( sfmt( "[WARNING] UIs.setOS() unknown OS '%s'", tostring(platform) ))
		print( sfmt( "Setting to default '%s'", tostring( os ) ) )
	end
	UI.__os__ = os

	--== Set OS Version

	local versions = UI._VALID_OS_VERSION[ os ]
	local value = versions[ version ]
	if not value then
		value = versions.default
		if LOCAL_DEBUG then
			print( sfmt( "[WARNING] UIs.setOS() unknown OS Version '%s'", tostring( version )))
			print( sfmt( "Setting to default '%s'", tostring( value ) ) )
		end
	end
	UI.__osVersion__ = value

	if LOCAL_DEBUG then
		print( "UI theme set for ", os, value )
	end

end



--====================================================================--
--== Init UIs
--====================================================================--


initialize()


return UI
