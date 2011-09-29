--====================================================================--
-- level_manager.lua
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--

--====================================================================--
-- Imports
--====================================================================--

local Objects = require( "dmc_objects" )
local Utils = require( "dmc_utils" )
local ui = require( "ui" )
local level_data = require( "level_data" )

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local CoronaBase = Objects.CoronaBase


--====================================================================--
-- Setup, Constants
--====================================================================--

local	tapSound = audio.loadSound( "assets/sounds/tapsound.wav" )

local level_manager = nil -- this will be our singleton


--====================================================================--
-- Level Manager class
--====================================================================--

local LevelManager = inheritsFrom( CoronaBase )
LevelManager.NAME = "Level Manager"


-- _init()
--
-- one of the base methods to override for dmc_objects
--
function LevelManager:_init( options )

	-- don't forget this !!!
	self:superCall( "_init" )

end


-- _createView()
--
-- one of the base methods to override for dmc_objects
--
function LevelManager:_createView()

	--== Shading

	local shadeRect = display.newRect( 0, 0, 480, 320 )
	shadeRect:setFillColor( 0, 0, 0, 255 )
	shadeRect.alpha = 0
	self:insert( shadeRect )
	transition.to( shadeRect, { time=100, alpha=0.85 } )

	--== Background

	local levelSelectionBg = display.newImageRect( "assets/backgrounds/levelselection.png", 328, 194 )
	levelSelectionBg.x = 240; levelSelectionBg.y = 160
	levelSelectionBg.isVisible = false
	self:insert( levelSelectionBg )
	timer.performWithDelay( 200, function() levelSelectionBg.isVisible = true; end, 1 )

	--== Level 1 Button

	local level1Btn = ui.newButton{
		defaultSrc = "assets/buttons/level1btn.png",
		defaultX = 114,
		defaultY = 114,
		overSrc = "assets/buttons/level1btn-over.png",
		overX = 114,
		overY = 114,
		onEvent = Utils.createObjectCallback( self, self.level1ButtonHandler ),
		id = "Level1Button",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 16,
		emboss = false
	}

	level1Btn.x = 174 level1Btn.y = 175
	level1Btn.isVisible = false

	self:insert( level1Btn )
	timer.performWithDelay( 200, function() level1Btn.isVisible = true; end, 1 )

	--== Level 2 Button

	local level2Btn = ui.newButton{
		defaultSrc = "assets/buttons/level2btn.png",
		defaultX = 114,
		defaultY = 114,
		overSrc = "assets/buttons/level2btn-over.png",
		overX = 114,
		overY = 114,
		onEvent = Utils.createObjectCallback( self, self.level2ButtonHandler ),
		id = "Level2Button",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 16,
		emboss = false
	}

	level2Btn.x = level1Btn.x + 134; level2Btn.y = 175
	level2Btn.isVisible = false

	self:insert( level2Btn )
	timer.performWithDelay( 200, function() level2Btn.isVisible = true; end, 1 )

	--== Close Button

	local closeBtn = ui.newButton{
		defaultSrc = "assets/buttons/closebtn.png",
		defaultX = 44,
		defaultY = 44,
		overSrc = "assets/buttons/closebtn-over.png",
		overX = 44,
		overY = 44,
		onEvent = Utils.createObjectCallback( self, self.cancelButtonHandler ),
		id = "CloseButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 16,
		emboss = false
	}

	closeBtn.x = 85; closeBtn.y = 245
	closeBtn.isVisible = false

	self:insert( closeBtn )
	timer.performWithDelay( 201, function() closeBtn.isVisible = true; end, 1 )

	self:hide()

end
-- _undoCreateView()
--
-- one of the base methods to override for dmc_objects
--
function LevelManager:_undoCreateView()
	for i=self.display.numChildren, 1, -1 do
		self.display[ i ]:removeSelf()
	end
end


--== Class Methods


function LevelManager:cancelButtonHandler( event )
	if event.phase == "release" then
		audio.play( tapSound )
		self:dispatchEvent( { name="level", type="cancelled" } )
	end

	return true
end

function LevelManager:level1ButtonHandler( event )
	if event.phase == "release" then
		audio.play( tapSound )
		self:dispatchEvent( { name="level", type="selected", data=level_data[ 'level1' ] } )
	end

	return true
end

function LevelManager:level2ButtonHandler( event )
	if event.phase == "release" then
		audio.play( tapSound )
		self:dispatchEvent( { name="level", type="selected", data=level_data[ 'level2' ] } )
	end

	return true
end


function LevelManager:getLevelData( name )
	return level_data[ name ]
end

function LevelManager:getNextLevelData( currentLevelName )
	local nextLevelName = level_data[ currentLevelName ].info.nextLevel
	return self:getLevelData( nextLevelName )
end



--[[
function createLevelManagerSingleton()
	print("createLevelManagerSingleton")
	level_manager = LevelManager:new()
end
createLevelManagerSingleton()
]]--


-- create our singleton of the level manager
local lvm = nil
if not lvm then
	lvm = LevelManager:new()
end

return lvm
