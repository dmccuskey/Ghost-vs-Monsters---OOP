--====================================================================--
-- manager/keyboard_mgr.lua
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
--== DMC Corona UI : Keyboard Manager
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
--== DMC UI : Keyboard Manager
--====================================================================--



--====================================================================--
--== Imports


local EventsMixModule = require 'dmc_events_mix'



--====================================================================--
--== Setup, Constants


local tcancel = timer.cancel
local tdelay = timer.performWithDelay
local trto = transition.to
local trcancel = transition.cancel

--== To be set in initialize()
local dUI = nil



--===================================================================--
--== Support Functions

local function getSystemOrientation()
	return string.find( system.orientation, 'landscape' )
end

local function getPlatformKeyboardHeight()
	local isLandscape = getSystemOrientation()
	if isLandscape then
		return display.pixelWidth*0.475
	else
		return display.pixelHeight*0.25
	end
end

local function getActualKeyboardHeight()
	local isLandscape = getSystemOrientation()
	local scale
	if isLandscape then
		scale = display.pixelWidth/display.actualContentHeight
	else
		scale = display.pixelWidth/display.actualContentWidth
	end

	local h = getPlatformKeyboardHeight()
	return h/scale
end

local function getPlatformKeyboardTransitionTime()
	return 300
end


local function calculateYOffset( obj )
	local _, y = obj:localToContent( 0, 0 )
	local adjH = obj.height*0.5
	local bottom = y+adjH
	local kbActualH = getActualKeyboardHeight()
	-- top of the keyboard, in content coordinates like y
	local keyboardY = display.screenOriginY + display.actualContentHeight - kbActualH
	return (keyboardY-bottom)
end



--====================================================================--
--== Keyboard Manager Class
--====================================================================--


local KeyboardMgr = {}

EventsMixModule.patch( KeyboardMgr )

--== Keyboard Status Constants


--== Event/Status Constants

KeyboardMgr.EVENT = 'keyboard-mgr-event'

KeyboardMgr.SHOWN = 'shown'
KeyboardMgr.SHOWING = 'showing'
KeyboardMgr.HIDING = 'hiding'
KeyboardMgr.HIDDEN = 'hidden'

--== Class properties

KeyboardMgr._KB_HEIGHT = 0
KeyboardMgr._KB_TRANS = 0

KeyboardMgr._focus_count = 0
KeyboardMgr._start_focus_timer = nil
KeyboardMgr._stop_focus_timer = nil
KeyboardMgr._keyboard_status = ''
KeyboardMgr._trans_timer = nil



--====================================================================--
--== Static Functions


function KeyboardMgr.initialize( manager, params )
	-- params = params or {}
	--==--
	dUI = manager

	KeyboardMgr._keyboard_status = KeyboardMgr.HIDDEN

	KeyboardMgr._KB_HEIGHT = getPlatformKeyboardHeight()
	KeyboardMgr._KB_TRANS = getPlatformKeyboardTransitionTime()

	dUI.KEYBOARD_SHOWING = KeyboardMgr.SHOWING
	dUI.KEYBOARD_HIDING = KeyboardMgr.HIDING

	--== Add API calls

	dUI.adjustForKeyboard = KeyboardMgr.adjustForKeyboard
	dUI.cancelAdjustForKeyboard = KeyboardMgr.cancelAdjustForKeyboard
	dUI.getKeyboardStatus = KeyboardMgr.getKeyboardStatus
	dUI.setKeyboardFocus = KeyboardMgr.setKeyboardFocus
	dUI.unsetKeyboardFocus = KeyboardMgr.unsetKeyboardFocus

end



--====================================================================--
--== Public Functions


function KeyboardMgr.adjustForKeyboard( obj, params )
	-- print( "KeyboardMgr.adjustForKeyboard", obj )
	assert( obj and obj.localToContent )
	params = params or {}
	if params.offset==nil then params.offset=0 end
	--==--
	local proxy = params.proxy or obj

	local HEIGHT = KeyboardMgr._KB_HEIGHT
	local TIME = KeyboardMgr._KB_TRANS

	local data = obj.__keymgr

	if data and data.phase==KeyboardMgr.HIDING then
		-- keyboard back while sliding down: slide up again, to where
		-- the first call put it (the proxy has moved by obj.y-data.y)
		local callback
		local offset = calculateYOffset( proxy ) + (obj.y-data.y) + params.offset

		callback = function(e)
			data.trans=nil
		end
		if data.trans then
			trcancel( data.trans )
			data.trans=nil
		end
		data.phase=KeyboardMgr.SHOWING
		if offset < 0 then
			data.trans = trto( obj, {y=data.y+offset, time=TIME, onComplete=callback })
		else
			data.trans = trto( obj, {y=data.y, time=TIME, onComplete=callback })
		end

	elseif data then
		-- keyboard to hide
		local callback

		callback = function(e)
			obj.__keymgr=nil
		end
		if data.trans then
			trcancel( data.trans )
		end
		data.phase=KeyboardMgr.HIDING
		data.trans = trto( obj, {y=data.y, time=TIME, onComplete=callback })

	else
		-- keyboard to show
		local data, callback
		local offset = calculateYOffset( proxy ) + params.offset

		callback = function(e)
			data.trans=nil
		end
		data = {
			y=obj.y,
			phase=KeyboardMgr.SHOWING,
			trans=nil
		}
		if offset < 0 then
			data.trans = trto( obj, {y=data.y+offset, time=TIME, onComplete=callback })
		end

		obj.__keymgr = data

	end

end

function KeyboardMgr.cancelAdjustForKeyboard( obj )
	local data = obj.__keymgr
	if not data then return end

	if data.trans then
		trcancel( data.trans )
	end
	obj.__keymgr=nil
end

function KeyboardMgr.getKeyboardStatus()
	return KeyboardMgr._keyboard_status
end

function KeyboardMgr.setKeyboardFocus( obj )
	-- print( "KeyboardMgr.setKeyboardFocus", obj )
	KeyboardMgr._startKeyboardFocus( obj )
end

function KeyboardMgr.unsetKeyboardFocus()
	-- print( "KeyboardMgr.unsetKeyboardFocus" )
	KeyboardMgr._stopKeyboardFocus()
end



--====================================================================--
--== Private Functions



function KeyboardMgr._startKeyboardFocus( obj )
	-- print( "KeyboardMgr._startKeyboardFocus", obj )
	--==--
	KeyboardMgr._cancelStopKeyboardFocus()
	KeyboardMgr._cancelStartKeyboardFocus()

	local count = KeyboardMgr._focus_count
	count = count + 1
	local f = function()
		local status = KeyboardMgr._keyboard_status
		native.setKeyboardFocus( obj )
		KeyboardMgr._keyboard_status = KeyboardMgr.SHOWN
		KeyboardMgr._start_focus_timer=nil
		-- back while hiding: it won't be hidden
		if KeyboardMgr._trans_timer then
			tcancel( KeyboardMgr._trans_timer )
			KeyboardMgr._trans_timer = nil
		end
		-- the focus moved to another field: the keyboard stays up
		if status==KeyboardMgr.SHOWN then return end
		KeyboardMgr._dispatchKeyboardStatus( KeyboardMgr.SHOWING )
	end
	KeyboardMgr._focus_count = count
	KeyboardMgr._start_focus_timer = tdelay( 2, f )

end

function KeyboardMgr:_cancelStartKeyboardFocus()
	-- print( "KeyboardMgr:_cancelStartKeyboardFocus" )
	local t = KeyboardMgr._start_focus_timer
	if not t then return end
	tcancel( t )
	KeyboardMgr._start_focus_timer = nil
end


function KeyboardMgr:_stopKeyboardFocus()
	-- print( "KeyboardMgr:_stopKeyboardFocus" )
	local TIME = KeyboardMgr._KB_TRANS

	KeyboardMgr._cancelStopKeyboardFocus()
	local count = KeyboardMgr._focus_count
	if count > 0 then count = count-1 end
	local hiding_f, hidden_f

	hidden_f = function()
		-- after keyboard transition complete
		KeyboardMgr._keyboard_status = KeyboardMgr.HIDDEN
		KeyboardMgr._dispatchKeyboardStatus()
		KeyboardMgr._trans_timer = nil
	end

	hiding_f = function()
		-- start keyboard transition
		if KeyboardMgr._focus_count==0 then
			local status = KeyboardMgr._keyboard_status
			native.setKeyboardFocus( nil )
			if status==KeyboardMgr.SHOWING or status==KeyboardMgr.SHOWN then
				KeyboardMgr._keyboard_status = KeyboardMgr.HIDING
				KeyboardMgr._dispatchKeyboardStatus()
				KeyboardMgr._trans_timer = tdelay( TIME, hidden_f )
			end
		end
		KeyboardMgr._stop_focus_timer=nil
	end
	KeyboardMgr._focus_count = count
	KeyboardMgr._stop_focus_timer = tdelay( 2, hiding_f )
end

function KeyboardMgr:_cancelStopKeyboardFocus()
	-- print( "KeyboardMgr:_cancelStopKeyboardFocus" )
	local t = KeyboardMgr._stop_focus_timer
	if not t then return end
	tcancel( t )
	KeyboardMgr._stop_focus_timer = nil
end





function KeyboardMgr._dispatchKeyboardStatus( status )
	-- print( "KeyboardMgr._dispatchKeyboardStatus", status )
	if status==nil then status=KeyboardMgr._keyboard_status end
	local data = { isDone='hello' }
	KeyboardMgr:dispatchEvent( status, data, {merge=true} )
end



--====================================================================--
--== Event Handlers


-- none



return KeyboardMgr
