--====================================================================--
-- scene/menu/level_overlay.lua
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
--== Ghost vs Monsters : Level Overlay
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"




--====================================================================--
--== Imports


local Objects = require 'lib.dmc_corona.dmc_objects'
local Utils = require 'lib.dmc_corona.dmc_utils'
local Widgets = require 'lib.dmc_widgets'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local tinsert = table.insert
local tremove = table.remove

local LOCAL_DEBUG = false



--====================================================================--
--== Level Overlay Class
--====================================================================--


local LevelOverlay = newClass( ComponentBase, {name="Level Overlay"} )

--== Event Constants

LevelOverlay.EVENT = 'level-overlay-event'

LevelOverlay.SELECTED = 'level-selected'
LevelOverlay.CANCELED = 'selection-canceled'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function LevelOverlay:__init__( params )
	self:superCall( '__init__', params )
	params = params or {}
	--==--

	--== Sanity Check

	assert( params.width and params.height, "Level Overlay requires params 'width' & 'height'")


	--== Properties

	self._width = params.width
	self._height = params.height

	-- array
	self._levels = {}

	--== Objects

	self._level_mgr = gService.level_mgr
	self._sound_mgr = gService.sound_mgr

	--== Display Objects

	self._primer = nil -- test

	self._shade = nil
	self._bg = nil

	self._btn_level1 = nil
	self._btn_level2 = nil
	self._btn_close = nil

end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function LevelOverlay:__createView__()
	self:superCall( '__createView__' )
	--==--
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, tmp

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


	-- Shading

	o = display.newRect( 0, 0, W, H )
	o.anchorX, o.anchorY = 0.5, 0
	o:setFillColor( 0, 0, 0, 0.8 )
	o.x, o.y = 0, 0

	self:insert( o )
	self._shade = o


	-- Background/text

	o = display.newImageRect( 'assets/backgrounds/levelselection.png', 328, 194 )
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = 0, 50

	self:insert( o )
	self._bg = o


	-- Level 1 Button

	tmp = self._bg
	o = Widgets.newPushButton{
		id='level-1-button',
		view='image',
		file='assets/buttons/level1btn.png',
		width=114, height=114,
		active={
			file='assets/buttons/level1btn-over.png'
		}
	}
	o.x, o.y = -(tmp.width/2)+o.width/2+40, tmp.y+tmp.height-o.height/2-25

	self:insert( o.view )
	self._btn_level1 = o


	-- Level 2 Button

	tmp = self._bg
	o = Widgets.newPushButton{
		id='level-2-button',
		view='image',
		file='assets/buttons/level2btn.png',
		width=114, height=114,
		active={
			file='assets/buttons/level2btn-over.png'
		}
	}
	o.x, o.y = (tmp.width/2)-o.width/2-40, tmp.y+tmp.height-o.height/2-25

	self:insert( o.view )
	self._btn_level2 = o


	-- Close Button

	tmp = self._bg
	o = Widgets.newPushButton{
		id='close-button',
		view='image',
		file='assets/buttons/closebtn.png',
		width=44, height=44,
		active={
			file='assets/buttons/closebtn-over.png'
		}
	}
	o.x, o.y = -(tmp.width/2)+10, tmp.y+tmp.height-10

	self:insert( o.view )
	self._btn_close = o

end
-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
--
function LevelOverlay:__undoCreateView__()
	local o

	o = self._btn_close
	o:removeSelf()
	self._btn_close = nil

	o = self._btn_level2
	o:removeSelf()
	self._btn_level2 = nil

	o = self._btn_level1
	o:removeSelf()
	self._btn_level1 = nil

	o = self._bg
	o:removeSelf()
	self._bg = nil

	o = self._shade
	o:removeSelf()
	self._shade = nil

	o = self._primer
	o:removeSelf()
	self._primer = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function LevelOverlay:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self._btn_level1.onRelease = self:createCallback( self.level1ButtonEvent_handler )
	self._btn_level2.onRelease = self:createCallback( self.level2ButtonEvent_handler )
	self._btn_close.onRelease = self:createCallback( self.cancelButtonEvent_handler )

	-- self:hide()
end

-- __undoInitComplete__()
--
function LevelOverlay:__undoInitComplete__()
	self._btn_close.onRelease = nil
	self._btn_level2.onRelease = nil
	self._btn_level1.onRelease = nil
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function LevelOverlay:cancelButtonEvent_handler( event )
	self._sound_mgr:play( self._sound_mgr.TAP )
	self:dispatchEvent( self.CANCELED )
end

function LevelOverlay:level1ButtonEvent_handler( event )
	self._sound_mgr:play( self._sound_mgr.TAP )
	local d = self._level_mgr:getLevelData( 1 )
	self:dispatchEvent( self.SELECTED, {name=d.info.name, level=d}, {merge=false}  )
end

function LevelOverlay:level2ButtonEvent_handler( event )
	self._sound_mgr:play( self._sound_mgr.TAP )
	local d = self._level_mgr:getLevelData( 'level2' )
	self:dispatchEvent( self.SELECTED, {name=d.info.name, level=d}, {merge=false} )
end




return LevelOverlay
