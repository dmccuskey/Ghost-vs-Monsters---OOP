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

local VERSION = "2.1.0"



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

local RowLayout = require( ui_find( 'dmc_widget.widget_tableview.row_layout' ) )
local ScrollView = require( ui_find( 'dmc_widget.widget_scrollview' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )



--====================================================================--
--== Setup, Constants


local mabs = math.abs
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
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

-- create the record for a row which is rendered: its place in
-- the list, its view, and the row object of the row events
--
local function createRecord( index, top, height, data )
	return {
		_yMin=top,
		_yMax=top+height,
		_height=height,
		_index=index,
		_view=nil,
		_user=data,
		setBackgroundColor=setRowBackgroundColor,
		setLineColor=setRowLineColor
	}
end


-- move the data of the rows from 'index' on by 'delta' rows
-- (1 after an insert, -1 after a remove). 'list' has an entry
-- only for the rows which were given one
--
local function shiftRowData( list, index, delta )
	local keys = {}
	for i in pairs( list ) do
		if i >= index then keys[ #keys+1 ] = i end
	end
	tsort( keys )
	local first, last, step = 1, #keys, 1
	-- moving up, start with the last: nothing is overwritten
	if delta > 0 then first, last, step = #keys, 1, -1 end
	for k = first, last, step do
		local i = keys[k]
		list[ i+delta ] = list[ i ]
		list[ i ] = nil
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

TableView.HEIGHT_FOR_ROW = 'row-height-event'
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
	-- 'estimatedRowHeight' is the older name of 'rowHeight'
	if params.rowHeight==nil then params.rowHeight=params.estimatedRowHeight end
	if params.rowHeight==nil then params.rowHeight=20 end
	if params.renderMargin==nil then params.renderMargin=TableView._DEFAULT_RENDER_MARGIN end

	-- set before going into ScrollView
	params.lowerHorizontalOffset=0
	params.upperHorizontalOffset=0

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._tv_tmp_params = params -- tmp

	--== Create Properties ==--

	self._rowHeight = -1

	self._renderMargin = -1

	--[[
	where the rows are: how many, the top and height of each.
	one of two layouts, picked at reloadData(): every row with the
	one height (rowHeight), or each with its own (the delegate's
	heightForRow). see row_layout.lua
	--]]
	self._rowLayout = nil

	--[[
	the data table of each row (the 'data' of the row events), by
	index. made the first time a row is rendered, and kept from then on
	--]]
	self._rowData = {}

	--[[
	array of the records of the rows which are rendered, in index
	order and without gaps. a row has a record only while it is rendered
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

	self._rowLayout = RowLayout.Uniform.new( 0, tmp.rowHeight )
	self._rowData = {}
	self._renderedTableCells = {}

	self._tableCellTouch_f = self:createCallback( TableView._tableCellTouch_handler )

	--== Use Setters
	self.rowHeight = tmp.rowHeight
	self.renderMargin = tmp.renderMargin

	self._tv_tmp_params = nil
end

--== initComplete

function TableView:__undoInitComplete__()
	-- print( "TableView:__undoInitComplete__" )

	self:_stopHighlightTimer()
	-- not removeAllRows(): no size change on the way out
	self:_unrenderAllTableCells( self._renderedTableCells )

	self._rowLayout = nil
	self._rowData = nil
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

--- set/get the height of the rows, the older name of @{rowHeight}.
--
-- @within Properties
-- @function .estimatedRowHeight
-- @usage widget.estimatedRowHeight = 30
-- @usage print( widget.estimatedRowHeight )

function TableView.__getters:estimatedRowHeight()
	-- print( "TableView.__getters:estimatedRowHeight" )
	return self._rowHeight
end
function TableView.__setters:estimatedRowHeight( value )
	self.rowHeight = value
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

--== .rowHeight

--- set/get the height of the rows.
-- every row has this height, unless the delegate has `heightForRow`:
-- then it is the height of a row for which that returns nothing.
-- the rows take a new value at the next reloadData().
--
-- @within Properties
-- @function .rowHeight
-- @usage widget.rowHeight = 30
-- @usage print( widget.rowHeight )

function TableView.__getters:rowHeight()
	-- print( "TableView.__getters:rowHeight" )
	return self._rowHeight
end
function TableView.__setters:rowHeight( value )
	assert( type(value)=='number' and value > 0, "TableView.rowHeight must be a number above zero" )
	--==--
	self._rowHeight = value
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
	local rec = self:_getRenderedRecord( idx )
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
	local layout = self._rowLayout
	if layout:count()==0 then
		-- the first row of a list: either layout will do
		layout = self:_createRowLayout( 0 )
		self._rowLayout = layout
	end
	assert( idx>=1 and idx<=layout:count()+1, "TableView:insertRowAt index must be from 1 to the number of rows plus 1" )

	-- the rows from here on have a new index, and move down
	self:_unrenderAllTableCells( self._renderedTableCells )
	shiftRowData( self._rowData, idx, 1 )
	layout:insert( idx, not layout.isUniform and self:_getRowHeight( idx ) or nil )

	self.scrollHeight = layout:totalHeight()
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
	local num = self._delegate:numberOfRows( self, 0 )

	self:_unrenderAllTableCells( self._renderedTableCells )
	self._rowData = {}
	self._rowLayout = self:_createRowLayout( num )

	self.scrollHeight = self._rowLayout:totalHeight()
	self:_renderDisplay{ clearAll=true }
end

--== :reloadRowAt

--- make a row again, with the height it has now.
-- asks the delegate for the row's height again (`heightForRow`),
-- moves the rows below it, and renders the row again.
-- the row keeps its data.
--
-- @within Methods
-- @function :reloadRowAt
-- @int index index of the row to make again

function TableView:reloadRowAt( idx )
	-- print( "TableView:reloadRowAt", idx )
	assert( type(idx)=='number', "TableView:reloadRowAt arg must be a number" )
	assert( self._delegate, "TableView:reloadRowAt missing delegate" )
	--==--
	local layout = self._rowLayout
	assert( idx>=1 and idx<=layout:count(), "TableView:reloadRowAt no row at that index" )

	self:_unrenderAllTableCells( self._renderedTableCells )
	if not layout.isUniform then
		layout:setHeight( idx, self:_getRowHeight( idx ) )
	end

	self.scrollHeight = layout:totalHeight()
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
	self:_unrenderAllTableCells( self._renderedTableCells )
	self._rowData = {}
	self._rowLayout = RowLayout.Uniform.new( 0, self._rowHeight )
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
	local layout = self._rowLayout
	if idx<1 or idx>layout:count() then
		print("WARNING: TableView:removeRowAt no row at that index")
		return
	end

	-- the rows below have a new index, and move up: also when
	-- the row removed was above the ones rendered
	self:_unrenderAllTableCells( self._renderedTableCells )
	self._rowData[ idx ] = nil
	shiftRowData( self._rowData, idx+1, -1 )
	layout:remove( idx )

	self.scrollHeight = layout:totalHeight()
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
	local layout = self._rowLayout
	assert( idx>=1 and idx<=layout:count(), "TableView:scrollToRowAt no row at that index" )

	local pos = self:_calculateScrollPosition( layout:top( idx ), layout:height( idx ), params.position )

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


-- the layout for 'count' rows, as the delegate has it: each row with
-- its own height if the delegate has heightForRow(), otherwise every
-- row with the one height
--
function TableView:_createRowLayout( count )
	-- print( "TableView:_createRowLayout", count )
	local delegate = self._delegate
	if not ( delegate and delegate.heightForRow ) then
		return RowLayout.Uniform.new( count, self._rowHeight )
	end

	local heights = {}
	for i = 1, count do
		heights[i] = self:_getRowHeight( i )
	end
	return RowLayout.Variable.new( heights )
end


-- ask the delegate for the height of a row.
-- rowHeight if it has none for it
--
function TableView:_getRowHeight( index )
	-- one table for all of the calls: a long list asks for every row
	local e = self._heightEvent
	if e==nil then
		e = { name=TableView.EVENT, type=TableView.HEIGHT_FOR_ROW, target=self }
		self._heightEvent = e
	end
	e.index = index
	local height = self._delegate:heightForRow( e )
	if height==nil then return self._rowHeight end
	assert( type(height)=='number' and height>0, "TableView: heightForRow must return a number above zero, or nothing" )
	return height
end


-- the data table of a row: made when first asked for, then kept
--
function TableView:_getRowData( index )
	local list = self._rowData
	local data = list[ index ]
	if data==nil then
		data = {}
		list[ index ] = data
	end
	return data
end


-- the record of a row, if the row is rendered
--
function TableView:_getRenderedRecord( index )
	local renderedCells = self._renderedTableCells
	local first = renderedCells and renderedCells[1]
	if not first then return nil end
	return renderedCells[ index - first._index + 1 ]
end


-- make the rows which are in the view (and its render margin),
-- and remove the ones which no longer are
--
function TableView:_renderDisplay( params )
	-- print( "TableView:_renderDisplay" )
	params = params or {}
	if params.clearAll==nil then params.clearAll=false end
	--==--
	local layout = self._rowLayout
	local renderedCells = self._renderedTableCells
	if not layout or not renderedCells then return end

	if params.clearAll then
		self:_unrenderAllTableCells( renderedCells )
	end
	if layout:count()==0 then return end

	local bounds = self:_viewportBounds()
	if not bounds.yMin then return end
	-- a row which the bounds cut is rendered too: with a small
	-- render margin it is partly in view
	local first, last = layout:range( bounds.yMin, bounds.yMax )

	if first==nil then
		self:_unrenderAllTableCells( renderedCells )
		return
	end

	--== Remove the rows which scrolled away ==--

	local record = renderedCells[ 1 ]
	while record and ( record._index < first or record._index > last ) do
		self:_unrenderTableCell( record, { index=1 } )
		record = renderedCells[ 1 ]
	end
	record = renderedCells[ #renderedCells ]
	while record and record._index > last do
		self:_unrenderTableCell( record, { index=#renderedCells } )
		record = renderedCells[ #renderedCells ]
	end

	--== Add rows above and below the ones there ==--

	if #renderedCells==0 then
		for i = first, last do
			self:_renderTableCell( i, { putAtHead=false } )
		end
	else
		for i = renderedCells[1]._index-1, first, -1 do
			self:_renderTableCell( i, { putAtHead=true } )
		end
		for i = renderedCells[ #renderedCells ]._index+1, last do
			self:_renderTableCell( i, { putAtHead=false } )
		end
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
-- @param index the index of a row which is not rendered
--
function TableView:_renderTableCell( index, options )
	-- print( "TableView:_renderTableCell", index )
	options = options or {}
	if options.putAtHead==nil then options.putAtHead=true end
	--==--
	local layout = self._rowLayout
	local record = createRecord( index, layout:top( index ), layout:height( index ), self:_getRowData( index ) )

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
-- @param record the record of a rendered row
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



-- the position of the list which puts a row, by its top and
-- height, at a place in the view
--
function TableView:_calculateScrollPosition( top, height, position )
	-- print( "TableView:_calculateScrollPosition", top, height, position )
	local value = 0
	local offset = 0

	if position=='top' then
		offset = 0+self.upperVerticalOffset
		value = offset-top
	elseif position=='bottom' then
		offset = self.height-self.lowerVerticalOffset
		value = offset-(top+height)
	else
		-- 'middle', and by default
		offset = self.height/2
		value = offset-top
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
		-- another row: it has a view only while it is rendered
		if type(rowIdx)~='number' or rowIdx<1 or rowIdx>self._rowLayout:count() then return end
		evt.index=rowIdx
		evt.view=self:getRowAt( rowIdx )
		evt.data=self:_getRowData( rowIdx )
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
