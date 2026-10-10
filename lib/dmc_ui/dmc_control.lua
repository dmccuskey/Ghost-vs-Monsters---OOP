--====================================================================--
-- dmc_ui/dmc_control.lua
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
--== DMC Corona UI : Control Interface
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
--== DMC UI : Control Interface
--====================================================================--



--====================================================================--
--== Imports




--====================================================================--
--== Setup, Constants


--== To be set in initialize()
local dUI = nil
local Widget = nil



--===================================================================--
--== Support Functions




--====================================================================--
--== Control Interface
--====================================================================--


local Control = {}



--====================================================================--
--== Control Static Functions


function Control.initialize( manager, params )
	-- print( "Control.initialize", manager )
	-- params = params or {}
	-- if params.mode==nil then params.mode=BaseControl.RUN_MODE end
	--==--
	dUI = manager

	--== Add API calls

	dUI.newNavigationControl = Control.newNavigationControl
	dUI.newPopoverControl = Control.newPopoverControl
	dUI.newPresentationControl = Control.newPresentationControl

end



--====================================================================--
--== Control Public Functions


--======================================================--
-- newNavigationControl Support

function Control._loadNavigationControlSupport( params )
	-- print( "Control._loadNavigationControlSupport" )
	if Control.Navigation then return end
	--==--

	--== Dependancies

	Control._loadViewControlSupport( params )
	dUI.Widget._loadNavBarSupport( params )

	--== Components

	local NavControl = require( ui_find( 'dmc_control.navigation_control' ) )

	Control.Navigation=NavControl

	NavControl.initialize( dUI, params )

end

function Control.newNavigationControl( params )
	-- print( "Control.newNavigationControl" )
	params = params or {}
	--==--
	if not Control.Navigation then Control._loadNavigationControlSupport() end
	return Control.Navigation:new( params )
end


--======================================================--
-- newPopoverControl Support

function Control._loadPopoverControlSupport( params )
	-- print( "Control._loadPopoverControlSupport" )
	if Control.Popover then return end
	--==--

	--== Dependancies

	Control._loadPresentationControlSupport( params )

	--== Components

	local PopoverControl = require( ui_find( 'dmc_control.popover_control' ) )

	Control.Popover=PopoverControl

	PopoverControl.initialize( dUI, params )

end

function Control.newPopoverControl( params )
	-- print( "Control.newPopoverControl" )
	params = params or {}
	--==--
	if not Control.Popover then Control._loadPopoverControlSupport() end
	return Control.Popover:new( params )
end


--======================================================--
-- newPresentationControl Support

function Control.newPresentationControl( params )
	-- print( "Control.newPresentationControl" )
	params = params or {}
	--==--
	if not Control.PresentationBase then Control._loadPresentationControlSupport() end
	return Control.PresentationBase:new( params )
end


--====================================================================--
--== Private Functions


function Control._loadViewControlSupport( params )
	-- print( "Control._loadViewControlSupport" )
	if Control.ViewBase then return end

	--== Components

	local ViewControl = require( ui_find( 'dmc_control.core.view_control' ) )

	Control.ViewBase=ViewControl

	ViewControl.initialize( dUI, params )
end


function Control._loadPresentationControlSupport( params )
	-- print( "Control._loadPresentationControlSupport" )
	if Control.PresentationBase then return end
	--==--

	--== Components

	local PresentationControl = require( ui_find( 'dmc_control.core.presentation_control' ) )

	Control.PresentationBase=PresentationControl

	PresentationControl.initialize( dUI, params )

end



--====================================================================--
--== Event Handlers


-- none



return Control
