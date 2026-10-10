--====================================================================--
-- dmc_ui/dmc_widget/widget_navbar/delegate_navbar.lua
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
--== DMC Corona UI : Nav Bar Delegate
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"


--- Nav Bar Delegate Interface.
-- the interface for controlling a Nav Bar via a delegate.
--
-- @classmod Delegate.NavBar
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newNavBar()
-- widget.delegate = <delgate object>
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newNavBar{
--   delegate=<delegate object>
-- }


--- (optional) asks delegate if Nav Item should be popped off stack.
-- call to the delegate to see whether the current Nav Item should be popped off the navigation stack. return boolean value.
--
-- @within Methods
-- @function :shouldPopItem
-- @param navBar the @{Widget.NavBar} object
-- @param navItem the @{Widget.NavItem} object to be popped
-- @treturn bool

--- (optional) informs delegate that Nav Item was popped off stack.
-- tells delegate that this Nav Item was popped off of the navigation stack. the delegate can respond appropriately. it is called once the Nav Item has slid off, before the Nav Bar removes it; not when shouldPopItem refused the pop.
--
-- @within Methods
-- @function :didPopItem
-- @param navBar the @{Widget.NavBar} object
-- @param navItem the @{Widget.NavItem} object which was popped

