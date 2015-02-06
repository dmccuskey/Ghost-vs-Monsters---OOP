--====================================================================--
-- dmc_widgets/scroller_view_base.lua
--
-- base class for scrolling UI elements
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



--[[

Item Info Record
this is what is passed in by user onRender()

{
	onItemRender = <func>, (local/global)
	onItemUnrender = <func>, (local/global)

	height = <int>, (optional)
	width = <int>, (optional)
	onItemEvent = <func>, (optional)
	bgColor = <table of colors>, (optional)
	data = ?? anything user wants (optional)

	isCategory = <bool>, (optional)

}

internal properties
{
	_category = <ref to category>
}

--]]



--[[

Item Data Record

{
	data = <item info rec>

	xMin = <int>
	xMax = <int>
	width = <int>

	yMin = <int>
	yMax = <int>
	height = <int>

	index = <int> -- reference to index position in list

	view = <display group>, main container of view, only avail if rendered
	background = <new rect>, reference to background
}

--]]



--====================================================================--
--== DMC Corona Widgets : Scroller View Base
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "1.1.0"



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local StatesMixModule = require 'dmc_states_mix'
local Utils = require 'dmc_utils'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local tinsert = table.insert
local tremove = table.remove

-- activate local debug functionality
local LOCAL_DEBUG = false



--====================================================================--
--== Basic Scroller
--====================================================================--


--[[
	need to create this small object so that we can
	easily set x/y offset of the scroller
	(thank you getters and setters !! =)
--]]

local BasicScroller = newClass( ComponentBase, {name="Basic Scroller"} )


--======================================================--
-- Start: Setup DMC Objects

function BasicScroller:__init__( params )
	-- print( "BasicScroller:__init__" )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	if params.x_offset == nil then params.x_offset = 0 end
	if params.y_offset == nil then params.y_offset = 0 end

	self._x_offset = params.x_offset
	self._y_offset = params.y_offset

end

-- END: Setup DMC Objects
--======================================================--


function BasicScroller.__setters:y( value )
	-- print( "BasicScroller.__setters:y" )
	self.view.y = ( value + self._y_offset )
end
function BasicScroller.__getters:y( value )
	-- print( "BasicScroller.__getters:y" )
	return ( self.view.y - self._y_offset )
end
function BasicScroller.__setters:x_offset( value )
	-- print( "BasicScroller.__setters:x_offset" )
	self._x_offset = value
end
function BasicScroller.__getters:x_offset()
	-- print( "BasicScroller.__getters:x_offset" )
	return self._x_offset
end
function BasicScroller.__setters:y_offset( value )
	-- print( "BasicScroller.__setters:y_offset" )
	self._y_offset = value
end
function BasicScroller.__getters:y_offset()
	-- print( "BasicScroller.__getters:y_offset" )
	return self._y_offset
end



--====================================================================--
--== Scroller View Base Class
--====================================================================--


local ScrollerBase = newClass( ComponentBase, {name="Scroller View Base Class"} )

StatesMixModule.patch( ScrollerBase )
-- ScrollerBase:setDebug( true ) -- States mixin

--== Class Constants

-- pixel amount to edges of ScrollerBase in which rows are de-/rendered
ScrollerBase.DEFAULT_RENDER_MARGIN = 100

-- flags used when scroller hits top/bottom of scroll range
ScrollerBase.HIT_TOP_LIMIT = "top_limit_hit"
ScrollerBase.HIT_BOTTOM_LIMIT = "bottom_limit_hit"

-- delta pixel amount before touch event is given up
ScrollerBase.X_TOUCH_LIMIT = 10
ScrollerBase.Y_TOUCH_LIMIT = 10


--== State Constants

ScrollerBase.STATE_CREATE = "state_create"
ScrollerBase.STATE_AT_REST = "state_at_rest"
ScrollerBase.STATE_TOUCH = "state_touch"
ScrollerBase.STATE_RESTRAINT = "state_restraint"
ScrollerBase.STATE_RESTORE = "state_restore"

ScrollerBase.STATE_RESTRAINT_TRANS_TIME = 100
ScrollerBase.STATE_RESTORE_TRANS_TIME = 400


--== Event Constants

ScrollerBase.EVENT = "scroller_view"

-- for scroll view
ScrollerBase.ITEM_SELECTED = 'item_selected'
ScrollerBase.ITEMS_MODIFIED = 'items_modified_event'
ScrollerBase.SCROLLING = 'view_scrolling_event'
ScrollerBase.SCROLLED = 'view_scrolled_event'
ScrollerBase.TAKE_FOCUS = 'take_focus_event'

-- for scroll items
ScrollerBase.ITEM_RENDER = "item_render_event"
ScrollerBase.ITEM_UNRENDER = "item_unrender_event"




--======================================================--
-- Start: Setup DMC Objects

function ScrollerBase:__init__( params )
	-- print( "ScrollerBase:__init__" )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	if params.x_offset == nil then params.x_offset = 0 end
	if params.y_offset == nil then params.y_offset = 0 end
	if params.automask == nil then params.automask = false end

	--== Sanity Check ==--

	if self.is_class then return end

	self._params = params -- save for later

	--== Create Properties ==--

	self._width = params.width or display.contentWidth
	self._height = params.height or display.contentHeight

	self._current_category = nil

	-- dimension in scroll direction
	-- based on our item data
	self._total_item_dimension = 0

	self._event_tmp = nil

	self._v_scroll_limit = nil -- type of limit, HIT_TOP_LIMIT, HIT_BOTTOM_LIMIT
	self._h_scroll_limit = nil -- type of limit, HIT_TOP_LIMIT, HIT_BOTTOM_LIMIT

	self._h_scroll_enabled = true
	self._v_scroll_enabled = true

	self._h_touch_limit = 10
	self._h_touch_lock = false
	self._v_touch_limit = 10
	self._v_touch_lock = false

	self._is_moving = false
	self._has_moved = false

	self._v_velocity = { value=0, vector=0 }
	self._h_velocity = { value=0, vector=0 }

	self._transition = nil -- handle of active transition

	self._returnFocus = nil -- return focus callback
	self._returnFocusCancel = nil -- return focus callback
	self._returnFocus_t = nil -- return focus timer

	self._is_rendered = true

	--== Display Groups ==--

	self._dg_scroller = nil  -- moveable item with rows
	self._dg_gui = nil  -- fixed items over table (eg, scrollbar)


	--== Object References ==--

	-- this is the *stationary* background of the table view
	self._bg_viewport = nil

	-- this is the *moving* background of all items
	self._bg = nil

	--[[
		array of item data objects
		this is all of the items which have been added to scroller
		data is plain Lua object, added from onRender() (item_info rec)
	--]]
	self._item_data_recs = nil

	--[[
		array of rendered items
		this is list of item data objects which have rendered views
		data is plain Lua object (item_data rec)
	--]]
	self._rendered_items = nil

	self._tmp_item = nil -- used when gotoItem

	--[[
		touch events stack
		used when calculating velocity
	--]]

	self._touch_evt_stack = nil

	self._categories = nil -- array of category data

	self._category_view = nil

	-- auto-masking
	if params.automask == true then
		self:_setView( display.newContainer( self._width, self._height ) )
		self.view.anchorChildren = false
		self.view.anchorX, self.view.anchorY = 0, 0
	end

end

--[[
function ScrollerBase:__undoInit__()
	-- print( "ScrollerBase:_undoInit" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]


-- __createView__()
--
function ScrollerBase:__createView__()
	-- print( "ScrollerBase:__createView__" )
	self:superCall( '__createView__' )
	--==--

	local W,H = self._width, self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, dg   -- object, display group

	--== viewport background

	o = display.newRect( 0,0, self._width, self._height )
	o:setFillColor( 0, 0, 0, 0 )
	if LOCAL_DEBUG then
		o:setFillColor( 0, 1, 1, 1 )
	end
	o.anchorX, o.anchorY = 0, 0 -- top left
	o.x,o.y = 0, 0

	self:insert( o )
	self._bg_viewport = o

	-- set anchor on self
	self.anchorX, self.anchorY = 0,0 -- top left
	o.x,o.y = 0, 0

	--== container for scroll items/background

	dg = BasicScroller:new{
		x_offset= self._params.x_offset,
		y_offset = self._params.y_offset
	}
	self:insert( dg.view )
	self._dg_scroller = dg

	dg.anchorX, dg.anchorY = 0,0 -- top left
	dg.x, dg.y = 0, 0

	--== background
	-- background dimensions are that of all slides/viewport

	o = display.newRect( 0, 0, self._width, self._height )
	o:setFillColor( 0, 0, 0, 0 )
	if LOCAL_DEBUG then
		o:setFillColor( 1, 1, 0, 1 )
	end

	-- top left anchor point
	o.anchorX, o.anchorY = 0, 0
	o.x,o.y = 0, 0

	dg:insert( o )
	self._bg = o

end

function ScrollerBase:__undoCreateView__()
	-- print( "ScrollerBase:__undoCreateView__" )

	local o

	o = self._bg
	o:removeSelf()
	self._bg = nil

	o = self._bg_viewport
	o:removeSelf()
	self._bg_viewport = nil

	o = self._dg_scroller
	o:removeSelf()
	self._dg_scroller = nil

	--==--
	self:superCall( "_undoCreateView" )
end


-- _initComplete()
--
function ScrollerBase:__initComplete__()
	-- print( "ScrollerBase:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--

	-- setup item containers
	self._item_data_recs = {}
	self._rendered_items = {}
	self._touch_evt_stack = {}

	-- add touch capability to our scroller item
	self._dg_scroller:addEventListener( 'touch', self )

	self._is_rendered = true

	self:setState( self.STATE_CREATE )
	self:gotoState( self.STATE_AT_REST )

end

function ScrollerBase:__undoInitComplete__()
	-- print( "ScrollerBase:__undoInitComplete__" )

	self._is_rendered = false

	self:deleteAllItems()

	-- remove touch capability to our scroller item
	self._dg_scroller:removeEventListener( 'touch', self )

	self._item_data_recs = nil
	self._rendered_items = nil
	self._touch_evt_stack = nil

	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- getter: return count of items
function ScrollerBase.__getters:item_count()
	-- print( "ScrollerBase:item_count" )
	local value = 0
	local items = self._item_data_recs
	if items then value = #items end
	return value
end

-- move scroller to item
function ScrollerBase:gotoItem( item_data )
	-- print( "ScrollerBase:gotoItem", item_data )
	self._tmp_item = item_data
	self:_updateView()
	self._tmp_item = nil
end


-- sets up giving away focus when someone wants to take it
--
function ScrollerBase:relinquishFocus( event )
	-- print( "ScrollerBase:relinquishFocus" )

	-- we need to end this touch action
	-- the following is copied from :touch(), END

	self:_checkScrollBounds()

	display.getCurrentStage():setFocus( nil )
	self._has_focus = false

	self._tch_event_tmp = event

	local next_state, next_params = self:_getNextState( { event=event } )
	self:gotoState( next_state, next_params )

end


function ScrollerBase:takeFocus( event )
	-- print( "ScrollerBase:takeFocus" )

	if self._returnFocusCancel then self._returnFocusCancel() end

	if event.returnFocus then

		local returnFocusCallback = event.returnFocus
		local returnFocusTarget = event.returnTarget

		local returnFocus_f, cancelFocus_f

		returnFocus_f = function( state )
			-- print( 'ScrollerBase: returnFocus' )

			cancelFocus_f()

			local e = self._tch_event_tmp

			local evt = {
				name = e.name,
				id=e.id,
				time=e.time,
				x=e.x,
				y=e.y,
				xStart=e.xStart,
				yStart=e.yStart,
			}

			if state then
				-- coming from end touch
				evt.phase = state  -- we want to give ended
			else
				-- coming from timer
				evt.phase = 'began'
				self:relinquishFocus( e )
			end

			evt.target = returnFocusTarget
			returnFocusCallback( evt )
		end

		cancelFocus_f = function()
			-- print( 'ScrollerBase: cancelFocus' )

			if self._returnFocus_t then
				timer.cancel( self._returnFocus_t )
				self._returnFocus_t = nil
			end

			self._returnFocus = nil
			self._returnFocusCancel = nil
		end

		self._returnFocus = returnFocus_f
		self._returnFocusCancel = cancelFocus_f
		self._returnFocus_t = timer.performWithDelay( 100, function(e) returnFocus_f() end )

	end

	-- remove previous focus, if any
	display.getCurrentStage():setFocus( nil )

	event.phase = 'began'
	event.target = self._dg_scroller
	self:touch( event )

end



-- insert new item into scroller
function ScrollerBase:insertItem( item_info )
	-- print( "ScrollerBase:insertSlide", item_info )
	assert( item_info, "ERROR:: ScrollerBase : missing item info in insertItem()" )
	--==--

	-- create record for our item
	local item_data = {
		data = item_info,

		xMin=0,
		xMax=0,
		width=0,

		yMin=0,
		yMax=0,
		height=0,

		isRendered=false,
		index=0
	}

	if not item_info.height then item_info.height = self._height end
	if not item_info.width then item_info.width = self._width end

	-- use global row render functions if not local

	if not item_info.onItemRender then item_info.onItemRender = self._onItemRender end
	if not item_info.onItemUnrender then item_info.onItemUnrender = self._onItemUnrender end

	if item_info.isCategory == nil then item_info.isCategory = false end

	--== category setup

	if item_info.isCategory then
		self._current_category = item_data
		tinsert( self._categories, item_data )

	else
		if self._current_category then
			item_info._category = self._current_category
		end

	end

	--== updates after change

	self:_updateDimensions( item_info, item_data )

	self:_updateBackground()
	self:_updateView()

	self:dispatchEvent( self.ITEMS_MODIFIED )

end


function ScrollerBase:deleteItem( index )
	-- print( "ScrollerBase:deleteItem", index )
	assert( type(index)=='number', "ScrollerBase:deleteItem: expected number for index" )
	--==--
	local items = self._item_data_recs
	local item_data

	-- get item data
	item_data = tremove( items, index )

	-- unrender if necessary
	if item_data.view then
		self:_unRenderItem( item_data, { index=nil } )
	end

	--== update display

	self:_reindexItems( index, item_data )
	self:_updateBackground()
	self:_updateView()

	self:dispatchEvent( self.ITEMS_MODIFIED )
end


function ScrollerBase:deleteAllItems()
	-- print( "ScrollerBase:deleteAllItems" )

	local rendered = self._rendered_items

	-- delete rendered items

	if #rendered > 0 then
		for i = #rendered, 1, -1 do
			local item_data = rendered[ i ]
			-- print( i, 'rendered row', item_data.index )
			self:_unRenderItem( item_data, { index=i } )
		end
	end

	-- reset everything

	self._dg_scroller.x, self._dg_scroller.y = 0, 0
	self._total_item_dimension = 0
	self._item_data_recs = {}

	self:_updateBackground()

	self:dispatchEvent( self.ITEMS_MODIFIED )

end



--====================================================================--
--== Private Methods


function ScrollerBase:_findFirstVisibleItem()
	-- print( "ScrollerBase:_findFirstVisibleItem" )

	local item

	if self._tmp_item then
		item = self._tmp_item
	else
		item = self._item_data_recs[1]
	end

	return item
end


-- binary search
function ScrollerBase:_findVisibleItem( min, max )
	-- print( "ScrollerBase:_findVisibleItem", min, max  )

	local items = self._item_data_recs

	if #items == 0 then return end

	local item
	local low, high = 1, #items
	local mid

	if self._tmp_item then
		return self._tmp_item.index

	else
		while( low <= high ) do
			mid = math.floor( low + ( (high-low)/2 ) )
			if items[mid].yMin > max then
				high = mid - 1
			elseif items[mid].yMin < min then
				low = mid + 1
			else
				return mid  -- found
			end

		end
	end

	return nil
end


-- this is the slide index
function ScrollerBase:_findRenderedItem( index )
	-- print( "ScrollerBase:_findRenderedItem", index )
	local rendered = self._rendered_items
	local record

	if #rendered > 0 then
		for i = #rendered, 1, -1 do
			local item_data = rendered[ i ]
			-- print( i, 'rendered row', item_data.index )
			if item_data.index == index then
				record = item_data
				break
			end
		end
	end

	return record
end


function ScrollerBase:_updateBackground()
	-- print( "ScrollerBase:_updateBackground" )
	error( "ScrollerBase:_updateBackground: override this ")
end


-- _viewportBounds()
-- calculates "viewport" bounding box on entire scroll list
-- based on scroll position and RENDER_MARGIN
-- used to determine if a item should be rendered
--  (xMin, xMax, yMin, yMax)
--
function ScrollerBase:_viewportBounds()
	-- print( 'ScrollerBase:_viewportBounds')

	local bounds = self._bg_viewport.contentBounds
	local scr = self._dg_scroller
	local scr_x, scr_x_offset = scr.x, scr._x_offset
	local scr_y, scr_y_offset = scr.y, scr._y_offset

	-- print( self._bg_viewport.y, self._bg_viewport.height )
	local o = self._bg_viewport


	-- print( "scroll offsets", scr_x, scr_x_offset, scr_y, scr_y_offset )
	-- print( "scroll offsets", scr_x, scr_x_offset, scr_y, scr_y_offset )
	-- print( o.x, o.width )
	-- print( bounds.yMin, bounds.yMax )

	local MARGIN = self.DEFAULT_RENDER_MARGIN

	local value =  {
		xMin = o.x - scr_x - MARGIN,
		xMax = o.x + o.width - scr_x + MARGIN,
		yMin = o.y - scr_y - MARGIN,
		yMax = o.y + o.height - scr_y + MARGIN,
	}
	-- print( value.xMin, value.xMax, value.yMin, value.yMax )
	return value

end





-- start at index
-- used for adding from TOP of list, moving UP
--
function ScrollerBase:_renderUp( index, bounds )
	-- print( "ScrollerBase:_renderUp", index )

	local bounded_f = self._isBounded
	local items = self._item_data_recs

	local item_data, is_bounded

	if index < 1 or index > #items then return end

	repeat

		item_data = items[ index ]
		is_bounded = bounded_f( self, bounds, item_data )
		-- print( index, item_data, is_bounded )
		if not is_bounded then
			break
		else
			self:_renderItem( item_data, { head=true } )
			index = index - 1
		end

	until true

end


-- start at index
-- used for adding from BOTTOM of list, moving DOWN
--
function ScrollerBase:_renderDown( index, bounds )
	-- print( "ScrollerBase:_renderDown", index )

	local bounded_f = self._isBounded
	local items = self._item_data_recs

	local item_data, is_bounded

	if index < 1 or index > #items then return end

	repeat

		item_data = items[ index ]
		is_bounded = bounded_f( self, bounds, item_data )
		-- print( index, item_data, is_bounded )
		if not is_bounded then
			break
		else
			self:_renderItem( item_data, { head=false } )
			index = index + 1
		end

	until true

end


-- used for removing starting from BOTTOM and moving UP
--
function ScrollerBase:_unrenderUp( bounds )
	-- print( "ScrollerBase:_unrenderUp"  )

	local bounded_f = self._isBounded
	local rendered = self._rendered_items

	local index, item_data, is_bounded

	index = #rendered
	item_data = rendered[ index ]
	while item_data do
		is_bounded = bounded_f( self, bounds, item_data )
		if is_bounded then
			break
		else
			self:_unRenderItem( item_data, { index=index } )
			index = #rendered
			item_data = rendered[ index ]
		end

	end

end


-- used for removing starting from TOP and moving DOWN
--
function ScrollerBase:_unrenderDown( bounds )
	-- print( "ScrollerBase:_unrenderDown"  )

	local bounded_f = self._isBounded
	local rendered = self._rendered_items

	local item_data, is_bounded

	-- we don't have to change the index
	item_data = rendered[ 1 ]
	while item_data do
		is_bounded = bounded_f( self, bounds, item_data )
		if is_bounded then
			break
		else
			self:_unRenderItem( item_data, { index=1 } )
			item_data = rendered[ 1 ]
		end
	end

end




-- _updateView()
-- checks current rendered items, re-/renders if necessary
--
function ScrollerBase:_updateView()
	-- print( "ScrollerBase:_updateView" )

	local bounds = self:_viewportBounds()
	-- print( 'bounds >> ', bounds.yMin, bounds.yMax )

	local renderUp = self._renderUp
	local renderDown = self._renderDown
	local unrenderUp = self._unrenderUp
	local unrenderDown = self._unrenderDown


	--== Start Processing ==--

	local items = self._item_data_recs
	local rendered = self._rendered_items
	local bounded_f = self._isBounded
	local item_data, is_bounded

	if #items == 0 then return end

	-- print( 'rendered items', #rendered )


	local index, item_data, is_bounded


	--== CASE: no rendered items ==--

	if #rendered == 0 then

		index = self:_findVisibleItem( bounds.yMin, bounds.yMax )

		if index then
			item_data = items[ index ]
			self:_renderItem( item_data )
			renderUp( self, index-1, bounds )
			renderDown( self, index+1, bounds )
		end

		return
	end


	--== CASE: we have rendered items


	--== check top of rendered list

	item_data = rendered[ 1 ]
	is_bounded = bounded_f( self, bounds, item_data )

	if is_bounded then
		-- the top item is still bound, so let's see if
		-- we need to add items to the bottom of rendered list
		item_data = rendered[ #rendered ]
		renderDown( self, item_data.index+1, bounds )

	else
		-- this item scrolled off screen
		-- so let's check rest below it too
		unrenderDown( self, bounds )

		if #rendered == 0 then
			-- we removed all of our items
			-- so find one which should be visible
			index = self:_findVisibleItem( bounds.yMin, bounds.yMax )

			if index then
				item_data = items[ index ]
				self:_renderItem( item_data )
				renderUp( self, index-1, bounds )
				renderDown( self, index+1, bounds )
			end

		else
			-- we have cleaned off the top
			-- so let's check to add to bottom
			item_data = rendered[ #rendered ]
			renderDown( self, item_data.index+1, bounds )

		end

		return
	end


	--== check bottom of rendered list

	item_data = rendered[ #rendered ]
	is_bounded = bounded_f( self, bounds, item_data )

	if is_bounded then
		-- the bottom item is still bound, so let's see if
		-- we need to add items to the top of rendered list
		item_data = rendered[ 1 ]
		renderUp( self, item_data.index-1, bounds )

	else
		-- this item scrolled off screen
		-- so let's check rest above it too
		unrenderUp( self, bounds )

		if #rendered == 0 then
			-- we removed all of our items
			-- so find one which should be visible
			index = self:_findVisibleItem( bounds.yMin, bounds.yMax )

			if index then
				item_data = items[ index ]
				self:_renderItem( item_data )
				renderUp( self, index-1, bounds )
				renderDown( self, index+1, bounds )
			end

		else
			-- we have cleaned off the bottom
			-- so let's check to add to the top
			item_data = rendered[ 1 ]
			renderUp( self, item_data.index-1, bounds )

		end

		return
	end

end



--[[

un-/render row event

local e = {}
e.name = "ScrollerBase_rowRender"
e.type = "unrender"
e.parent = self	-- ScrollerBase that this row belongs to
e.target = row
e.row = row
e.id = row.id
e.view = row.view
e.background = row.view.background
e.line = row.view.line
e.data = row.data
e.phase = "unrender"		-- phases: unrender, render, press, release, swipeLeft, swipeRight
e.index = row.index

--]]

function ScrollerBase:_renderItem( item_data, options )
	-- print( "ScrollerBase:_renderItem", item_data, item_data.index )
	options = options or {}
	--==--

	if item_data.view then print("already rendered") ; return end

	local dg = self._dg_scroller
	local item_info = item_data.data
	local view, bg, line

	--== Setup

	if item_info.hasBackground == nil then item_info.hasBackground = true end

	--== Create View Items

	-- create view for this item
	view = display.newGroup()

	dg:insert( view )
	item_data.view = view

	-- create background
	bg = display.newRect( 0, 0, self._width, item_info.height )
	bg.anchorX, bg.anchorY = 0,0
	bg.isVisible = item_info.hasBackground

	-- set colors
	if item_info.bgColor then
		bg:setFillColor( unpack( item_info.bgColor ) )
	else
		bg:setFillColor( 0,0,0,0 )
		bg.isHitTestable = true
	end
	bg:setStrokeColor( 0,0,0,0 )
	bg.strokeWidth = 0

	view:insert( bg )
	item_data.background = bg

	-- hide data on background, for touch
	-- bg._data = item_info
	-- bg:addEventListener( 'touch', self )

	-- create bottom-line
	-- TODO: create line

	--== Render View

	local e ={
		name = self.EVENT,
		type = self.ITEM_RENDER,

		parent = self,
		target = item_info,
		view = view,
		background = bg,
		line = line,
		data = item_info.data,
		index = item_data.index,
	}
	item_info.onItemRender( e )

	--== Update Item

	-- print( 'render ', item_data.yMin, item_data.yMax )
	view.x, view.y = item_data.xMin, item_data.yMin

	--== Save Item Data

	local idx = 1
	if options.head == false then idx = #self._rendered_items+1 end

	-- print( 'insert', #self._rendered_items, idx )
	tinsert( self._rendered_items, idx, item_data )

end


function ScrollerBase:_unRenderItem( item_data, options )
	-- print( "ScrollerBase:_unRenderItem", item_data.index )
	options = options or {}
	--==--

	-- Utils.print( item_data )

	-- if no item view then no need to unrender
	if not item_data.view then return end

	local rendered = self._rendered_items

	-- local dg = self._dg_scroller
	local index = options.index

	local item_info = item_data.data

	local view, bg, line

	if index == nil then
		for i,v in ipairs( rendered ) do
			-- print(i,v)
			if item_data == v then
				index = i
				-- print( "breaking at ", index )
				break
			end
		end
	end

	--== Remove Rendered Item

	view = item_data.view
	bg = item_data.background

	tremove( rendered, index )

	local e ={
		name = self.EVENT,
		type = self.ITEM_UNRENDER,

		parent = self,
		target = item_info,
		row = item_info,
		view = view,
		background = bg,
		line = line,
		data = item_info.data,
		index = item_data.index,
	}
	item_info.onItemUnrender( e )


	bg = item_data.background
	bg._data = nil
	bg:removeSelf()
	item_data.background = nil

	view = item_data.view
	view:removeSelf()
	item_data.view = nil

end


-- _checkScrollBounds()
-- check to see if scroll position is still valid
--
function ScrollerBase:_checkScrollBounds()
	-- print( 'ScrollerBase:_checkScrollBounds' )

	local scr = self._dg_scroller

	if self._h_scroll_enabled then
		local h_calc = self._width - self._bg.width
		if scr.x > 0 then
			self._h_scroll_limit = ScrollerBase.HIT_TOP_LIMIT
		elseif scr.x <  h_calc then
			self._h_scroll_limit = ScrollerBase.HIT_BOTTOM_LIMIT
		else
			self._h_scroll_limit = nil
		end
	end

	if self._v_scroll_enabled then
		local y_offset = scr.y_offset or 0
		local v_calc = self._height - self._bg.height - scr.y_offset
		-- print( "scr.y, ", scr.y , v_calc )

		if scr.y > 0 then
			self._v_scroll_limit = ScrollerBase.HIT_TOP_LIMIT
		elseif scr.y < v_calc then
			self._v_scroll_limit = ScrollerBase.HIT_BOTTOM_LIMIT
		else
			self._v_scroll_limit = nil
		end
	end

	-- print( self._h_scroll_limit, self._v_scroll_limit )
end


function ScrollerBase:_do_item_tap()
	-- OVERRIDE THIS
end



--======================================================--
-- START: SCROLLER BASE STATE MACHINE

function ScrollerBase:_getNextState( params )
	-- print( "ScrollerBase:_getNextState" )
	params = params or {}

	local limit = self._v_scroll_limit
	local v = self._v_velocity

	local s, p -- state, params

	if v.value <= 0 and not limit then
		s = self.STATE_AT_REST
		p = { event=params.event }

	elseif v.value > 0 and not limit then
		s = self.STATE_SCROLL
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


-- state_create()
--
function ScrollerBase:state_create( next_state, params )
	-- print( "ScrollerBase:state_create: >> ", next_state )

	if next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	else
		print( "WARNING :: ScrollerBase:state_create > " .. tostring( next_state ) )
	end
end


function ScrollerBase:do_state_at_rest( params )
	-- print( "ScrollerBase:do_state_at_rest", params  )
	params = params or {}

	local h_v, v_v = self._h_velocity, self._v_velocity
	local scr = self._dg_scroller

	h_v.value, h_v.vector = 0, 0
	v_v.value, v_v.vector = 0, 0

	self._enterFrameIterator = nil
	-- this one is redundant
	Runtime:removeEventListener( 'enterFrame', self )

	self:setState( self.STATE_AT_REST )
end

function ScrollerBase:state_at_rest( next_state, params )
	-- print( "ScrollerBase:state_at_rest: >> ", next_state )

	if next_state == self.STATE_TOUCH then
		self:do_state_touch( params )

	else
		print( "WARNING :: ScrollerBase:state_at_rest > " .. tostring( next_state ) )
	end

end



function ScrollerBase:do_state_touch( params )
	-- print( "ScrollerBase:do_state_touch" )
	params = params or {}
	--==--

	local VEL_STACK_LENGTH = 4 -- number of items to use for velocity calculation

	local h_v, v_v = self._h_velocity, self._v_velocity
	local vel_stack = {}

	local evt_tmp = nil -- enter frame event, updated each frame
	local last_tevt = nil -- touch events, reset for each calculation

	local enterFrameFunc1, enterFrameFunc2


	-- work to do after first event
	--
	enterFrameFunc2 = function( e )
		-- print( "enterFrameFunc: enterFrameFunc2 state touch " )

		local te_stack = self._touch_evt_stack
		local num_evts = #te_stack

		local x_delta, y_delta, t_delta


		--== process incoming touch events

		if num_evts == 0 then
			tinsert( vel_stack, 1, { 0, 0 }  )

		else
			t_delta = ( e.time-evt_tmp.time ) / num_evts

			for i, tevt in ipairs( te_stack ) do
				x_delta = tevt.x - last_tevt.x
				y_delta = tevt.y - last_tevt.y

				-- print( "events >> ", i, ( x_delta/t_delta ), ( y_delta/t_delta ) )
				tinsert( vel_stack, 1, { ( x_delta/t_delta ), ( y_delta/t_delta ) }  )

				last_tevt = tevt
			end

		end

		--== do calculations
		-- calculate average velocity and clean off
		-- velocity stack at same time

		local h_v_ave, v_v_ave = 0, 0
		local vel

		for i = #vel_stack, 1, -1 do
			if i > VEL_STACK_LENGTH then
				tremove( vel_stack, i )
			else
				vel = vel_stack[i]
				h_v_ave = h_v_ave + vel[1]
				v_v_ave = v_v_ave + vel[2]
				-- print(i, vel, vel[1], vel[2] )
			end
		end
		h_v_ave = h_v_ave / #vel_stack
		v_v_ave = v_v_ave / #vel_stack
		-- print( 'touch vel ave ', v_v_ave )

		v_v.value = math.abs( v_v_ave )
		v_v.vector = 0
		if v_v_ave < 0 then
			v_v.vector = -1
		elseif v_v_ave > 0 then
			v_v.vector = 1
		end

		h_v.value = math.abs( h_v_ave )
		h_v.vector = 1
		if h_v_ave < 0 then h_v.vector = -1 end


		--== prep for next frame

		self._touch_evt_stack = {}
		evt_tmp = e

	end


	-- this is only for the first enterFrame on a touch event
	-- we might already have several events in our stack,
	-- especially if someone is tapping hard/fast
	-- the last one is usually closer to the target,
	-- so we'll start with that one
	--
	enterFrameFunc1 = function( e )
		-- print( "enterFrameFunc: enterFrameFunc1 touch " )

		v_v.value, v_v.vector = 0, 0
		h_v.value, h_v.vector = 0, 0

		last_tevt = tremove( self._touch_evt_stack, #self._touch_evt_stack )
		self._touch_evt_stack = {}

		evt_tmp = e

		-- switch to other iterator
		self._enterFrameIterator = enterFrameFunc2
	end

	if self._enterFrameIterator == nil then
		Runtime:addEventListener( 'enterFrame', self )
	end

	self._enterFrameIterator = enterFrameFunc1

	self:setState( self.STATE_TOUCH )
end


function ScrollerBase:state_touch( next_state, params )
	-- print( "ScrollerBase:state_touch: >> ", next_state )

	if next_state == self.STATE_RESTORE then
		self:do_state_restore( params )

	elseif next_state == self.STATE_RESTRAINT then
		self:do_state_restraint( params )

	elseif next_state == self.STATE_AT_REST then
		self:do_state_at_rest( params )

	elseif next_state == self.STATE_SCROLL then
		self:do_state_scroll( params )

	else
		print( "WARNING :: ScrollerBase:state_touch > " .. tostring( next_state ) )
	end

end

-- END: SCROLLER BASE STATE MACHINE
--======================================================--



--====================================================================--
--== Event Handlers


-- bring to this class to make lookup faster
ScrollerBase.dispatchEvent = ComponentBase.dispatchEvent


function ScrollerBase:enterFrame( event )
	-- print( 'ScrollerBase:enterFrame' )

	local f = self._enterFrameIterator
	local scr = self._dg_scroller

	if not f or not self._is_rendered then
		Runtime:removeEventListener( 'enterFrame', self )

	else
		f( event )
		self._event_tmp = event
		self:_updateView()
		self:_checkScrollBounds()

		if self._is_moving then
			self._has_moved = true

			local v = self._v_velocity
			local data = {
				x=scr.x,
				y=scr.y,
				velocity = v.value * v.vector
			}
			self:dispatchEvent( ScrollerBase.SCROLLING, data )
		end

		if not self._enterFrameIterator and self._has_moved then
			self._has_moved = false
			local data = {
				x=scr.x,
				y=scr.y,
				velocity = 0
			}
			self:dispatchEvent( ScrollerBase.SCROLLED, data )
		end

	end
end


function ScrollerBase:touch( event )
	-- print( "ScrollerBase:touch", event.phase, event.id )

	local LIMIT = 200

	local background = self._bg
	local phase = event.phase
	local target = event.target -- scroller view

	local x_delta, y_delta

	tinsert( self._touch_evt_stack, event )

	if phase == 'began' then

		self._v_touch_lock = false
		self._h_touch_lock = false

		-- stop any active movement

		self:gotoState( self.STATE_TOUCH )

		-- save event for movement calculations
		self._tch_event_tmp = event

		-- handle touch
		display.getCurrentStage():setFocus( target )
		target._has_focus = true

	end

	if not target._has_focus then return false end

	if phase == 'moved' then
		-- Utils.print( event )

		local scr = self._dg_scroller
		local h_v = self._h_velocity
		local v_v = self._v_velocity
		local h_mult, v_mult
		local d, t, s
		local x_delta, y_delta

		--== Check to see if we need to reliquish the touch
		-- this is checking in our non-scroll direction

		x_delta = math.abs( event.xStart - event.x )
		if not self._v_touch_lock and x_delta > self._h_touch_limit then
			-- we're only moving in H direction now
			self._is_moving = true
			self._h_touch_lock = true
		end
		if not self._v_touch_lock and not self._h_scroll_enabled then
			if x_delta > self._h_touch_limit then
				self:dispatchEvent( self.TAKE_FOCUS, event )
			end
		end
		if self._returnFocusCancel and self._h_touch_lock and self._h_scroll_enabled then
			self._returnFocusCancel()
		end

		y_delta = math.abs( event.yStart - event.y )
		if not self._h_touch_lock and y_delta > self._v_touch_limit then
			-- we're only moving in V direction now
			self._is_moving = true
			self._v_touch_lock = true
		end

		if not self._h_touch_lock and not self._v_scroll_enabled then
			if y_delta > self._v_touch_limit then
				self:dispatchEvent( self.TAKE_FOCUS, event )
			end
		end
		if self._returnFocusCancel and y_delta > self._v_touch_limit*0.5 and self._v_scroll_enabled then
			self._returnFocusCancel()
		end

		self:_checkScrollBounds()

		--== Calculate motion multiplier

		-- horizonal
		s = 0
		if self._h_scroll_limit == self.HIT_TOP_LIMIT then
			s = scr.x
		elseif self._h_scroll_limit == self.HIT_BOTTOM_LIMIT then
			s = ( self._width - background.width ) - scr.x
		end
		h_mult = 1 - (s/LIMIT)

		-- vertical
		s = 0
		if self._v_scroll_limit == self.HIT_TOP_LIMIT then
			s = scr.y
		elseif self._v_scroll_limit == self.HIT_BOTTOM_LIMIT then
			s = ( self._height - background.height ) - scr.y
		end
		v_mult = 1 - (s/LIMIT)

		--== Move scroller

		if self._h_scroll_enabled and not self._v_touch_lock then
			x_delta = event.x - self._tch_event_tmp.x
			scr.x = scr.x + ( x_delta * h_mult )
		end

		if self._v_scroll_enabled and not self._h_touch_lock then
			y_delta = event.y - self._tch_event_tmp.y
			scr.y = scr.y + ( y_delta * v_mult )
		end

		--== The Rest

		self:_updateView()

		-- save event for movement calculation
		self._tch_event_tmp = event


	elseif phase == 'ended' or phase == 'cancelled' then

		-- validate our location
		self:_checkScrollBounds()

		-- clean up
		display.getCurrentStage():setFocus( nil )
		target._has_focus = false
		self._is_moving = false

		-- add system time, we can re-use this event for Runtime
		self._tch_event_tmp = event
		-- event.time = system.getTimer()


		-- maybe we have ended without moving
		-- so need to give back ended as a touch to our item

		local next_state, next_params = self:_getNextState( { event=event } )
		self:gotoState( next_state, next_params )

		if self._returnFocus then self._returnFocus( 'ended' ) end

		if not self._h_touch_lock and not self._v_touch_lock then
			self:_do_item_tap()
		end

	end

	return true
end




return ScrollerBase
