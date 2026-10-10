--====================================================================--
-- dmc_ui/dmc_widget/widget_navbar.lua
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
--== DMC Corona UI : NavBar Widget
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
--== DMC UI : newNavBar
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )



--====================================================================--
--== Setup, Constants


local tinsert = table.insert
local tremove = table.remove

-- space between the bar's edge and its left, back and right buttons
local MARGIN_X = 5

-- a touch or a tap on the bar stays with it (Solar2D sends 'tap' apart
-- from 'touch'): neither reaches what lies behind the bar
local function eventBlock_handler( event )
	return true
end

--== To be set in initialize()
local dUI = nil
local Widget = nil



--====================================================================--
--== Nav Bar Widget Class
--====================================================================--


--- NavBar Widget.
-- a widget used for navigation between pages.
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- **Style Object:** <br>
-- * @{Style.NavBar}
--
-- @classmod Widget.NavBar
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newNavBar()

local NavBar = newClass( WidgetBase, {name="Nav Bar Widget"}
)

--- Class Constants.
-- @section

--== Class Constants

NavBar.FORWARD = 'forward-trans'
NavBar.REVERSE = 'reverse-trans'
NavBar.TRANSITION_TIME = 400

--== Style/Theme Constants

NavBar.STYLE_CLASS = nil -- added later
NavBar.STYLE_TYPE = uiConst.NAVBAR

--== Event Constants

--- NavBar event constant.
-- used when setting up event listeners
--
-- @usage
-- widget:addEventListener( widget.EVENT, listener )

NavBar.EVENT = 'navbar-event'

--- NavBar event constant for press on Back Button.
-- used inside of event handler
--
-- @usage
-- local function listener( event )
--   local target = event.target -- the NavBar
--   if event.type == target.BACK_BUTTON then
--    -- handle event here
--   end
-- end
-- widget:addEventListener( widget.EVENT, listener )

NavBar.BACK_BUTTON = 'back-button-released-event'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function NavBar:__init__( params )
	-- print( "NavBar:__init__" )
	params = params or {}
	if params.transitionTime==nil then params.transitionTime=NavBar.TRANSITION_TIME end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._trans_time = params.transitionTime
	self._items = {} -- stack of nav items

	self._animation = nil
	self._animation_dirty=false

	-- the transition which is waiting or running, if any
	-- { func=<transition>, final=<its last percent> }
	self._transition = nil

	self._enterFrame_f = nil

	self._layout_dirty=true

	-- properties stored in Style

	-- "Virtual" properties

	self._widgetStyle_dirty=true
	self._wgtBgStyle_dirty=true

	--== Object References ==--

	self._delegate = params.delegate

	-- references to Nav Items
	self._root_item = nil
	self._back_item = nil
	self._top_item = nil
	self._new_item = nil

	self._wgtBg = nil -- background widget
	self._wgtBg_dirty=true

	self._rctHit = nil  -- background touch object

end

function NavBar:__undoInit__()
	-- print( "NavBar:__undoInit__" )
	self._root_item = nil
	self._back_item = nil
	self._top_item = nil
	self._new_item = nil
	--==--
	self:superCall( '__undoInit__' )
end


--== createView

function NavBar:__createView__()
	-- print( "NavBar:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o = display.newRect( 0,0,0,0 )
	o.isHitTestable = true
	o.anchorX, o.anchorY = 0.5,0.5
	self._dgBg:insert( o )
	self._rctHit = o
end

function NavBar:__undoCreateView__()
	-- print( "NavBar:__undoCreateView__" )
	self:_removeBackground()

	self._rctHit:removeSelf()
	self._rctHit=nil
	--==--
	self:superCall( '__undoCreateView__' )
end


--== initComplete

function NavBar:__initComplete__()
	-- print( "NavBar:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self._rctHit:addEventListener( 'touch', eventBlock_handler )
	self._rctHit:addEventListener( 'tap', eventBlock_handler )

	self._back_f = self:createCallback( self._backButtonEvent_handler )

end

function NavBar:__undoInitComplete__()
	-- print( "NavBar:__undoInitComplete__" )
	self:_stopEnterFrame()
	self._transition = nil
	self._animation = nil
	self._animation_dirty=false

	-- the bar removes its items, as it does a popped one
	local new_item = self._new_item
	for i=#self._items, 1, -1 do
		local item = tremove( self._items )
		if item==new_item then new_item=nil end
		self:_removeItemFromNavBar( item )
	end
	if new_item then self:_removeItemFromNavBar( new_item ) end

	self._back_f = nil

	self._rctHit:removeEventListener( 'tap', eventBlock_handler )
	self._rctHit:removeEventListener( 'touch', eventBlock_handler )
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function NavBar.initialize( manager )
	-- print( "NavBar.initialize" )
	dUI = manager
	Widget = dUI.Widget

	local Style = dUI.Style
	NavBar.STYLE_CLASS = Style.NavBar

	Style.registerWidget( NavBar )
end



--====================================================================--
--== Public Methods


--== .delegate

--- set/get delegate for item.
--
-- @within Properties
-- @function .delegate
-- @usage widget.delegate = <delegate object>
-- @usage print( widget.delegate )

NavBar.__getters.delegate = WidgetHelp.__getters.delegate
NavBar.__setters.delegate = WidgetHelp.__setters.delegate


--- add Nav Item to navigation stack.
-- push a new Nav Item, furthering the navigation stack. this typically will animate the new view on the screen. a transition which is still running is taken to its end first.
--
-- @within Methods
-- @function :pushNavItem
-- @param navItem @{Widget.NavItem}
-- @tab params optional parameters
-- @usage widget:pushNavItem( navItem, params )

--- pop Nav Item from navigation stack.
-- removes top-level Nav Item from navigation stack, animating the previous view on the screen. the popped Nav Item is removed, along with its buttons. the first (root) Nav Item stays: with one item on the stack this does nothing.
--
-- @within Methods
-- @function :popNavItemAnimated
-- @usage widget:popNavItemAnimated()


--======================================================--
-- Nav Bar Methods

function NavBar:pushNavItem( item, params )
	-- print( "NavBar:pushNavItem", item )
	params = params or {}
	assert( type(item)=='table' and item.isa and item:isa( Widget.NavItem ), "pushNavItem: item must be a NavItem" )
	--==--
	-- a transition which is waiting or running goes to its end first
	self:_finishTransition()
	for _, o in ipairs( self._items ) do
		assert( o~=item, "pushNavItem: item is already on the stack" )
	end
	self:_setNextItem( item, params ) -- params.animate set here
	self:_gotoNextItem( params.animate )
end

function NavBar:popNavItemAnimated()
	-- print( "NavBar:popNavItemAnimated" )
	self:_finishTransition()
	-- the root item stays
	if #self._items<2 then return end
	self:_gotoPrevItem( true )
end


--======================================================--
-- methods used by dUI.NavigationControl

function NavBar:pushNavItemGetTransition( item, params )
	self:_setNextItem( item, params )
	return self:_getNextTrans()
end

function NavBar:popNavItemGetTransition()
	return self:_getPrevTrans()
end


--======================================================--
-- Theme Methods

-- afterAddStyle()
--
function NavBar:afterAddStyle()
	-- print( "NavBar:afterAddStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end

-- beforeRemoveStyle()
--
function NavBar:beforeRemoveStyle()
	-- print( "NavBar:beforeRemoveStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end



--====================================================================--
--== Private Methods


--======================================================--
-- Item Methods

function NavBar:_pushStackItem( item )
	-- print("NavBar:_pushStackItem", #self._items )
	tinsert( self._items, item )
end

function NavBar:_popStackItem( notify )
	-- print("NavBar:_popStackItem", #self._items )
	return tremove( self._items )
end

function NavBar:_getPreviousItem()
	return self._items[ #self._items-1 ]
end


function NavBar:_setNextItem( item, params )
	params = params or {}
	if params.animate==nil then params.animate=true end
	--==--
	if not self._root_item then
		-- first item added to NavBar
		self._root_item = item
		self._top_item = nil
		params.animate = false
	end
	self._new_item = item

	self:__invalidateProperties__()
end


function NavBar:_addItemToNavBar( item )
	-- print( "NavBar:_addItemToNavBar", item )
	local dg = self._dgViews
	local o

	o = item.title
	if o then
		dg:insert( o.view )
		o.isVisible=false
	end
	o = item.backButton
	if o then
		dg:insert( o.view )
		o.isVisible=false
	end
	o = item.leftButton
	if o then
		dg:insert( o.view )
		o.isVisible=false
	end
	o = item.rightButton
	if o then
		dg:insert( o.view )
		o.isVisible=false
	end

	self:_layoutItem( item )
end

-- set what doesn't change in a transition: anchors and y.
-- each part is centered on the bar's height
--
function NavBar:_layoutItem( item )
	-- print( "NavBar:_layoutItem", item )
	local style = self.curr_style
	local y = (0.5-style.anchorY)*style.height
	local o

	o = item.title
	if o then
		o.anchorX, o.anchorY = 0.5, 0.5
		o.y = y
	end
	o = item.backButton
	if o then
		o.anchorX, o.anchorY = 0, 0.5
		o.y = y
	end
	o = item.leftButton
	if o then
		o.anchorX, o.anchorY = 0, 0.5
		o.y = y
	end
	o = item.rightButton
	if o then
		o.anchorX, o.anchorY = 1, 0.5
		o.y = y
	end
end

-- put the top item's parts where they rest,
-- eg after the bar's width has changed
--
function NavBar:_placeTopItem()
	-- print( "NavBar:_placeTopItem" )
	local item = self._top_item
	if not item then return end
	local style = self.curr_style
	local W = style.width
	local mX_OFF = W*(0.5-style.anchorX)
	local o

	o = item.leftButton or item.backButton
	if o then o.x = mX_OFF-W*0.5+MARGIN_X end
	o = item.title
	if o then o.x = mX_OFF end
	o = item.rightButton
	if o then o.x = mX_OFF+W*0.5-MARGIN_X end
end

function NavBar:_removeItemFromNavBar( item )
	-- print( "NavBar:_removeItemFromNavBar", item )
	if item.removeSelf then item:removeSelf() end
end


--======================================================--
-- Animation Methods

function NavBar:_startEnterFrame( func )
	self._enterFrame_f = func
	Runtime:addEventListener( 'enterFrame', func )
end

function NavBar:_stopEnterFrame()
	if not self._enterFrame_f then return end
	Runtime:removeEventListener( 'enterFrame', self._enterFrame_f )
	self._enterFrame_f = nil
end

-- take the transition which is waiting or running to its end
--
function NavBar:_finishTransition()
	-- print( "NavBar:_finishTransition" )
	local trans = self._transition
	if not trans then return end
	self:_stopEnterFrame()
	self._transition = nil
	self._animation = nil
	self._animation_dirty=false
	trans.func( trans.final, false )
end


function NavBar:_startForward( func )
	local start_time = system.getTimer()
	local duration = self._trans_time
	local frw_f -- forward

	frw_f = function(e)
		local delta_t = e.time-start_time
		local perc = delta_t/duration*100
		if perc > 100 then
			perc = 100
			self:_stopEnterFrame()
			self._transition = nil
		end
		func( perc, true )
	end
	self:_startEnterFrame( frw_f )
end

function NavBar:_startReverse( func )
	local start_time = system.getTimer()
	local duration = self._trans_time
	local rev_f -- forward

	rev_f = function(e)
		local delta_t = e.time-start_time
		local perc = 100-(delta_t/duration*100)
		if perc < 0 then
			perc = 0
			self:_stopEnterFrame()
			self._transition = nil
		end
		func( perc, true )
	end
	self:_startEnterFrame( rev_f )
end


function NavBar:_gotoNextItem( animate )
	-- print( "NavBar:_gotoNextItem" )
	local func = self:_getNextTrans()
	self._transition = { func=func, final=100 }

	local animFunc = function()
		if not animate then
			self._transition = nil
			func( 100, animate )
		else
			self:_startForward( func )
		end
	end

	self._animation = animFunc
	self._animation_dirty=true
	self:__invalidateProperties__()
end

function NavBar:_gotoPrevItem( animate )
	-- print( "NavBar:_gotoPrevItem" )
	local func = self:_getPrevTrans()
	self._transition = { func=func, final=0 }

	local animFunc = function()
		if not animate then
			self._transition = nil
			func( 0, animate )
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

function NavBar:_getNextTrans()
	-- print( "NavBar:_getNextTrans" )
	return self:_getTransition( self._top_item, self._new_item, self.FORWARD )
end

function NavBar:_getPrevTrans()
	-- print( "NavBar:_getPrevTrans" )
	return self:_getTransition( self._back_item, self._top_item, self.REVERSE )
end


function NavBar:_getTransition( from_item, to_item, direction )
	-- print( "NavBar:_getTransition", from_item, to_item, direction )
	local style = self.curr_style
	local MARGINS = {x=MARGIN_X,y=0}
	local isAtEdge = true -- if we're at the start/edge of our transition

	-- display(left/back), back, left, title, right
	local f_d, f_b, f_l, f_t, f_r
	local fHasLeft=false
	local t_d, t_b, t_l, t_t, t_r
	local tHasLeft=false

	local animationFunc
	local animationHasStarted = false
	local animationIsFinished = false

	-- setup from_item vars
	if from_item then
		f_b, f_l, f_r = from_item.backButton, from_item.leftButton, from_item.rightButton
		f_t = from_item.title
		f_d = f_b
		if f_l then
			fHasLeft=true
			f_b.isVisible = false
			f_d = f_l
		end
	end

	-- setup to_item vars
	if to_item then
		t_b, t_l, t_r = to_item.backButton, to_item.leftButton, to_item.rightButton
		t_t = to_item.title
		t_d = t_b
		if t_l then
			tHasLeft=true
			t_b.isVisible=false
			t_d = t_l
		end
	end

	-- calcs for showing left/back buttons
	local stack_offset = 0
	if direction==self.FORWARD then
		self:_addItemToNavBar( to_item )
		stack_offset = 0
	else
		stack_offset = 1
	end

	local stack_size = #self._items

	animationFunc = function( percent, animate )
		-- print( "NavBar:transition", percent )
		-- read at each call: the bar's size can change during a transition
		local W = style.width
		local H_CENTER = W*0.5
		local mX_OFF = W*(0.5-style.anchorX) -- master offset

		local dec_p = percent/100
		local from_a, to_a = 1-dec_p, dec_p

		local aX_OFF = H_CENTER*dec_p -- animation offset

		if animate and not animationHasStarted then
			-- TODO: unattach current listener
			animationHasStarted = true
		end

		if percent==0 then
			--== edge of transition ==--

			--[[
			if not animate then
				-- we jumped here without going through middle of trans
			end
			--]]

			--== Finish up

			if direction==self.REVERSE then
				--popstack has to be before #self._items check below

				local item = self:_popStackItem()

				self._top_item = from_item
				self._new_item = nil
				self._back_item = self:_getPreviousItem()

				if to_item then
					self:_detachBackListener( to_item.backButton )
				end
				if from_item then
					self:_attachBackListener( from_item.backButton )
				end

				--== Left/Back

				if t_d then
					t_d.isVisible = false
				end

				if f_d then
					if fHasLeft or #self._items>1 then
						f_d.isVisible = true
						f_d.x = mX_OFF-H_CENTER+MARGINS.x
						f_d.alpha = 1
					else
						f_d.isVisible = false
					end
				end

				--== Title

				if t_t then
					t_t.isVisible = false
				end

				if f_t then
					f_t.isVisible = true
					f_t.x = mX_OFF
					f_t.alpha = 1
				end

				--== Right

				if t_r then
					t_r.isVisible = false
				end

				if f_r then
					f_r.isVisible = true
					f_r.x = mX_OFF+H_CENTER-MARGINS.x
					f_r.alpha = 1
				end

				--== Tell the delegate, then remove the popped item

				local del = self._delegate
				local f = del and del.didPopItem
				if f then f( del, self, item ) end

				self:_removeItemFromNavBar( item )

			end


		elseif percent==100 then
			--== edge of transition ==--

			if animate and animationHasStarted then
				animationIsFinished = true
			end
			--[[
			if not animate then
				-- we jumped here without going through middle of trans
			end
			--]]

			--== Left/Back

			-- checking if Left exists or Stack, still use t_d
			if tHasLeft or stack_size>0 then
				t_d.x = mX_OFF-H_CENTER+MARGINS.x
				t_d.isVisible = true
				t_d.alpha = 1
				-- attach listener
			else
				t_d.isVisible = false
			end

			if f_d then
				f_d.isVisible = false
			end

			--== Title

			if t_t then
				t_t.x = mX_OFF
				t_t.isVisible = true
				t_t.alpha = 1
			end

			if f_t then
				f_t.isVisible = false
			end

			--== Right

			if t_r then
				t_r.x = mX_OFF+H_CENTER-MARGINS.x
				t_r.isVisible = true
				t_r.alpha = 1
			end

			if f_r then
				f_r.isVisible = false
			end

			--== Finish up

			if direction==self.FORWARD then

				self._back_item = from_item
				self._new_item = nil
				self._top_item = to_item

				if from_item then
					self:_detachBackListener( from_item.backButton )
				end
				if to_item then
					self:_attachBackListener( to_item.backButton )
				end

				self:_pushStackItem( to_item )
			end


		else
			--== middle of transition ==--

			--== Left/Back

			if tHasLeft or stack_size>(0+stack_offset) then
				t_d.isVisible = true
				t_d.x = mX_OFF-aX_OFF+MARGINS.x
				t_d.alpha = to_a
			else
				t_d.isVisible = false
			end

			if f_d then
				if fHasLeft or stack_size>(1+stack_offset) then
					f_d.isVisible = true
					f_d.x = mX_OFF-H_CENTER-aX_OFF+MARGINS.x
					f_d.alpha = from_a
				else
					f_d.isVisible = false
				end
			end

			--== Title

			if t_t then
				t_t.isVisible = true
				-- t_t.x, t_t.y = H_CENTER-X_OFF, V_CENTER
				t_t.x = mX_OFF+H_CENTER-aX_OFF
				t_t.alpha = to_a
			end
			if f_t then
				f_t.isVisible = true
				f_t.x = mX_OFF-aX_OFF
				f_t.alpha = from_a
			end

			--== Right

			if t_r then
				t_r.isVisible = true
				t_r.x = mX_OFF+W-aX_OFF-MARGINS.x
				t_r.alpha = to_a
			end

			if f_r then
				f_r.isVisible = true
				f_r.x = mX_OFF+H_CENTER-aX_OFF-MARGINS.x
				f_r.alpha = from_a
			end

		end
	end

	return animationFunc
end


--======================================================--
-- DMC Lifecycle Methods

--== Create/Destroy Background Widget

function NavBar:_removeBackground()
	-- print( "NavBar:_removeBackground" )
	local o = self._wgtBg
	if not o then return end
	o:removeSelf()
	self._wgtBg = nil
end

function NavBar:_createBackground()
	-- print( "NavBar:_createBackground" )

	self:_removeBackground()
	local dg = self._dgBg

	local o = Widget.newBackground()
	dg:insert( o.view )
	self._wgtBg = o

	--== Reset properties

	self._wgtBgStyle_dirty=true
end


function NavBar:__commitProperties__()
	-- print( 'NavBar:__commitProperties__' )

	--== Update Widget Components ==--

	if self._wgtBg_dirty then
		self:_createBackground()
		self._wgtBg_dirty = false
	end

	--== Update Widget View ==--

	local style = self.curr_style
	local view = self.view
	local hit = self._rctHit
	local bg = self._wgtBg

	-- x/y

	if self._x_dirty then
		view.x = self._x
		self._x_dirty=false
	end
	if self._y_dirty then
		view.y = self._y
		self._y_dirty=false
	end

	-- width/height

	if self._width_dirty then
		local width = style.width
		hit.width = width
		self._width_dirty=false
		self._layout_dirty=true
	end
	if self._height_dirty then
		local height = style.height
		hit.height = height
		self._height_dirty=false
		self._layout_dirty=true
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		hit.anchorX = style.anchorX
		self._anchorX_dirty = false
		self._layout_dirty=true
	end
	if self._anchorY_dirty then
		hit.anchorY = style.anchorY
		self._anchorY_dirty = false
		self._layout_dirty=true
	end

	--== Virtual

	if self._widgetStyle_dirty then
		self._widgetStyle_dirty=false

		self._wgtBgStyle_dirty=true
	end

	--== Set Styles

	if self._wgtBgStyle_dirty then
		bg:setActiveStyle( style.background, {copy=false} )
		self._wgtBgStyle_dirty=false
	end

	-- debug on

	if self._debugOn_dirty then
		if style.debugOn==true then
			hit:setFillColor( 1,1,0,0.3 )
		else
			hit:setFillColor( 0,0,0,0 )
		end
		self._debugOn_dirty=false
	end


	-- the items follow the bar's size and anchors

	if self._layout_dirty then
		local new_item = self._new_item
		for _, item in ipairs( self._items ) do
			if item==new_item then new_item=nil end
			self:_layoutItem( item )
		end
		if new_item then self:_layoutItem( new_item ) end
		-- a transition places the parts itself
		if not self._transition then self:_placeTopItem() end
		self._layout_dirty=false
	end

	if self._animation_dirty then
		local animFunc = self._animation
		self._animation = nil
		self._animation_dirty=false
		animFunc()
	end

end


--======================================================--
-- Misc Methods

function NavBar:_attachBackListener( back )
	-- print( "NavBar:_attachBackListener" )
	if not back then return end
	back:addEventListener( back.EVENT, self._back_f )
end

function NavBar:_detachBackListener( back )
	-- print( "NavBar:_detachBackListener" )
	if not back then return end
	back:removeEventListener( back.EVENT, self._back_f )
end



--====================================================================--
--== Event Handlers


function NavBar:_backButtonEvent_handler( event )
	-- print( "NavBar:_backButtonEvent_handler", event.property, event.value )
	local target = event.target
	local phase = event.phase
	local del = self._delegate

	if phase==target.RELEASED then
		-- a press during a slide, eg a double tap, is ignored
		if self._transition then return end

		local f
		local shouldPopItem = true
		f = del and del.shouldPopItem
		if f then shouldPopItem = f( del, self, self._top_item ) end

		if shouldPopItem then
			-- the delegate's didPopItem is called once the item is off
			self:popNavItemAnimated()
		end

		self:dispatchEvent( NavBar.BACK_BUTTON )
	end
end


function NavBar:stylePropertyChangeHandler( event )
	-- print( "NavBar:stylePropertyChangeHandler", event.property, event.value )
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



return NavBar
