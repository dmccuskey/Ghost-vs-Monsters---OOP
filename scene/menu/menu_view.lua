--====================================================================--
-- scene/menu/menu_view.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Ghost vs Monsters : Main Menu View
--====================================================================--



--====================================================================--
--== Imports


-- local HUDFactory = require( "hud_objects" )
-- local levelMgr = require( "level_manager" )

local Objects = require 'lib.dmc_corona.dmc_objects'
local Utils = require 'lib.dmc_corona.dmc_utils'
local Widgets = require 'lib.dmc_widgets'

--== Services

local LevelMgr = require 'service.level_manager'
local SoundMgr = require 'service.sound_manager'

--== Components

local LevelOverlay = require 'scene.menu.level_overlay'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local LOCAL_DEBUG = false



--====================================================================--
--== Menu View Class
--====================================================================--


local MenuView = newClass( ComponentBase, {name="Menu View"} )

--== Class Constants

-- transition time value for ghost animation
MenuView.GHOST_DELAY = 400

-- y positions for ghost animation
MenuView.GHOST_POS = {
	up={y=160},
	start={y=165},
	down={y=170}
}

--== Event Constants

MenuView.EVENT = 'menu-view-event'

MenuView.SELECTED = 'button-selected'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function MenuView:__init__( params )
	print( "MenuView:__init__" )
	self:superCall( '__init__', params )
	params = params or {}
	--==--

	--== Sanity Check

	assert( params.level_mgr and params.level_mgr:isa(LevelMgr), "Menu View requires param 'level_mgr'")
	assert( params.sound_mgr and params.sound_mgr:isa(SoundMgr), "Menu View requires param 'sound_mgr'")
	assert( params.width and params.height, "Menu View requires params 'width' & 'height'")

	--== Properties

	self._width = params.width
	self._height = params.height

	self._tween_ghost = nil
	self._tween_play = nil
	self._tween_feint = nil

	--== Objects

	self._sound_mgr = params.sound_mgr
	self._level_mgr = params.level_mgr

	self._dg_main = nil
	self._dg_overlay = nil

	--== Display Objects

	self._primer = nil -- test

	self._bg = nil
	self._ghost = nil

	self._btn_play = nil
	self._btn_feint = nil

	self._view_level = nil
	self._view_level_f = nil

end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function MenuView:__createView__()
	-- print( "MenuView:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg, o, tmp

	-- setup display primer

	o = display.newRect( 0, 0, W, 10)
	o.anchorX, o.anchorY = 0.5, 0
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(1,0,0,0.75)
	end
	o.x, o.y = 0, 0

	self:insert( o )
	self._primer = o

	-- main group

	o = display.newGroup()
	self:insert( o )
	self._dg_main = o

	-- overlay group

	o = display.newGroup()
	self:insert( o )
	self._dg_overlay = o


	dg = self._dg_main

	-- background

	o = display.newImageRect( 'assets/backgrounds/mainmenu.png', W, H )
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = 0, 0

	dg:insert( o )
	self._bg = o

	-- ghost

	o = display.newImageRect( 'assets/characters/menughost.png', 50, 62 )
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = 0, 0

	dg:insert( o )
	self._ghost = o

	-- openfeint button

	o = Widgets.newPushButton{
		id='feint-button',
		view='image',
		file='assets/buttons/menuofbtn.png',
		width=118, height=88,
		active={
			file='assets/buttons/menuofbtn-over.png'
		}
	}
	o.x, o.y = 0,0
	o.isVisible=false

	dg:insert( o.view )
	self._btn_feint = o

	-- play button

	o = Widgets.newPushButton{
		id='play-button',
		view='image',
		file='assets/buttons/playbtn.png',
		width=146, height=116,
		active={
			file='assets/buttons/playbtn-over.png'
		}
	}
	o.x, o.y = 0,0
	o.isVisible=false

	dg:insert( o.view )
	self._btn_play = o

end
-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
--
function MenuView:__undoCreateView__()
	local o

	o = self._btn_play
	o:removeSelf()
	self._btn_play = nil

	o = self._btn_feint
	o:removeSelf()
	self._btn_feint = nil

	o = self._ghost
	o:removeSelf()
	self._ghost = nil

	o = self._bg
	o:removeSelf()
	self._bg = nil

	o = self._primer
	o:removeSelf()
	self._primer = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function MenuView:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self._btn_play.onRelease = self:createCallback( self.playButtonEvent_handler )
	self._btn_feint.onRelease = self:createCallback( self.feintButtonEvent_handler )

	self:_startButtonAnimations()
	self:_startGhostAnimation()
end

-- __undoInitComplete__()
--
function MenuView:__undoInitComplete__()
	self:superCall( '__undoInitComplete__' )
	self:_stopGhostAnimation()
	self:_stopButtonAnimations()

	self._btn_feint.onRelease = nil
	self._btn_play.onRelease = nil
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Private Methods


function MenuView:_startButtonAnimations()
	print( "MenuView:_startButtonAnimations" )

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local step1, step2, step3
	local o

	-- bring up and move play button
	step1 = function()

		local s1_a, s1_b, s1_c, s1_d
		local o = self._btn_play
		local Sx,Sy = 125, H+o.height/2

		s1_a = function()
			-- set starting point
			o.x, o.y = Sx, Sy
			o.isVisible=true
			s1_b()
		end
		s1_b = function()
			-- move play up
			local Dx,Dy = o.x, H-o.height/2
			local p = { time=400, x=Dx, y=Dy, onComplete=s1_c }
			self._tween_play = transition.to( o, p )
		end
		s1_c = function()
			-- move play over
			local Dx,Dy = o.x+10, o.y+5
			local p = { delay=200, time=100, x=Dx, y=Dy, onComplete=step2 }
			self._tween_play = transition.to( o, p )
		end

		s1_a()
	end

	-- bring up and move feint button
	step2 = function()
		local s2_a, s2_b, s2_c
		local o = self._btn_feint
		local Sx,Sy = 35, H+o.height/2

		s2_a = function()
			-- set starting point
			o.x, o.y = Sx, Sy
			o.isVisible=true
			s2_b()
		end
		s2_b = function()
			-- move feint up
			local Dx,Dy = o.x, H-o.height/2
			local p = { time=400, x=Dx, y=Dy, onComplete=s2_c }
			self._tween_feint = transition.to( o, p )
		end
		s2_c = function()
			-- move play over
			local Dx,Dy = o.x-10, o.y+5
			local p = { delay=200, time=100, x=Dx, y=Dy, onComplete=step3 }
			self._tween_feint = transition.to( o, p )
		end

		s2_a()
	end

	-- complete event
	step3 = function()
		self:_stopButtonAnimations()
	end

	step1() -- start animation
end

function MenuView:_stopButtonAnimations()
	print( "MenuView:_stopButtonAnimations" )
	transition.cancel( self._tween_play )
	transition.cancel( self._tween_feint )
	self._tween_play = nil
	self._tween_feint = nil
end


function MenuView:_animateGhostDown()
	print( "MenuView:_animateGhostDown" )
	local p = {
		time=MenuView.GHOST_DELAY,
		y=MenuView.GHOST_POS.down.y,
		onComplete=self:createCallback( self._animateGhostUp )
	}
	self._tween_ghost = transition.to( self._ghost, p )
end

function MenuView:_animateGhostUp()
	print( "MenuView:_animateGhostUp" )
	local p = {
		time=MenuView.GHOST_DELAY,
		y=MenuView.GHOST_POS.up.y,
		onComplete=self:createCallback( self._animateGhostDown )
	}
	self._tween_ghost = transition.to( self._ghost, p )
end


function MenuView:_startGhostAnimation()
	print( "MenuView:_startGhostAnimation" )
	self._ghost.y = MenuView.GHOST_POS.start.y
	self:_animateGhostUp()
end

function MenuView:_stopGhostAnimation()
	print( "MenuView:_stopGhostAnimation" )
	transition.cancel( self._tween_ghost )
	self._tween_ghost = nil
end


function MenuView:_createLevelOverlay()
	print( "MenuView:_createLevelOverlay" )
	if self._view_level then self:_destroyLevelOverlay() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_overlay
	local o, f

	o = LevelOverlay:new{
		width=W, height=H,
		level_mgr=self._level_mgr,
		sound_mgr=self._sound_mgr
	}
	o.x, o.y = 0, 0

	dg:insert( o.view )
	self._view_level = o

	f = Utils.createObjectCallback( self, self._levelOverlayEvent_handler )
	o:addEventListener( o.EVENT, f )

	self._view_level_f = f
end

function MenuView:_destroyLevelOverlay()
	print( "MenuView:_destroyLevelOverlay" )
	local o, f = self._view_level, self._view_level_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_level_f = nil
	end
	if o then
		o:removeSelf()
		self._view_level = nil
	end
end



--====================================================================--
--== Event Handlers


function MenuView:playButtonEvent_handler( event )
	self._sound_mgr:play( self._sound_mgr.TAP )
	self:_createLevelOverlay()
end

function MenuView:feintButtonEvent_handler( event )
	self._sound_mgr:play( self._sound_mgr.TAP )
	print( "OpenFeint Button Pressed." )

	-- Will display OpenFeint dashboard when uncommented
	-- (if OpenFeint was properly initialized in main.lua)
	-- app_token.openfeint.launchDashboard()
end

-- event handler for the Level Overlay
--
function MenuView:_levelOverlayEvent_handler( event )
	print( "MenuView:_levelOverlayEvent_handler: ", event.type )
	local target = event.target

	if event.type == target.CANCELED then
		self:_destroyLevelOverlay()
	elseif event.type == target.SELECTED then
		self:_destroyLevelOverlay()
		local data = event.data
		local name, level = data.name, data.level
		print( "level info:", data.name, data.level )
		local p = {level=level}
		self:dispatchEvent( self.SELECTED, p, {merge=false} )
	else
		print( "unknown event", event.type )
	end
end




return MenuView
