--====================================================================--
-- dmc_ui/dmc_widget/widget_tableview.lua
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
--== DMC Corona UI : TableView Widget
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
--== DMC UI : newTableView
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local TouchMgr = require 'dmc_touchmanager'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local ScrollView = require( ui_find( 'dmc_widget.widget_scrollview' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )



--====================================================================--
--== Setup, Constants


local mabs = math.abs
local mfloor = math.floor
local tinsert = table.insert
local tremove = table.remove
local tcancel = timer.cancel
local tdelay = timer.performWithDelay

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Support Function


local function setRowBackgroundColor( row, ... )
	local bg = row and row._view and row._view.__bg
	if not bg then return end
	bg:setFillColor( ... )
end

local function setRowLineColor( row, ... )
	local line = row and row._view and row._view.__line
	if not line then return end
	line:setFillColor( ... )
end

-- create records for TableView
-- these are records for each row, hold user data, position, etc. it can create multiple records at a time. uses tail-call
--
local function createRecords( list, idx, count, tinsert )
	-- print( "createRecords" )
	if idx<=count then
		local rec = {
			_yMin=0,
			_yMax=0,
			_height=0,
			_index=0,
			_view=nil,
			_user={},
			setBackgroundColor=setRowBackgroundColor,
			setLineColor=setRowLineColor
		}
		tinsert( list, idx, rec )
		return createRecords( list, idx+1, count, tinsert )
	end
end


-- remove records from end moving forward
-- idx2, idx1 – indexes, inclusive
--
local function removeRecords( list, idx2, idx1, tremove )
	-- print( "removeRecords", idx2, idx1, #list )
	for i=idx2,idx1,-1 do
		tremove( list, i )
	end
end


-- (re-)index all of the record items in the TableView.
-- makes sure indexes and position (yMin/yMax) are correct. uses tail-call
--
local function indexItems( list, idx, yMin, height )
	-- print( "indexItems" )
	local yMax = yMin+height
	if idx<=#list then
		local rec = list[idx]
		rec._yMin=yMin
		rec._yMax=yMax
		rec._height=height
		rec._index=idx
		return indexItems( list, idx+1, yMax, height )
	end
end



--====================================================================--
--== TableView Widget Class
--====================================================================--


--- TableView Widget.
-- a widget for scrolling items in a list.
--
-- **Inherits from:** <br>
-- * @{Widget.ScrollView}
--
-- **Style Object:** <br>
-- * @{Style.TableView}
--
-- @classmod Widget.TableView
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newTableView()

local TableView = newClass( ScrollView, {name="TableView Widget"} )

--- Class Constants.
-- @section

--== Class Constants

TableView._BOUND_CUT = 'cut'
TableView._BOUND_FULL = 'full'
TableView._BOUND_EXTEND = 'extend'

-- pixel amount to edges in which rows are de-/rendered
TableView._DEFAULT_RENDER_MARGIN = 100

--== Style/Theme Constants

TableView.STYLE_CLASS = nil -- added later
TableView.STYLE_TYPE = uiConst.TABLEVIEW

-- TODO: hook up later
-- ScrollView.DEFAULT = 'default'

-- ScrollView.THEME_STATES = {
-- 	ScrollView.DEFAULT,
-- }

--== Event Constants

--- TableView event constant.
-- used when setting up event listeners
--
-- @usage
-- widget:addEventListener( widget.EVENT, listener )

TableView.EVENT = 'tableview-event'

TableView.RENDER_ROW = 'row-render-event'
TableView.UNRENDER_ROW = 'row-unrender-event'
TableView.SHOULD_HIGHLIGHT_ROW = 'row-should-highlight-event'
TableView.HIGHLIGHT_ROW = 'row-highlight-event'
TableView.UNHIGHLIGHT_ROW = 'row-unhighlight-event'
TableView.WILL_SELECT_ROW = 'row-will-select-event'
TableView.SELECTED_ROW = 'row-selected-event'


--======================================================--
-- Start: Setup DMC Objects

function TableView:__init__( params )
	-- print( "TableView:__init__" )
	params = params or {}
	if params.decelerateTransitionTime==nil then params.decelerateTransitionTime=uiConst.TABLEVIEW_DECELERATE_TIME end
	if params.estimatedRowHeight==nil then params.estimatedRowHeight=20 end
	if params.renderMargin==nil then params.renderMargin=TableView._DEFAULT_RENDER_MARGIN end

	-- set before going into ScrollView
	params.lowerHorizontalOffset=0
	params.upperHorizontalOffset=0

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._tv_tmp_params = params -- tmp

	--== Create Properties ==--

	self._estimatedRowHeight = -1

	self._renderMargin = -1

	--[[
	array of data records for each row
	this is all of the items which have been added to scroller
	data is plain Lua object, added from onRender() (item_info rec)
	--]]
	self._rowItemRecords = {}

	--[[
	array of rendered items
	this is list of item which have been rendered
	data is plain Lua object
	--]]
	self._renderedTableCells = nil

	-- saved Touch Event, usually 'began'
	-- to enable motion "from beginning"
	self._tmpTouchEvt = nil

	--== Display Groups ==--

	--== Object References ==--

	self._tableCellHighlight_timer = nil
	self._tableCellTouch_f = nil

end

-- function TableView:__undoInit__()
-- 	-- print( "TableView:__undoInit__" )
-- 	--==--
-- 	self:superCall( '__undoInit__' )
-- end


--== initComplete

function TableView:__initComplete__()
	-- print( "TableView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local tmp = self._tv_tmp_params

	self._is_rendered = false

	self._rowItemRecords = {}
	self._renderedTableCells = {}

	self._tableCellTouch_f = self:createCallback( TableView._tableCellTouch_handler )

	--== Use Setters
	self.estimatedRowHeight = tmp.estimatedRowHeight
	self.renderMargin = tmp.renderMargin

	self._tv_tmp_params = nil
end

--== initComplete

function TableView:__undoInitComplete__()
	-- print( "TableView:__undoInitComplete__" )

	self:_stopHighlightTimer()
	-- not removeAllRows(): no size change on the way out
	self:_unrenderAllTableCells( self._renderedTableCells )

	self._rowItemRecords = nil
	self._renderedTableCells = nil

	self._is_rendered = false

	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function TableView.initialize( manager, params )
	-- print( "TableView.initialize" )
	dUI = manager

	local Style = dUI.Style
	TableView.STYLE_CLASS = Style.TableView

	Style.registerWidget( TableView )
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

TableView.__getters.delegate = WidgetHelp.__getters.delegate
TableView.__setters.delegate = WidgetHelp.__setters.delegate


--== .estimatedRowHeight

--- set/get the estimated height for each row.
-- the rows take a new value at the next reloadData().
--
-- @within Properties
-- @function .estimatedRowHeight
-- @usage widget.estimatedRowHeight = 30
-- @usage print( widget.estimatedRowHeight )

function TableView.__getters:estimatedRowHeight()
	-- print( "TableView.__getters:estimatedRowHeight" )
	return self._estimatedRowHeight
end
function TableView.__setters:estimatedRowHeight( value )
	assert( type(value)=='number' and value > 0 )
	--==--
	self._estimatedRowHeight = value
end

--== .horizontalScrollEnabled

-- block horizontal motion change
--
function TableView.__setters:horizontalScrollEnabled( value )
	-- print( "TableView.__setters:horizontalScrollEnabled", value )
	ScrollView.__setters.horizontalScrollEnabled( self, false )
end

--== .lowerOffset

--- set/get the lower offset for the TableView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .lowerOffset
-- @usage widget.lowerOffset = 30
-- @usage print( widget.lowerOffset )

function TableView.__getters:lowerOffset()
	-- print( "TableView.__getters:lowerOffset" )
	return self.lowerVerticalOffset
end
function TableView.__setters:lowerOffset( value )
	-- print( "TableView.__setters:lowerOffset", value )
	self.lowerVerticalOffset = value
end

--== .marginX

-- [**style**] set/get marginX.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginX
-- @usage widget.marginX = 18
-- @usage print( widget.marginX )

TableView.__getters.marginX = WidgetHelp.__getters.marginX
TableView.__setters.marginX = WidgetHelp.__setters.marginX

--== .marginY

-- [**style**] set/get marginX.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginX
-- @usage widget.marginX = 18
-- @usage print( widget.marginX )

TableView.__getters.marginY = WidgetHelp.__getters.marginY
TableView.__setters.marginY = WidgetHelp.__setters.marginY

--== .renderMargin

-- set the additional boundary beyond the view which defines the boundary for rendering table cells.
--
-- @within Properties
-- @function .renderMargin
-- @usage widget.renderMargin = 100
-- @usage print( widget.renderMargin )

function TableView.__getters:renderMargin()
	return self._renderMargin
end
function TableView.__setters:renderMargin( value )
	-- print( "TableView.__setters:renderMargin", value )
	assert( type(value)=='number' and value>=0, "TableView.renderMargin must be a number, zero or more" )
	--==--
	self._renderMargin = value
end

--== .scrollEnabled

--- set/get control TableView scrolling motion.
-- setting to false will disable scrolling in Y-axis.
--
-- @within Properties
-- @function .scrollEnabled
-- @usage widget.scrollEnabled = true
-- @usage print( widget.scrollEnabled )

function TableView.__getters:scrollEnabled()
	-- print( "TableView.__getters:scrollEnabled" )
	return ScrollView.__getters.verticalScrollEnabled( self )
end
function TableView.__setters:scrollEnabled( value )
	-- print( "TableView.__setters:scrollEnabled", value )
	ScrollView.__setters.verticalScrollEnabled( self, value )
end

--== .scrollWidth

-- block width change
--
function TableView.__setters:scrollWidth( value )
	-- print( "TableView.__setters:scrollWidth", value )
	ScrollView.__setters.scrollWidth( self, 0 )
end

--== .upperOffset

--- set/get the upper offset for the TableView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .upperOffset
-- @usage widget.upperOffset = 30
-- @usage print( widget.upperOffset )

function TableView.__getters:upperOffset()
	-- print( "TableView.__getters:upperOffset" )
	return self.upperVerticalOffset
end
function TableView.__setters:upperOffset( value )
	-- print( "TableView.__setters:upperOffset", value )
	self.upperVerticalOffset = value
end



--== :getContentPosition

--- Returns the y coordinates of the TableView content.
--
-- @within Methods
-- @function :getContentPosition
-- @treturn number y
-- @usage local y = widget:getContentPosition()

function TableView:getContentPosition()
	-- print( "TableView:getContentPosition" )
	local _, y = ScrollView.getContentPosition( self )
	return y
end

--== :getRowAt

--- returns the reference to the row view located at index.
-- the row view or nil if not visible
--
-- @within Methods
-- @function :getRowAt
-- @int index row index at which to get row view
--
-- @return view or nil if the row is not visible/rendered

function TableView:getRowAt( idx )
	-- print( "TableView:getRowAt", pos )
	local records = self._rowItemRecords
	local rec = records[idx]
	return rec and rec._view
end

--== :insertRowAt

--- insert a new row in table.
-- row will be inserted at index given.
--
-- @within Methods
-- @function :insertRowAt
-- @int index index at which to insert a row

function TableView:insertRowAt( idx )
	-- print( "TableView:insertRowAt", idx )
	assert( type(idx)=='number', "TableView:insertRowAt arg must be a number" )
	assert( self._delegate, "TableView:insertRowAt missing delegate" )
	--==--
	local records = self._rowItemRecords
	assert( idx>=1 and idx<=#records+1, "TableView:insertRowAt index must be from 1 to the number of rows plus 1" )
	-- a row at the end goes below the last one
	local rec, prev = records[idx], records[idx-1]
	local yMin = rec and rec._yMin or ( prev and prev._yMax or 0 )
	local eRH = self._estimatedRowHeight

	self.scrollHeight = self.scrollHeight + eRH
	createRecords( records, idx, idx, tinsert )
	indexItems( records, idx, yMin, eRH )
	self:_renderDisplay{ clearAll=true }
end

--== :reloadData

--- reload data from data source.
-- will rerender everything.
--
-- @within Methods
-- @function :reloadData

function TableView:reloadData()
	-- print( "TableView:reloadData" )
	assert( self._delegate, "TableView:reloadData missing delegate" )
	--==--
	local eRH = self._estimatedRowHeight
	local num = self._delegate:numberOfRows( self, 0 )
	local records = {}
	local yMin = 0

	self.scrollHeight = num*eRH
	createRecords( records, 1, num, tinsert )
	indexItems( records, 1, yMin, eRH )
	self._rowItemRecords = records

	self:_renderDisplay{ clearAll=true }
end

--== :removeAllRows

--- remove all rows from the tableview.
--
-- @within Methods
-- @function :removeAllRows
-- @usage widget:removeAllRows()

function TableView:removeAllRows()
	-- print( "TableView:removeAllRows" )
	local records = self._rowItemRecords
	self:_unrenderAllTableCells( self._renderedTableCells )
	removeRecords( records, #records, 1, tremove )
	-- nothing left to scroll (the setter keeps it at the view's height)
	self.scrollHeight = 0
end

--== :removeRowAt

--- remove existing row from table.
-- row at index will be removed.
--
-- @within Methods
-- @function :removeRowAt
-- @int index index at which to remove row

function TableView:removeRowAt( idx )
	-- print( "TableView:removeRowAt", idx )
	assert( type(idx)=='number', "TableView:removeRowAt arg must be a number" )
	--==--
	local records = self._rowItemRecords
	local rec = records[idx]
	if not rec then
		print("WARNING: TableView:removeRowAt no row at that index")
		return
	end
	local yMin = rec and rec._yMin or 0
	local eRH = self._estimatedRowHeight

	self.scrollHeight = self.scrollHeight - eRH
	self:_unrenderTableCell( rec )
	removeRecords( records, idx, idx, tremove )
	indexItems( records, idx, yMin, eRH )
	-- always: the rows below moved up, also when the row removed
	-- was above the ones rendered
	self:_renderDisplay{ clearAll=true }
end

--== :scrollToRowAt

--- scrolls to row located at index.
-- use this when you want scrolling relative to a row and location in the TableView.
--
-- @within Methods
-- @function :scrollToRowAt
-- @int index index for row to scroll to
-- @tab[opt] params table of method parameters
-- @string[opt='none'] params.position The location reference for scroll action – 'none', 'top', 'middle', 'bottom'.
-- @int[opt=0] params.time the duration for scroll animation, in milliseconds. 0, the default, moves at once
-- @func[opt] params.onComplete a function to call when the animation is complete
--
-- @usage widget:scrollToRowAt( 5, { position='top' } )

function TableView:scrollToRowAt( idx, params )
	-- print( "TableView:scrollToRowAt" )
	assert( type(idx)=='number' )
	params = params or {}
	if params.time==nil then params.time=0 end
	if params.position==nil then params.position='none' end
	if params.limitIsActive==nil then params.limitIsActive=false end
	--==--
	local record = self._rowItemRecords[ idx ]
	assert( record, "TableView:scrollToRowAt no row at that index" )

	local pos = self:_calculateScrollPosition( record, params.position )

	-- the rows are rendered as the axis reports its positions
	self._axisY:scrollToPosition( pos, params )
end

--== :setContentPosition

--- Scroll to a specific y position.
-- Moves content position to y over a certain time duration. Use this when you want to scroll to a specific Y location.
--
-- @within Methods
-- @function :setContentPosition
-- @tab params table of parameters
-- @int params.y the y position to scroll to
-- @int[opt=500] params.time the duration for scroll animation, in milliseconds. set to 0 for immediate transition
-- @func[opt] params.onComplete a function to call when the animation is complete
-- @usage widget:setContentPosition( { y=-35 } )

function TableView:setContentPosition( params )
	-- print( "TableView:setContentPosition" )
	assert( type(params)=='table' )
	params.x = nil
	--==--
	ScrollView.setContentPosition( self, params )
end



--====================================================================--
--== Private Methods


-- _viewportBounds()
-- calculates "viewport" bounding box on entire scroll list
-- based on scroll position and RENDER_MARGIN
-- used to determine if a item should be rendered
--  (xMin, xMax, yMin, yMax)
--
function TableView:_viewportBounds()
	-- print( "TableView:_viewportBounds" )
	local bounds =  {
		yMin = nil,
		yMax = nil,
	}
	local o = self._axisY
	local rM = self._renderMargin
	if o then
		bounds.yMin = 0 - o.value - rM
		bounds.yMax = 0 + o.length - o.value + rM
	end
	-- print( bounds.yMin, bounds.yMax )
	return bounds
end


-- determine if record is inside of Table View bounds
--
function TableView:_isWithinBounds( bounds, record )
	-- print( "TableView:_isWithinBounds", bounds, record.index )

	local result = false
	local bType = 'none'

	if record._yMin < bounds.yMin and bounds.yMin <= record._yMax then
		-- view cut on top
		bType = 'cut'
		result = true
	elseif record._yMin <= bounds.yMax and bounds.yMax < record._yMax then
		-- view cut on bottom
		bType = 'cut'
		result = true
	elseif record._yMin >= bounds.yMin and record._yMax <= bounds.yMax  then
		-- view fully in View Port
		bType = 'full'
		result = true
	elseif record._yMin < bounds.yMin and bounds.yMax < record._yMax then
		-- view extends over View Port
		bType = 'extend'
		result = true
	end

	return result, bType
end


-- search for an item which should be visible.
-- usually used when there are no visible table cells
-- uses binary search
-- @table records array of data items
--
function TableView:_findVisibleItem( records, min, max )
	-- print( "TableView:_findVisibleItem", min, max  )

	if #records == 0 then return end
	local _mfloor = mfloor
	local low, high = 1, #records
	local mid

	while( low <= high ) do
		mid = _mfloor( low + ( (high-low)*0.5 ) )
		-- any row which overlaps the bounds will do
		if records[mid]._yMin > max then
			high = mid - 1
		elseif records[mid]._yMax < min then
			low = mid + 1
		else
			return mid  -- found
		end
	end

	return nil
end


-- renders table cells.
-- adds cells starting at Top, moving Up
--
function TableView:_renderUp( records, index, bounds )
	-- print( "TableView:_renderUp", index, bounds )

	if index < 1 or index > #records then return end

	local isBounded_f = self._isWithinBounds
	local renderCell_f = self._renderTableCell
	local record, isBounded, bType

	repeat
		record = records[ index ]
		if not record then break end
		isBounded, bType = isBounded_f( self, bounds, record )
		-- print( "rU", index, bType, record, record._yMin, isBounded )
		-- a row cut by the bounds is rendered too: with a small
		-- render margin it is partly in view
		if not isBounded then
			break
		else
			renderCell_f( self, record, { putAtHead=true } )
			index = index - 1
		end
	until false

end

-- renders table cells.
-- adds cells starting at Bottom, moving Down
--
function TableView:_renderDown( records, index, bounds )
	-- print( "TableView:_renderDown", index, bounds )

	if index < 1 or index > #records then return end

	local isBounded_f = self._isWithinBounds
	local renderCell_f = self._renderTableCell
	local record, isBounded, bType

	repeat
		record = records[ index ]
		if not record then break end
		isBounded, bType = isBounded_f( self, bounds, record )
		-- print( "rD", index, bType, record, record._yMax, isBounded )
		-- a row cut by the bounds is rendered too: with a small
		-- render margin it is partly in view
		if not isBounded then
			break
		else
			renderCell_f( self, record, { putAtHead=false } )
			index = index + 1
		end
	until false

end


-- removes rendered table cells
-- starts check from Bottom and moves Up
--
function TableView:_unrenderUpFromBottom( bounds )
	-- print( "TableView:_unrenderUpFromBottom"  )

	local isBounded_f = self._isWithinBounds
	local unrenderCell_f = self._unrenderTableCell
	local renderedCells = self._renderedTableCells
	local index, record, isBounded, bType

	index = #renderedCells
	record = renderedCells[ index ]
	while record do
		isBounded, bType = isBounded_f( self, bounds, record )
		if isBounded then
			break
		else
			unrenderCell_f( self, record, { index=index } )
			index = #renderedCells
			record = renderedCells[ index ]
		end
	end

end

-- removes rendered table cells
-- starts check from Top and moves Down
--
function TableView:_unrenderDownFromTop( bounds )
	-- print( "TableView:_unrenderDownFromTop"  )

	local isBounded_f = self._isWithinBounds
	local unrenderCell_f = self._unrenderTableCell
	local renderedCells = self._renderedTableCells
	local record, isBounded, bType

	-- the index never changes
	record = renderedCells[ 1 ]
	while record do
		isBounded, bType = isBounded_f( self, bounds, record )
		if isBounded then
			break
		else
			unrenderCell_f( self, record, { index=1 } )
			record = renderedCells[ 1 ]
		end
	end

end


function TableView:_renderDisplay( params )
	-- print( "TableView:_renderDisplay" )
	params = params or {}
	if params.clearAll==nil then params.clearAll=false end
	--==--

	local records = self._rowItemRecords
	if #records == 0 then return end

	if params.clearAll then
		self:_unrenderAllTableCells( self._renderedTableCells )
	end

	local isBounded_f = self._isWithinBounds
	local renderedCells = self._renderedTableCells

	local bounds = self:_viewportBounds()
	local record, isBounded, bType

	local function renderAllCells( recs, bnds )
		local idx = self:_findVisibleItem( recs, bnds.yMin, bnds.yMax )
		if idx then
			local rec = recs[ idx ]
			self:_renderTableCell( rec )
			self:_renderUp( recs, rec._index-1, bnds )
			self:_renderDown( recs, rec._index+1, bnds )
		end
	end

	--== Check top of rendered list ==--

	if #renderedCells==0 then
		renderAllCells( records, bounds )
	else
		record = renderedCells[ 1 ]
		isBounded, bType = isBounded_f( self, bounds, record )
		if not isBounded then
			-- this item scrolled off screen so check others below
			self:_unrenderDownFromTop( bounds )
		else
			self:_renderUp( records, record._index-1, bounds )
		end
	end

	--== Check bottom of rendered list ==--

	if #renderedCells==0 then
		renderAllCells( records, bounds )
	else
		record = renderedCells[ #renderedCells ]
		isBounded, bType = isBounded_f( self, bounds, record )
		if not isBounded then
			-- this item scrolled off screen so check others above
			self:_unrenderUpFromBottom( bounds )
		else
			self:_renderDown( records, record._index+1, bounds )
		end
	end

	--== Final Check ==--

	if #renderedCells==0 then
		renderAllCells( records, bounds )
	end

end



function TableView:_startHighlightTimer( record )
	-- print( "TableView:_startHighlightTimer", record )
	local f = function(e)
		self:_dispatchHighlightRow( record )
		self._tableCellHighlight_timer=nil
	end
	self._tableCellHighlight_timer = tdelay( 10, f )

end
function TableView:_stopHighlightTimer()
	-- print( "TableView:_startHighlightTimer" )
	local t = self._tableCellHighlight_timer
	if not t then return end
	tcancel( t )
	self._tableCellHighlight_timer = nil
end


-- create callback function for returnFocus
-- this is how ScrollView will communicate
--
function TableView:_getReturnFocusCallback( method )
	-- print( "TableView:_getReturnFocusCallback" )
	return function( event )
		event.focusBack = true
		method( self, event )
	end
end

function TableView:_tableCellTouch_handler( event )
	-- print( "TableView:_tableCellTouch_handler", event.phase )
	local phase = event.phase
	local target = event.target -- hit area
	local record = target.__rec

	if event.phase == 'began' and not event.focusBack then
		-- this is initial pass through Touch Handler
		-- give Touch Event to ScrollView right away (takeFocus)
		--
		event.returnFocus = self:_getReturnFocusCallback( self._tableCellTouch_handler )
		event.returnTarget = target
		self:takeFocus( event )

	elseif event.phase == 'began' then
		-- this is second pass through Touch Handler
		-- being here means ScrollView didn't use
		-- Touch Event, so gave it back (returnFocus)
		--
		TouchMgr.setFocus( target, event.id )
		self:_startHighlightTimer( record )
		-- save initial 'began' Event in case we need to
		-- give back again. this enables better looking motion
		self._tmpTouchEvt = event

	elseif phase == 'moved' then
		local threshold = uiConst.TABLEVIEW_TOUCH_THRESHOLD
		local hasScrolled = (mabs( event.yStart - event.y ) > threshold)
		if hasScrolled then
			-- movement has surpassed threshold
			-- give Touch Event back to ScrollView
			self:_stopHighlightTimer( record )
			self:_dispatchUnhighlightRow( record )
			self:takeFocus( self._tmpTouchEvt )
			self._tmpTouchEvt = nil
		end

	elseif phase == 'ended' or phase == 'cancelled' then
		TouchMgr.unsetFocus( target, event.id )
		self:_stopHighlightTimer( record )
		self:_dispatchUnhighlightRow( record )
		if phase == 'ended' then
			self:_dispatchSelectedRow( record )
		end
		self._tmpTouchEvt = nil
	end

	return true
end



-- setup creation of new Table Cell
-- creates visual holder for User's TableCell
--
-- @param record an record for a row item
--
function TableView:_renderTableCell( record, options )
	-- print( "TableView:_renderTableCell", record, record._index )
	options = options or {}
	if options.putAtHead==nil then options.putAtHead=true end
	--==--

	if record._view then --[[ print("already rendered") ; --]] return end

	local width = self.width
	local renderedCells = self._renderedTableCells
	local view, hit
	local bg, line, o

	--== Create View Items

	-- create view for this item
	view = display.newGroup()
	record._view = view

	-- create hit background
	o = display.newRect( 0, 0, width, record._height )
	o.anchorX, o.anchorY = 0,0
	o.isVisible = true
	o:setFillColor( 0,0,0,0 )
	o.isHitTestable = true

	o.__rec = record
	view:insert( o )
	view.__hit = o

	TouchMgr.register( o, self._tableCellTouch_f )

	-- create background
	o = display.newRect( 0, 0, width, record._height )
	o.anchorX, o.anchorY = 0,0
	o.isVisible = true
	o:setFillColor( 1,1,1,1 )
	o.isHitTestable = false

	view:insert( o )
	view.__bg = o

	-- create line
	o = display.newRect( 0, 0, width, 1 )
	o.anchorX, o.anchorY = 0,1
	o.y=record._height
	o.isVisible = true
	o:setFillColor( 0,0,0,0 )
	o.isHitTestable = false

	view:insert( o )
	view.__line = o

	--== Render View

	local e = {
		name=TableView.EVENT,
		type=TableView.RENDER_ROW,

		target=self,
		row=record,
		view=view,
		index=record._index,
		data=record._user,
	}
	self._delegate:onRowRender( e )

	self._scroller:insertItem( view )
	view.x, view.y = 0, record._yMin

	-- save rendered record
	local idx = #renderedCells+1
	if options.putAtHead==true then idx=1 end
	tinsert( renderedCells, idx, record )

end


-- setup deleation of existing Table Cell
-- deletes visual holder for User's TableCell
--
-- @param record an record for a row item
--
function TableView:_unrenderTableCell( record, options )
	-- print( "TableView:_unrenderTableCell", record, record._index )
	options = options or {}
	options.index=options.index
	--==--
	if not record._view then return false end

	local renderedCells = self._renderedTableCells
	local index = options.index
	local view, hit
	local o

	if index==nil then
		-- find the index
		for i=1,#renderedCells do
			if record==renderedCells[i] then index=i ; break end
		end
	end

	--== Remove Rendered Item

	view = record._view

	tremove( renderedCells, index )

	self._scroller:removeItem( view )

	local e ={
		name = TableView.EVENT,
		type = TableView.UNRENDER_ROW,

		target=self,
		row=record,
		view=view,
		data=record._user,
		index=record._index,
	}
	-- optional: a row's view is removed with everything in it
	local delegate = self._delegate
	if delegate and delegate.onRowUnrender then
		delegate:onRowUnrender( e )
	end

	view.__bg:removeSelf()
	view.__bg= nil

	view.__line:removeSelf()
	view.__line= nil

	hit = view.__hit
	TouchMgr.unregister( hit, self._tableCellTouch_f )
	hit:removeSelf()
	view.__hit=nil

	view:removeSelf()
	record._view = nil

	return true
end

function TableView:_unrenderAllTableCells( rendered )
	-- print( "TableView:_unrenderAllTableCells", #rendered )
	local unrenderCell_f = TableView._unrenderTableCell
	for i=#rendered, 1, -1 do
		local record = tremove( rendered, i )
		unrenderCell_f( self, record, {index=i} )
	end
end



--[[
function TableView:_updateBackground()
	-- print( "TableView:_updateBackground" )

	local items = self._item_data_recs
	local o = self._bg

	local total_dim, item
	local x, y

	-- set our total item dimension

	if #items == 0 then
		total_dim = 0
	else
		item = items[ #items ]
		total_dim = item.yMax
	end

	self._total_item_dimension = total_dim

	-- set background height, make at least height of window

	if total_dim < self._height then
		total_dim = self._height
	end

	x, y = o.x, o.y
	o.height = total_dim
	o.anchorX, o.anchorY = 0,0
	o.x, o.y = x, y

end
--]]


-- calculate vertical direction
--
--[[
function TableView:_updateDimensions( item_info, item_data )
	-- print( "TableView:_updateDimensions", item_info )

	local total_dim = self._total_item_dimension
	local o
	local x, y

	-- configure item data of new item element

	item_data.height = item_info.height
	item_data.yMin = self._total_item_dimension
	item_data.yMax = item_data.yMin + item_data.height

	tinsert( self._item_data_recs, item_data )
	item_data.index = #self._item_data_recs

	-- print( 'item insert', item_data.yMin, item_data.yMax )

	total_dim = total_dim + item_data.height

	self._total_item_dimension = total_dim


	-- adjust background height

	if total_dim < self._height then
		total_dim = self._height
	end

	o = self._bg
	x, y = o.x, o.y -- temp
	o.height = total_dim
	o.anchorX, o.anchorY = 0,0
	o.x, o.y = x, y

end
--]]


function TableView:_calculateScrollPosition( record, position )
	-- print( "TableView:_calculateScrollPosition", record, position )
	local value = 0
	local offset = 0

	if position=='top' then
		offset = 0+self.upperVerticalOffset
		value = offset-record._yMin
	elseif position=='middle' then
		offset = self.height/2
		value = offset-record._yMin
	elseif position=='bottom' then
		offset = self.height-self.lowerVerticalOffset
		value = offset-(record._yMin+record._height)
	else
		offset = self.height/2
		value = offset-record._yMin
	end

	-- stay inside the scroll limits: the first rows can't be
	-- in the middle, nor the last ones at the top
	local upper = self.upperVerticalOffset
	local lower = self.height - self.scrollHeight - self.lowerVerticalOffset
	if lower > upper then lower = upper end
	if value > upper then
		value = upper
	elseif value < lower then
		value = lower
	end

	return value
end



--======================================================--
-- Event Dispatch

function TableView:_dispatchHighlightRow( record )
	-- print( "TableView:_dispatchHighlightRow" )
	-- the row can be gone by now (scrolled away, removed)
	if not record._view then return end
	local delegate = self._delegate
	local cell = record._view.cell
	local f, evt

	evt = {
		name=TableView.EVENT,
		type=TableView.SHOULD_HIGHLIGHT_ROW,

		target=self,
		index=record._index,
		view=record._view,
		data=record._user
	}

	f = delegate and delegate.shouldHighlightRow
	if f then
		if not f( delegate, evt ) then return end
	end

	if cell then
		cell.highlight=true
	end

	f = delegate and delegate.didHighlightRow
	evt.type = TableView.HIGHLIGHT_ROW
	if f then f( delegate, evt ) end

end


function TableView:_dispatchUnhighlightRow( record )
	-- print( "TableView:_dispatchUnhighlightRow" )
	-- if highlight then tell
	if not record._view then return end
	local delegate = self._delegate
	local cell = record._view.cell
	local f, evt

	if cell then
		cell.highlight=false
	end

	evt = {
		name=TableView.EVENT,
		type=TableView.UNHIGHLIGHT_ROW,

		target=self,
		index=record._index,
		view=record._view,
		data=record._user
	}
	f = delegate and delegate.didUnhighlightRow
	if f then f( delegate, evt ) end

end


function TableView:_dispatchSelectedRow( record )
	-- print( "TableView:_dispatchSelectedRow" )
	-- if highlight then tell
	local delegate = self._delegate
	local rowIdx = record._index
	local f, evt

	evt = {
		name=TableView.EVENT,
		type=TableView.WILL_SELECT_ROW,

		target=self,
		index=record._index,
		view=record._view,
		data=record._user
	}

	f = delegate and delegate.willSelectRow
	if f then
		rowIdx = f( delegate, evt )
		if rowIdx==nil then return end
	end
	if rowIdx~=record._index then
		-- get alternate record
		record = self._rowItemRecords[ rowIdx ]
		if not record then return end
		evt.index=record._index
		evt.view=record._view
		evt.data=record._user
	end

	evt.type=TableView.SELECTED_ROW
	f = delegate and delegate.didSelectRow
	if f then f( delegate, evt ) end

end



--======================================================--
-- DMC Lifecycle Methods

function TableView:__commitProperties__()
	-- print( "TableView:__commitProperties__" )
	local widthChanged = self._width_dirty
	local sizeChanged = widthChanged or self._height_dirty or self._scrollHeight_dirty

	self:superCall( '__commitProperties__' )
	--==--
	-- rows are made as wide as the view: make them again for a new
	-- width; a new height or scroll height changes which are in view
	if sizeChanged and self._renderedTableCells then
		self:_renderDisplay{ clearAll=widthChanged }
	end
end



--====================================================================--
--== Event Handlers


function TableView:_axisEvent_handler( event )
	-- print( "TableView:_axisEvent_handler" )
	if event.id=='y' then
		self._scroller.y = event.value
	end
	self:_scrollIndicatorEvent( event )
	self:_renderDisplay()
	-- after the rows for this position are made
	self:_scrollDelegateEvent( event )
end




return TableView
