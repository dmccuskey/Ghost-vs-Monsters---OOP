--====================================================================--
-- scene/game/game_view.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Ghost vs Monsters : Game Main View
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Imports


local physics = require 'physics'

local AppUtils = require 'lib.app_utils'
local Objects = require 'lib.dmc_corona.dmc_objects'
local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

--== Components

local ObjectFactory = require 'component.object_factory'
local PauseOverlay = require 'component.pause_overlay'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase
local StatesMix = StatesMixModule.StatesMix

local mCeil = math.ceil
local mAtan2 = math.atan2
local mPi = math.pi
local mSqrt = math.sqrt
local tinsert = table.insert
local tremove = table.remove

local LOCAL_DEBUG = true



--====================================================================--
--== Support Functions


local function DisplayReferenceFactory( name )

	if name == 'TopLeft' then
		return ComponentBase.TopLeftReferencePoint
	elseif name == 'CenterLeft' then
		return ComponentBase.CenterLeftReferencePoint
	elseif name == 'BottomLeft' then
		return ComponentBase.BottomLeftReferencePoint
	else
		return ComponentBase.TopLeftReferencePoint
	end

end


-- saveValue() --> used for saving high score, etc.

local saveValue = function( strFilename, strValue )
	-- will save specified value to specified file
	local theFile = strFilename
	local theValue = strValue

	local path = system.pathForFile( theFile, system.DocumentsDirectory )

	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "w+" )
	if file then
		-- write game score to the text file
		file:write( theValue )
		io.close( file )
	end
end


-- loadValue() --> load saved value from file (returns loaded value as string)

local loadValue = function( strFilename )
	-- will load specified file, or create new file if it doesn't exist

	local theFile = strFilename

	local path = system.pathForFile( theFile, system.DocumentsDirectory )

	-- io.open opens a file at path. returns nil if no file found
	local file = io.open( path, "r" )
	if file then
		-- read all contents of file into a string
		local contents = file:read( "*a" )
		io.close( file )
		return contents
	else
		-- create file b/c it doesn't exist yet
		file = io.open( path, "w" )
		file:write( "0" )
		io.close( file )
		return "0"
	end
end






--====================================================================--
--== Game Engine class
--====================================================================--


local GameView = newClass( { ComponentBase, StatesMix }, {name="Game View"} )

--== Class Constants

GameView.RIGHT_POS = 'right'
GameView.LEFT_POS = 'left'

GameView.WIN_GAME = 'win-game'
GameView.LOSE_GAME = 'lose-game'

--== State Constants

GameView.STATE_CREATE = 'state_create'
GameView.STATE_INIT = 'state_init'

GameView.TO_NEW_ROUND = 'trans_new_round'
GameView.STATE_NEW_ROUND = 'state_new_round'

GameView.TO_AIMING_SHOT = 'trans_aiming_shot'
GameView.STATE_AIMING_SHOT = 'state_aiming_shot'

GameView.TO_SHOT_IN_PLAY = 'trans_shot_in_play'
GameView.STATE_SHOT_IN_PLAY = 'state_shot_in_play'

GameView.TO_END_ROUND = 'trans_end_round'
GameView.STATE_END_ROUND = 'state_end_round'

GameView.TO_CALL_ROUND = 'trans_call_round'
GameView.STATE_END_GAME = 'state_end_game'

--== Event Constants

GameView.EVENT = 'game-view-event'

GameView.GAME_ACTIVE_EVENT = 'game-active'
GameView.AIMING_EVENT = 'game-aiming'
GameView.GAME_OVER_EVENT = 'game-is-over'
GameView.GAME_EXIT_EVENT = 'game-exit'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
-- put on our object properties
--
function GameView:__init__( params )
	--print( "GameView:__init__", params )
	self:superCall( StatesMix, '__init__', params )
	self:superCall( ComponentBase, '__init__', params )
	--==--

	--== Sanity Check

	assert( params.width and params.height, "Game View requires params 'width' & 'height'")
	assert( params.level_data==nil or type(params.level_data)=='table', "Game View wrong type for 'level_data'")

	--== Properties

	self._width = params.width
	self._height = params.height

	self._level_data = params.level_data
	self.__game_is_active = false
	self._is_physics_active = false

	self._tracking_timer = nil

	self._screen_position = ""	-- "left" or "right"

	-- if we are panning the scene
	self._is_panning = false

	self._life_icons = {}
	self.__game_lives = 0
	self._enemy_count = 0

	self.__best_score = -1
	self.__game_score = -1

	self._sound_mgr = gService.sound_mgr

	self._enemy_f = nil
	self._megaphone_f = nil

	--== Display Groups

	self._dg_game = nil -- all game items items
	self._dg_overlay = nil -- all game items items

	-- DG Game items
	self._dg_bg = nil -- background items
	self._dg_ph_bg = nil -- physics background items
	self._dg_shot = nil -- shot feedback items
	self._dg_ph_game = nil -- physics game items
	self._dg_ph_fore = nil -- physics foreground items
	self._dg_dot_trail = nil -- trail of dots

	--== Display Objects

	self._shot_orb = nil
	self._shot_arrow = nil

	self._character = nil
	self._character_f = nil

	self._pause_overlay = nil
	self._pause_overlay_f = nil

	self._txt_continue = nil
	self._txt_continue_timer = nil

	self._txt_score = nil

	self:setState( GameView.STATE_CREATE )
end

-- function GameView:_undoInit()
-- 	--==--
-- 	self:superCall( '__undoCreateView__' )
-- end



-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function GameView:__createView__()
	--print( "GameView:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5
	local H_MARGIN, V_MARGIN = 15, 10

	local dg, o

	-- setup display primer

	o = display.newRect( 0, 0, W, 10)
	o.anchorX, o.anchorY = 0, 0
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(1,0,0,0.75)
	end
	o.x, o.y = 0, 0

	self:insert( o )
	self._primer = o

	-- main game group

	o = display.newGroup()
	self:insert( o )
	self._dg_game = o

	-- overlay group

	o = display.newGroup()
	self:insert( o )
	self._dg_overlay = o


	dg = self._dg_game -- display group temp

	-- background items group

	o = display.newGroup()
	dg:insert( o )
	self._dg_bg = o

	-- physics background items
	o = display.newGroup()
	dg:insert( o )
	self._dg_ph_bg = o

	-- shot feedback items

	o = display.newGroup()
	dg:insert( o )
	self._dg_shot = o

	-- physics game items

	o = display.newGroup()
	dg:insert( o )
	self._dg_ph_game = o

	-- physics forground game items

	o = display.newGroup()
	dg:insert( o )
	self._dg_ph_fore = o

	-- physics trailgroup items

	o = display.newGroup()
	dg:insert( o )
	self._dg_dot_trail = o

	--== Setup Overlay Items

	dg = self._dg_overlay -- display group temp

	-- score display

	o = display.newText( "0", 470, 22, "Helvetica-Bold", 52 )
	o:setTextColor( 1,1,1,1 )	--> white
	o.xScale, o.yScale = 0.5, 0.5  --> for clear retina display text

	dg:insert( o )
	self._txt_score = o

	-- "tap to continue" display

	o = display.newText( "TAP TO CONTINUE", 240, 18, "Helvetica", 36 )
	o.anchorX, o.anchorY = 0.5, 0
	o:setTextColor( 249/255, 203/255, 64/255 )
	o.xScale, o.yScale = 0.5, 0.5
	o.x, o.y = H_CENTER, V_MARGIN

	dg:insert( o )
	self._txt_continue = o

	-- pause button overlay

	o = PauseOverlay:new{
		width=W, height=H
	}
	o.x, o.y = H_CENTER, 0

	dg:insert( o.view )
	self._pause_overlay = o

end

function GameView:__undoCreateView__()
	-- print( "GameView:__undoCreateView__" )

	local o

	o = self._pause_overlay
	o:removeSelf()
	self._pause_overlay = nil

	o = self._txt_continue
	o:removeSelf()
	self._txt_continue = nil

	o = self._txt_score
	o:removeSelf()
	self._txt_score  = nil

	o = self._dg_dot_trail
	o:removeSelf()
	self._dg_dot_trail = nil

	o = self._dg_ph_fore
	o:removeSelf()
	self._dg_ph_fore = nil

	o = self._dg_ph_game
	o:removeSelf()
	self._dg_ph_game = nil

	o = self._dg_shot
	o:removeSelf()
	self._dg_shot = nil

	o = self._dg_ph_bg
	o:removeSelf()
	self._dg_ph_bg = nil

	o = self._dg_bg
	o:removeSelf()
	self._dg_bg  = nil

	o = self._dg_overlay
	o:removeSelf()
	self._dg_overlay  = nil

	o = self._dg_game
	o:removeSelf()
	self._dg_game  = nil

	o = self._primer
	o:removeSelf()
	self._primer  = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function GameView:__initComplete__()
	-- print( "GameView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local o, f

	self:_createShotFeedback()
	self:_createLifeIndicator()

	f = self:createCallback( self._ghostEvent_handler )
	self._character_f = f

	f = self:createCallback( self._enemyEvent_handler )
	self._enemy_f = f

	-- megaphone communication
	f = self:createCallback( self._megaphoneEvent_handler )
	gMegaphone:listen( f )
	self._megaphone_f = f

	o = self._pause_overlay
	f = self:createCallback( self._pauseOverlayEvent_handler )
	o:addEventListener( o.EVENT, f )
	self._pause_overlay_f = f

	Runtime:addEventListener( 'touch', self )
	Runtime:addEventListener( 'enterFrame', self )

end
function GameView:__undoInitComplete__()
	-- print( "GameView:__undoInitComplete__" )
	local o, f

	self:_destroyAllLevelObjects()

	self:_stopPhysics() -- after destroy objects

	Runtime:removeEventListener( 'touch', self )
	Runtime:removeEventListener( 'enterFrame', self )

	o = self._pause_overlay
	f = self._pause_overlay_f
	o:removeEventListener( o.EVENT, f )
	self._pause_overlay_f = nil

	-- megaphone communication
	f = self._megaphone_f
	gMegaphone:ignore( f )
	self._megaphone_f = nil

	self._enemy_f = nil
	self._character_f = nil

	self:_destroyLifeIndicator()
	self:_destroyShotFeedback()

	self:_stopBlinkingText()
	self:_stopTrackingTimer()
	self:_clearTrackingDots()

	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function GameView.__setters:level_data( data )
	-- print( "GameView.__setters:level_data", data.info.name )
	assert( data, "missing level data" )
	--==--
	self._level_data = data
end


function GameView:startGamePlay()
	-- print( "GameView:startGamePlay" )
	self:gotoState( GameView.STATE_INIT )
end
function GameView:pauseGamePlay()
	-- print( "GameView:pauseGamePlay" )
	self._game_is_active = false -- setter
end
function GameView:resumeGamePlay()
	-- print( "GameView:resumeGamePlay" )
	self._game_is_active = true -- setter
end



--====================================================================--
--== Private Methods


--== Getters / Setters ==--


-- _best_score
--
function GameView.__getters:_best_score()
	local bestScoreFilename = self._level_data.info.name .. ".data"
	if self.__best_score == -1 then
		self.__best_score = tonumber( loadValue( bestScoreFilename ) )
	end
	return self.__best_score
end
function GameView.__setters:_best_score( value )
	assert( type(value)=='number' )
	--==--
	if value < self.__best_score then return end

	local bestScoreFilename = self._level_data.info.name .. ".data"

	-- clean up value
	if value < 0 then value = 0 end
	self.__best_score = value

	saveValue( bestScoreFilename, tostring( self._best_score ) )
end



-- getter/setter: _game_score
--
function GameView.__getters:_game_score()
	return self.__game_score
end
function GameView.__setters:_game_score( value )
	assert( type(value)=='number' )
	--==--
	if self.__game_score == value then return end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5
	local H_MARGIN, V_MARGIN = 15, 10

	if value < 0 then value = 0 end
	self.__game_score = value

	-- update scoreboard
	local o = self._txt_score
	o.text = AppUtils.comma_value( value )
	o.anchorX, o.anchorY = 1, 0
	o.x, o.y = W-H_MARGIN, V_MARGIN
end


-- _game_lives
--
function GameView.__getters:_game_lives()
	return self.__game_lives
end
function GameView.__setters:_game_lives( value )
	assert( type(value)=='number', "wrong type for game lives" )
	--==--
	-- clean up value
	if value < 0 then value = 0 end
	if value > 4 then value = 4 end

	self.__game_lives = value

	-- update icons
	for i, item in ipairs( self._life_icons ) do
		if i <= value then
			item.alpha = 1.0
		else
			item.alpha = 0.4
		end
	end
end


-- _game_is_active
--
function GameView.__getters:_game_is_active()
	return self.__game_is_active
end
function GameView.__setters:_game_is_active( value )
	-- print( "GameView.__setters:_game_is_active", value )
	assert( type(value)=='boolean', "wrong type for game is active")
	--==--
	if self.__game_is_active == value then return end

	self.__game_is_active = value

	if value == true then
		self:_startPhysics( true )
	else
		self:_pausePhysics()
	end

	self:dispatchEvent( GameView.GAME_ACTIVE_EVENT, {value=value} )
end



function GameView.__setters:_is_tracking_character( value )
	-- print("GameView:_is_tracking_character ", value )
	assert( type(value)=='boolean' )
	--==--
	if value then
		self:_startTrackingTimer()
	else
		self:_stopTrackingTimer()
	end
end



-- getter/setter: _text_is_blinking()
--
function GameView.__getters:_text_is_blinking()
	return ( self._txt_continue_timer ~= nil )
end
function GameView.__setters:_text_is_blinking( value )
	--print("GameView.__setters:_text_is_blinking")
	assert( type(value)=='boolean' )
	--==--
	self._txt_continue.isVisible = value
	if value then
		self:_startBlinkingText()
	else
		self:_stopBlinkingText()
	end
end


function GameView:_startBlinkingText()
	local o = self._txt_continue
	self:_stopBlinkingText()
	local startBlinking = function()
		local continueBlink = function()
			o.isVisible = not o.isVisible
		end
		self._txt_continue_timer = timer.performWithDelay( 350, continueBlink, 0 )
	end
	self._txt_continue_timer = timer.performWithDelay( 300, startBlinking, 1 )
end

function GameView:_stopBlinkingText()
	if not self._txt_continue_timer then return end
	timer.cancel( self._txt_continue_timer )
	self._txt_continue_timer = nil
end




--== Methods ==--


function GameView:_addGameObject( item, group, is_physics )
	-- print( "GameView:_addGameObject", item, is_physics )
	local ENEMY_NAME = self._level_data.info.enemyName
	local o, d

	-- most of the creation magic happens in this line
	-- game objects are created from level data entries
	o = ObjectFactory.create( item.name, {game_engine=self} )
	assert( o, "object not created" )

	-- process attributes found in the level data
	if item.reference then
		o.anchorX, o.anchorY = unpack( DisplayReferenceFactory( item.reference )  )
	end
	-- TODO: process special properties and layer the rest
	if item.rotation then o.rotation = item.rotation end
	if item.alpha then o.alpha = item.alpha end
	if item.x then o.x = item.x end
	if item.y then o.y = item.y end

	-- add object to the display group
	d = o
	if o.view then
		d = o.view
	elseif o.display then
		d = o.display
	end
	group:insert( d )

	-- add object to the physics engine
	if is_physics and physics.addBody then
		physics.addBody( d, o.physicsType, o.physicsProperties )
	end

	-- listen to enemies and count them
	if o.TYPE == ENEMY_NAME then
		self._enemy_count = self._enemy_count + 1
		if o.EVENT then
			o:addEventListener( o.EVENT, self._enemy_f )
		end
	end

end


function GameView:_removeGameObject( obj, is_physics )
	-- print( "GameView:_removeGameObject", item, is_physics )
	local ENEMY_NAME = self._level_data.info.enemyName
	local d

	obj = getDMCObject( obj )
	d = obj
	if obj.view then
		d = obj.view
	elseif obj.display then
		d = obj.display
	end

	if is_physics and physics.removeBody then
		if not physics.removeBody( d ) then
			print( "\n\nERROR: COULD NOT REMOVE BODY FROM PHYSICS ENGINE\n\n")
		end
	end

	if obj.TYPE == ENEMY_NAME and obj.EVENT then
		obj:removeEventListener( obj.EVENT, self._enemy_f )
	end

	obj:removeSelf()
end

-- _addDataItems()
--
-- loop through game data items and put on stage
--
function GameView:_addDataItems( data, group, params )
	-- print( "GameView:_addDataItems" )
	data = data or {}
	params = params or {}
	if params.is_physics==nil then params.is_physics=false end
	--==--
	for _, item in ipairs( data ) do
		-- print( _, item.name, item )
		-- item is one of the entries in our data file
		self:_addGameObject( item, group, params.is_physics )
	end
end

-- _removeDataItems()
--
-- loop through display groups and remove their items
--
function GameView:_removeDataItems( group, params )
	-- print( "GameView:_removeDataItems" )
	local params = params or {}
	if params.is_physics==nil then params.is_physics=false end
	--==--
	for i = group.numChildren, 1, -1 do
		-- print( group[i] )
		self:_removeGameObject( group[i], params.is_physics )
	end
end


-- _createBackground()
--
function GameView:_createBackgroundItems()
	-- print( "GameView:_createBackgroundItems" )
	self:_addDataItems( self._level_data.backgroundItems, self._dg_bg )
end
function GameView:_destroyBackgroundItems()
	-- print( "GameView:_destroyBackgroundItems" )
	self:_removeDataItems( self._dg_bg )
end

-- _createPhysicsBackgroundItems()
--
function GameView:_createPhysicsBackgroundItems()
	-- print( "GameView:_createPhysicsBackgroundItems" )
	self:_addDataItems( self._level_data.physicsBackgroundItems, self._dg_ph_bg, {is_physics=true} )
end
function GameView:_destroyPhysicsBackgroundItems()
	-- print( "GameView:_destroyPhysicsBackgroundItems" )
	self:_removeDataItems( self._dg_ph_bg, {is_physics=true} )
end

-- _createPhysicsGameItems()
--
function GameView:_createPhysicsGameItems()
	-- print( "GameView:_createPhysicsGameItems" )
	self:_addDataItems( self._level_data.physicsGameItems, self._dg_ph_game, {is_physics=true} )
end
function GameView:_destroyPhysicsGameItems()
	-- print( "GameView:_destroyPhysicsGameItems" )
	self:_removeDataItems( self._dg_ph_game, {is_physics=true} )
end


-- _createPhysicsForegroundItems()
--
function GameView:_createPhysicsForegroundItems()
	self:_addDataItems( self._level_data.physicsForgroundItems, self._dg_ph_fore, {is_physics=true} )
end
function GameView:_destroyPhysicsForegroundItems()
	-- print( "GameView:_destroyPhysicsForegroundItems" )
	self:_removeDataItems( self._dg_ph_fore, {is_physics=true} )
end


-- _createAllLevelObjects()
--
function GameView:_createAllLevelObjects()

	-- cleanup
	self:_destroyAllLevelObjects()

	self:_createBackgroundItems()
	self:_createPhysicsBackgroundItems()
	self:_createPhysicsGameItems()
	self:_createPhysicsForegroundItems()

end

-- _destroyAllLevelObjects()
--
function GameView:_destroyAllLevelObjects()

	if not self._is_physics_active then
		-- need to turn physics on for removal/addition
		self._game_is_active = true
	end

	self:_destroyPhysicsForegroundItems()
	self:_destroyPhysicsGameItems()
	self:_destroyPhysicsBackgroundItems()
	self:_destroyBackgroundItems()
end



--== Tracking

function GameView:_clearTrackingDots()
	local dg = self._dg_dot_trail
	for i = dg.numChildren,1,-1 do
		local o = dg[i]
		o.parent:remove( o )
	end
end

function GameView:_startTrackingTimer()
	local dg = self._dg_dot_trail
	local char = self._character

	self:_stopTrackingTimer()
	self:_clearTrackingDots()

	local startDots = function()
		local odd = true
		local createDot = function()
			local trailDot
			local size = ( odd and 1.5 ) or 2.5
			trailDot = display.newCircle( dg, char.x, char.y, size )
			trailDot:setFillColor( 1,1,1,1 )
			odd = not odd
		end
		self._tracking_timer = timer.performWithDelay( 50, createDot, 50 )
	end
	startDots()
end

function GameView:_stopTrackingTimer()
	if not self._tracking_timer then return end
	timer.cancel( self._tracking_timer )
	self._tracking_timer = nil
end



-- _createShotFeedback()
--
function GameView:_createShotFeedback()
	local dg = self._dg_shot
	local o

	-- shot orb
	o = display.newImageRect( 'assets/game_objects/orb.png', 96, 96 )
	o.xScale, o.yScale = 1.0, 1.0
	o.isVisible = false
	o.alpha = 0.75

	dg:insert( o )
	self._shot_orb = o

	-- shot arrow
	o = display.newImageRect( 'assets/game_objects/arrow.png', 240, 240 )
	o.x, o.y = 150, 195
	o.isVisible = false

	dg:insert( o )
	self._shot_arrow = o
end

-- _destroyShotFeedback()
--
function GameView:_destroyShotFeedback()
	local o

	o = self._shot_orb
	o:removeSelf()
	self._shot_orb = nil

	o = self._shot_arrow
	o:removeSelf()
	self._shot_arrow = nil

end



-- _panCamera()
--
-- direction, string 'left'/'right'
-- duration, number of milliseconds
-- params, table of options
-- - callback
-- - transition
--
function GameView:_panCamera( direction, duration, params )
	--print( "GameView:_panCamera" )
	local params = params or {}
	--==--
	local dg, f, p
	local xvalue

	if direction == 'left' then
		xvalue = 0
	else
		xvalue = -480
	end

	self._is_panning = true

	dg = self._dg_game
	f = function()
		local cb = params.callback
		self._is_panning = false
		self._screen_position = direction
		if cb then cb() end
	end
	p = {
		time=duration,
		x=xvalue,
		transition=params.transition,
		onComplete=f
	}
	transition.to( dg, p )

end


function GameView:_startPhysics( param )
	-- print( "GameView:_startPhysics" )
	self._is_physics_active = true
	physics.start( param )

	-- set to "normal" "debug" or "hybrid" to see collision boundaries
	physics.setDrawMode( 'normal' )
	physics.setGravity( 0, 11 )	--> 0, 9.8 = Earth-like gravity
end

function GameView:_pausePhysics()
	--print( "GameView:_pausePhysics" )
	self._is_physics_active = false
	physics.pause()
end

function GameView:_stopPhysics()
	-- print( "GameView:_stopPhysics" )
	self._is_physics_active = false
	physics.stop()
end



--== Game Character Creation and Event Handlers ==--

function GameView:_createGhost()
	--print( "GameView:_createGhost" )
	local item = self._level_data.info.characterName

	local o = ObjectFactory.create( item, {game_engine=self} )

	self._dg_ph_fore:insert( o.view )
	self._character = o

	o:addEventListener( o.EVENT, self._character_f )

	-- TODO: move to ghost
	physics.addBody( o.view, o.physicsType, o.physicsProperties )
	o.isBodyActive = false

	return o
end

function GameView:_destroyGhost()
	-- print( "GameView:_destroyGhost" )
	local o = self._character

	assert( physics.removeBody( o.view ) )

	o:removeEventListener( o.EVENT, self._character_f )

	o:removeSelf()

	self._character = nil
end



-- _createLifeIndicator()
--
function GameView:_createLifeIndicator()

	-- LIVES DISPLAY
	local X_BASE, Y_BASE = 25, 20
	local X_OFFSET = 25

	local dg = self._dg_overlay
	local list = self._life_icons
	local o, tmp

	-- TWO BLACK RECTANGLES AT TOP AND BOTTOM (for those viewing from iPad)
	-- img = display.newRect( 0, -160, 480, 160 )
	-- img:setFillColor( 0, 0, 0, 255 )
	-- dg:insert( img )

	-- img = display.newRect( 0, 320, 480, 160 )
	-- img:setFillColor( 0, 0, 0, 255 )
	-- dg:insert( img )

	o = ObjectFactory.create( ObjectFactory.LIFE_ICON )
	o.x, o.y = X_BASE, Y_BASE
	dg:insert( o )
	tinsert( list, o )

	tmp = o
	o = ObjectFactory.create( ObjectFactory.LIFE_ICON )
	o.x, o.y = tmp.x + X_OFFSET, Y_BASE
	dg:insert( o )
	tinsert( list, o )

	tmp = o
	o = ObjectFactory.create( ObjectFactory.LIFE_ICON )
	o.x, o.y = tmp.x + X_OFFSET, Y_BASE
	dg:insert( o )
	tinsert( list, o )

	tmp = o
	o = ObjectFactory.create( ObjectFactory.LIFE_ICON )
	o.x, o.y = tmp.x + X_OFFSET, Y_BASE
	dg:insert( o )
	tinsert( list, o )

end

function GameView:_destroyLifeIndicator()

	local list = self._life_icons
	for i = #list, 1, -1 do
		list[i]:removeSelf()
		tremove( list, i )
	end
	self._life_icons = nil

	-- -- black rectangles
	-- for i = group.numChildren, 1, -1 do
	-- 	group:remove( i )
	-- end

end



function GameView:_resetGameView()
	-- print( "GameView:_resetGameView" )

	self._dg_game.x = -480
	self._screen_position = GameView.RIGHT_POS
	self._is_panning = false

	self._game_score = 0 -- setter

	self._game_lives = 4 -- change to DEBUG app, default 4
	self._enemy_count = 0

	self._text_is_blinking = false

	self._is_tracking_character = false
	self:_clearTrackingDots()
end




--====================================================================--
--== Event Handlers


-- megaphone communication
--
function GameView:_megaphoneEvent_handler( event )
	-- print( "GameView:_megaphoneEvent_handler", event.type )
	local target = event.target

	if event.type == target.PAUSE_GAMEPLAY then
		self:pauseGamePlay()

	elseif event.type == target.RESUME_GAMEPLAY then
		self:resumeGamePlay()

	end
end


function GameView:_ghostEvent_handler( event )
	-- print( "GameView:_ghostEvent_handler", event.type )
	local target = event.target

	if event.type == target.STATE_BORN then
		-- pass

	elseif event.type == target.STATE_LIVING then
		self:gotoState( GameView.STATE_NEW_ROUND )

	elseif event.type == target.STATE_AIMING then
			-- pass

	elseif event.type == target.STATE_FLYING then
		self._is_tracking_character = true

	elseif event.type == target.STATE_HIT then
		self._game_score = self._game_score + 500
		self._is_tracking_character = false

	elseif event.type == target.STATE_DYING then
		self._game_lives = self._game_lives - 1

	elseif event.type == target.STATE_DEAD then
		self:gotoState( GameView.TO_END_ROUND )

	else
		print("[WARNING] GameView:_ghostEvent_handler", event.type )
	end

end


function GameView:_enemyEvent_handler( event )
	-- print( "GameView:_enemyEvent_handler", event.type )
	local target = event.target

	if event.type == target.STATE_DEAD then
		self._enemy_count = self._enemy_count - 1

		local newScore = self._game_score + mCeil( 5000 * event.force )
		self._game_score = newScore

		self:_removeGameObject( target, true )

	else
		print("[WARNING] GameView:_enemyEvent_handler", event.type )
	end

end


function GameView:_pauseOverlayEvent_handler( event )
	-- print( "GameView:_pauseOverlayEvent_handler", event.type )
	local target = event.target

	if event.type == target.ACTIVE then
		-- in this sense, "active" means "pause is activated"
		local pause_is_active = event.is_active
		self._game_is_active = ( not pause_is_active )

	elseif event.type == target.MENU then
		self:dispatchEvent( GameView.GAME_EXIT_EVENT )

	end
end


function GameView:touch( event )
	-- print( "GameView:touch", event.phase )

	local mCeil = math.ceil
	local mAtan2 = math.atan2
	local mPi = math.pi
	local mSqrt = math.sqrt

	local ghost = self._character

	local phase = event.phase
	local x, xStart = event.x, event.xStart
	local y, yStart = event.y, event.yStart

	local curr_state = self:getState()

	--== TOUCH HANDLING, active game
	if self._game_is_active then
		-- BEGINNING OF AIM
		if phase == 'began' and curr_state == GameView.STATE_NEW_ROUND and xStart > 115 and xStart < 180 and yStart > 160 and yStart < 230 and self._screen_position == GameView.LEFT_POS then

			self:gotoState( GameView.TO_AIMING_SHOT )

		-- RELEASE THE DUDE
		elseif phase == 'ended' and curr_state == GameView.STATE_AIMING_SHOT then

			local xF = (-1 * (x - ghost.x)) * 2.15	--> 2.75
			local yF = (-1 * (y - ghost.y)) * 2.15	--> 2.75

			local data = { xForce=xF, yForce=yF  }
			self:gotoState( GameView.TO_SHOT_IN_PLAY, {shot=data} )

		-- SWIPE SCREEN
		elseif phase == 'ended' and curr_state == GameView.STATE_NEW_ROUND and not self._is_panning then

			local newPosition, diff

			-- check which direction we're swiping
			if xStart > x then
				newPosition = GameView.RIGHT_POS
			elseif xStart < x then
				newPosition = GameView.LEFT_POS
			end

			-- update screen
			if newPosition == GameView.RIGHT_POS and self._screen_position == "left" then
				diff = xStart - x
				if diff >= 100 then
					self:_panCamera( newPosition, 700 )
				else
					self:_panCamera( self._screen_position, 100 )
				end
			else
				diff = x - xStart
				if diff >= 100 then
					self:_panCamera( newPosition, 700 )
				else
					self:_panCamera( self._screen_position, 100 )
				end
			end

		-- PROCESS TAP during "Tap To Continue"
		elseif phase == 'ended' and curr_state == GameView.STATE_END_ROUND then
			self:gotoState( GameView.TO_CALL_ROUND )

		end
	end


	--== AIMING ORB and ARROW

	if curr_state == GameView.STATE_AIMING_SHOT then

		local orb = self._shot_orb
		local arrow = self._shot_arrow

		local xOffset = ghost.x
		local yOffset = ghost.y

		-- Formula math.sqrt( ((event.y - yOffset) ^ 2) + ((event.x - xOffset) ^ 2) )
		local distanceBetween = mCeil(mSqrt( ((y - yOffset) ^ 2) + ((x - xOffset) ^ 2) ))

		orb.xScale = -distanceBetween * 0.02
		orb.yScale = -distanceBetween * 0.02

		-- Formula: 90 + (math.atan2(y2 - y1, x2 - x1) * 180 / PI)
		local angleBetween = mCeil(mAtan2( (y - yOffset), (x - xOffset) ) * 180 / mPi) + 90

		ghost.rotation = angleBetween + 180
		arrow.rotation = ghost.rotation
	end

	--== SWIPE START

	if not self._is_panning and curr_state == GameView.STATE_NEW_ROUND then
		local dg = self._dg_game

		if self._screen_position == GameView.LEFT_POS then
			-- Swipe left to go right
			if xStart > 180 then
				dg.x = x - xStart
				if dg.x > 0 then dg.x = 0 end
			end

		elseif self._screen_position == GameView.RIGHT_POS then
			-- Swipe right to go to the left
			dg.x = (x - xStart) - 480
			if dg.x < -480 then dg.x = -480 end
		end
	end

	return true
end


function GameView:enterFrame( event )
	-- print( "GameView:enterFrame", event )

	local char = self._character
	local dg = self._dg_game
	local curr_state = self:getState()

	if self._game_is_active then

		if char then
			-- CAMERA CONTROL
			if char.x > 240 and char.x < 720 and curr_state == GameView.STATE_SHOT_IN_PLAY then
				dg.x = -char.x + 240
			end

			-- CHECK IF GHOST GOES PAST SCREEN
			if not char.is_offscreen and curr_state == GameView.STATE_SHOT_IN_PLAY and ( char.x < 0 or char.x >= 960 ) then
				char.is_offscreen = true
			end

		end
	end

	return true
end




--======================================================--
-- START: STATE MACHINE

--== State Create ==--

function GameView:state_create( next_state, params )
	-- print( "GameView:state_create: >> ", next_state )
	if next_state == GameView.STATE_INIT then
		self:do_state_init( params )
	else
		print( "[WARNING] GameView:state_create", tostring( next_state ) )
	end
end


--== State Init ==--

function GameView:do_state_init( params )
	-- print( "GameView:do_state_init" )
	-- params = params or {}
	--==--
	self:setState( GameView.STATE_INIT )

	self._pause_overlay.is_active = false
	self._pause_overlay:show()

	self:_resetGameView()

	self:_createAllLevelObjects() -- after game is active

	self:gotoState( GameView.TO_NEW_ROUND )
end

function GameView:state_init( next_state, params )
	-- print( "GameView:state_init: >> ", next_state )
	if next_state == GameView.TO_NEW_ROUND then
		self:do_trans_new_round( params )
	else
		print( "[WARNING] GameView:state_create", tostring( next_state ) )
	end
end


--== State To New Round ==--

function GameView:do_trans_new_round( params )
	-- print( "GameView:do_trans_new_round" )
	-- params = params or {}
	--==--
	self:setState( GameView.TO_NEW_ROUND )

	local step1, step2

	step1 = function( e )
		-- pan camera to left
		self:_panCamera( GameView.LEFT_POS, 1000, { callback=step2, transition=easing.inOutExpo } )
	end

	step2 = function( e )

		self._screen_position = GameView.LEFT_POS

		-- create new ghost
		local o = self:_createGhost()
		o:toBack()

		self._sound_mgr:play( self._sound_mgr.NEW_ROUND )
	end

	timer.performWithDelay( 1000, step1, 1 )
end

function GameView:trans_new_round( next_state, params )
	-- print( "GameView:trans_new_round: >> ", next_state )
	if next_state == GameView.STATE_NEW_ROUND then
		self:do_state_new_round( params )
	else
		print( "[WARNING] GameView:trans_new_round", tostring( next_state ) )
	end
end


--== State New Round ==--

function GameView:do_state_new_round( params )
	-- print( "GameView:do_state_new_round" )
	-- params = params or {}
	--==--
	self:setState( GameView.STATE_NEW_ROUND )

	self._pause_overlay:show()
	self._character:toFront()
end

function GameView:state_new_round( next_state, params )
	-- print( "GameView:state_new_round: >> ", next_state )
	if next_state == GameView.STATE_INIT then
		self:do_state_init( params )
	elseif next_state == GameView.TO_AIMING_SHOT then
		self:do_trans_aiming_shot( params )
	else
		print( "[WARNING] GameView:state_new_round", tostring( next_state ) )
	end
end


--== State To Aiming Shot ==--

function GameView:do_trans_aiming_shot( params )
	-- print( "GameView:do_trans_aiming_shot" )
	-- params = params or {}
	--==--
	local orb = self._shot_orb
	local arrow = self._shot_arrow
	local char = self._character

	self:setState( GameView.TO_AIMING_SHOT )

	-- orb stuff
	orb.x, orb.y = char.x, char.y
	orb.xScale, orb.yScale = 0.1, 0.1
	orb.isVisible = true

	-- arrow stuff
	arrow.isVisible = true

	self:gotoState( GameView.STATE_AIMING_SHOT )
end

function GameView:trans_aiming_shot( next_state, params )
	-- print( "GameView:trans_aiming_shot: >> ", next_state )
	if next_state == GameView.STATE_AIMING_SHOT then
		self:do_state_aiming_shot( params )
	else
		print( "[WARNING] GameView:trans_aiming_shot", tostring( next_state ) )
	end
end


--== State Aiming Shot ==--

function GameView:do_state_aiming_shot( params )
	-- print( "GameView:do_state_aiming_shot" )
	-- params = params or {}
	self:setState( GameView.STATE_AIMING_SHOT )
	self:dispatchEvent( GameView.AIMING_EVENT )
end
function GameView:state_aiming_shot( next_state, params )
	-- print( "GameView:state_aiming_shot: >> ", next_state )
	if next_state == GameView.TO_SHOT_IN_PLAY then
		self:do_trans_shot_in_play( params )
	else
		print( "[WARNING] GameView:state_aiming_shot", tostring( next_state ) )
	end
end


--== State To Shot In Play ==--

function GameView:do_trans_shot_in_play( params )
	-- print( "GameView:do_trans_shot_in_play" )
	params = params or {}
	assert( params.shot )
	--==--
	local orb = self._shot_orb

	self:setState( GameView.TO_SHOT_IN_PLAY )
	self._sound_mgr:play( self._sound_mgr.BLAST_OFF )

	local step1 = function()
		self:gotoState( GameView.STATE_SHOT_IN_PLAY, params )
	end
	transition.to( orb, { time=175, xScale=0.1, yScale=0.1, onComplete=step1 })

end
function GameView:trans_shot_in_play( next_state, params )
	-- print( "GameView:trans_shot_in_play: >> ", next_state )
	if next_state == GameView.STATE_SHOT_IN_PLAY then
		self:do_state_shot_in_play( params )
	else
		print( "[WARNING] GameView:trans_shot_in_play", tostring( next_state ) )
	end
end


--== State Shot In Play ==--

function GameView:do_state_shot_in_play( params )
	-- print( "GameView:do_state_shot_in_play" )
	params = params or {}
	assert( params.shot )
	--==--
	local orb = self._shot_orb
	local arrow = self._shot_arrow
	local char = self._character
	local shot = params.shot

	self:setState( GameView.STATE_SHOT_IN_PLAY )

	-- remove aiming feedback
	orb.isVisible = false
	arrow.isVisible = false

	char:applyForce( shot.xForce, shot.yForce, char.x, char.y )

	self._pause_overlay:hide()

end
function GameView:state_shot_in_play( next_state, params )
	-- print( "GameView:state_shot_in_play: >> ", next_state )
	if next_state == GameView.TO_END_ROUND then
		self:do_trans_end_round( params )
	else
		print( "[WARNING] GameView:state_shot_in_play", tostring( next_state ) )
	end
end


--== State To End Round ==--

function GameView:do_trans_end_round( params )
	-- print( "GameView:do_trans_end_round" )
	--==--
	self:setState( GameView.TO_END_ROUND )

	-- remove the character, after delay
	timer.performWithDelay( 5, function() self:_destroyGhost() end)

	-- move camera to see what we've done
	local cb = function() self:gotoState( GameView.STATE_END_ROUND ) end
	self:_panCamera( GameView.RIGHT_POS, 500, {callback=cb} )

end
function GameView:trans_end_round( next_state, params )
	-- print( "GameView:trans_end_round: >> ", next_state )
	if next_state == GameView.STATE_END_ROUND then
		self:do_state_end_round( params )
	else
		print( "[WARNING] GameView:trans_end_round", tostring( next_state ) )
	end
end


--== State End Round ==--

function GameView:do_state_end_round( params )
	-- print( "GameView:do_state_end_round" )
	--==--
	self:setState( GameView.STATE_END_ROUND )

	self._text_is_blinking = true
end
function GameView:state_end_round( next_state, params )
	-- print( "GameView:state_end_round: >> ", next_state )
	if next_state == GameView.TO_CALL_ROUND then
		self:do_trans_call_round( params )
	else
		print( "[WARNING] GameView:state_end_round", tostring( next_state ) )
	end
end


--== State To Call Round ==--

function GameView:do_trans_call_round( params )
	-- print( "GameView:do_trans_call_round" )
	--==--
	self:setState( GameView.TO_CALL_ROUND )

	self._text_is_blinking = false

	if self._enemy_count == 0 then
		-- WIN
		timer.performWithDelay( 200, function() self:gotoState( GameView.STATE_END_GAME, {result=GameView.WIN_GAME} ) end )

	elseif self._enemy_count > 0 and self._game_lives == 0 then
		-- LOSE
		timer.performWithDelay( 200, function() self:gotoState( GameView.STATE_END_GAME, {result=GameView.LOSE_GAME} ) end )

	else
		-- NEXT ROUND
		timer.performWithDelay( 200, function() self:gotoState( GameView.TO_NEW_ROUND ) end )
	end

end
function GameView:trans_call_round( next_state, params )
	-- print( "GameView:trans_call_round: >> ", next_state )
	if next_state == GameView.TO_NEW_ROUND then
		self:do_trans_new_round( params )
	elseif next_state == GameView.STATE_END_GAME then
		self:do_state_end_game( params )
	else
		print("[WARNING] GameView:trans_call_round", tostring( next_state ) )
	end
end


--== State End Game ==--

function GameView:do_state_end_game( params )
	-- print( "GameView:do_state_end_game" )
	params = params or {}
	assert( params.result )
	--==--
	self:setState( GameView.STATE_END_GAME )

	-- Give score bonus depending on how many ghosts left
	local ghostBonus = self._game_lives * 20000
	self._game_score = self._game_score + ghostBonus

	self._best_score = self._game_score

	self._pause_overlay:hide()
	self._txt_continue.isVisible = false
	self._txt_score.isVisible = false

	-- stop game action, dispatches event
	self._game_is_active = false

	local data = {
		outcome = params.result,
		score = self._game_score,
		best_score = self._best_score,
	}
	self:dispatchEvent( GameView.GAME_OVER_EVENT, data )

end
function GameView:state_end_game( next_state, params )
	-- print( "GameView:state_end_game: >> ", next_state )
	if next_state == GameView.STATE_INIT then
		self:do_state_init( params )
	else
		print( "[WARNING] GameView:state_end_game", tostring( next_state ) )
	end
end

-- END: STATE MACHINE
--======================================================--





return GameView

