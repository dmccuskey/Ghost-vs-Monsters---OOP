--====================================================================--
-- component/object_factory/ghost.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Ghost vs Monsters : Ghost Character
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Objects = require 'lib.dmc_corona.dmc_objects'
local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

local MovieClip = require 'lib.movieclip'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local PhysicsComponentBase = Objects.PhysicsComponentBase
local StatesMix = StatesMixModule.StatesMix

local LOCAL_DEBUG = false



--====================================================================--
--== Ghost Character Class
--====================================================================--


local Ghost = newClass( { PhysicsComponentBase, StatesMix }, {name="A Ghost"} )

--== Class Constants

Ghost.TYPE = 'ghost'

--== State Constants

Ghost.STATE_CONCEIVED = 'state_conceived'
Ghost.STATE_BORN = 'state_born'
Ghost.STATE_LIVING = 'state_living'
Ghost.STATE_AIMING = 'state_aiming'
Ghost.STATE_FLYING = 'state_flying'
Ghost.STATE_HIT = 'state_hit'
Ghost.STATE_DYING = 'state_dying'
Ghost.STATE_DEAD = 'state_dead'

--== Event Constants

Ghost.EVENT = 'ghost-character-event'

Ghost.UPDATED = 'character-updated'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function Ghost:__init__( params )
	-- print( "Ghost:__init__", params )
	params = params or {}
	self:superCall( StatesMix, '__init__', params )
	self:superCall( PhysicsComponentBase, '__init__', params )
	--==--

	--== Sanity Check

	assert( params.game_engine, "Ghost requires params 'game_engine'")

	--== Properties

	self._is_active = true
	self._is_offscreen = false
	self.__is_animating = false
	self.__is_hit = false
	self._ghost_tween = nil

	self.rotation = 0

	--== Objects

	self._sound_mgr = gService.sound_mgr

	self._game_engine = params.game_engine
	self._game_engine_f = nil

	self._enterframe_f = nil

	--== Physics Properties

	self.isBullet = true
	self.radius = 12
	self.physicsType = 'static'
	self.physicsProperties = { density=1.0, bounce=0.4, friction=0.15, radius=self.radius }

	--== Display Objects

	self._mc_ghost = nil
	self._blast = nil
	self._poof = nil

	self:setState( Ghost.STATE_CONCEIVED )
end

-- __undoInit__()
--
-- function Ghost:__undoInit__()
-- 	--==--
-- 	self:superCall( '__undoInit__' )
-- end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function Ghost:__createView__()
	-- print( "Ghost:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o

	-- ghost anim

	o = MovieClip.newAnim({ 'assets/characters/ghost1-waiting.png', 'assets/characters/ghost1.png' }, 26, 26 )
	self:insert( o )
	self._mc_ghost = o

	-- blast glow

	o = display.newImageRect( 'assets/effects/blastglow.png', 54, 54 )
	o.x, o.y = -7, 8
	o.isVisible = false
	self:insert( o )
	self._blast = o

	-- ghost poof

	o = display.newImageRect( 'assets/effects/poof.png', 80, 70 )
	o.alpha = 1.0
	o.isVisible = false
	self:insert( o )
	self._poof = o

end

-- __undoCreateView__()
--
function Ghost:__undoCreateView__()
	-- print( "Ghost:__undoCreateView__" )
	local o

	o = self._poof
	o:removeSelf()
	self._poof = nil

	o = self._blast
	o:removeSelf()
	self._blast = nil

	o = self._mc_ghost
	o:removeSelf()
	self._mc_ghost = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function Ghost:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	local o, f

	self:addEventListener( 'collision', self )

	o = self._game_engine
	f = self:createCallback( self._gameEngineEvent_handler )
	o:addEventListener( o.EVENT, f )
	self._game_engine_f = f

	self:gotoState( Ghost.STATE_BORN )
end

-- __undoInitComplete__()
--
function Ghost:__undoInitComplete__()
	-- print( "Ghost:__undoInitComplete__" )

	local o, f

	o = self._game_engine
	f = self._game_engine_f
	o:removeEventListener( o.EVENT, f )
	self._game_engine_f = nil

	self:removeEventListener( 'collision', self )

	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- getter/setter: is_offscreen
--
function Ghost.__getters:is_offscreen()
	return self._is_offscreen
end
function Ghost.__setters:is_offscreen( value )
	-- print( "Ghost.__setters:is_offscreen" )
	assert( type(value)=='boolean' )
	--==--
	if self._is_offscreen==value then return end

	self._is_offscreen = value
	self:gotoState( Ghost.STATE_DYING )
end


-- applyForce( xForce, yForce, bodyX, bodyY )
--
function Ghost:applyForce( ... )
	self:gotoState( Ghost.STATE_FLYING )
	self:superCall( 'applyForce', ... )
end



--====================================================================--
--== Private Methods


-- getter/setter: _is_animating
--
function Ghost.__getters:_is_animating()
	return self.__is_animating
end
function Ghost.__setters:_is_animating( value )
	-- print( "Ghost.__setters:_is_animating" )
	assert( type(value)=='boolean' )
	--==--
	if self.__is_animating==value then return end

	self.__is_animating = value

	if value==true then
		self:_doGhostAnimation()
	else
		self:_stopGhostAnimation()
	end
end


-- getter/setter: _is_hit
--
function Ghost.__getters:_is_hit()
	return self.__is_hit
end
function Ghost.__setters:_is_hit( value )
	-- print( "Ghost.__setters:_is_hit" )
	assert( type(value)=='boolean' )
	--==--
	self.__is_hit = value
end


function Ghost:_changeImage( value )
	self._mc_ghost:stopAtFrame( value )
end


function Ghost:_startEnterFrame()
	local f = self._enterframe_f
	if f then return end
	f = self:createCallback( self._enterFrameEvent_handler )
	Runtime:addEventListener( 'enterFrame', f )
	self._enterframe_f = f
end
function Ghost:_stopEnterFrame()
	local f = self._enterframe_f
	if not f then return end
	Runtime:removeEventListener( 'enterFrame', f )
	self._enterframe_f = nil
end


function Ghost:_stopGhostAnimation()
	-- print( "Ghost:_stopGhostAnimation" )
	if not self._ghost_tween then return end
	transition.cancel( self._ghost_tween )
	self._ghost_tween = nil
end
function Ghost:_doGhostAnimation( event )
	-- print( "Ghost:_doGhostAnimation" )
	local lY = ( self.y == 190 ) and 200 or 190

	self:_stopGhostAnimation()
	local p = {
		time=375,
		y=lY,
		onComplete=self:createCallback( self._doGhostAnimation )
	}
	self._ghost_tween = transition.to( self, p )
end



--====================================================================--
--== Event Handlers


function Ghost:collision( event )
	-- print( "Ghost:collision" )
	if event.phase == 'began' then
		self._sound_mgr:play( self._sound_mgr.IMPACT )
		if not self._is_hit then
			timer.performWithDelay( 1, self:gotoState( Ghost.STATE_HIT, {event=event}, {merge=false} ) )
		end
	end
	return true
end


function Ghost:_enterFrameEvent_handler( event )
	-- print( "Ghost:_enterFrameEvent_handler" )
	local curr_state = self:getState()

	if self._is_active and ( curr_state == Ghost.STATE_FLYING or curr_state == Ghost.STATE_HIT ) then
		-- constrain ghost's rotation
		if self.rotation < -45 then
			self.rotation = -45
		elseif self.rotation > 30 then
			self.rotation = 30
		end
	end
end


function Ghost:_gameEngineEvent_handler( event )
	-- print( "Ghost:_gameEngineEvent_handler ", event.type )
	local target = event.target

	if event.type == target.AIMING_SHOT then
		self:gotoState( Ghost.STATE_AIMING )

	elseif event.type == target.GAME_ISACTIVE then
		self._is_animating = event.value
		self._is_active = value

	end

end


--======================================================--
--== START: State Machine

--== State Conceived ==--

function Ghost:state_conceived( next_state, params )
	-- print( "Ghost:state_conceived: >> ", next_state )
	if next_state == Ghost.STATE_BORN then
		self:do_state_born( params )
	else
		print( "[WARNING] Ghost:state_conceived :: " .. tostring( next_state ) )
	end
end


--== State Born ==--

function Ghost:do_state_born( params )
	-- print( "Ghost:do_state_born", params )

	self.x, self.y  = 150, 300
	self:_changeImage( 1 )

	local f = function()
		self:setState( Ghost.STATE_BORN )
		self:dispatchEvent( Ghost.STATE_BORN )

		self:gotoState( Ghost.STATE_LIVING )
	end

	transition.to( self, { time=1000, y=195, transition=easing.inOutExpo, onComplete=f })

end

function Ghost:state_born( next_state, params )
	-- print( "Ghost:state_born: >> ", next_state, params )

	if next_state == Ghost.STATE_LIVING then
		self:do_state_living( params )
	else
		print( "[WARNING] Ghost:state_born :: " .. tostring( next_state ) )
	end
end


--== State Living ==--

function Ghost:do_state_living( params )
	-- print( "Ghost:do_state_living", params )

	self:setState( Ghost.STATE_LIVING )
	self._is_animating = true
	self:dispatchEvent( Ghost.STATE_LIVING )
end

function Ghost:state_living( next_state, params )
	-- print( "Ghost:state_living: >> ", next_state, params )

	if next_state == Ghost.STATE_AIMING then
		self:do_state_aiming( params )
	else
		print( "[WARNING] Ghost:state_living :: " .. tostring( next_state ) )
	end
end


--== State Aiming ==--

function Ghost:do_state_aiming( params )
	-- print( "Ghost:do_state_aiming", params )

	self:setState( Ghost.STATE_AIMING )
	self._is_animating = false
	self.y = 195
	self:dispatchEvent( Ghost.STATE_AIMING )
end

function Ghost:state_aiming( next_state, params )
	-- print( "Ghost:state_aiming: >> ", next_state, params )

	if next_state == Ghost.STATE_FLYING then
		self:do_state_flying( params )
	else
		print( "[WARNING] Ghost:state_aiming :: " .. tostring( next_state ) )
	end
end


--== State Flying ==--

function Ghost:do_state_flying( params )
	-- print( "Ghost:do_state_flying", params )
	self:setState( Ghost.STATE_FLYING )

	self:_startEnterFrame()

	-- visual
	self._blast.isVisible = true
	self:_changeImage( 2 )

	-- physics
	self.bodyType = 'dynamic'
	self.isBodyActive = true

	self._sound_mgr:play( self._sound_mgr.WEE )

	self:dispatchEvent( Ghost.STATE_FLYING )
end

function Ghost:state_flying( next_state, params )
	-- print( "Ghost:state_flying: >> ", next_state, params )

	if next_state == Ghost.STATE_HIT then
		self:do_state_hit( params )
	elseif next_state == Ghost.STATE_DYING then
		self:do_state_dying( params )
	else
		print( "[WARNING] Ghost:state_flying :: " .. tostring( next_state ) )
	end
end


--== State Hit ==--

function Ghost:do_state_hit( params )
	-- print( "Ghost:do_state_hit", params )
	params = params or {}
	assert( params.event )
	--==--
	local hit_with = params.event.other
	local delay = 1700

	self:setState( Ghost.STATE_HIT )

	self:_startEnterFrame()

	-- object properties
	self._is_hit = true
	self._blast.isVisible = false

	-- visual - prepare poof
	local pList = { 'wood', 'stone', 'tomb', 'monster' }
	if Utils.propertyIn( pList, hit_with.TYPE ) then
		delay = 500
	end
	timer.performWithDelay( delay, function() self:gotoState( Ghost.STATE_DYING ) end, 1 )

	self:dispatchEvent( Ghost.STATE_HIT )
end

function Ghost:state_hit( next_state, params )
	-- print( "Ghost:state_hit: >> ", next_state, params )

	if next_state == Ghost.STATE_DYING then
		self:do_state_dying( params )
	else
		print( "[WARNING] Ghost:state_hit :: " .. tostring( next_state ) )
	end
end


--== State Dying ==--

function Ghost:do_state_dying( params )
	-- print( "Ghost:do_state_dying", params )

	local o

	self:setState( Ghost.STATE_DYING )

	self:_stopEnterFrame()

	-- object properties
	self.rotation = 0

	-- physics properties
	self:setLinearVelocity( 0, 0 )
	self.bodyType = 'static'
	self.isBodyActive = false

	-- ghost image
	self._mc_ghost.isVisible = false

	-- poof image
	o = self._poof
	o.isVisible = true
	o.alpha = 0

	local fadePoof = function()
		transition.to( o, { time=2000, alpha=0 } )
		self:gotoState( Ghost.STATE_DEAD )
	end
	transition.to( o, { time=100, alpha=1.0, onComplete=fadePoof } )

	self._sound_mgr:play( self._sound_mgr.GHOST_POOF )

	self:dispatchEvent( Ghost.STATE_DYING )
end

function Ghost:state_dying( next_state, params )
	-- print( "Ghost:state_dying: >> ", next_state, params )

	if next_state == Ghost.STATE_DEAD then
		self:do_state_dead( params )
	else
		print( "[WARNING] Ghost:state_dying :: " .. tostring( next_state ) )
	end
end


--== State Dead ==--

function Ghost:do_state_dead( params )
	-- print( "Ghost:do_state_dead", params )
	self:setState( Ghost.STATE_DEAD )
	self:dispatchEvent( Ghost.STATE_DEAD )
end

function Ghost:state_dead( next_state, params )
	-- print( "Ghost:state_dead: >> ", next_state, params )
	print( "[WARNING] Ghost:state_dead :: " .. tostring( next_state ) )
end

--== END: State Machine
--======================================================--




return Ghost
