--====================================================================--
-- game_objects.lua
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
local movieclip = require( "movieclip" )
local Utils = require( "dmc_utils" )

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local CoronaPhysics = Objects.CoronaPhysics

local GameEngineConstants = require( "game_engine_constants" )

--====================================================================--
-- Setup, Constants
--====================================================================--

local IMPACT_SOUND = audio.loadSound( "assets/sounds/impact.wav" )


--====================================================================--
-- Ghost Character class
--====================================================================--

local GhostCharacter = inheritsFrom( CoronaPhysics )
GhostCharacter.NAME = "A Ghost"

-- Dispatched Event Name
GhostCharacter.UPDATE_EVENT = "characterUpdateEvent"

-- Event Types
GhostCharacter.STATE_CONCEIVED = "state_conceived"
GhostCharacter.STATE_BORN = "state_born"
GhostCharacter.STATE_LIVING = "state_living"
GhostCharacter.STATE_AIMING = "state_aiming"
GhostCharacter.STATE_FLYING = "state_flying"
GhostCharacter.STATE_HIT = "state_hit"
GhostCharacter.STATE_DYING = "state_dying"
GhostCharacter.STATE_DEAD = "state_dead"

-- Audio Sounds
GhostCharacter.POOF_SOUND = audio.loadSound( "assets/sounds/ghostpoof.wav" )
GhostCharacter.WEE_SOUND = audio.loadSound( "assets/sounds/wee.wav" )

-- _init()
--
function GhostCharacter:_init( gameEngine )
	--print ("GhostCharacter:_init()")

	-- don't forget this !!!
	self:superCall( "_init" )
	self.myName = "ghost"

	self.layer = {}
	self._isActive = true
	self._gameEngine = gameEngine

	self._isOffscreen = false
	self._isAnimating = false
	self._isHit = false
	self.rotation = 0

	self._currState = nil -- ref to state method
	self._currStateName = "" -- name of state method

	-- Physics Properties
	self.isBullet = true
	self.radius = 12
	self.physicsType = "static"
	self.physicsProperties = { density=1.0, bounce=0.4, friction=0.15, radius=self.radius }

	self:_setState( GhostCharacter.STATE_CONCEIVED )

end
function GhostCharacter:_undoInit()
	self.layer = nil
	Utils.destroy( self.physicsProperties )
	self._gameEngine = nil

end


-- _createView()
--
function GhostCharacter:_createView()
	--print ("GhostCharacter:_createView()")

	local layer = self.layer
	local img

	img = movieclip.newAnim({ "assets/characters/ghost1-waiting.png", "assets/characters/ghost1.png" }, 26, 26 )
	layer.character = img
	self:insert( img )

	-- Create the Blast Glow
	img = display.newImageRect( "assets/effects/blastglow.png", 54, 54 )
	img.x = -7; img.y = 8
	img.isVisible = false
	layer.blast = img
	self:insert( img )

	-- Create Poof Objects
	img = display.newImageRect( "assets/effects/poof.png", 80, 70 )
	img.alpha = 1.0
	img.isVisible = false
	layer.poof = img
	self:insert( img )

end
function GhostCharacter:_undoCreateView()
	--print ("GhostCharacter:_undoCreateView()")

	self.layer.character:removeSelf()
	self.layer.character = nil
	self.layer.blast:removeSelf()
	self.layer.blast = nil
	self.layer.poof:removeSelf()
	self.layer.poof = nil
end


-- _initComplete()
--
function GhostCharacter:_initComplete()
	--print ("GhostCharacter:_initComplete()")

	self:changeImage( 1 )
	self:addEventListener( "collision", self )
	Runtime:addEventListener( "enterFrame", self )
	self._gameEngine:addEventListener( GameEngineConstants.GAME_ENGINE_EVENT, self )

	self:_gotoState( GhostCharacter.STATE_BORN )
end
-- _undoInitComplete()
--
function GhostCharacter:_undoInitComplete()
	--print ("GhostCharacter:_undoInitComplete()")
	self:removeEventListener( "collision", self )
	Runtime:removeEventListener( "enterFrame", self )

	self._gameEngine:removeEventListener( GameEngineConstants.GAME_ENGINE_EVENT, self )
end


-- applyForce( xForce, yForce, bodyX, bodyY )
--
function GhostCharacter:applyForce( ... )

	self:_gotoState( GhostCharacter.STATE_FLYING )

	self:superCall( "applyForce", ... )
end


--==

function GhostCharacter.__getters:isAnimating()
	return self._isAnimating
end
function GhostCharacter.__setters:isAnimating( value )
	--print( "GhostCharacter.__setters:isAnimating" )
	self._isAnimating = value

	if self._ghostTween or ( not value and self._ghostTween ) then
		transition.cancel( self._ghostTween )
		self._ghostTween = nil
	end
	if value then
		self:doGhostAnimation()
	end
end

function GhostCharacter.__getters:isOffscreen()
	return self._isOffscreen
end
function GhostCharacter.__setters:isOffscreen( value )
	--print( "GhostCharacter.__setters:isOffscreen" )

	self._isOffscreen = value
	self:_gotoState( GhostCharacter.STATE_DYING )

end
function GhostCharacter.__getters:isHit()
	return self._isHit
end
function GhostCharacter.__setters:isHit( value )
	self._isHit = value
end


function GhostCharacter:changeImage( value )
	self.layer.character:stopAtFrame( value )
end


function GhostCharacter:doGhostAnimation( event )

	local lY = ( self.y == 190 ) and 200 or 190

	if self._ghostTween then
		transition.cancel( self._ghostTween )
	end
	self._ghostTween = transition.to( self, { time=375, y=lY, onComplete=Utils.createObjectCallback( self, self.doGhostAnimation ) })
end


--======================================================--
--== START: GHOST STATE MACHINE

function GhostCharacter:_gotoState( state, ... )
	--print( "GhostCharacter:_gotoState : " .. state )
	self:_currState( state, ... )
end

function GhostCharacter:_setState( state )
	--print( "GhostCharacter: NOW IN : " .. state )
	local f = self[ state ]
	if f then
		self._currState = f
		self._currStateName = state
	else
		print( "\n\nERROR: " .. tostring( state ) .. "\n\n")
	end
end


-- state_conceived()
-- handles transition effects for birth
--
function GhostCharacter:state_conceived( nextState )

	if nextState == GhostCharacter.STATE_BORN then

		self.x = 150 ; self.y = 300

		local f = function()
			-- set new state
			self:_setState( GhostCharacter.STATE_BORN )
			self:_dispatchAnEvent( GhostCharacter.STATE_BORN )

			-- next state
			self:_gotoState( GhostCharacter.STATE_LIVING )
		end

		transition.to( self, { time=1000, y=195, transition=easing.inOutExpo, onComplete=f })
	end
end
-- state_born()
-- handles effects for Living
--
function GhostCharacter:state_born( nextState )

	if nextState == GhostCharacter.STATE_LIVING then
		self.isAnimating = true

		-- set new state
		self:_setState( GhostCharacter.STATE_LIVING )
		self:_dispatchAnEvent( GhostCharacter.STATE_LIVING )
	end

end
-- state_living()
-- handles effects for AIMING (FUTURE)
--
function GhostCharacter:state_living( nextState )

	if nextState == GhostCharacter.STATE_AIMING then
		self.isAnimating = false
		self.y = 195

		-- set new state
		self:_setState( GhostCharacter.STATE_AIMING )
		self:_dispatchAnEvent( GhostCharacter.STATE_AIMING )
	end

end
-- state_aiming()
-- handles effects for FLYING
--
function GhostCharacter:state_aiming( nextState )
	if nextState == GhostCharacter.STATE_FLYING then
		-- visual
		self.layer.blast.isVisible = true
		self:changeImage( 2 )

		-- physics
		self.bodyType = "dynamic"
		self.isBodyActive = true

		-- audio
		audio.play( GhostCharacter.WEE_SOUND )

		-- set new state
		self:_setState( GhostCharacter.STATE_FLYING )
		self:_dispatchAnEvent( GhostCharacter.STATE_FLYING )
	end

end
-- state_flying()
-- handles effects for HIT or DYING
--
function GhostCharacter:state_flying( nextState, event )

	if nextState == GhostCharacter.STATE_HIT then

		-- object properties
		self.isHit = true
		self.layer.blast.isVisible = false

		-- visual - prepare poof
		local pList = { "wood", "stone", "tomb", "monster" }
		local delay = 1700
		if Utils.propertyIn( pList, event.other.myName ) then
			delay = 500
		end
		timer.performWithDelay( delay, function() self:_gotoState( GhostCharacter.STATE_DYING ) end, 1 )

		-- set new state
		self:_setState( GhostCharacter.STATE_HIT )
		self:_dispatchAnEvent( GhostCharacter.STATE_HIT )

	elseif nextState == GhostCharacter.STATE_DYING then
		-- set new state
		self:_setState( GhostCharacter.STATE_DYING )
		self:_dispatchAnEvent( GhostCharacter.STATE_DYING )

		-- goto next state
		timer.performWithDelay( 10, function() self:_gotoState( GhostCharacter.STATE_DEAD ) end, 1 )
	end
end
-- state_hit()
-- handles effects for DYING
--
function GhostCharacter:state_hit( nextState, event )

	if nextState == GhostCharacter.STATE_DYING then

		-- object properties
		self:setLinearVelocity( 0, 0 )
		self.bodyType = "static"
		self.isBodyActive = false
		self.rotation = 0

		-- ghost image
		self.layer.character.isVisible = false

		-- poof image
		local poof = self.layer.poof
		poof.isVisible = true
		poof.alpha = 0

		local fadePoof = function()
			transition.to( poof, { time=2000, alpha=0 } )
			self:_gotoState( GhostCharacter.STATE_DEAD )
		end
		transition.to( poof, { time=100, alpha=1.0, onComplete=fadePoof } )

		audio.play( GhostCharacter.POOF_SOUND )

		-- set new state
		self:_setState( GhostCharacter.STATE_DYING )
		self:_dispatchAnEvent( GhostCharacter.STATE_DYING )
	end

end
-- state_dying()
-- handles effects for state DEAD
--
function GhostCharacter:state_dying( nextState, event )

	if nextState == GhostCharacter.STATE_DEAD then
		-- set new state
		self:_setState( GhostCharacter.STATE_DEAD )
		self:_dispatchAnEvent( GhostCharacter.STATE_DEAD )
	end
end
-- state_dead()
-- handles cleanup for CLEAN
--
function GhostCharacter:state_dead( nextState, event )

end

--== END: GHOST STATE MACHINE
--======================================================--

function GhostCharacter:collision( event )
	--print( "GhostCharacter:collision" )

	if event.phase == "began" then

		audio.play( IMPACT_SOUND )

		if self.isHit then
			return true
		else
			timer.performWithDelay( 10, self:_gotoState( GhostCharacter.STATE_HIT, event ) )

			return true
		end
	end
end

function GhostCharacter:enterFrame( event )

	local currState = self._currStateName

	-- MAKE SURE GHOST's Rotation Doesn't Go Past Limits
	if self._isActive and currState == GhostCharacter.STATE_FLYING or currState == GhostCharacter.STATE_HIT then
		if self.rotation < -45 then
			self.rotation = -45
		elseif self.rotation > 30 then
			self.rotation = 30
		end
	end
end

function GhostCharacter:gameEngineEvent( event )
	--print( "GhostCharacter:gameEngineEvent " .. event.type )

	if event.type == GameEngineConstants.AIMING_SHOT then
		self:_gotoState( GhostCharacter.STATE_AIMING )

	elseif event.type == GameEngineConstants.GAME_ISACTIVE then
		self.isAnimating = event.value
		self._isActive = value

	elseif event.type == GameEngineConstants.CHARACTER_REMOVED and event.target == self then
		self:removeSelf()

	end

end

function GhostCharacter:_dispatchAnEvent( eventType, eventParams )
	--print( "GhostCharacter._dispatchAnEvent : " .. eventType )
	local e = {
		name=GhostCharacter.UPDATE_EVENT,
		type=eventType,
		target=self,
	}

	self:dispatchEvent( e )
end


--====================================================================--
-- Monster Character class
--====================================================================--

local MonsterCharacter = inheritsFrom( CoronaPhysics )
MonsterCharacter.NAME = "A Monster"

-- Dispatched Event Name
MonsterCharacter.UPDATE_EVENT = "characterUpdateEvent"

MonsterCharacter.STATE_DYING = "state_dying"
MonsterCharacter.STATE_DEAD = "state_dead"

MonsterCharacter.POOF_SOUND = audio.loadSound( "assets/sounds/monsterpoof.wav" )


-- _init()
--
function MonsterCharacter:_init( gameEngine )
	--print ("MonsterCharacter:_init()")

	-- don't forget this !!!
	self:superCall( "_init" )

	self.layer = {}

	self.isHit = false
	self._gameEngine = gameEngine

	-- Physics Properties
	self.myName = "monster"
	self.physicsType = "dynamic"
	self.monsterShape = { -12,-13, 12,-13, 12,13, -12,13 }
	self.physicsProperties = { density=1.0, bounce=0.0, friction=0.5, shape=self.monsterShape }

end
-- _undoInit()
--
function MonsterCharacter:_undoInit()
	self.monsterShape = nil
	self._gameEngine = nil
	Utils.destroy( self.physicsProperties )
	Utils.destroy( self.layers )
end


-- _createView()
--
function MonsterCharacter:_createView()
	--print ("GhostCharacter:_createView()")

	local layer = self.layer
	local img

	img = display.newImageRect( "assets/characters/monster.png", 26, 30 )
	layer.character = img
	self:insert( img )

	-- Create Poof Objects
	img = display.newImageRect( "assets/effects/greenpoof.png", 80, 70 )
	img.isVisible = false
	layer.poof = img
	self:insert( img )

end
-- _createView()
--
function MonsterCharacter:_undoCreateView()
	-- createView
	self.layer.character:removeSelf()
	self.layer.character = nil
	self.layer.poof:removeSelf()
	self.layer.poof = nil
end

-- _initComplete()
--
function MonsterCharacter:_initComplete()
	--print ("MonsterCharacter:_initComplete()")

	self._gameEngine:addEventListener( GameEngineConstants.GAME_ENGINE_EVENT, self )
	self:addEventListener( "postCollision", self )
end
-- _undoInitComplete()
--
function MonsterCharacter:_undoInitComplete()
	self._gameEngine:removeEventListener( GameEngineConstants.GAME_ENGINE_EVENT, self )
	self:removeEventListener( "postCollision", self )
end


--== Class Methods


function MonsterCharacter:postCollision( event )
	--print( "MonsterCharacter.postCollision" )

	if event.force > 1.5 and self.isHit == false then

		print( "Monster destroyed! Force: " .. event.force )

		audio.play( MonsterCharacter.POOF_SOUND )

		self.isHit = true

		timer.performWithDelay( 10, function() self:showPoof( event.force ); end )

		return true
	end
end


function MonsterCharacter:showPoof( collisionForce )
	--print( "MonsterCharacter.showPoof" )

	-- main image
	self.layer.character.isVisible = false

	-- poof image
	local poof = self.layer.poof
	poof.alpha = 0
	poof.isVisible = true

	-- animate the poof
	local fadePoof = function()
		self.isBodyActive = false
		self:_dispatchAnEvent( MonsterCharacter.STATE_DEAD, { force=collisionForce })
		transition.to( poof, { time=500, alpha=0 } )
	end
	transition.to( poof, { time=50, alpha=1.0, onComplete=fadePoof } )

end

function MonsterCharacter:gameEngineEvent( event )
	--print( "MonsterCharacter:gameEngineEvent " .. event.type )

	if event.type == GameEngineConstants.CHARACTER_REMOVED and event.target == self then
		self:removeSelf()
		return true
	end

end

function MonsterCharacter:_dispatchAnEvent( eventType, eventParams )
	--print( "MonsterCharacter._dispatchAnEvent : " .. eventType )

	local e = {
		name=MonsterCharacter.UPDATE_EVENT,
		type=eventType,
		target=self
	}

	if eventType == MonsterCharacter.STATE_DEAD then
		e.force = eventParams.force
	end

	self:dispatchEvent( e )
end


--====================================================================--
-- Cloud class
--====================================================================--

local Cloud = inheritsFrom( CoronaPhysics )
Cloud.NAME = "Cloud"

function Cloud:new( options, gameEngine )

	local o = self:_bless()
	o:_init( options, gameEngine )
	if options ~= nil then
		o:_createView( options )
		o:_initComplete()
	end

	return o
end

-- _init()
--
function Cloud:_init( options, gameEngine )

	self:superCall( "_init" )

	self._isActive = true
	self._gameEngine = gameEngine

end
-- _undoInit()
--
function Cloud:_undoInit()
	self._isActive = nil
	self._gameEngine = nil
end


-- _createView()
--
function Cloud:_createView( file )
	--print ("Cloud:_createView()")
	self:_setDisplay( display.newImageRect( file, 480, 320 ) )
end

-- _initComplete()
--
function Cloud:_initComplete()
	--print ("Cloud:_initComplete()")

	self._gameEngine:addEventListener( GameEngineConstants.GAME_ENGINE_EVENT, self )
	Runtime:addEventListener( "enterFrame", self )
end
-- _undoInitComplete()
--
function Cloud:_undoInitComplete()
	self._gameEngine:removeEventListener( GameEngineConstants.GAME_ENGINE_EVENT, self )
	Runtime:removeEventListener( "enterFrame", self )
end


--== Class Methods


-- gameEngineEvent()
-- process events coming from the game engine
--
function Cloud:gameEngineEvent( event )
	--print ("Cloud:gameEngineEvent()")

	if event.type == GameEngineConstants.GAME_ISACTIVE then
		self._isActive = event.value
	end

end

-- enterFrame()
-- handle enterFrame events from Corona
--
function Cloud:enterFrame( event )

	-- stop motion if isActive is not set
	if not self._isActive then return end

	local cloudMoveSpeed = 0.5

	self.x = self.x - cloudMoveSpeed
	if self.x <= -240 then
		self.x = 1680
	end

	return true
end



--====================================================================--
-- Game Object Factory
--====================================================================--

local GameObjectFactory = {}

function GameObjectFactory.create( objType, gameEngine )
	--print( "GameObjectFactory.create : " .. objType )

	local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
	local vSlabShape = { -12,-26, 12,-26, 12,26, -12,26 }
	local vPlankShape = { -6,-48, 6,-48, 6,48, -6,48 }
	local hPlankShape = { -48,-6, 48,-6, 48,6, -48,6 }
	local tombShape = { -18,-21, 18,-21, 18,21, -18,21 }

	local o

	-- BACKGROUND ONE
	if objType == "background-one" then
		o = display.newImageRect( "assets/backgrounds/background1.png", 480, 320 )
		o.myName = "background-one"

	-- BACKGROUND TWO
	elseif objType == "background-two" then
		o = display.newImageRect( "assets/backgrounds/background2.png", 480, 320 )
		o.myName = "background-two"

	-- ALT BACKGROUND ONE
	elseif objType == "altbackground-one" then
		o = display.newImageRect( "assets/backgrounds/altbackground1.png", 480, 320 )
		o.myName = "altbackground-one"

	-- ALT BACKGROUND TWO
	elseif objType == "altbackground-two" then
		o = display.newImageRect( "assets/backgrounds/altbackground2.png", 480, 320 )
		o.myName = "altbackground-two"

	-- TREES LEFT
	elseif objType == "trees-left" then
		o = display.newImageRect( "assets/backgrounds/trees-left.png", 480, 320 )
		o.myName = "trees-left"

	-- TREES RIGHT
	elseif objType == "trees-right" then
		o = display.newImageRect( "assets/backgrounds/trees-right.png", 480, 320 )
		o.myName = "trees-right"

	-- CLOUDS LEFT
	elseif objType == "clouds-left" then
		--o = display.newImageRect( "assets/backgrounds/clouds-left.png", 480, 320 )
		o = Cloud:new( "assets/backgrounds/clouds-left.png", gameEngine )
		o.myName = "clouds-left"

	-- CLOUDS RIGHT
	elseif objType == "clouds-right" then
		--o = display.newImageRect( "assets/backgrounds/clouds-right.png", 480, 320 )
		o = Cloud:new( "assets/backgrounds/clouds-right.png", gameEngine )
		o.myName = "clouds-right"

	-- RED GLOW
	elseif objType == "red-glow" then
		o = display.newImageRect( "assets/backgrounds/redglow.png", 480, 320 )
		o.myName = "red-glow"

	-- GROUND LIGHT
	elseif objType == "ground-light" then
		o = display.newImageRect( "assets/backgrounds/groundlight.png", 228, 156 )
		o.myName = "ground-light"

	-- LIFE ICON
	elseif objType == "life-icon" then
		o = display.newImageRect( "assets/game_objects/lifeicon.png", 22, 22 )
		o.myName = "life-icon"


	-- GROUND ONE
	elseif objType == "ground-one" then
		o = display.newImageRect( "assets/game_objects/ground1.png", 480, 76 )
		o.myName = "ground"
		o.physicsType = "static"
		o.physicsProperties = { density=1.0, bounce=0, friction=0.5, shape=groundShape }

	-- GROUND TWO
	elseif objType == "ground-two" then
		o = display.newImageRect( "assets/game_objects/ground2.png", 480, 76 )
		o.myName = "ground"
		o.physicsType = "static"
		o.physicsProperties = { density=1.0, bounce=0, friction=0.5, shape=groundShape }

	-- GHOST
	elseif objType == "ghost" then
		o = GhostCharacter:new( gameEngine )
		o.myName = "ghost"

	-- MONSTER
	elseif objType == "monster" then
		o = MonsterCharacter:new( gameEngine )
		o.myName = "monster"

	-- STONE SLAB
	elseif objType == "vert-slab" then
		o = display.newImageRect( "assets/game_objects/vertical-stone.png", 28, 58 )
		o.myName = "stone"
		o.physicsType = "dynamic"
		o.physicsProperties = { density=5.0, bounce=0, friction=0.5, shape=vSlabShape }

	-- WOOD PLANK - horiz
	elseif objType == "horiz-plank" then
		o = display.newImageRect( "assets/game_objects/horizontal-wood.png", 98, 14 )
		o.myName = "wood"
		o.physicsType = "dynamic"
		o.physicsProperties = { density=2.0, bounce=0, friction=0.5, shape=hPlankShape }

	-- WOOD PLANK -- vert
	elseif objType == "vert-plank" then
		o = display.newImageRect( "assets/game_objects/vertical-wood.png", 14, 98 )
		o.myName = "wood"
		o.physicsType = "dynamic"
		o.physicsProperties = { density=2.0, bounce=0, friction=0.5, shape=vPlankShape }

	-- TOMBSTONE
	elseif objType == "tombstone" then
		o = display.newImageRect( "assets/game_objects/tombstone.png", 38, 46 )
		o.myName = "tomb"
		o.physicsType = "dynamic"
		o.physicsProperties = { density=5.5, bounce=0, friction=0.5, shape=tombShape }

	-- ERROR
	else
		print( "\n\nERROR: Game Objects Factory, unknown object '" .. tostring( objType ) .. "'\n\n")
	end

	return o
end


return GameObjectFactory
