--====================================================================--
-- dmc_ui/dmc_control/core/view_control.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (C) 2015 David McCuskey. All Rights Reserved.

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
--== DMC Corona UI : View Control Base
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== DMC Corona UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI :
--====================================================================--



--====================================================================--
--== Imports


local LifecycleMixModule = require 'dmc_lifecycle_mix'
local Objects = require 'dmc_objects'
local uiConst = require( ui_find( 'ui_constants' ) )



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local LifecycleMix = LifecycleMixModule.LifecycleMix

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== View Control Base Class
--====================================================================--


local ViewControl = newClass(
	{ ComponentBase, LifecycleMix }, {name="View Control"}
)

--== Event Constants

ViewControl.EVENT = 'view-control-event'


--======================================================--
-- Start: Setup DMC Objects

function ViewControl:__init__( params )
	-- print( "ViewControl:__init__" )
	params = params or {}
	if params.x==nil then params.x=0 end
	if params.y==nil then params.y=0 end

	self:superCall( LifecycleMix, '__init__', params )
	self:superCall( ComponentBase, '__init__', params )
	--==--

	--== Create Properties ==--

	self._width = params.width or dUI.WIDTH
	self._height = params.height or dUI.HEIGHT

	self._modalStyle = nil
	self._modalStyle_init = params.modalStyle -- set in __initComplete__
	self._preferredContentSize = params.preferredContentSize

	--[[
	the Presentation Control which shows this Control,
	made when modalStyle is set (a Popover Control for dUI.POPOVER)
	--]]
	self._presentationControl = nil

end

function ViewControl:__undoInit__()
	--print( "ViewControl:__undoInit__" )
	--==--
	self:superCall( ComponentBase, '__undoInit__' )
	self:superCall( LifecycleMix, '__undoInit__' )
end


function ViewControl:__createView__()
	-- print( "ViewControl:__createView__" )
	self:superCall( ComponentBase, '__createView__' )
	--==--
end

function ViewControl:__undoCreateView__()
	-- print( "ViewControl:__undoCreateView__" )
	--==--
	self:superCall( ComponentBase, '__undoCreateView__' )
end


--== initComplete

function ViewControl:__initComplete__()
	-- print( "ViewControl:__initComplete__" )
	self:superCall( ComponentBase, '__initComplete__' )
	--==--
	local style = self._modalStyle_init
	self._modalStyle_init = nil
	if style then self.modalStyle = style end
end

function ViewControl:__undoInitComplete__()
	-- print( "ViewControl:__undoInitComplete__" )
	self:_destroyPresentationControl()
	--==--
	self:superCall( ComponentBase, '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ViewControl.initialize( manager )
	-- print( "ViewControl.initialize" )
	dUI = manager
end



--====================================================================--
--== Public Methods


--== .width

function ViewControl:_widthChanged()
	-- print( "OVERRIDE ViewControl:_widthChanged" )
end
function ViewControl.__getters:width()
	return self._width
end
function ViewControl.__setters:width( value )
	self._width = value
	self:_widthChanged()
end

--== .height

function ViewControl:_heightChanged()
	-- print( "OVERRIDE ViewControl:_heightChanged" )
end
function ViewControl.__getters:height()
	return self._height
end
function ViewControl.__setters:height( value )
	-- print( "ViewControl.__setters:height", value )
	self._height = value
	self:_heightChanged()
end

--== .modalStyle

-- how the Control is shown by presentControl(): dUI.MODAL (a page over
-- the app), dUI.POPOVER, or nil (it isn't presented, the default).
-- setting it makes the Control's Presentation Control, which takes the
-- Control's view; nil gives the view back to where it was
--
function ViewControl.__getters:modalStyle()
	-- print( "ViewControl.__getters:modalStyle" )
	return self._modalStyle
end
function ViewControl.__setters:modalStyle( value )
	-- print( "ViewControl.__setters:modalStyle" )
	assert(
		value==nil or value==dUI.MODAL or value==dUI.POPOVER,
		"[ERROR] ViewControl.modalStyle expected dUI.MODAL, dUI.POPOVER or nil"
	)
	--==--
	if value == self._modalStyle then return end

	self:_destroyPresentationControl()
	self._modalStyle = value
	if value then self:_createPresentationControl() end
end

--== .preferredContentSize

-- the size of the Control when presented, a table { width=, height= }.
-- nil (the default) is all of the screen below the status bar for
-- dUI.MODAL, and 320x600 or what fits the screen for dUI.POPOVER
--
function ViewControl.__getters:preferredContentSize()
	-- print( "ViewControl.__getters:preferredContentSize" )
	return self._preferredContentSize
end
function ViewControl.__setters:preferredContentSize( value )
	-- print( "ViewControl.__setters:preferredContentSize" )
	assert(
		value==nil or ( type(value)=='table' and value.width and value.height ),
		"[ERROR] ViewControl.preferredContentSize expected a table { width=, height= } or nil"
	)
	--==--
	self._preferredContentSize = value
	local o = self._presentationControl
	if o then o:_layout() end
end

--== .presentationControl

-- the Presentation Control which shows this Control (read only),
-- nil without a modalStyle
--
function ViewControl.__getters:presentationControl()
	return self._presentationControl
end

--== .popoverControl

-- the Popover Control which shows this Control (read only),
-- nil unless modalStyle is dUI.POPOVER
--
function ViewControl.__getters:popoverControl()
	-- print( "ViewControl.__getters:popoverControl" )
	if self._modalStyle ~= dUI.POPOVER then return nil end
	return self._presentationControl
end

--== .isPresented

-- if the Control shows or is on its way in (read only)
--
function ViewControl.__getters:isPresented()
	local o = self._presentationControl
	return ( o~=nil and o.isPresented )
end


-- presentControl
-- show the Control as its modalStyle says. params are optional:
-- transition (dUI.SLIDE_UP, dUI.FADE, dUI.NO_TRANSITION), animated
-- (false: no transition), time, onComplete
--
function ViewControl:presentControl( params )
	-- print( "ViewControl:presentControl" )
	local o = self._presentationControl
	assert( o, "[ERROR] ViewControl:presentControl needs a modalStyle, eg dUI.MODAL" )
	--==--
	o:presentControl( params )
end

-- dismissControl
-- remove the presented Control from the screen. params are optional,
-- as for presentControl()
--
function ViewControl:dismissControl( params )
	-- print( "ViewControl:dismissControl" )
	local o = self._presentationControl
	assert( o, "[ERROR] ViewControl:dismissControl needs a modalStyle, eg dUI.MODAL" )
	--==--
	o:dismissControl( params )
end


--[[
function ViewControl:viewIsVisible( value )
	-- print( "ViewControl:viewIsVisible" )
	local o = self._current_view
	if o and o.viewIsVisible then o:viewIsVisible( value ) end
end

function ViewControl:viewInMotion( value )
	-- print( "ViewControl:viewInMotion" )
	local o = self._current_view
	if o and o.viewInMotion then o:viewInMotion( value ) end
end
--]]



--====================================================================--
--== Private Methods


function ViewControl:_destroyPresentationControl()
	-- print( "ViewControl:_destroyPresentationControl" )
	local o = self._presentationControl
	if not o then return end
	self._presentationControl = nil
	o:removeSelf()
end


function ViewControl:_createPresentationControl()
	-- print( "ViewControl:_createPresentationControl" )
	local o
	if self._modalStyle == dUI.POPOVER then
		o = dUI.Control.newPopoverControl()
	else
		o = dUI.Control.newPresentationControl()
	end
	self._presentationControl = o
	o:init( self )
end



--======================================================--
-- DMC Lifecycle Methods

function ViewControl:__commitProperties__()
	-- print( "ViewControl:__commitProperties__" )
end



--====================================================================--
--== Event Handlers


-- none



return ViewControl
