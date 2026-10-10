--====================================================================--
-- dmc_ui/dmc_widget/widget_button/button_push.lua
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



--====================================================================--
--== DMC Corona Widgets : Push Button Widget
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local ButtonBase = require( ui_find( 'dmc_widget.widget_button.button_base' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass



--===================================================================--
--== Radio Button Class
--===================================================================--


--- Push Button Widget.
-- a button widget to be used within a Radio Group.
--
-- @classmod Widget.PushButton
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newPushButton()

local PushButton = newClass( ButtonBase, {name="Push Button"} )

PushButton.TYPE = 'push'


--======================================================--
-- Start: Setup DMC Objects

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


--[[
Inherited - copied from dmc_widget.core.widget
--]]

--- set/get x position.
--
-- @within Properties
-- @function .x
-- @usage widget.x = 5
-- @usage print( widget.x )

--- set/get y position.
--
-- @within Properties
-- @function .y
-- @usage widget.y = 5
-- @usage print( widget.y )

--- set/get width.
--
-- @within Properties
-- @function .width
-- @usage widget.width = 5
-- @usage print( widget.width )

--- set/get height.
--
-- @within Properties
-- @function .height
-- @usage widget.height = 5
-- @usage print( widget.height )

--- set/get anchorX.
--
-- @within Properties
-- @function .anchorX
-- @usage widget.anchorX = 5
-- @usage print( widget.anchorX )

--- set/get anchorY.
--
-- @within Properties
-- @function .anchorY
-- @usage widget.anchorY = 5
-- @usage print( widget.anchorY )



--[[
Inherited - from dmc_ui.dmc_widget.widget_button
--]]

--- set/get strokeWidth on background style.
-- this is a convenience method for calling on background style.
-- @within Properties
-- @function .backgroundStrokeWidth
-- @usage widget.backgroundStrokeWidth = 10
-- @usage print( widget.backgroundStrokeWidth )
-- @usage
-- (same as)
-- print( widget.style.background.strokeWidth = 10 )

--- set/get user data for button.
-- convenient storage area for user data. this property is availble within button events.
-- @within Properties
-- @function .data
-- @usage widget.data = 5
-- @usage print( widget.data )

--- set/get x-axis hit margin.
-- increases horizontal hit area for button, useful when button area is small. value must be greater or equal to 0.
-- @within Properties
-- @function .hitMarginX
-- @usage widget.hitMarginX = 5
-- @usage print( widget.hitMarginX )

--- set/get y-axis hit margin.
-- increases vertical hit area for button, useful when button area is small. value must be greater or equal to 0.
-- @within Properties
-- @function .hitMarginY
-- @usage widget.hitMarginY = 5
-- @usage print( widget.hitMarginY )

--- set/get button id.
-- optional id value for button. this value is passed in during button events, making it easy to differentiate buttons.
-- @within Properties
-- @function .id
-- @usage widget.id = 'left-button'
-- @usage print( widget.id )

--- get button 'active' state.
-- check whether button is in 'active' state.
-- @within Properties
-- @function .isActive
-- @usage print( widget.isActive )

--- set/get whether button is 'disabled' or can be pressed/activated.
-- property to set button disabled state or to see if it's enabled. this sets both the *look* of the button and the button action; it leaves the style's .isHitActive as is.
-- @within Properties
-- @function .isEnabled
-- @usage widget.isEnabled = false
-- @usage print( widget.isEnabled )

--- set/get button press *action*.
-- this gets the *action* of the button, whether a press is handled or not. a disabled button ignores presses whatever this value.
-- @within Properties
-- @function .isHitActive
-- @usage widget.isHitActive = false
-- @usage print( widget.isHitActive )

--- set/get text for button label.
--
-- @within Properties
-- @function .labelText
-- @usage widget.labelText = "Press"
-- @usage print( widget.labelText )

--- set font to use for button label.
--
-- @within Properties
-- @function .labelFont
-- @usage widget.labelFont = native.systemFont
-- @usage
-- equivalent to:
-- widget.style.label.font = native.systemFont

--- set font size to use for button label.
--
-- @within Properties
-- @function .labelFontSize
-- @usage widget.labelFontSize = 12
-- @usage
-- equivalent to:
-- widget.style.label.fontSize = 12

--- set callback for onPress events.
--
-- @within Properties
-- @function .onPress
-- @usage widget.onPress = <function>

--- set callback for onRelease events.
--
-- @within Properties
-- @function .onRelease
-- @usage widget.onRelease = <function>

--- set callback for onEvent events.
--
-- @within Properties
-- @function .onEvent
-- @usage widget.onEvent = <function>



--- programmatically "press" a button.
-- this will fire both 'began' and 'ended' events.
-- @within Methods
-- @function press
-- @usage widget:press()

--- set/get strokeWidth on background style.
-- this is a convenience method for calling on background style.
-- @within Methods
-- @function setBackgroundFillColor
-- @usage widget:setBackgroundFillColor( 1, 1, 1, 1 )
-- @usage
-- equivalent to:
-- widget.style.background.fillColor = { 1,1,1,1 }

--- set hit margin for button.
-- this is a convenience method to set hit margins at same time. args can be two integers or a table as array. (there is no difference with this or the properties)
-- @within Methods
-- @function setHitMargin
-- @usage print( widget:setHitMargin( 5, 0 ) )
-- @usage print( widget:setHitMargin( { 2, 3 } ) )

--- set text color for button label.
-- this is a convenience method to set the text color of the label
-- @within Methods
-- @function setLabelTextColor
-- @usage widget:setLabelTextColor( 1, 1, 1, 1 )
-- equivalent to:
-- widget.style.label.textColor = { 1,1,1,1 }




--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function PushButton:_hitAreaTouch_handler( event )
	-- print( "PushButton:_hitAreaTouch_handler", event.phase )

	if not self:_isPressable() then return self:_dropFocus() end

	local phase = event.phase
	local button = event.target

	if phase == 'began' then
		display.getCurrentStage():setFocus( button )
		self._has_focus = true

		self:gotoState( self.STATE_ACTIVE )
		self:_doPressEventDispatch()
		return true
	end

	if not self._has_focus then return end

	local bounds = button.contentBounds
	local x,y = event.x,event.y
	local is_bounded =
		( x >= bounds.xMin and x <= bounds.xMax and
		y >= bounds.yMin and y <= bounds.yMax )

	if phase == 'moved' then
		if is_bounded then
			self:gotoState( self.STATE_ACTIVE )
		else
			self:gotoState( self.STATE_INACTIVE )
		end

	elseif phase == 'ended' or phase == 'canceled' then
		display.getCurrentStage():setFocus( nil )
		self._has_focus = false
		self:gotoState( self.STATE_INACTIVE )

		if is_bounded then
			self:_doReleaseEventDispatch()
		end
	end

	return true
end




return PushButton
