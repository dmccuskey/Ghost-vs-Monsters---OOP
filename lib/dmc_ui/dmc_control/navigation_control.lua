--====================================================================--
-- dmc_ui/dmc_control/navigation_control.lua
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
--== DMC Corona UI : Navigation Control
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
--== DMC UI : newNavigationControl
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local uiConst = require( ui_find( 'ui_constants' ) )

local ViewControl = require( ui_find( 'dmc_control.core.view_control' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

local tinsert = table.insert
local tremove = table.remove

local LOCAL_DEBUG = false

-- a touch or a tap on the control stays with it (Solar2D sends 'tap' apart
-- from 'touch'): what a view doesn't take doesn't reach what lies behind
local function eventBlock_handler( event )
	return true
end

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Navigation Control Class
--====================================================================--


local NavControl = newClass( ViewControl, {name="Navigation Control"}
)

--== Class Constants

NavControl.ANCHOR = { x=0.5,y=0 }

NavControl.FORWARD = 'forward-direction'
NavControl.REVERSE = 'reverse-direction'

--== Event Constants

NavControl.REMOVED_VIEW = 'removed-view-event'


--======================================================--
-- Start: Setup DMC Objects

function NavControl:__init__( params )
	-- print( "NavControl:__init__" )
	params = params or {}
	if params.transitionTime==nil then params.transitionTime=uiConst.NAVBAR_TRANSITION_TIME end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._animation = nil
	self._animation_dirty=false

	self._enterFrame_f = nil

	-- the transition which is waiting or running: { func=, final= }
	self._transition = nil

	self._trans_time = params.transitionTime

	self._views = {} -- slide list, in order

	-- pushes and pops which wait for the transition to end, in order
	self._pending = {}

	--== Display Groups ==--

	self._dgBg = nil -- group for background
	self._dgViews = nil -- group for views
	self._dgUI = nil -- group for nav bar

	--== Object References ==--

	self._back_view = nil
	self._top_view = nil
	self._new_view = nil

	self._primer = nil
	self._navBar = nil

end

function NavControl:__undoInit__()
	--print( "NavControl:__undoInit__" )
	self._back_view = nil
	self._top_view = nil
	self._new_view = nil

	--==--
	self:superCall( '__undoInit__' )
end


function NavControl:__createView__()
	-- print( "NavControl:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local ANCHOR = NavControl.ANCHOR
	local W, H = self._width, self._height
	local o, dg  -- object, display group

	--== Setup display layers

	dg = display.newGroup()
	self:insert( dg )
	self._dgBg = dg

	dg = display.newGroup()
	self:insert( dg )
	self._dgViews = dg

	dg = display.newGroup()
	self:insert( dg )
	self._dgUI = dg

	--== Setup display objects

	-- background

	o = display.newRect( 0, 0, W, H )
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(1,0,0,0.2)
	end
	o.isHitTestable = true
	o.anchorX, o.anchorY = ANCHOR.x, ANCHOR.y

	self._dgBg:insert( o )
	self._primer = o

	-- navbar

	o = dUI.newNavBar{
		delegate = self
	}
	o.anchorX, o.anchorY = ANCHOR.x, ANCHOR.y
	o.width = W -- the bar's own default is the content width

	self._dgUI:insert( o.view )
	self._navBar = o

end

function NavControl:__undoCreateView__()
	-- print( "NavControl:__undoCreateView__" )

	self._navBar:removeSelf()
	self._navBar = nil

	self._primer:removeSelf()
	self._primer = nil

	self._dgUI:removeSelf()
	self._dgUI = nil

	self._dgViews:removeSelf()
	self._dgViews = nil

	self._dgBg:removeSelf()
	self._dgBg = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


--== initComplete

function NavControl:__initComplete__()
	-- print( "NavControl:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self._primer:addEventListener( 'touch', eventBlock_handler )
	self._primer:addEventListener( 'tap', eventBlock_handler )
end

function NavControl:__undoInitComplete__()
	-- print( "NavControl:__undoInitComplete__" )
	self:_cleanUp()

	self._primer:removeEventListener( 'tap', eventBlock_handler )
	self._primer:removeEventListener( 'touch', eventBlock_handler )
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function NavControl.initialize( manager )
	-- print( "NavControl.initialize" )
	dUI = manager
end



--====================================================================--
--== Public Methods


--== .navBar

-- the control's NavBar (read only), eg for its height or its style
--
function NavControl.__getters:navBar()
	return self._navBar
end


--== .isViewInMotion

-- if a push or pop is under way (read only): true from the call until
-- its slide, and each one which waits in line, has ended
--
function NavControl.__getters:isViewInMotion()
	return ( self._transition~=nil )
end


-- a push or pop during a slide waits for the slide to end,
-- then does its own; several wait in line, in the order of the calls.
-- with params.wait=false it doesn't wait: the slide, and whatever
-- waits behind it, is put at its end at once, then this one starts
--
function NavControl:pushView( view, params )
	-- print( "NavControl:pushView" )
	params = params or {}
	assert( view, "[ERROR] NavControl:pushView requires a view object" )
	--==--
	local animate = params.animate
	if animate==nil then animate=true end

	assert( not self:_isOnItsWay( view ), "[ERROR] NavControl:pushView view is already on the stack" )

	-- the view is hidden from now on, also while it waits in line
	self:_prepareView( view )

	if params.wait==false then self:_finishAll() end
	if self._transition then
		tinsert( self._pending, { view=view, animate=animate } )
	else
		self:_pushView( view, animate )
	end
end

-- returns false, and does nothing, when the root view is
-- on top, or will be once the pushes and pops in line are done
--
function NavControl:popViewAnimated( params )
	-- print( "NavControl:popViewAnimated" )
	params = params or {}
	--==--
	if self:_getFutureDepth()<2 then return false end

	if params.wait==false then self:_finishAll() end
	if self._transition then
		tinsert( self._pending, { pop=true } )
	else
		self:_popView()
	end
	return true
end



--====================================================================--
--== Private Methods


function NavControl:_widthChanged()
	-- print( "NavControl:_widthChanged", self._width )
	local w = self._width
	self._primer.width = w
	self._navBar.width = w
	self:_modifyViews( function( i, v )
		self:_sizeView( v )
	end)
end

function NavControl:_heightChanged()
	-- print( "NavControl:_heightChanged", self._height )
	local h = self._height
	self._primer.height = h
	self:_modifyViews( function( i, v )
		self:_sizeView( v )
	end)
end


-- the views on the stack, and the one on its way there
--
function NavControl:_modifyViews( func )
	local views = self._views
	if self._new_view then func( #views+1, self._new_view ) end
	for i=#views, 1, -1 do func( i, views[i] ) end
end


function NavControl:_cleanUp()
	-- print( "NavControl:_cleanUp" )
	-- the views in line never got in: they stay hidden, and their owner's
	for _, op in ipairs( self._pending ) do
		if op.view then
			op.view.__obj = nil
			op.view.__view = nil
		end
	end
	self._pending = {}
	self:_finishTransition()
	self:_removeAllViews()
	self._back_view = nil
	self._top_view = nil
	self._new_view = nil
end


--======================================================--
-- Push/Pop Methods

function NavControl:_pushView( view, animate )
	-- print( "NavControl:_pushView", view, animate )
	if #self._views==0 then
		-- the first (root) view appears at once
		self._back_view = nil
		self._top_view = nil
		animate = false
	end
	self:_setNextView( view )
	self:_gotoNextView( animate )
end

function NavControl:_popView()
	-- print( "NavControl:_popView" )
	-- the root view stays
	if #self._views<2 then return self:_runPending() end
	self:_gotoPrevView( true )
end

-- start the push or pop which is first in line, if nothing runs
--
function NavControl:_runPending()
	-- print( "NavControl:_runPending" )
	if self._transition then return end
	local op = tremove( self._pending, 1 )
	if not op then return end
	if op.pop then
		self:_popView()
	else
		self:_pushView( op.view, op.animate )
	end
end

-- take the transition, and each push and pop in line, to its end
--
function NavControl:_finishAll()
	-- print( "NavControl:_finishAll" )
	self:_finishTransition()
	while #self._pending>0 do
		self:_runPending()
		self:_finishTransition()
	end
end

-- how many views the stack will hold once the
-- transition and what is in line are done
--
function NavControl:_getFutureDepth()
	local depth = #self._views
	local trans = self._transition
	if trans then
		if trans.final==100 then depth = depth+1 else depth = depth-1 end
	end
	for _, op in ipairs( self._pending ) do
		if op.pop then depth = depth-1 else depth = depth+1 end
	end
	return depth
end

-- if a view is on the stack, on its way there, or in line
--
function NavControl:_isOnItsWay( view )
	if view==self._new_view then return true end
	for _, v in ipairs( self._views ) do
		if v==view then return true end
	end
	for _, op in ipairs( self._pending ) do
		if op.view==view then return true end
	end
	return false
end


--======================================================--
-- View Methods

function NavControl:_pushStackView( view )
	tinsert( self._views, view )
end

function NavControl:_popStackView( notify )
	return tremove( self._views )
end

function NavControl:_getPreviousView()
	return self._views[ #self._views-1 ]
end

function NavControl:_removeAllViews()
	for i=#self._views, 1, -1 do
		local view = self:_popStackView()
		self:_removeViewFromNavControl( view )
	end
end


function NavControl:_setNextView( view )
	-- print( "NavControl:_setNextView", view )
	view.parent = self
	self._new_view = view

	self:_sizeView( view )
end

-- find what to show and who to talk with, and hide the view:
-- done when the view is pushed, so one which waits in line
-- doesn't show where it was made
--
function NavControl:_prepareView( view )
	-- print( "NavControl:_prepareView", view )

	-- support various types of objects
	-- looking around for the View
	local o = view
	if o.view then
		o = o.view
	elseif o.display then
		o = o.display
	end
	view.__view = o
	-- pre-calc who to talk with
	if view.isa then
		-- dmc object
		view.__obj = view
	else
		-- plain Lua obj
		view.__obj = view.__view
	end
	view.__obj.isVisible=false
end

-- put a view below the bar, top center, the size of what is left.
-- a display group has no size of its own (a width or height
-- would scale what it holds), so it is only placed
--
function NavControl:_sizeView( view )
	-- print( "NavControl:_sizeView", view )
	local ANCHOR = NavControl.ANCHOR
	local nb_height = self._navBar.height
	local obj = view.__obj
	local isGroup = ( obj==view.__view and obj.numChildren~=nil )

	if not isGroup then
		obj.height = self._height - nb_height
		obj.width = self._width
	end
	obj.y = nb_height
	obj.anchorX, obj.anchorY = ANCHOR.x, ANCHOR.y
end


function NavControl:_addViewToNavControl( view )
	-- print( "NavControl:_addViewToNavControl", view )
	local f = view.willBeAdded
	if f then f( view ) end

	self._dgViews:insert( view.__view )
end

function NavControl:_removeViewFromNavControl( view )
	-- print( "NavControl:_removeViewFromNavControl", view )
	local obj = view.__obj
	if obj then obj.isVisible=false end
	view.__obj = nil
	view.__view = nil
	-- the bar removed the view's nav item with the pop:
	-- the view gets a new one if it is pushed again
	view.navItem = nil

	local f = view.willBeRemoved
	if f then f( view ) end

	self:_dispatchRemovedView( view )
end


--======================================================--
-- Animation Methods

function NavControl:_startEnterFrame( func )
	self._enterFrame_f = func
	Runtime:addEventListener( 'enterFrame', func )
end

function NavControl:_stopEnterFrame()
	if not self._enterFrame_f then return end
	Runtime:removeEventListener( 'enterFrame', self._enterFrame_f )
	self._enterFrame_f = nil
end

-- take the transition which is waiting or running to its end
--
function NavControl:_finishTransition()
	-- print( "NavControl:_finishTransition" )
	local trans = self._transition
	if not trans then return end
	self:_stopEnterFrame()
	self._transition = nil
	self._animation = nil
	self._animation_dirty=false
	trans.func( trans.final, false )
end


function NavControl:_startForward( func )
	local start_time = system.getTimer()
	local duration = self._trans_time
	local frw_f -- forward

	frw_f = function(e)
		local delta_t = e.time-start_time
		local perc = delta_t/duration*100
		if perc >= 100 then
			perc = 100
			self:_stopEnterFrame()
			self._transition = nil
		end
		func( perc, true )
		if perc==100 then self:_runPending() end
	end
	self:_startEnterFrame( frw_f )
end

function NavControl:_startReverse( func )
	local start_time = system.getTimer()
	local duration = self._trans_time
	local rev_f -- reverse

	rev_f = function(e)
		local delta_t = e.time-start_time
		local perc = 100-(delta_t/duration*100)
		if perc <= 0 then
			perc = 0
			self:_stopEnterFrame()
			self._transition = nil
		end
		func( perc, true )
		if perc==0 then self:_runPending() end
	end
	self:_startEnterFrame( rev_f )
end


function NavControl:_gotoNextView( animate )
	-- print( "NavControl:_gotoNextView", animate )
	local func = self:_getNextTrans()
	self._transition = { func=func, final=100 }

	local animFunc = function()
		if not animate then
			self._transition = nil
			func( 100, animate )
			self:_runPending()
		else
			self:_startForward( func )
		end
	end

	self._animation = animFunc
	self._animation_dirty=true
	self:__invalidateProperties__()
end

function NavControl:_gotoPrevView( animate )
	-- print( "NavControl:_gotoPrevView" )
	local func = self:_getPrevTrans()
	self._transition = { func=func, final=0 }

	local animFunc = function()
		if not animate then
			self._transition = nil
			func( 0, animate )
			self:_runPending()
		else
			self:_startReverse( func )
		end
	end

	self._animation = animFunc
	self._animation_dirty=true
	self:__invalidateProperties__()
end


--======================================================--
-- Transition Methods

function NavControl:_getNavBarNextTransition( view )
	-- print( "NavControl:_getNavBarNextTransition", view )
	local o = view.navItem
	if not o then
		o = dUI.newNavItem{
			titleText=view.title or "Unknown"
		}
		view.navItem = o
	end
	return self._navBar:pushNavItemGetTransition( o )
end

function NavControl:_getNextTrans()
	-- print( "NavControl:_getNextTrans" )
	local nB_f = self:_getNavBarNextTransition( self._new_view )
	local nC_f = self:_getTransition( self._top_view, self._new_view, self.FORWARD )
	-- make function which wraps both
	return function( percent, animate )
		nB_f( percent, animate )
		nC_f( percent, animate )
	end
end


function NavControl:_getNavBarPrevTransition()
	-- print( "NavControl:_getNavBarPrevTransition" )
	return self._navBar:popNavItemGetTransition()
end

function NavControl:_getPrevTrans()
	-- print( "NavControl:_getPrevTrans" )
	local nB_f = self:_getNavBarPrevTransition()
	local nC_f = self:_getTransition( self._back_view, self._top_view, self.REVERSE )
	-- make function which wraps both
	return function( percent, animate )
		nB_f( percent, animate )
		nC_f( percent, animate )
	end
end


function NavControl:_getTransition( from_view, to_view, direction )
	-- print( "NavControl:_getTransition", from_view, to_view, direction )
	local animationFunc, notifyInMotion
	local inMotion = false -- if the views have been told they are moving

	if direction==self.FORWARD then
		self:_addViewToNavControl( to_view )
	end

	animationFunc = function( percent, animate )
		-- print( "animationFunc", percent )
		-- read at each call: the control's size can change during a slide
		local W = self._width
		local dec_p = percent/100
		local FROM_X_OFF = W*0.25*dec_p
		local TO_X_OFF = W*dec_p
		local obj = nil
		local f

		if percent==0 then
			--== edge of transition ==--

			if from_view then
				obj = from_view.__obj
				obj.isVisible = true
				obj.x = 0
			end

			if to_view then
				obj = to_view.__obj
				obj.isVisible = false
			end

			if inMotion then
				inMotion = false
				notifyInMotion( false )
			end

			--== Finish up

			if direction==self.REVERSE then

				-- the stack first: a view's function can push or pop
				self:_popStackView()

				self._top_view = from_view
				self._new_view = nil
				self._back_view = self:_getPreviousView()

				if from_view then
					f = from_view.viewDidAppear
					if f then f( from_view ) end
				end
				if to_view then
					f = to_view.viewDidDisappear
					if f then f( to_view ) end
				end

				self:_removeViewFromNavControl( to_view )
			end


		elseif percent==100 then
			--== edge of transition ==--

			if to_view then
				obj = to_view.__obj
				obj.isVisible = true
				obj.x = 0
			end

			if from_view then
				obj = from_view.__obj
				obj.isVisible = false
				obj.x = 0-FROM_X_OFF
			end

			if inMotion then
				inMotion = false
				notifyInMotion( false )
			end

			--== Finish up

			if direction==self.FORWARD then

				-- the stack first: a view's function can push or pop
				self:_pushStackView( to_view )

				self._back_view = from_view
				self._new_view = nil
				self._top_view = to_view

				if from_view then
					f = from_view.viewDidDisappear
					if f then f( from_view ) end
				end
				if to_view then
					f = to_view.viewDidAppear
					if f then f( to_view ) end
				end
			end


		else
			--== middle of transition ==--

			-- notify views motion has started

			if animate and not inMotion then
				inMotion = true
				notifyInMotion( true )
			end

			if to_view then
				obj = to_view.__obj
				obj.isVisible = true
				obj.x = W-TO_X_OFF
			end

			if from_view then
				obj = from_view.__obj
				obj.isVisible = true
				obj.x = 0-FROM_X_OFF
			end

		end

	end

	notifyInMotion = function( value )
		local f
		if from_view then
			f = from_view.viewInMotion
			if f then f( from_view, value ) end
		end
		if to_view then
			f = to_view.viewInMotion
			if f then f( to_view, value ) end
		end
	end

	return animationFunc
end


--======================================================--
-- DMC Lifecycle Methods

function NavControl:__commitProperties__()
	-- print( 'NavControl:__commitProperties__' )

	if self._animation_dirty then
		local animFunc = self._animation
		self._animation = nil
		self._animation_dirty=false
		if animFunc then animFunc() end
	end
end


--======================================================--
-- NavBar Delegate Methods

-- the Back button: the control pops its view and the bar's item
-- together, so the bar is told not to pop on its own.
-- a press during a slide is ignored, as the bar does by itself
--
function NavControl:shouldPopItem( navBar, navItem )
	-- print( "NavControl:shouldPopItem" )
	if not self._transition then self:_popView() end
	return false
end


--======================================================--
-- Misc Methods

function NavControl:_dispatchRemovedView( view )
	-- print( "NavControl:_dispatchRemovedView", view )
	self:dispatchEvent( self.REMOVED_VIEW, {view=view}, {merge=true} )
end



--====================================================================--
--== Event Handlers


-- none



return NavControl
