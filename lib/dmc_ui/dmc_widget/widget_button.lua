--====================================================================--
-- dmc_widget/widget_button.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014-2015 David McCuskey

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

--- Button Widget Module
-- @module Widget.Button
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newButton()



--====================================================================--
--== DMC Corona UI : Widget Button
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
--== DMC UI : newButton
--====================================================================--



--====================================================================--
--== Imports


local ButtonBase = require( ui_find( 'dmc_widget.widget_button.button_base' ) )
local PushButton = require( ui_find( 'dmc_widget.widget_button.button_push' ) )
local RadioButton = require( ui_find( 'dmc_widget.widget_button.button_radio' ) )
local ToggleButton = require( ui_find( 'dmc_widget.widget_button.button_toggle' ) )



--===================================================================--
--== Button Factory
--===================================================================--


local function initializeButtons( manager )
	-- print( "Buttons.initialize" )
	dUI = manager

	local Style = dUI.Style
	ButtonBase.STYLE_CLASS = Style.Button

	ButtonBase.initialize( manager )

	Style.registerWidget( ButtonBase )
end


local Buttons = {}

Buttons.initialize = initializeButtons

-- export class instantiations for direct access
Buttons.Base = ButtonBase
Buttons.PushButton = PushButton
Buttons.ToggleButton = ToggleButton
Buttons.RadioButton = RadioButton

-- Button factory method

function Buttons.create( params )
	-- print( "Buttons.create", params.type )
	params = params or {}
	if params.action==nil then params.action=PushButton.TYPE end
	--==--
	local action = params.action

	if action == PushButton.TYPE then
		return PushButton:new( params )

	elseif action == RadioButton.TYPE then
		return RadioButton:new( params )

	elseif action == ToggleButton.TYPE then
		return ToggleButton:new( params )

	else
		error( "newButton: unknown button type: " .. tostring( action ) )

	end
end



return Buttons
