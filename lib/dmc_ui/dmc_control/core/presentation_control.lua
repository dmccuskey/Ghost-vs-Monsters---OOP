--====================================================================--
-- dmc_ui/dmc_control/core/presentation_control.lua
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
--== DMC Corona UI : Presentation Control
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
--== DMC UI : Presentation Control
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local uiConst = require( ui_find( 'ui_constants' ) )



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local mmax = math.max
local mmin = math.min
local tinsert = table.insert

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Support Functions


local function eventBlock_handler( event )
	return true
end



--====================================================================--
--== Presentation Control Base Class
--====================================================================--


--[[
Shows a control (the "presented control") over the rest of the app:
a dimming layer the size of the screen, and on it a panel which holds
the control's view and clips it. The panel slides up from the bottom,
fades in, or appears at once.

A control makes its Presentation Control itself, when its 'modalStyle'
is set (see view_control.lua); an app asks the control to present and
dismiss, and uses this object for the delegate and the dimming.

This base class is the modal page (dUI.MODAL): the size of the screen
below the status bar, or the control's 'preferredContentSize' centered
there. A subclass (Popover Control) gives the panel another frame.
--]]

local Presentation = newClass( ComponentBase, {name="Presentation Control"} )

--== Class Constants

Presentation.DISMISSED = 'dismissed'
Presentation.PRESENTING = 'presenting'
Presentation.PRESENTED = 'presented'
Presentation.DISMISSING = 'dismissing'

Presentation.DEFAULT_TRANSITION = uiConst.SLIDE_UP
Presentation.DEFAULT_DISMISS_ON_TAP_OUTSIDE = false
Presentation.DEFAULT_DIM_COLOR = uiConst.PRESENT_CONTROL_DIM_COLOR

-- the width of the panel's frame around the control, in the panel's color
Presentation.BORDER = 0

--== Event Constants

Presentation.EVENT = 'presentation-control-event'


--======================================================--
-- Start: Setup DMC Objects

--== init

function Presentation:__init__( params )
	-- print( "Presentation:__init__" )
	params = params or {}
	if params.dismissOnTapOutside==nil then
		params.dismissOnTapOutside = self.DEFAULT_DISMISS_ON_TAP_OUTSIDE
	end

	self:superCall( '__init__', params )
	--==--

	if self.is_class then return end

	--== Create Properties ==--

	-- properties stored in Class

	self._state = Presentation.DISMISSED

	-- how much of the presentation shows, 0 (dismissed) to 1 (presented)
	self._progress = 0

	-- the running motion: { from=, to=, start=, time= }
	self._motion = nil
	self._enterFrame_f = nil
	self._onComplete = {} -- functions to call when the motion ends

	-- the transition of this presentation, kept for its dismissal
	self._transition = self.DEFAULT_TRANSITION

	self._dimColor = params.dimColor or self.DEFAULT_DIM_COLOR
	self._panelColor = params.panelColor or uiConst.PRESENT_CONTROL_PANEL_COLOR
	self._dismissOnTap = params.dismissOnTapOutside

	-- the panel's frame: { x=, y=, width=, height= }, x/y its top center
	self._frame = nil

	--== Display Groups ==--

	self._dgBg = nil -- group for the dimming layer
	self._panel = nil -- container which clips the presented view
	self._dgMain = nil -- group for the presented view, inside the panel

	--== Object References ==--

	-- Control which is presented, and where its view came from
	self._presentedControl = nil
	self._home = nil

	-- delegate object, told about the presentation
	self._delegate = params.delegate

	--== Visual

	self._rctDim = nil -- dimming layer
	self._rctHit = nil -- the panel's background, keeps its touches

	self._resize_f = nil

end

function Presentation:__undoInit__()
	--print( "Presentation:__undoInit__" )
	self._delegate = nil
	self._onComplete = nil
	--==--
	self:superCall( '__undoInit__' )
end

--== createView

function Presentation:__createView__()
	-- print( "Presentation:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o, dg

	dg = display.newGroup()
	self:insert( dg )
	self._dgBg = dg

	-- dimming layer

	o = display.newRect( 0, 0, 10, 10 )
	o.isHitTestable = true
	dg:insert( o )
	self._rctDim = o

	-- panel, and in it the group for the presented view.
	-- a container's content is placed from its center

	o = display.newContainer( 10, 10 )
	self:insert( o )
	self._panel = o

	-- the panel's background, which keeps the touches on it

	o = display.newRect( 0, 0, 10, 10 )
	o.isHitTestable = true
	self._panel:insert( o )
	self._rctHit = o

	dg = display.newGroup()
	self._panel:insert( dg )
	self._dgMain = dg

end

function Presentation:__undoCreateView__()
	-- print( "Presentation:__undoCreateView__" )
	self._dgMain:removeSelf()
	self._dgMain = nil

	self._rctHit:removeSelf()
	self._rctHit = nil

	self._panel:removeSelf()
	self._panel = nil

	self._rctDim:removeSelf()
	self._rctDim = nil

	self._dgBg:removeSelf()
	self._dgBg = nil
	--==--
	self:superCall( '__undoCreateView__' )
end

--== initComplete

function Presentation:__initComplete__()
	-- print( "Presentation:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self._dimTap_f = function( event ) return self:_dimTap_handler( event ) end
	self._rctDim:addEventListener( 'touch', eventBlock_handler )
	self._rctDim:addEventListener( 'tap', self._dimTap_f )
	self._rctHit:addEventListener( 'touch', eventBlock_handler )
	self._rctHit:addEventListener( 'tap', eventBlock_handler )

	self._resize_f = function( event ) self:_resize_handler( event ) end
	Runtime:addEventListener( 'resize', self._resize_f )

	self.dimColor = self._dimColor
	self.panelColor = self._panelColor
	self.isVisible = false
end

function Presentation:__undoInitComplete__()
	-- print( "Presentation:__undoInitComplete__" )
	self:_stopMotion()
	self:_unsetPresentedControl()

	Runtime:removeEventListener( 'resize', self._resize_f )
	self._resize_f = nil

	self._rctHit:removeEventListener( 'tap', eventBlock_handler )
	self._rctHit:removeEventListener( 'touch', eventBlock_handler )
	self._rctDim:removeEventListener( 'tap', self._dimTap_f )
	self._rctDim:removeEventListener( 'touch', eventBlock_handler )
	self._dimTap_f = nil
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function Presentation.initialize( manager )
	-- print( "Presentation.initialize" )
	dUI = manager
end



--====================================================================--
--== Public Methods


--== .delegate

-- an object told about the presentation. each method is optional,
-- and gets this Presentation Control:
-- presentationWillBegin, presentationEnded, dismissalWillBegin,
-- dismissalEnded, and shouldDismiss (a tap outside the panel:
-- return false to keep the presentation)
--
function Presentation.__getters:delegate()
	return self._delegate
end
function Presentation.__setters:delegate( value )
	self._delegate = value
end

--== .dimColor

-- the color of the layer over the app, a table { r, g, b, a }
--
function Presentation.__getters:dimColor()
	return self._dimColor
end
function Presentation.__setters:dimColor( value )
	assert( type(value)=='table', "[ERROR] dimColor expected a table { r, g, b, a }" )
	--==--
	self._dimColor = value
	self._rctDim:setFillColor( unpack( value ) )
end

--== .panelColor

-- the color of the panel behind the control's view,
-- a table { r, g, b, a }
--
function Presentation.__getters:panelColor()
	return self._panelColor
end
function Presentation.__setters:panelColor( value )
	assert( type(value)=='table', "[ERROR] panelColor expected a table { r, g, b, a }" )
	--==--
	self._panelColor = value
	self._rctHit:setFillColor( unpack( value ) )
	self:_panelColorChanged()
end

--== .dismissOnTapOutside

-- if a tap outside the panel dismisses the presentation
--
function Presentation.__getters:dismissOnTapOutside()
	return self._dismissOnTap
end
function Presentation.__setters:dismissOnTapOutside( value )
	self._dismissOnTap = ( value==true )
end

--== .state

-- one of DISMISSED, PRESENTING, PRESENTED, DISMISSING (read only)
--
function Presentation.__getters:state()
	return self._state
end

--== .isPresented

-- if the presentation shows or is on its way in (read only)
--
function Presentation.__getters:isPresented()
	local state = self._state
	return ( state==Presentation.PRESENTING or state==Presentation.PRESENTED )
end

--== .presentedControl

function Presentation.__getters:presentedControl()
	return self._presentedControl
end


-- init
-- set the Control to present, call presentControl() after.
-- a Control does this itself (ViewControl:presentControl)
--
function Presentation:init( presentedControl )
	-- print( "Presentation:init" )
	assert( presentedControl, "[ERROR] Presentation:init requires a control" )
	--==--
	if self._presentedControl == presentedControl then return end
	self:_stopMotion()
	self:_unsetPresentedControl()
	self:_setPresentedControl( presentedControl )
end


-- presentControl
-- show the presentation. params are optional:
-- transition: dUI.SLIDE_UP, dUI.FADE or dUI.NO_TRANSITION
-- animated: false puts the control in place at once, this time
-- time: of the transition, in milliseconds
-- onComplete: function to call when the control is in place
--
-- during a dismissal, the motion turns around from where it is
--
function Presentation:presentControl( params )
	-- print( "Presentation:presentControl" )
	params = params or {}
	assert( self._presentedControl, "[ERROR] Presentation:presentControl has no control to present" )
	--==--
	local state = self._state

	if state==Presentation.PRESENTED then
		if params.onComplete then params.onComplete() end
		return
	elseif state==Presentation.PRESENTING then
		tinsert( self._onComplete, params.onComplete )
		return
	end

	if state==Presentation.DISMISSED then
		-- a new presentation: its transition, its place, in front
		self._transition = self:_getTransition( params, self.DEFAULT_TRANSITION )
		self.isVisible = true
		self.view:toFront()
		self:_layout()
	end

	self._state = Presentation.PRESENTING
	self:_callDelegate( 'presentationWillBegin' )
	self:_startMotion( 1, params )
end


-- dismissControl
-- remove the presentation. params are optional, as for
-- presentControl(); the transition is the presentation's own
-- unless one is given.
--
-- during a presentation, the motion turns around from where it is
--
function Presentation:dismissControl( params )
	-- print( "Presentation:dismissControl" )
	params = params or {}
	--==--
	local state = self._state

	if state==Presentation.DISMISSED then
		if params.onComplete then params.onComplete() end
		return
	elseif state==Presentation.DISMISSING then
		tinsert( self._onComplete, params.onComplete )
		return
	end

	self._transition = self:_getTransition( params, self._transition )
	-- another transition starts from the control in its place
	if state==Presentation.PRESENTED then self:_setProgress( 1 ) end

	self._state = Presentation.DISMISSING
	self:_callDelegate( 'dismissalWillBegin' )
	self:_startMotion( 0, params )
end



--====================================================================--
--== Private Methods


function Presentation:_panelColorChanged()
	-- print( "OVERRIDE Presentation:_panelColorChanged" )
end


function Presentation:_callDelegate( name )
	local del = self._delegate
	local f = del and del[ name ]
	if f then return f( del, self ) end
end


function Presentation:_getTransition( params, default )
	local trans = params.transition or default
	assert(
		trans==uiConst.SLIDE_UP or trans==uiConst.FADE or trans==uiConst.NO_TRANSITION,
		"[ERROR] Presentation: unknown transition '"..tostring( trans ).."'"
	)
	return trans
end

function Presentation:_getTransitionTime( params )
	if params.time then return params.time end
	if self._transition==uiConst.SLIDE_UP then
		return uiConst.PRESENT_CONTROL_SLIDE_TIME
	end
	return uiConst.PRESENT_CONTROL_TRANSITION_TIME
end


--======================================================--
-- Presented Control

function Presentation:_setPresentedControl( control )
	-- print( "Presentation:_setPresentedControl" )
	local view = control.view
	self._presentedControl = control
	self._home = {
		parent=view.parent, x=view.x, y=view.y,
		width=control.width, height=control.height
	}
	self._dgMain:insert( view )
	view.x, view.y = 0, 0
	self:_layout()
end

-- give the control's view back to where it came from
--
function Presentation:_unsetPresentedControl()
	-- print( "Presentation:_unsetPresentedControl" )
	local control, home = self._presentedControl, self._home
	if not control then return end
	self._presentedControl = nil
	self._home = nil

	local view = control.view
	if not view or not view.parent then return end -- control was removed

	local parent = home.parent
	if not parent or not parent.insert then parent = display.getCurrentStage() end
	parent:insert( view )
	view.x, view.y = home.x, home.y
	control.width, control.height = home.width, home.height
end


--======================================================--
-- Layout

-- the screen as the device shows it, in content coordinates,
-- and the part of it below the status bar
--
function Presentation:_getScreen()
	local sbH = display.topStatusBarContentHeight
	return {
		x=display.screenOriginX,
		y=display.screenOriginY,
		width=display.actualContentWidth,
		height=display.actualContentHeight,
		top=display.screenOriginY + sbH,
	}
end

-- the size asked for, nil for all of the room
--
function Presentation:_getPreferredSize()
	return self._presentedControl.preferredContentSize
end

-- the panel's frame: x/y are its top center.
-- here the control's preferred size centered below the status bar,
-- or all of that room
--
function Presentation:_getPanelFrame( screen )
	local size = self:_getPreferredSize()
	local roomH = screen.height - ( screen.top-screen.y )
	local w, h = screen.width, roomH
	if size then
		w, h = mmin( size.width, w ), mmin( size.height, h )
	end
	return {
		x=screen.x + screen.width*0.5,
		y=screen.top + ( roomH-h )*0.5,
		width=w, height=h,
	}
end

function Presentation:_layout()
	-- print( "Presentation:_layout" )
	local control = self._presentedControl
	if not control then return end

	local screen = self:_getScreen()
	local frame = self:_getPanelFrame( screen )
	local w, h = frame.width, frame.height
	local border = self.BORDER
	local o

	self._screen = screen
	self._frame = frame

	o = self._rctDim
	o.width, o.height = screen.width, screen.height
	o.x, o.y = screen.x + screen.width*0.5, screen.y + screen.height*0.5

	o = self._panel
	o.width, o.height = w, h

	o = self._rctHit
	o.width, o.height = w, h

	-- the control's view is placed by its top center, inside the frame
	self._dgMain.y = -h*0.5 + border
	w, h = mmax( 0, w-border*2 ), mmax( 0, h-border*2 )

	if control.width~=w then control.width = w end
	if control.height~=h then control.height = h end

	self:_setProgress( self._progress )
end

-- show the presentation at a point of its transition,
-- 0 (dismissed) to 1 (presented)
--
function Presentation:_setProgress( value )
	local frame, screen = self._frame, self._screen
	local panel = self._panel
	local trans = self._transition
	self._progress = value
	if not frame then return end

	local x, y = frame.x, frame.y + frame.height*0.5
	local alpha = 1

	if trans==uiConst.SLIDE_UP then
		-- from below the screen, slowing down on its way in
		local away = ( 1-value )*( 1-value )
		y = y + away*( screen.y+screen.height - frame.y )
	elseif trans==uiConst.FADE then
		alpha = value
	elseif value<1 then
		alpha = 0
	end

	self._rctDim.alpha = value
	panel.x, panel.y = x, y
	panel.alpha = alpha
end


--======================================================--
-- Motion

function Presentation:_stopMotion()
	local f = self._enterFrame_f
	if f then
		Runtime:removeEventListener( 'enterFrame', f )
		self._enterFrame_f = nil
	end
	self._motion = nil
end

-- move to progress 'target' (0 or 1) from where the presentation is.
-- the functions of the motion this one cuts short aren't called
--
function Presentation:_startMotion( target, params )
	-- print( "Presentation:_startMotion", target )
	self:_stopMotion()
	self._onComplete = { params.onComplete }

	local from = self._progress
	local time = self:_getTransitionTime( params )
	-- part of the way takes part of the time
	time = time * math.abs( target-from )

	if params.animated==false or self._transition==uiConst.NO_TRANSITION or time<=0 then
		self:_endMotion( target )
		return
	end

	local motion = { from=from, to=target, start=system.getTimer(), time=time }
	local f = function( event )
		local p = ( event.time-motion.start )/motion.time
		if p>=1 then
			self:_endMotion( motion.to )
		elseif p>0 then
			self:_setProgress( motion.from + ( motion.to-motion.from )*p )
		end
	end
	self._motion = motion
	self._enterFrame_f = f
	Runtime:addEventListener( 'enterFrame', f )
end

function Presentation:_endMotion( target )
	-- print( "Presentation:_endMotion", target )
	local funcs = self._onComplete
	self:_stopMotion()
	self._onComplete = {}
	self:_setProgress( target )

	if target==1 then
		self._state = Presentation.PRESENTED
		self:_callDelegate( 'presentationEnded' )
	else
		self._state = Presentation.DISMISSED
		self.isVisible = false
		self:_callDelegate( 'dismissalEnded' )
	end
	-- a function may remove the control, or present it again
	for i=1, #funcs do funcs[i]() end
end



--====================================================================--
--== Event Handlers


-- a tap outside the panel. the layer keeps it either way
--
function Presentation:_dimTap_handler( event )
	-- print( "Presentation:_dimTap_handler" )
	if self._dismissOnTap and self._state==Presentation.PRESENTED then
		if self:_callDelegate( 'shouldDismiss' )~=false then
			self:dismissControl()
		end
	end
	return true
end

-- the screen changed, eg the device was turned
--
function Presentation:_resize_handler( event )
	if self._state==Presentation.DISMISSED then return end
	self:_layout()
end



return Presentation
