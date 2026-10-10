--====================================================================--
-- dmc_ui/dmc_widget/widget_tableview/delegate_tableview.lua
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
--== DMC Corona UI : TableView Delegate
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"


--- TableView Delegate Interface.
-- the interface for controlling a TableView via a delegate.
--
-- @classmod Delegate.TableView
-- @usage
-- local dUI = require 'dmc_ui'
--
-- -- setup delegate object
-- local delegate = {
--   numberOfRows=function(self, tableview, section)
--     -- return row data here
--   end,
--   onRowRender=function(self, event)
--     -- create row view
--   end,
--   onRowUnrender=function(self, event)
--     -- destroy row view
--   end,
--
--   shouldHighlightRow=function(self, event)
--     return true
--   end,
--   willSelectRow=function(self, event)
--     return event.index
--   end,
-- }
--
-- @usage
-- local widget = dUI.newTableView()x
-- widget.delegate = <delgate object>
--
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newTableView{
--   delegate=<delegate object>
-- }




--- description of methods for a row object.
-- the row object within the onRender/onUnrender has methods which can be used to modify some of the row attributes.
-- @within Row-Object
-- @tfield function setBackgroundColor sets the background color of the row
-- @tfield function setLineColor sets the line color of the row
-- @table .rowObjectMethods


--- (required) asks the delegate to return the number of rows to be rendered.
--
-- @within Methods
-- @function :numberOfRows
-- @param tableview the @{Widget.TableView} object
-- @param section the section in question (not yet implemented)
-- @treturn number


--- (required) asks the delegate to render the view for the row to be added to the display.
--
-- @within Methods
-- @function :onRowRender
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.RENDER_ROW`)
-- @object event.target the @{Widget.TableView} object
-- @object event.row the row object @{rowObjectMethods}
-- @object event.view the row's Display Group, for visual items
-- @tparam number event.index the index of the row inside of the TableView
-- @tab event.data a table for general data storage for the row.


--- (required) asks the delegate to unrender the view for the row to be removed from the display.
--
-- @within Methods
-- @function :onRowUnrender
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.UNRENDER_ROW`)
-- @object event.target the @{Widget.TableView} object
-- @object event.row the row object @{rowObjectMethods}
-- @object event.view the row's Display Group, for visual items
-- @tparam number event.index the index of the row inside of the TableView
-- @tab event.data a table for general data storage for the row.


--- (optional) asks delegate if specified row should be highlighted.
-- return true if row should be highlighted otherwise return false if not. if this method is not implemented, the default return value is true.
--
-- @within Methods
-- @function :shouldHighlightRow
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.SHOULD_HIGHLIGHT_ROW`)
-- @object event.target the TableView
-- @tparam number event.index the index of the row inside of the TableView
-- @object event.view the row's Display Group, for visual items
-- @tab event.data a table for general data storage for the row.
-- @treturn bool true if row should be highlighted.


--- (optional) informs delegate that row was highlighted.
--
-- @within Methods
-- @function :didHighlightRow
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.HIGHLIGHT_ROW`)
-- @object event.target the TableView
-- @tparam number event.index the index of the row inside of the TableView
-- @object event.view the row's Display Group, for visual items
-- @tab event.data a table for general data storage for the row.


--- (optional) informs delegate that row has been unhighlighted.
--
-- @within Methods
-- @function :didUnhighlightRow
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.UNHIGHLIGHT_ROW`)
-- @object event.target the TableView
-- @tparam number event.index the index of the row inside of the TableView
-- @object event.view the row's Display Group, for visual items
-- @tab event.data a table for general data storage for the row.


--- (optional) asks delegate if specified row should be selected.
-- this method must either return the `index` given (to select that row), an alternate `index` (to select another row) or `nil` to not select anything. if this method is not implemented, the default return value is the index passed in.
--
-- @within Methods
-- @function :willSelectRow
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.WILL_SELECT_ROW`)
-- @object event.target the TableView
-- @tparam number event.index the index of the row inside of the TableView
-- @object event.view the row's Display Group, for visual items
-- @tab event.data a table for general data storage for the row.
-- @return index passed in, a different index, or nil


--- (optional) informs delegate that Nav Item was popped off stack.
-- tells delegate that this Nav Item was popped off of the navigation stack. the delegate can respond appropriately.
--
-- @within Methods
-- @function :didSelectRow
-- @param event the event table
-- @tparam string event.name the event name (`TableView.EVENT`)
-- @tparam string event.type the event type (`TableView.SELECTED_ROW`)
-- @object event.target the TableView
-- @tparam number event.index the index of the row inside of the TableView
-- @object event.view the row's Display Group, for visual items
-- @tab event.data a table for general data storage for the row.


--- (optional) informs delegate that the list starts to scroll.
-- by touch or from code (`scrollToRowAt`, `setContentPosition`).
--
-- @within Methods
-- @function :willBeginScrolling
-- @param event the event table
-- @object event.target the TableView
-- @tparam number event.x always 0
-- @tparam number event.y the position of the list: 0 at the top, negative as it scrolls
-- @tparam string event.verticalLimit `HIT_TOP_LIMIT` or `HIT_BOTTOM_LIMIT` when the list is at or past that end, otherwise nil


--- (optional) informs delegate that the list has moved.
-- called for each move, about once a frame while scrolling.
--
-- @within Methods
-- @function :didScroll
-- @param event the event table, as in @{willBeginScrolling}


--- (optional) informs delegate that the list has come to rest.
--
-- @within Methods
-- @function :didEndScrolling
-- @param event the event table, as in @{willBeginScrolling}

