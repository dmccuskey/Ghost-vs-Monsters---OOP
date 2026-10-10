--====================================================================--
-- dmc_ui/dmc_widget/widget_tableview/delegate_textfield.lua
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
--== DMC Corona UI : TextField Delegate
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"


--- TextField Delegate Interface.
-- the interface for controlling a TextField via a delegate.
--
-- @classmod Delegate.TextField
-- @usage
-- local dUI = require 'dmc_ui'
--
-- -- setup delegate object
--
-- local delegate = {
--
--   shouldBeginEditing=function(self, textField)
--     return true
--   end,
--
--   onRowRender=function(self, textField)
--     return true
--   end,
--
--   onRowUnrender=function(self, textField)
--     return true
--   end,
-- }
-- @usage
-- local widget = dUI.newTextField()
-- widget.delegate = delegate
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newTextField{
--   delegate=delegate
-- }


--- (optional) ask if contents of Text Field should be cleared.
-- if the method is omitted, the text is cleared as if this method had returned `true`.
--
-- @within Methods
-- @function :shouldClearTextField
-- @param textField the Text Field containing the text.
-- @treturn bool return true to clear Text Field contents


--- (optional) ask if editing should begin in the specified Text Field.
-- if the method is omitted, the edit is Started as if this method had returned `true`.
--
-- @within Methods
-- @function :shouldBeginEditing
-- @param textField the Text Field for which editing is about to _Begin_.
-- @treturn bool return true to allow editing


--- (optional) ask if editing should end for the specified Text Field.
-- if the method is omitted, the edit is Ended as if this method had returned `true`.
--
-- @within Methods
-- @function :shouldEndEditing
-- @param textField the Text Field for which editing is about to _End_.
-- @treturn bool return true to end editing


--- (optional) ask if TextField should be updated according to changed character(s).
-- if the method is omitted, it's as if this method had returned `true`.
--
-- @within Methods
-- @function :shouldChangeCharacters
-- @param event the event table
-- @object event.target the TableView
-- @tparam string event.startPosition the location at which the change took place
-- @tparam string event.newCharacters the changed characters
-- @tparam number event.numDeleted the amount of characters deleted
-- @tparam string event.text the complete text string with changes
-- @treturn bool return true to keep the changes


