--====================================================================--
-- component/pause_screen.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--

--[[
the anchor for this view is Top Center
--]]

--====================================================================--
--== Ghost vs Monsters : Pause Overlay
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Imports


--local Facebook = require 'dmc_facebook'
local Objects = require 'lib.dmc_corona.dmc_objects'
-- local Utils = require 'lib.dmc_corona.dmc_utils'
local Widgets = require 'lib.dmc_widgets'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local LOCAL_DEBUG = false



--====================================================================--
--== Pause Overlay class
--====================================================================--


local PauseOverlay = newClass( ComponentBase, {name="Pause Overlay"} )


--== Event Constants

PauseOverlay.EVENT = 'pause-overlay-event'

PauseOverlay.ACTIVE = 'active-changed'
PauseOverlay.MENU = 'menu-selected'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function PauseOverlay:__init__( params )
	-- print( "PauseOverlay:__init__" )
	self:superCall( '__init__', params )
	--==--

	--== Properties

	self._is_paused = nil -- boolean, nil to allow setter

	--== Objects

	self._sound_mgr = gService.sound_mgr

	--== Display Objects

	self._primer = nil -- test

	self._group = nil -- display group

	self._bg = nil

	self._btn_menu = nil
	self._btn_pause = nil

end
-- __undoInit__()
--
-- function PauseOverlay:__undoInit__()
-- 	--==--
-- 	self:superCall( '__undoInit__' )
-- end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function PauseOverlay:__createView__()
	-- print( "PauseOverlay:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local BASE_YPOS = 290
	local o, dg

	-- Setup display primer

	o = display.newRect( 0, 0, 480, 10)
	o.anchorX, o.anchorY = 0.5, 0
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(1,0,0,1)
	end
	o.x, o.y = 0, 0

	self:insert( o )
	self._primer = o

	-- group for main/shade

	dg = display.newGroup()

	self:insert( dg )
	self._group = dg

	-- shade background

	o = display.newRect( 0, 0, 480, 320 )
	o.anchorX, o.anchorY = 0.5, 0
	o:setFillColor( 0,0,0 )
	o.alpha = 0.6
	o.x, o.y = 0, 0

	dg:insert( o )
	self._bg = o

	-- main menu button

	o = Widgets.newPushButton{
		id='menu-button',
		view='image',
		file='assets/buttons/pausemenubtn.png',
		width=44, height=44,
		active={
			file='assets/buttons/pausemenubtn-over.png'
		}
	}
	o.x, o.y = -200, BASE_YPOS

	dg:insert( o.view )
	self._btn_menu = o

	-- pause button

	o = Widgets.newToggleButton{
		id='pause-button',
		view='image',
		file='assets/buttons/pausebtn.png',
		width=44, height=44,
		active={
			file='assets/buttons/pausebtn-over.png'
		}
	}
	o.x, o.y = 200, BASE_YPOS

	self:insert( o.view )
	self._btn_pause = o

end
-- __undoCreateView__()
--
function PauseOverlay:__undoCreateView__()
	--print( "PauseOverlay:__undoCreateView__" )
	local o

	o = self._btn_pause
	o:removeSelf()
	self._btn_pause = nil

	o = self._btn_menu
	o:removeSelf()
	self._btn_menu = nil

	o = self._bg
	o:removeSelf()
	self._bg = nil

	o = self._group
	o:removeSelf()
	self._group = nil

	o = self._primer
	o:removeSelf()
	self._primer = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function PauseOverlay:__initComplete__()
	-- print( "PauseOverlay:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local o

	o = self._btn_pause
	o.onRelease = self:createCallback( self.pauseButtonEvent_handler )

	o = self._btn_menu
	o.onRelease = self:createCallback( self.menuButtonEvent_handler )

	self.is_active = self._btn_pause.is_active
	self:show()
end
-- __undoInitComplete__()
--
function PauseOverlay:__undoInitComplete__()
	self:hide()
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- is_active
--
function PauseOverlay.__getters:is_active()
	return self._is_paused
end
function PauseOverlay.__setters:is_active( value )
	-- print( "PauseOverlay.__setters:is_active", value )
	assert( type(value)=='boolean', "incorrect type for is_active" )
	--==--
	if self._is_paused == value then return end
	self._is_paused = value
	-- self._btn_pause.is_active = value
	self._group.isVisible = value
end


function PauseOverlay:menuConfirmation( event )
	-- print( "PauseOverlay:menuConfirmation", event.action )
	if 'clicked' == event.action then
		local i = event.index
		if i == 1 then
			self._btn_pause:press()
			-- Player clicked Yes, go to main menu
			self:dispatchEvent( self.MENU )
		end
	end
end



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function PauseOverlay:pauseButtonEvent_handler( event )
	-- print( "PauseOverlay:pauseButtonEvent_handler" )
	local btn = event.target

	self._sound_mgr:play( self._sound_mgr.TAP )

	self.is_active = btn.is_active
	self:dispatchEvent( self.ACTIVE, {is_active=btn.is_active} )
end


function PauseOverlay:menuButtonEvent_handler( event )
	-- print( "PauseOverlay:menuButtonEvent_handler" )
	local btn = event.target

	self._sound_mgr:play( self._sound_mgr.TAP )

	native.showAlert(
		"Are You Sure?",
		"Your current game will end.",
		{ "Yes", "Cancel" },
		self:createCallback( self.menuConfirmation )
	)
end




return PauseOverlay
