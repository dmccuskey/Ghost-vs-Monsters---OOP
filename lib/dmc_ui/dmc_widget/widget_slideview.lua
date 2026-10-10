--====================================================================--
-- dmc_ui/dmc_widget/widget_slideview.lua
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



--====================================================================--
--== DMC Corona UI : SlideView Widget
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
--== DMC UI : newSlideView
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local uiConst = require( ui_find( 'ui_constants' ) )

local AxisMotion = require( ui_find( 'dmc_widget.widget_scrollview.axis_motion' ) )
local ScrollView = require( ui_find( 'dmc_widget.widget_scrollview' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

local mfloor = math.floor
local tcancel = timer.cancel
local tdelay = timer.performWithDelay
local type = _G.type

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== SlideView Widget Class
--====================================================================--


--- SlideView Widget.
-- a widget which shows one slide at a time, each the size of the widget,
-- side by side. a drag or a flick moves to the next or the previous one.
--
-- **Inherits from:** <br>
-- * @{Widget.ScrollView}
--
-- **Style Object:** <br>
-- * @{Style.ScrollView}
--
-- @classmod Widget.SlideView
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newSlideView()

local SlideView = newClass( ScrollView, {name="SlideView Widget"} )

--- Class Constants.
-- @section

--== Class Constants

-- how long a move to another slide takes, gotoSlide()
SlideView._DEFAULT_TRANSITION_TIME = uiConst.SLIDEVIEW_TRANSITION_TIME

-- pixel amount beyond the view in which slides are de-/rendered:
-- at rest, the slides next to the one showing are ready
SlideView._DEFAULT_RENDER_MARGIN = 1

--== Style/Theme Constants

-- a SlideView has the style of a ScrollView
SlideView.STYLE_CLASS = nil -- added later
SlideView.STYLE_TYPE = uiConst.SCROLLVIEW

--== Event Constants

--- SlideView event constant.
-- the name of the events given to the delegate
--
SlideView.EVENT = 'slideview-event'

SlideView.RENDER_SLIDE = 'slide-render-event'
SlideView.UNRENDER_SLIDE = 'slide-unrender-event'
SlideView.SHOWN_SLIDE = 'slide-shown-event'
SlideView.SELECTED_SLIDE = 'slide-selected-event'


--======================================================--
-- Start: Setup DMC Objects

function SlideView:__init__( params )
	-- print( "SlideView:__init__" )
	params = params or {}
	if params.autoAdvanceTime==nil then params.autoAdvanceTime=0 end
	if params.renderMargin==nil then params.renderMargin=SlideView._DEFAULT_RENDER_MARGIN end
	if params.showHorizontalScrollIndicator==nil then params.showHorizontalScrollIndicator=false end
	if params.transitionTime==nil then params.transitionTime=SlideView._DEFAULT_TRANSITION_TIME end

	-- set before going into ScrollView
	params.isPagingEnabled=true
	params.verticalScrollEnabled=false
	params.showVerticalScrollIndicator=false
	params.lowerHorizontalOffset=0
	params.upperHorizontalOffset=0
	params.scrollWidth=nil
	params.scrollHeight=nil

	--== Create Properties ==--

	-- before ScrollView, whose setup uses our 'scrollWidth'

	--[[
	array of records, one for each slide: plain Lua objects
	{ _index=<number>, _view=<display group, or nil>, _user=<table for the app> }
	--]]
	self._slides = {}

	-- rendered records, by index
	self._renderedSlides = {}

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._slv_tmp_params = params -- tmp

	-- the slide showing, or where a move is going; 0 without slides
	self._index = 0
	-- the last one the delegate was told about
	self._shownIndex = nil

	-- the size the rendered slides were made for
	self._slideWidth = 0
	self._slideHeight = 0

	self._renderMargin = -1
	self._transitionTime = -1

	self._autoAdvanceTime = 0
	self._isAutoAdvancing = false
	self._isTouched = false -- auto-advance waits for the finger

	--== Object References ==--

	self._advance_f = nil
	self._advance_timer = nil
	self._tap_f = nil
end

--== initComplete

function SlideView:__initComplete__()
	-- print( "SlideView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local tmp = self._slv_tmp_params

	self._advance_f = self:createCallback( SlideView._advance )

	-- a tap which nothing in the slide took
	self._tap_f = self:createCallback( SlideView._tap_handler )
	self._rectBg:addEventListener( 'tap', self._tap_f )

	--== Use Setters
	self.renderMargin = tmp.renderMargin
	self.transitionTime = tmp.transitionTime
	self.autoAdvanceTime = tmp.autoAdvanceTime

	self._slv_tmp_params = nil

	if self._autoAdvanceTime > 0 then
		self:startAutoAdvance()
	end
end

function SlideView:__undoInitComplete__()
	-- print( "SlideView:__undoInitComplete__" )
	self:stopAutoAdvance()
	self._advance_f = nil

	self._rectBg:removeEventListener( 'tap', self._tap_f )
	self._tap_f = nil

	self:_unrenderAllSlides()
	self._slides = {}

	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function SlideView.initialize( manager, params )
	-- print( "SlideView.initialize" )
	dUI = manager

	local Style = dUI.Style
	SlideView.STYLE_CLASS = Style.ScrollView
end



--====================================================================--
--== Public Methods


--== .autoAdvanceTime

--- set/get the time each slide stays when the SlideView advances by itself.
-- in milliseconds. as an option, a value above zero starts the advance. see startAutoAdvance().
--
-- @within Properties
-- @function .autoAdvanceTime
-- @usage widget.autoAdvanceTime = 3000
-- @usage print( widget.autoAdvanceTime )

function SlideView.__getters:autoAdvanceTime()
	return self._autoAdvanceTime
end
function SlideView.__setters:autoAdvanceTime( value )
	-- print( "SlideView.__setters:autoAdvanceTime", value )
	assert( type(value)=='number' and value>=0, "SlideView.autoAdvanceTime must be a number, zero or more" )
	--==--
	if self._autoAdvanceTime==value then return end
	self._autoAdvanceTime = value
	if not self._isAutoAdvancing then return end
	if value==0 then
		self:stopAutoAdvance()
	else
		self:_startAdvanceTimer()
	end
end

--== .index

--- get the index of the slide showing (read only).
-- after gotoSlide() it is the slide asked for, also while the move is under way. 0 if there are no slides.
--
-- @within Properties
-- @function .index
-- @usage print( widget.index )

function SlideView.__getters:index()
	return self._index
end

--== .isAutoAdvancing

--- whether the SlideView advances by itself (read only).
--
-- @within Properties
-- @function .isAutoAdvancing
-- @usage print( widget.isAutoAdvancing )

function SlideView.__getters:isAutoAdvancing()
	return self._isAutoAdvancing
end

--== .isPagingEnabled

-- block change: a SlideView always stops on a slide
--
function SlideView.__setters:isPagingEnabled( value )
	-- print( "SlideView.__setters:isPagingEnabled", value )
	ScrollView.__setters.isPagingEnabled( self, true )
end

--== .numberOfSlides

--- get the number of slides (read only).
-- it is the number the delegate gave at the last reloadData().
--
-- @within Properties
-- @function .numberOfSlides
-- @usage print( widget.numberOfSlides )

function SlideView.__getters:numberOfSlides()
	return #self._slides
end

--== .renderMargin

-- set the additional boundary beyond the view in which slides are rendered.
--
-- @within Properties
-- @function .renderMargin
-- @usage widget.renderMargin = 1
-- @usage print( widget.renderMargin )

function SlideView.__getters:renderMargin()
	return self._renderMargin
end
function SlideView.__setters:renderMargin( value )
	-- print( "SlideView.__setters:renderMargin", value )
	assert( type(value)=='number' and value>=0, "SlideView.renderMargin must be a number, zero or more" )
	--==--
	self._renderMargin = value
end

--== .scrollHeight

-- block height change: a slide is as high as the view
--
function SlideView.__setters:scrollHeight( value )
	-- print( "SlideView.__setters:scrollHeight", value )
	ScrollView.__setters.scrollHeight( self, 0 )
end

--== .scrollWidth

-- block width change: the slides side by side
--
function SlideView.__setters:scrollWidth( value )
	-- print( "SlideView.__setters:scrollWidth", value )
	ScrollView.__setters.scrollWidth( self, self:_slidesWidth() )
end

--== .transitionTime

--- set/get how long a move to another slide takes, in milliseconds.
-- used by gotoSlide(), nextSlide(), previousSlide() and the auto-advance.
--
-- @within Properties
-- @function .transitionTime
-- @usage widget.transitionTime = 400
-- @usage print( widget.transitionTime )

function SlideView.__getters:transitionTime()
	return self._transitionTime
end
function SlideView.__setters:transitionTime( value )
	-- print( "SlideView.__setters:transitionTime", value )
	assert( type(value)=='number' and value>=0, "SlideView.transitionTime must be a number, zero or more" )
	--==--
	self._transitionTime = value
end

--== .verticalScrollEnabled

-- block vertical motion change
--
function SlideView.__setters:verticalScrollEnabled( value )
	-- print( "SlideView.__setters:verticalScrollEnabled", value )
	ScrollView.__setters.verticalScrollEnabled( self, false )
end


--== :getSlideAt

--- returns the view of the slide at index.
--
-- @within Methods
-- @function :getSlideAt
-- @int index the index of the slide
-- @return view, or nil if the slide is not rendered

function SlideView:getSlideAt( index )
	-- print( "SlideView:getSlideAt", index )
	local rec = self._slides[ index ]
	return rec and rec._view
end

--== :gotoSlide

--- move to the slide at index.
--
-- @within Methods
-- @function :gotoSlide
-- @int index the index of the slide to show
-- @tab[opt] params table of method parameters
-- @bool[opt=true] params.animate false to move at once
-- @int[opt] params.time the duration of the move, in milliseconds. defaults to transitionTime; 0 moves at once
-- @func[opt] params.onComplete a function to call when the slide shows
--
-- @usage widget:gotoSlide( 3 )
-- @usage widget:gotoSlide( 1, { animate=false } )

function SlideView:gotoSlide( index, params )
	-- print( "SlideView:gotoSlide", index )
	assert( type(index)=='number', "SlideView:gotoSlide arg must be a number" )
	params = params or {}
	--==--
	local slides = self._slides
	assert( slides[ index ], "SlideView:gotoSlide no slide at that index" )

	local time = params.time
	if time==nil then time=self._transitionTime end
	if params.animate==false then time=0 end

	self._index = index
	self:_moveToIndex( time, params.onComplete )
end

--== :nextSlide

--- move to the next slide, if there is one.
--
-- @within Methods
-- @function :nextSlide
-- @tab[opt] params table of method parameters, as for gotoSlide()
-- @usage widget:nextSlide()

function SlideView:nextSlide( params )
	-- print( "SlideView:nextSlide" )
	if self._index >= #self._slides then return end
	self:gotoSlide( self._index+1, params )
end

--== :previousSlide

--- move to the previous slide, if there is one.
--
-- @within Methods
-- @function :previousSlide
-- @tab[opt] params table of method parameters, as for gotoSlide()
-- @usage widget:previousSlide()

function SlideView:previousSlide( params )
	-- print( "SlideView:previousSlide" )
	if self._index <= 1 then return end
	self:gotoSlide( self._index-1, params )
end

--== :reloadData

--- reload the slides from the delegate.
-- asks for the number of slides and makes the ones in view again. the slide showing stays, if it still exists.
--
-- @within Methods
-- @function :reloadData

function SlideView:reloadData()
	-- print( "SlideView:reloadData" )
	local delegate = self._delegate
	assert( delegate, "SlideView:reloadData missing delegate" )
	--==--
	local num = delegate:numberOfSlides( self )
	assert( type(num)=='number' and num>=0, "SlideView:reloadData numberOfSlides() must return a number, zero or more" )

	self:_unrenderAllSlides()

	local slides = {}
	for i=1,num do
		slides[i] = { _index=i, _view=nil, _user={} }
	end
	self._slides = slides
	self.scrollWidth = 0 -- setter, of the slides

	local index = self._index
	if num==0 then
		index = 0
	elseif index < 1 then
		index = 1
	elseif index > num then
		index = num
	end
	self._index = index
	self._shownIndex = nil

	self:_renderDisplay{ atIndex=true }
	self:_moveToIndex( 0 )
	self:_dispatchShownSlide()
end

--== :startAutoAdvance

--- start advancing to the next slide by itself.
-- each slide stays for autoAdvanceTime; after the last one comes the first. the advance waits while a finger is on the SlideView.
--
-- @within Methods
-- @function :startAutoAdvance
-- @int[opt] time a new autoAdvanceTime, in milliseconds
-- @usage widget:startAutoAdvance( 3000 )

function SlideView:startAutoAdvance( time )
	-- print( "SlideView:startAutoAdvance", time )
	if time~=nil then self.autoAdvanceTime = time end
	assert( self._autoAdvanceTime > 0, "SlideView:startAutoAdvance needs an autoAdvanceTime above zero" )
	--==--
	self._isAutoAdvancing = true
	self:_startAdvanceTimer()
end

--== :stopAutoAdvance

--- stop advancing by itself.
--
-- @within Methods
-- @function :stopAutoAdvance
-- @usage widget:stopAutoAdvance()

function SlideView:stopAutoAdvance()
	-- print( "SlideView:stopAutoAdvance" )
	self._isAutoAdvancing = false
	self:_stopAdvanceTimer()
end



--====================================================================--
--== Private Methods


-- the width of all the slides: each is as wide as the view
--
function SlideView:_slidesWidth()
	local num = #self._slides
	if num < 1 then num = 1 end
	return num * self.width
end

-- the scroll position at which the slide at index shows
--
function SlideView:_positionOf( index )
	if index < 1 then index = 1 end
	return -( index-1 ) * self.width
end

-- the index of the slide nearest to a scroll position
--
function SlideView:_indexAt( value )
	local num = #self._slides
	if num==0 then return 0 end
	local index = mfloor( -value/self.width + 0.5 ) + 1
	if index < 1 then index = 1 elseif index > num then index = num end
	return index
end


-- scroll to the slide of 'self._index'
--
function SlideView:_moveToIndex( time, onComplete )
	-- print( "SlideView:_moveToIndex", time )
	local axis = self._axisX
	local pos = self:_positionOf( self._index )

	if pos==axis.value and axis:getState()==AxisMotion.STATE_AT_REST and axis._enterFrameIterator==nil then
		-- already there
		if onComplete then onComplete() end
		return
	end
	axis:scrollToPosition( pos, { time=time, onComplete=onComplete } )
end


function SlideView:_stopAdvanceTimer()
	local t = self._advance_timer
	if not t then return end
	tcancel( t )
	self._advance_timer = nil
end

-- (re-)start the wait for the next advance
--
function SlideView:_startAdvanceTimer()
	self:_stopAdvanceTimer()
	if not self._isAutoAdvancing or self._isTouched then return end
	self._advance_timer = tdelay( self._autoAdvanceTime, self._advance_f, 0 )
end

-- the auto-advance: the next slide, or the first after the last
--
function SlideView:_advance()
	-- print( "SlideView:_advance" )
	local num = #self._slides
	if num < 2 or self._isTouched then return end
	if self._index >= num then
		self:gotoSlide( 1 )
	else
		self:gotoSlide( self._index+1 )
	end
end


-- create the view for a slide, and have the delegate fill it
--
function SlideView:_renderSlide( record )
	-- print( "SlideView:_renderSlide", record._index )
	if record._view then return end

	local view = display.newGroup()
	record._view = view
	self._renderedSlides[ record._index ] = record

	self._scroller:insertItem( view )
	view.x, view.y = -self:_positionOf( record._index ), 0

	local e = {
		name=SlideView.EVENT,
		type=SlideView.RENDER_SLIDE,

		target=self,
		index=record._index,
		view=view,
		data=record._user,
		width=self.width,
		height=self.height,
	}
	self._delegate:onSlideRender( e )
end

-- remove the view of a slide
--
function SlideView:_unrenderSlide( record )
	-- print( "SlideView:_unrenderSlide", record._index )
	local view = record._view
	if not view then return end

	self._renderedSlides[ record._index ] = nil

	local e = {
		name=SlideView.EVENT,
		type=SlideView.UNRENDER_SLIDE,

		target=self,
		index=record._index,
		view=view,
		data=record._user,
	}
	-- optional: a slide's view is removed with everything in it
	local delegate = self._delegate
	if delegate and delegate.onSlideUnrender then
		delegate:onSlideUnrender( e )
	end

	self._scroller:removeItem( view )
	view:removeSelf()
	record._view = nil
end

function SlideView:_unrenderAllSlides()
	-- print( "SlideView:_unrenderAllSlides" )
	local list = {}
	for _, record in pairs( self._renderedSlides ) do
		list[ #list+1 ] = record
	end
	for i=1,#list do
		self:_unrenderSlide( list[i] )
	end
end


-- make the slides which are in view (plus the render margin),
-- remove the ones which left it.
-- @param params.clearAll make them all again (eg, for a new size)
-- @param params.atIndex for the position of the slide of 'self._index',
-- not for the current scroll position (a move there is about to start)
--
function SlideView:_renderDisplay( params )
	-- print( "SlideView:_renderDisplay" )
	params = params or {}
	--==--
	local slides = self._slides
	local num = #slides

	if params.clearAll then
		self:_unrenderAllSlides()
	end
	if num==0 then return end

	local width = self.width
	local margin = self._renderMargin
	local value = self._axisX.value

	self._slideWidth = width
	self._slideHeight = self.height

	if params.atIndex then
		value = self:_positionOf( self._index )
	end

	local first = mfloor( ( -value - margin ) / width ) + 1
	local last = mfloor( ( -value + width + margin ) / width ) + 1
	if first < 1 then first = 1 end
	if last > num then last = num end

	local out = {}
	for index, record in pairs( self._renderedSlides ) do
		if index < first or index > last then out[ #out+1 ] = record end
	end
	for i=1,#out do
		self:_unrenderSlide( out[i] )
	end

	for index=first,last do
		self:_renderSlide( slides[ index ] )
	end
end



--======================================================--
-- Event Dispatch

-- tell the delegate which slide shows, once for each change
--
function SlideView:_dispatchShownSlide()
	-- print( "SlideView:_dispatchShownSlide" )
	local index = self._index
	if index==self._shownIndex then return end
	self._shownIndex = index

	local record = self._slides[ index ]
	if not record then return end

	local delegate = self._delegate
	local f = delegate and delegate.didShowSlide
	if not f then return end
	f( delegate, {
		name=SlideView.EVENT,
		type=SlideView.SHOWN_SLIDE,

		target=self,
		index=index,
		view=record._view,
		data=record._user,
	})
end

function SlideView:_dispatchSelectedSlide( index )
	-- print( "SlideView:_dispatchSelectedSlide" )
	local record = self._slides[ index ]
	if not record then return end

	local delegate = self._delegate
	local f = delegate and delegate.didSelectSlide
	if not f then return end
	f( delegate, {
		name=SlideView.EVENT,
		type=SlideView.SELECTED_SLIDE,

		target=self,
		index=index,
		view=record._view,
		data=record._user,
	})
end



--======================================================--
-- DMC Lifecycle Methods

function SlideView:__commitProperties__()
	-- print( "SlideView:__commitProperties__" )
	local widthChanged = self._width_dirty

	if widthChanged then
		-- the slides are as wide as the view
		local scrollWidth = self:_slidesWidth()
		if self._scrollWidth~=scrollWidth then
			self._scrollWidth = scrollWidth
			self._scrollWidth_dirty = true
		end
	end

	self:superCall( '__commitProperties__' )
	--==--
	-- make the slides again for a new size, and stay on the one showing
	local sizeChanged = ( self.width~=self._slideWidth or self.height~=self._slideHeight )
	if sizeChanged and #self._slides > 0 then
		self:_renderDisplay{ clearAll=true, atIndex=true }
		self:_moveToIndex( 0 )
	end
end



--====================================================================--
--== Event Handlers


function SlideView:_axisEvent_handler( event )
	-- print( "SlideView:_axisEvent_handler" )
	if event.id=='x' then
		self._scroller.x = event.value
	end
	self:_scrollIndicatorEvent( event )
	self:_renderDisplay()
	-- after the slides for this position are made
	self:_scrollDelegateEvent( event )

	if event.id=='x' and event.state==AxisMotion.SCROLLED then
		-- at rest: this is the slide showing
		self._index = self:_indexAt( event.value )
		self:_dispatchShownSlide()
	end
end


-- the auto-advance waits while a finger is on the view,
-- and starts its wait again when it lifts
--
function SlideView:_gestureEvent_handler( event )
	-- print( "SlideView:_gestureEvent_handler", event.phase )
	ScrollView._gestureEvent_handler( self, event )

	if event.type~=event.target.GESTURE then return end
	local phase = event.phase
	if phase=='began' then
		self._isTouched = true
		self:_stopAdvanceTimer()
	elseif phase~='changed' then
		self._isTouched = false
		self:_startAdvanceTimer()
	end
end


-- a tap which nothing in the slide took: the slide is selected
--
function SlideView:_tap_handler( event )
	-- print( "SlideView:_tap_handler" )
	self:_dispatchSelectedSlide( self:_indexAt( self._axisX.value ) )
	return true
end




return SlideView
