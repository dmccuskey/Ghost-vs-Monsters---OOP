--====================================================================--
-- dmc_widgets/widget_slideview.lua
--
-- Documentation: http://docs.davidmccuskey.com/
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
--== DMC Corona Widgets : Slide View
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "1.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--


local dmc_widget_data, dmc_widget_func
dmc_widget_data = _G.__dmc_widget
dmc_widget_func = dmc_widget_data.func



--====================================================================--
--== Slide View Setup
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'

--== Components

local ScrollerViewBase = require( dmc_widget_func.find( 'scroller_view_base' ) )
local easingx = require( dmc_widget_func.find( 'lib.easingx' ) )



--====================================================================--
--== Setup, Constants

-- setup some aliases to make code cleaner
local newClass = Objects.newClass



--====================================================================--
-- Slide View Widget Class
--====================================================================--


local SlideView = newClass( ScrollerViewBase, {name="Slide View Widget"} )

--== Class Constants

--== State Constants

-- STATE_CREATE = "state_create"
-- STATE_AT_REST = "state_at_rest"
-- STATE_TOUCH = "state_touch"
-- STATE_RESTRAINT = "state_touch"
-- STATE_RESTORE = "state_touch"
SlideView.STATE_MOVE_TO_NEAREST_SLIDE = 'move_to_nearest_slide'
SlideView.STATE_MOVE_TO_NEXT_SLIDE = 'move_to_next_slide'

SlideView.STATE_MOVE_TO_NEAREST_SLIDE_TRANS_TIME = 250
SlideView.STATE_MOVE_TO_NEXT_SLIDE_TRANS_TIME = 250


--== Event Constants

SlideView.SLIDE_IN_FOCUS = 'slide_in_focus_event'

SlideView.SLIDE_RENDER = ScrollerViewBase.ITEM_RENDER
SlideView.SLIDE_UNRENDER = ScrollerViewBase.ITEM_UNRENDER



--======================================================--
-- Start: Setup DMC Objects

function SlideView:__init__( params )
	-- print( "SlideView:__init__" )
	params = params or { }
	self:superCall( '__init__', params )
	--==--


	--== Create Properties ==--

	-- self._width = 0
	-- self._height = 0
	-- self._total_item_dimension = 0
	-- self._scroll_limit = nil -- type of limit, HIT_TOP_LIMIT, HIT_BOTTOM_LIMIT

	-- self._current_category = nil

	-- self._total_row_height = 0

	-- self._event_tmp = nil


	-- self._velocity = { value=0, vector=1 }

	-- self._transition = nil -- handle of active transition


	-- --== Display Groups ==--

	-- self._dg_scroller = nil  -- moveable item with rows
	-- self._dg_gui = nil  -- fixed items over table (eg, scrollbar)


	-- --== Object References ==--

	-- self._primer = nil

	-- self._bg = nil


	-- --[[
	-- 	array of rendered row data
	-- --]]
	-- self._rendered_rows = nil

	-- self._categories = nil -- array of category data

	-- self._category_view = nil
	-- self._inactive_dots = {}

	self.index = -1 -- index of slide showing, or -1
	self.slide = nil -- slide showing, or nil

	self._h_scroll_enabled = true
	self._v_scroll_enabled = false

end

function SlideView:__undoInit__()
	-- print( "SlideView:__undoInit__" )

	--==--
	self:superCall( '__undoInit__' )
end



-- __createView__()
--
function SlideView:__createView__()
	-- print( "SlideView:__createView__" )
	self:superCall( '__createView__' )
	--==--

	local W,H = self._width, self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, dg, tmp  -- object, display group, tmp

end

function SlideView:__undoCreateView__()
	-- print( "SlideView:__undoCreateView__" )

	local o

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function SlideView:__initComplete__()
	--print( "SlideView:__initComplete__" )

	local o, f


	self:setState( self.STATE_CREATE )
	self:gotoState( self.STATE_AT_REST )

	--==--
	self:superCall( '__initComplete__' )
end

function SlideView:__undoInitComplete__()
	--print( "SlideView:__undoInitComplete__" )

	--==--
	self:superCall( '__undoInitComplete__' )
end

--== END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- set method on our object, make lookup faster


SlideView.insertSlide = ScrollerViewBase.insertItem

SlideView.deleteSlide = ScrollerViewBase.deleteItem

SlideView.deleteAllSlides = ScrollerViewBase.deleteAllItems



function SlideView:gotoSlide( index )
	-- print( "SlideView:gotoSlide", index )

	local scr = self._dg_scroller
	local items = self._item_data_recs
	local item_data

	item_data = items[ index ]
	scr.x = -item_data.xMin

	ScrollerViewBase.gotoItem( self, item_data )

	self.index = index
	self.slide = self._rendered_items[ self.index ]

	local data = {
		index = index,
		slide = self.slide
	}
	if data.index and data.slide then
		self:dispatchEvent( self.SLIDE_IN_FOCUS, data )
	else
		print( "SlideView::goto slide not in focus", index, self.slide )
	end

end


-- return data portion of what user gave us
--
function SlideView:getSlideData( index )
	-- print( "SlideView:getSlideData", index )

	local items = self._item_data_recs
	local idx = index or self.index
	local item_info, obj_data -- info from user

	if idx and items[ idx ] then
		item_info = items[ idx ].data -- item_info record
		obj_data = item_info.data
	end

	return obj_data
end



--====================================================================--
--== Private Methods


function SlideView:_reindexItems( index, record )
	-- print( "SlideView:_reindexItems", index, record )

	local items = self._item_data_recs
	local item_data, view, w
	w = record.width

	for i=index,#items do
		-- print(i)
		item_data = items[ i ]
		item_data.xMin = item_data.xMin - w
		item_data.xMax = item_data.xMax - w
		item_data.index = i
		view = item_data.view
		if view then view.x, view.y = item_data.xMin, item_data.yMin end
	end

end

function SlideView:_updateBackground()
	-- print( "SlideView:_updateBackground" )

	local items = self._item_data_recs
	local o = self._bg

	local total_dim, item
	local x, y

	-- set our total item dimension

	if #items == 0 then
		total_dim = 0
	else
		item = items[ #items ]
		total_dim = item.xMax
	end

	self._total_item_dimension = total_dim


	-- set background width, make at least width of window

	if total_dim < self._width then
		total_dim = self._width
	end

	x, y = o.x, o.y
	o.width = total_dim
	o.anchorX, o.anchorY = 0,0
	o.x, o.y = x, y

end


-- calculate horizontal direction
--
function SlideView:_updateDimensions( item_info, item_data )
	-- print( "SlideView:_updateDimensions", item_info )

	local total_dim = self._total_item_dimension

	local o
	local x, y


	-- configure item data of new item element

	item_data.width = item_info.width
	item_data.xMin = self._total_item_dimension
	item_data.xMax = item_data.xMin + item_data.width

	table.insert( self._item_data_recs, item_data )
	item_data.index = #self._item_data_recs

	-- print( 'item insert', item_data.xMin, item_data.xMax )

	total_dim = total_dim + item_data.width
	self._total_item_dimension = total_dim


	-- do i want this here ?
	if #self._rendered_items == 1 then

		self.index = 1
		self.slide = self:_findRenderedItem( self.index )

		local data = {
			index=self.index,
			slide=self.slide
		}
		if data.index and data.slide then
			self:dispatchEvent( self.SLIDE_IN_FOCUS, data )
		else
			print( "SlideView::_updateDimensions not in focus" )
		end

	end
end



function SlideView:_isBounded( scroller, item )
	-- print( "SlideView:_isBounded", scroller, item )

	local result = false

	if item.xMin < scroller.xMin and scroller.xMin <= item.xMax then
		-- cut on left
		result = true
	elseif item.xMin <= scroller.xMax and scroller.xMax < item.xMax then
		-- cut on right
		result = true
	elseif item.xMin >= scroller.xMin and item.xMax <= scroller.xMax then
		-- fully in view
		result = true
	elseif item.xMin < scroller.xMin and scroller.xMax < item.xMax then
		-- extends over view
		result = true
	end

	return result
end



function SlideView:_findClosestSlide()
	-- print( "SlideView:_findClosestSlide" )

	local item, pos, idx  = nil, 999, 0
	local rendered = self._rendered_items
	local bounds = self:_viewportBounds()
	local scr = self._dg_scroller

	for i,v in ipairs( rendered ) do
		-- print(i,v)
		local dist = math.abs( v.xMin + scr.x )
		-- print( v.xMin, scr.x, dist, pos )
		if dist < pos then
			item = v
			pos = dist
			idx = i
		end
	end

	return item, (item.xMin + scr.x), idx
end



function SlideView:_findNextSlide()
	-- print( "SlideView:_findNextSlide" )

	local scr = self._dg_scroller
	local v = self._h_velocity
	local rendered = self._rendered_items

	local close, dist, index = self:_findClosestSlide()

	local idx, item

	if v.vector == -1 then
		idx = index + 1
	else
		idx = index - 1
	end

	item = rendered[ idx ]
	if not item then item = rendered[ index ] end

	-- print( close.index, idx, item )
	return item, (item.xMin + scr.x)
end



function SlideView:_do_item_tap()
	-- print( "SlideView:_do_item_tap" )
	local data = {
		index=self.index,
		slide=self.slide,
		data=self.slide.data.data
	}
	self:dispatchEvent( self.ITEM_SELECTED, data )
end



--======================================================--
--== START: SLIDEVIEW STATE MACHINE


function SlideView:_getNextState( params )
	-- print( "SlideView:_getNextState" )

	params = params or {}

	local limit = self._h_scroll_limit
	local v = self._h_velocity

	local s, p -- state, params

	if v.value <= 0 and not limit then
		s = self.STATE_MOVE_TO_NEAREST_SLIDE
		p = { event=params.event }

	elseif v.value > 0 and not limit then
		s = self.STATE_MOVE_TO_NEXT_SLIDE
		p = { event=params.event }

	elseif v.value <= 0 and limit then
		s = self.STATE_RESTORE
		p = { event=params.event }

	elseif v.value > 0 and limit then
		s = self.STATE_RESTRAINT
		p = { event=params.event }

	end

	return s, p
end



--[[
-- from parent
function SlideView:do_state_touch( next_state, params )
end
--]]

function SlideView:state_touch( next_state, params )
	-- print( "SlideView:state_touch: >> ", next_state )

	if next_state == self.STATE_RESTORE then
		self:do_state_restore( params )

	elseif next_state == self.STATE_RESTRAINT then
		self:do_state_restraint( params )

	elseif next_state == self.STATE_MOVE_TO_NEAREST_SLIDE then
		self:do_move_to_nearest_slide( params )

	elseif next_state == self.STATE_MOVE_TO_NEXT_SLIDE then
		self:do_move_to_next_slide( params )

	else
		print( "WARNING :: SlideView:state_touch > " .. tostring( next_state ) )
	end

end



-- when object has neither velocity nor limit
-- we scroll to closest slide
--
function SlideView:do_move_to_nearest_slide( params )
	-- print( "SlideView:do_move_to_nearest_slide" )

	params = params or {}
	local evt_start = params.event

	local TIME = self.STATE_MOVE_TO_NEAREST_SLIDE_TRANS_TIME
	local ease_f = easingx.easeOut

	local scr = self._dg_scroller
	local pos = scr.x

	local item, dist = self:_findClosestSlide()

	local delta = -dist


	local enterFrameFunc = function( e )
		-- print( "SlideView: enterFrameFunc: do_move_to_nearest_slide" )

		local evt_frame = self._event_tmp

		local start_time_delta = e.time - evt_start.time -- total

		local x_delta

		--== Calculation

		x_delta = ease_f( start_time_delta, TIME, pos, delta )


		--== Action

		if start_time_delta < TIME then
			scr.x = x_delta

		else
			-- final state
			scr.x = pos + delta
			self:gotoState( self.STATE_AT_REST, item )

		end
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( self.STATE_MOVE_TO_NEAREST_SLIDE )
end

function SlideView:move_to_nearest_slide( next_state, params )
	-- print( "SlideView:move_to_nearest_slide: >> ", next_state, params )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		print( "WARNING :: SlideView:move_to_nearest_slide > " .. tostring( next_state ) )
	end

end



-- when object has neither velocity nor limit
-- we scroll to closest slide
--
function SlideView:do_move_to_next_slide( params )
	-- print( "SlideView:do_move_to_next_slide" )

	params = params or {}
	local evt_start = params.event

	local TIME = self.STATE_MOVE_TO_NEXT_SLIDE_TRANS_TIME
	local ease_f = easingx.easeOut

	local scr = self._dg_scroller
	local pos = scr.x

	local item, dist = self:_findNextSlide()

	local delta = -dist


	local enterFrameFunc = function( e )
		-- print( "SlideView: enterFrameFunc: do_move_to_next_slide" )

		local evt_frame = self._event_tmp

		local start_time_delta = e.time - evt_start.time -- total

		local x_delta

		--== Calculation

		x_delta = ease_f( start_time_delta, TIME, pos, delta )


		--== Action

		if start_time_delta < TIME then
			scr.x = x_delta

		else
			-- final state
			scr.x = pos + delta
			self:gotoState( self.STATE_AT_REST, item  )

		end
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( self.STATE_MOVE_TO_NEXT_SLIDE )
end

function SlideView:move_to_next_slide( next_state, params )
	-- print( "SlideView:move_to_next_slide: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		print( "WARNING :: SlideView:move_to_next_slide > " .. tostring( next_state ) )
	end

end



-- when object has velocity and hit limit
-- we constrain its motion away from limit
--
function SlideView:do_state_restraint( params )
	-- print( "SlideView:do_state_restraint" )

	params = params or {}
	local evt_start = params.event

	local TIME = self.STATE_RESTRAINT_TRANS_TIME
	local ease_f = easingx.easeOut

	local v = self._h_velocity
	local scr = self._dg_scroller

	local velocity = v.value * v.vector
	local v_delta = -velocity


	local enterFrameFunc = function( e )
		-- print( "SlideView: enterFrameFunc: do_state_restraint" )

		local evt_frame = self._event_tmp
		local limit = self._v_scroll_limit

		local start_time_delta = e.time - evt_start.time -- total
		local frame_time_delta = e.time - evt_frame.time

		local x_delta


		--== Calculation

		v.value = ease_f( start_time_delta, TIME, velocity, v_delta )
		x_delta = v.value * frame_time_delta


		--== Action

		if start_time_delta < TIME and math.abs(x_delta) >= 1 then
			scr.x = scr.x + x_delta

		else
			-- final state
			v.value, v.vector = 0, 0
			self:gotoState( self.STATE_RESTORE, { event=e } )
		end
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( self.STATE_RESTRAINT )
end

function SlideView:state_restraint( next_state, params )
	-- print( "SlideView:state_restraint: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_RESTORE then
		self:do_state_restore( params )

	else
		print( "WARNING :: SlideView:state_restraint > " .. tostring( next_state ) )
	end

end





-- when object has neither velocity nor limit
-- we scroll to closest slide
--
function SlideView:do_state_restore( params )
	-- print( "SlideView:do_state_restore" )

	params = params or {}
	local evt_start = params.event

	local TIME = self.STATE_RESTORE_TRANS_TIME
	local ease_f = easingx.easeOut

	local v = self._h_velocity
	local limit = self._h_scroll_limit
	local scr = self._dg_scroller
	local background = self._bg

	local pos = scr.x
	local dist, delta
	local rendered, item

	rendered = self._rendered_items

	if limit == self.HIT_TOP_LIMIT then
		dist = scr.x
		item = rendered[ 1 ]
	else
		dist = pos - ( self._width - background.width )
		item = rendered[ #rendered ]
	end

	delta = -dist


	local enterFrameFunc = function( e )
		-- print( "SlideView: enterFrameFunc: do_state_restore" )

		local evt_frame = self._event_tmp

		local start_time_delta = e.time - evt_start.time -- total

		local x_delta


		--== Calculation

		x_delta = ease_f( start_time_delta, TIME, pos, delta )


		--== Action

		if start_time_delta < TIME then
			scr.x = x_delta

		else
			-- final state
			v.value, v.vector = 0, 0
			scr.x = pos + delta
			self:gotoState( self.STATE_AT_REST, item )

		end
	end

	-- start animation

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end
	self._enterFrameIterator = enterFrameFunc

	-- set current state
	self:setState( self.STATE_RESTORE )
end

function SlideView:state_restore( next_state, params )
	-- print( "SlideView:state_restore: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	elseif next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		print( "WARNING :: SlideView:state_restore > " .. tostring( next_state ) )
	end

end


function SlideView:do_state_at_rest( slide )
	-- print( "SlideView:do_state_at_rest: >> ", slide )

	params = params or {}
	-- TODO: figure out why this doesn't work
	-- self:superCall( 'do_state_at_rest', params )
	ScrollerViewBase.do_state_at_rest( self, params )
	--==--
	if not slide then
		self.slide = nil
		self.index = -1
	else
		self.slide = slide
		self.index = slide.index
		local data = {
			index=slide.index,
			slide=slide
		}
		if data.index and data.slide then
			if self._has_moved then
				self:dispatchEvent( self.SLIDE_IN_FOCUS, data )
			end
		else
			print( "SlideView::do_state_at_rest not in focus" )
		end
	end

end


-- function SlideView:


--====================================================================--
--== Event Handlers



-- set method on our object, make lookup faster
SlideView.enterFrame = ScrollerViewBase.enterFrame




return SlideView
