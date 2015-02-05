--====================================================================--
-- component/object_factory.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Monster vs Monsters : Game Object Factory
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


--== Components

local CloudFactory = require 'component.object_factory.cloud'
local GhostCharacter = require 'component.object_factory.ghost'
local MonsterCharacter = require 'component.object_factory.monster'



--====================================================================--
--== Setup, Constants


local sformat = string.format



--====================================================================--
--== Game Object Factory
--====================================================================--


local Factory = {}

-- Types

Factory.BG_ONE = 'background-one'
Factory.BG_TWO = 'background-two'

Factory.ALT_BG_ONE = 'altbackground-one'
Factory.ALT_BG_TWO = 'altbackground-two'

Factory.TREES_LEFT = 'trees-left'
Factory.TREES_RIGHT = 'trees-right'

Factory.CLOUDS_LEFT = 'clouds-left'
Factory.CLOUDS_RIGHT = 'clouds-right'

Factory.RED_GLOW = 'red-glow'
Factory.GROUND_LIGHT = 'ground-light'

Factory.LIFE_ICON = 'life-icon'
Factory.GROUND = 'ground'

Factory.MONSTER = MonsterCharacter.TYPE
Factory.GHOST = GhostCharacter.TYPE

-- Shapes

Factory.groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
Factory.tombShape = { -18,-21, 18,-21, 18,21, -18,21 }
Factory.hPlankShape = { -48,-6, 48,-6, 48,6, -48,6 }
Factory.vPlankShape = { -6,-48, 6,-48, 6,48, -6,48 }
Factory.vSlabShape = { -12,-26, 12,-26, 12,26, -12,26 }


function Factory.create( obj_type, params )
	-- print( "Factory.create : ", obj_type )
	params = params or {}
	--==--

	local o

	-- BACKGROUND ONE
	if obj_type == Factory.BG_ONE then
		o = display.newImageRect( 'assets/backgrounds/background1.png', 480, 320 )
		o.TYPE = Factory.BG_ONE

	-- BACKGROUND TWO
	elseif obj_type == Factory.BG_TWO then
		o = display.newImageRect( 'assets/backgrounds/background2.png', 480, 320 )
		o.TYPE = Factory.BG_TWO

	-- ALT BACKGROUND ONE
	elseif obj_type == Factory.ALT_BG_ONE then
		o = display.newImageRect( 'assets/backgrounds/altbackground1.png', 480, 320 )
		o.TYPE = Factory.ALT_BG_ONE

	-- ALT BACKGROUND TWO
	elseif obj_type == Factory.ALT_BG_TWO then
		o = display.newImageRect( 'assets/backgrounds/altbackground2.png', 480, 320 )
		o.TYPE = Factory.ALT_BG_TWO

	-- TREES LEFT
	elseif obj_type == Factory.TREES_LEFT then
		o = display.newImageRect( 'assets/backgrounds/trees-left.png', 480, 320 )
		o.TYPE = Factory.TREES_LEFT

	-- TREES RIGHT
	elseif obj_type == Factory.TREES_RIGHT then
		o = display.newImageRect( 'assets/backgrounds/trees-right.png', 480, 320 )
		o.TYPE = Factory.TREES_RIGHT

	-- CLOUDS LEFT
	elseif obj_type == Factory.CLOUDS_LEFT then
		o = CloudFactory.create( CloudFactory.LEFT, {game_engine=params.game_engine})
		o.TYPE = Factory.CLOUDS_LEFT

	-- CLOUDS RIGHT
	elseif obj_type == Factory.CLOUDS_RIGHT then
		o = CloudFactory.create( CloudFactory.RIGHT, {game_engine=params.game_engine})
		o.TYPE = Factory.CLOUDS_RIGHT

	-- RED GLOW
	elseif obj_type == Factory.RED_GLOW then
		o = display.newImageRect( 'assets/backgrounds/redglow.png', 480, 320 )
		o.TYPE = Factory.RED_GLOW

	-- GROUND LIGHT
	elseif obj_type == Factory.GROUND_LIGHT then
		o = display.newImageRect( 'assets/backgrounds/groundlight.png', 228, 156 )
		o.TYPE = Factory.GROUND_LIGHT

	-- LIFE ICON
	elseif obj_type == Factory.LIFE_ICON then
		o = display.newImageRect( 'assets/game_objects/lifeicon.png', 22, 22 )
		o.TYPE = Factory.LIFE_ICON


	-- GROUND ONE
	elseif obj_type == "ground-one" then
		o = display.newImageRect( 'assets/game_objects/ground1.png', 480, 76 )
		o.TYPE = Factory.GROUND
		o.physicsType = 'static'
		o.physicsProperties = { density=1.0, bounce=0, friction=0.5, shape=Factory.groundShape }

	-- GROUND TWO
	elseif obj_type == "ground-two" then
		o = display.newImageRect( 'assets/game_objects/ground2.png', 480, 76 )
		o.TYPE = Factory.GROUND
		o.physicsType = 'static'
		o.physicsProperties = { density=1.0, bounce=0, friction=0.5, shape=Factory.groundShape }

	-- GHOST
	elseif obj_type == Factory.GHOST then
		o = GhostCharacter:new{ game_engine=params.game_engine }

	-- MONSTER
	elseif obj_type == Factory.MONSTER then
		o = MonsterCharacter:new{ game_engine=params.game_engine }

	-- STONE SLAB
	elseif obj_type == "vert-slab" then
		o = display.newImageRect( 'assets/game_objects/vertical-stone.png', 28, 58 )
		o.TYPE = "stone"
		o.physicsType = 'dynamic'
		o.physicsProperties = { density=5.0, bounce=0, friction=0.5, shape=Factory.vSlabShape }

	-- WOOD PLANK - horiz
	elseif obj_type == "horiz-plank" then
		o = display.newImageRect( 'assets/game_objects/horizontal-wood.png', 98, 14 )
		o.TYPE = "wood"
		o.physicsType = 'dynamic'
		o.physicsProperties = { density=2.0, bounce=0, friction=0.5, shape=Factory.hPlankShape }

	-- WOOD PLANK -- vert
	elseif obj_type == "vert-plank" then
		o = display.newImageRect( 'assets/game_objects/vertical-wood.png', 14, 98 )
		o.TYPE = "wood"
		o.physicsType = 'dynamic'
		o.physicsProperties = { density=2.0, bounce=0, friction=0.5, shape=Factory.vPlankShape }

	-- TOMBSTONE
	elseif obj_type == "tombstone" then
		o = display.newImageRect( 'assets/game_objects/tombstone.png', 38, 46 )
		o.TYPE = "tomb"
		o.physicsType = 'dynamic'
		o.physicsProperties = { density=5.5, bounce=0, friction=0.5, shape=Factory.tombShape }

	-- ERROR
	else
		local emsg = sformat( "\n\nERROR: Game Objects Factory, unknown object '%s'\n\n", tostring( obj_type ) )
		error( emsg )
	end

	return o
end



return Factory
