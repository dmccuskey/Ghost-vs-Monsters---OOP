--====================================================================--
-- component/object_factory/ghost.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Monster vs Monsters : Monster Character
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Objects = require 'lib.dmc_corona.dmc_objects'
local Utils = require 'lib.dmc_corona.dmc_utils'

local MovieClip = require 'lib.movieclip'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local PhysicsComponentBase = Objects.PhysicsComponentBase

local LOCAL_DEBUG = true



--====================================================================--
--== Monster Character Class
--====================================================================--


local Monster = newClass( PhysicsComponentBase, {name="A Monster"} )

--== Class Constants

Monster.TYPE = 'monster'

--== Event Constants

Monster.EVENT = 'monster-character-event'

Monster.STATE_DEAD = 'character-dead'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function Monster:__init__( params )
	-- print( "Monster:__init__", params )
	params = params or {}
	self:superCall( PhysicsComponentBase, '__init__', params )
	--==--

	--== Sanity Check

	assert( params.game_engine, "Monster requires params 'game_engine'")

	--== Properties

	self._is_hit = false

	--== Objects

	self._sound_mgr = gService.sound_mgr

	self._game_engine = params.game_engine
	self._game_engine_f = nil

	--== Physics Properties

	self.isBodyActive = true
	self.physicsType = 'dynamic'
	self._monsterShape = { -12,-13, 12,-13, 12,13, -12,13 }
	self.physicsProperties = { density=1.0, bounce=0.0, friction=0.5, shape=self._monsterShape }

	--== Display Objects

	self._character = nil
	self._poof = nil
end

-- __undoInit__()
--
-- function Monster:__undoInit__()
-- 	--==--
-- 	self:superCall( '__undoInit__' )
-- end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function Monster:__createView__()
	-- print( "Monster:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o

	-- monster
	o = display.newImageRect( 'assets/characters/monster.png', 26, 30 )
	self:insert( o )
	self._character = o

	-- poof
	o = display.newImageRect( 'assets/effects/greenpoof.png', 80, 70 )
	o.isVisible = false
	self:insert( o )
	self._poof = o

end

-- __undoCreateView__()
--
function Monster:__undoCreateView__()
	-- print( "Monster:__undoCreateView__" )
	local o

	o = self._poof
	o:removeSelf()
	self._poof = nil

	o = self._character
	o:removeSelf()
	self._character = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function Monster:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	local o, f

	self:addEventListener( 'postCollision', self )

	o = self._game_engine
	f = self:createCallback( self._gameEngineEvent_handler )
	o:addEventListener( o.EVENT, f )
	self._game_engine_f = f
end

-- __undoInitComplete__()
--
function Monster:__undoInitComplete__()
	-- print( "Monster:__undoInitComplete__" )

	local o, f

	o = self._game_engine
	f = self._game_engine_f
	o:removeEventListener( o.EVENT, f )
	self._game_engine_f = nil

	self:removeEventListener( 'postCollision', self )

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


function Monster:_showPoof( force )
	-- print( "Monster:_showPoof" )
	local o

	-- main image
	self._character.isVisible = false

	-- poof image
	o = self._poof
	o.alpha = 0
	o.isVisible = true

	-- animate the poof
	local fadePoof = function()
		self.isBodyActive = false
		self:dispatchEvent( Monster.STATE_DEAD, {force=force} )
		transition.to( o, { time=500, alpha=0 } )
	end
	transition.to( o, { time=50, alpha=1.0, onComplete=fadePoof } )

end



--====================================================================--
--== Event Handlers


function Monster:postCollision( event )
	-- print( "Monster:postCollision" )

	if event.force > 1.5 and self._is_hit==false then
		print( "Monster destroyed! Force: ", event.force )

		self._is_hit = true
		self._sound_mgr:play( self._sound_mgr.POOF )
		timer.performWithDelay( 10, function() self:_showPoof( event.force ) end )

		return true
	end
end


function Monster:_gameEngineEvent_handler( event )
	-- print( "Monster:_gameEngineEvent_handler ", event.type )
	local target = event.target
	local item = event.item
	Utils.print( event )

	if event.type == target.CHARACTER_REMOVED and item==self then
		-- self:removeSelf()

	end

end



return Monster
