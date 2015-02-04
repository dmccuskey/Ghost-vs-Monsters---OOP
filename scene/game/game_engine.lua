--====================================================================--
-- game_engine.lua
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

local physics = require( "physics" )

local GameEngineConstants = require( "game_engine_constants" )

local ui = require( "ui" )
local Utils = require( "dmc_utils" )

local Objects = require( "dmc_objects" )
local GameObjectFactory = require( "game_objects" )
local HUDFactory = require( "hud_objects" )

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local CoronaBase = Objects.CoronaBase


--====================================================================--
-- Setup, Constants
--====================================================================--

local newRoundSound = audio.loadSound( "assets/sounds/newround.wav" )
local blastOffSound = audio.loadSound( "assets/sounds/blastoff.wav" )


--====================================================================--
-- Support Functions
--====================================================================--

local function DisplayReferenceFactory( name )

	if name == "TopLeft" then
		return display.TopLeftReferencePoint
	elseif name == "CenterLeft" then
		return display.CenterLeftReferencePoint
	elseif name == "BottomLeft" then
		return display.BottomLeftReferencePoint
	else
		return display.TopLeftReferencePoint
	end

end

-- comma_value()
--
local function comma_value( amount )
	local formatted = amount
	while true do
		formatted, k = string.gsub( formatted, "^(-?%d+)(%d%d%d)", '%1,%2' )
		if ( k==0 ) then
			break
		end
	end

	return formatted
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
-- Game Engine class
--====================================================================--

local GameEngine = inheritsFrom( CoronaBase )
GameEngine.NAME = "Game Engine"

-- Layer in the constants for the Game Engine
Utils.extend( GameEngineConstants, GameEngine )


-- _init()
--
-- one of the base methods to override for dmc_objects
-- put on our object properties
--
function GameEngine:_init( data )
	--print( "GameEngine:_init" )

	-- be sure to call this first !
	self:superCall( "_init" )

	-- == Create Properties ==
	self.game_data = data
	self._gameIsActive = false	-- our saved value
	self._character = nil

	self._screenPosition = ""	-- "left" or "right"
	self._isPanning = false

	self.layer = {}

	self.lifeIcons = {}
	self._gameLives = 0
	self._enemyCount = 0

	self._bestScore = -1
	self._gameScore = 0	-- our saved value

	-- the game hud display
	self.hudRefs = {}	-- continue text, pause button, score text

	self.continueText = nil	-- the display object
	self._continueTextTimer = nil

	self._current_state = ""
	self._trackingTimer = nil

	-- start physics engine here, so it doesn't crash
	self:_startPhysics( true )
	physics.setDrawMode( "normal" )	-- set to "normal" "debug" or "hybrid" to see collision boundaries
	physics.setGravity( 0, 11 )	--> 0, 9.8 = Earth-like gravity

end

function GameEngine:_undoInit()

	if self._character ~= nil then
		self._character = nil
	end
	if self._continueTextTimer then
		timer.cancel( self._continueTextTimer )
		self._continueTextTimer = nil
	end
	if self._trackingTimer then
		timer.cancel( self._trackingTimer )
		self._trackingTimer = nil
	end

	self:_stopPhysics()

	Utils.destroy( self.game_data )
end



-- _createView()
--
-- one of the base methods to override for dmc_objects
-- assemble the images for our object
--
function GameEngine:_createView()
	--print( "GameEngine:_createView" )

	local d

	local gameGroup = display.newGroup()
	self.layer.gameGroup = gameGroup
	self:insert( gameGroup )

	-- background items
	d = display.newGroup()
	self.layer.backgroundGroup = d
	gameGroup:insert( d )

	self:_createBackgroundItems()

	-- physics background items
	d = display.newGroup()
	self.layer.physicsBackgroundGroup = d
	gameGroup:insert( d )

	self:_createPhysicsBackgroundItems()

	-- shot feedback items
	d = display.newGroup()
	self.layer.shot = d
	gameGroup:insert( d )

	self:_createShotFeedback()

	-- physics game items
	d = display.newGroup()
	self.layer.physicsGameGroup = d
	gameGroup:insert( d )

	self:_createPhysicsGameItems()

	-- physics forground game items
	d = display.newGroup()
	self.layer.physicsForegroundGroup = d
	gameGroup:insert( d )

	self:_createPhysicsForegroundItems()

	-- physics trailgroup items
	d = display.newGroup()
	self.layer.trailGroup = d
	gameGroup:insert( d )

	-- game details hud
	d = display.newGroup()
	self.layer.details = d
	self:insert( d )

	self:_createGameDetailsHUD()

end

function GameEngine:_undoCreateView()
	--print( "GameEngine:_undoCreateView" )

	local obj, group
	local layer = self.layer
	local gameGroup = layer.gameGroup

	-- Game Details HUD
	self:_removeGameDetailsHUD()
	gameGroup:remove( layer.details )

	-- Tracking Group
	group = layer.trailGroup
	for i = group.numChildren, 1, -1 do
		group:remove( i )
	end
	gameGroup:remove( layer.trailGroup )

	-- physics forground items
	self:_removeDataItems( layer.physicsBackgroundGroup, { isPhysics=true } )
	gameGroup:remove( layer.physicsBackgroundGroup )

	-- physics game group
	self:_removeDataItems( layer.physicsGameGroup, { isPhysics=true } )
	gameGroup:remove( layer.physicsGameGroup )

	-- shot feedback items
	group = layer.shot
	for i = group.numChildren, 1, -1 do
		group:remove( i )
	end
	gameGroup:remove( layer.shot )

	-- physics background items
	self:_removeDataItems( layer.physicsBackgroundGroup, { isPhysics=true } )
	gameGroup:remove( layer.physicsBackgroundGroup )

	-- background items
	self:_removeDataItems( layer.backgroundGroup )
	gameGroup:remove( layer.backgroundGroup )

	layer.gameGroup:removeSelf()
end


-- _initComplete()
--
function GameEngine:_initComplete()
	--print( "GameEngine:_initComplete" )

	self:_pausePhysics()

	Runtime:addEventListener( "touch", self )
	Runtime:addEventListener( "enterFrame", self )
end
function GameEngine:_undoInitComplete()
	--print( "GameEngine:_undoInitComplete" )

	Runtime:removeEventListener( "touch", self )
	Runtime:removeEventListener( "enterFrame", self )
end


function GameEngine:startGamePlay()
	--print( "GameEngine:startGamePlay" )
	self:updateState( GameEngine.STATE_INIT )
end
function GameEngine:pauseGamePlay()
	--print( "GameEngine:pauseGamePlay" )
	self.gameIsActive = false
end


function GameEngine:_startPhysics( param )
	--print( "GameEngine:_startPhysics" )
	self.physicsIsActive = true
	physics.start( param )
end

function GameEngine:_pausePhysics()
	--print( "GameEngine:_pausePhysics" )
	self.physicsIsActive = false
	physics.pause()
end

function GameEngine:_stopPhysics()
	--print( "GameEngine:_stopPhysics" )
	self.physicsIsActive = false
	physics.stop()
end


function GameEngine:_dispatchAnEvent( eventType, eventParams )
	--print( "GameEngine:_dispatchAnEvent : " .. eventType )

	local e = {
		name=GameEngine.GAME_ENGINE_EVENT,
		type=eventType
	}

	if eventType == GameEngine.AIMING_SHOT then
		-- nothing to add

	elseif eventType == GameEngine.GAME_ISACTIVE then
		if eventParams == nil or eventParams.value == nil then
			print( "bad parameters for eventType: " .. eventType )
		end
		e.value = eventParams.value

	elseif eventType == GameEngine.CHARACTER_REMOVED then
		if eventParams == nil or eventParams.target == nil then
			print( "bad parameters for eventType: " .. eventType )
		end
		e.target = eventParams.target

	end

	self:dispatchEvent( e )
end


-- _addDataItems()
--
-- loop through game data items and put on stage
--
function GameEngine:_addDataItems( data, group, params )
	--print( "GameEngine:_addDataItems" )

	local params = params or {}
	local isPhysics = params.isPhysics or false

	local o, d

	for _, item in ipairs( data ) do
		-- item is one of the entries in our data file

		-- most of the creation magic happens in this line
		-- game objects are created from level data entries
		o = GameObjectFactory.create( item.name, self )

		-- sanity check - if we have something, then process it
		if o then
			-- process attributes found in the level data
			if item.reference then
				o:setReferencePoint( DisplayReferenceFactory( item.reference ) )
			end
			-- TODO: process special properties and layer the rest
			if item.rotation then o.rotation = item.rotation end
			if item.alpha then o.alpha = item.alpha end
			if item.x then o.x = item.x end
			if item.y then o.y = item.y end

			-- add new object to the display group and physics engine
			d = o
			if o.isa ~= nil and o:isa( CoronaBase ) then
				-- type is of dmc_object
				d = o.display
			end
			if isPhysics then
				physics.addBody( d, o.physicsType, o.physicsProperties )
			end
			group:insert( d )

			-- count enemies being place on screen
			if o.myName == self.game_data.info.enemyName then
				self._enemyCount = self._enemyCount + 1
				o:addEventListener( o.UPDATE_EVENT, self )
			end
		end
	end

end

-- _removeDataItems()
--
-- loop through display groups and remove their items
--
function GameEngine:_removeDataItems( group, params )
	--print( "GameEngine:_removeDataItems" )
	local params = params or {}
	local isPhysics = params.isPhysics or false
	local o, d

	for i = group.numChildren, 1, -1 do
		o = group[ i ]
		-- TODO: make this a little cleaner. need API for it
		if o.__dmcRef then
			o = o.__dmcRef
		end
		if isPhysics then
			d = o
			if o.isa ~= nil and o:isa( CoronaBase ) then
				d = o.display
			end
			if physics.removeBody and not physics.removeBody( d ) then
				print( "\n\nERROR: COULD NOT REMOVE BODY FROM PHYSICS ENGINE\n\n")
			end
		end
		if o.myName ~= self.game_data.info.enemyName then
			o:removeSelf()
		else
			o:removeEventListener( o.UPDATE_EVENT, self )
			-- let the character know that GE is done, can remove itself
			self:_dispatchAnEvent( GameEngine.CHARACTER_REMOVED, { target=o } )
		end
	end

end

--== Game Character Creation and Event Handlers ==--

function GameEngine:_createGhost()
	--print( "GameEngine:_createGhost" )

	local o = GameObjectFactory.create( self.game_data.info.characterName, self )

	physics.addBody( o.display, o.physicsType, o.physicsProperties )
	self.layer.physicsForegroundGroup:insert( o.display )
	o.isBodyActive = false
	o:addEventListener( o.UPDATE_EVENT, self )

	self._character = o

	return o
end

function GameEngine:characterUpdateEvent( event )
	--print( "GameEngine:characterUpdateEvent " .. event.type )
	local target = event.target
	local mCeil = math.ceil

	-- Process Ghost
	if target.myName == self.game_data.info.characterName then

		if event.type == target.STATE_LIVING then
			self:updateState( GameEngine.STATE_NEW_ROUND )

		elseif event.type == target.STATE_FLYING then
			self:isTrackingCharacter( true )

		elseif event.type == target.STATE_HIT then
			self.gameScore = self.gameScore + 500
			self:isTrackingCharacter( false )

		elseif event.type == target.STATE_DYING then
			self.gameLives = self.gameLives - 1

		elseif event.type == target.STATE_DEAD then

			if physics.removeBody and not physics.removeBody( target.display ) then
				print( "\n\nERROR: COULD NOT REMOVE BODY FROM PHYSICS ENGINE\n\n")
			end
			target:removeEventListener( target.UPDATE_EVENT, self )
			self._character = nil

			-- let the character know that GE is done, can remove itself
			self:_dispatchAnEvent( GameEngine.CHARACTER_REMOVED, { target=target } )
			self:updateState( GameEngine.TO_END_ROUND )

		end

		return true

	-- Process Monster
	elseif target.myName == self.game_data.info.enemyName then

		if event.type == target.STATE_LIVING then
			self:updateState( GameEngine.STATE_NEW_ROUND )

		elseif event.type == target.STATE_DEAD then

			self._enemyCount = self._enemyCount - 1

			local newScore = self.gameScore + mCeil( 5000 * event.force )
			self.gameScore = newScore

			target:removeEventListener( target.UPDATE_EVENT, self )

			if physics.removeBody and not physics.removeBody( target.display ) then
				print( "\n\nERROR: COULD NOT REMOVE BODY FROM PHYSICS ENGINE\n\n")
			end

			-- let the character know that GE is done, can remove itself
			self:_dispatchAnEvent( GameEngine.CHARACTER_REMOVED, { target=target } )
		end

		return true
	end
end



-- _createBackground()
--
function GameEngine:_createBackgroundItems()
	if self.game_data.backgroundItems then
		self:_addDataItems( self.game_data.backgroundItems, self.layer.backgroundGroup )
	end
end

-- _createPhysicsBackgroundItems()
--
function GameEngine:_createPhysicsBackgroundItems()
	if self.game_data.physicsBackgroundItems then
		self:_addDataItems( self.game_data.physicsBackgroundItems, self.layer.physicsBackgroundGroup, { isPhysics=true } )
	end
end

-- _createPhysicsGameItems()
--
function GameEngine:_createPhysicsGameItems()
	if self.game_data.physicsGameItems then
		self:_addDataItems( self.game_data.physicsGameItems, self.layer.physicsGameGroup, { isPhysics=true } )
	end
end
-- _createPhysicsForegroundItems()
--
function GameEngine:_createPhysicsForegroundItems()
	if self.game_data.physicsForgroundItems then
		self:_addDataItems( self.game_data.physicsForgroundItems, self.layer.physicsForegroundGroup, { isPhysics=true } )
	end
end


-- _createShotFeedback()
--
function GameEngine:_createShotFeedback()

	local group = self.layer.shot

	-- shot orb
	local img = display.newImageRect( "assets/game_objects/orb.png", 96, 96 )
	img.xScale = 1.0; img.yScale = 1.0
	img.isVisible = false
	img.alpha = 0.75
	group:insert( img )

	-- shot arrow
	img = display.newImageRect( "assets/game_objects/arrow.png", 240, 240 )
	img.x = 150; img.y = 195
	img.isVisible = false
	group:insert( img )


end

-- _createGameDetailsHUD()
--
function GameEngine:_createGameDetailsHUD()

	local group = self.layer.details
	local hudRefs = self.hudRefs
	local img, txt

	-- TWO BLACK RECTANGLES AT TOP AND BOTTOM (for those viewing from iPad)
	img = display.newRect( 0, -160, 480, 160 )
	img:setFillColor( 0, 0, 0, 255 )
	group:insert( img )

	img = display.newRect( 0, 320, 480, 160 )
	img:setFillColor( 0, 0, 0, 255 )
	group:insert( img )


	-- LIVES DISPLAY
	local y_base = 18
	local x_offset = 25
	local prev

	img = GameObjectFactory.create( "life-icon" )
	img.x = 20; img.y = y_base
	group:insert( img )
	table.insert( self.lifeIcons, img )
	prev = img

	img = GameObjectFactory.create( "life-icon" )
	img.x = prev.x + x_offset; img.y = y_base
	group:insert( img )
	table.insert( self.lifeIcons, img )
	prev = img

	img = GameObjectFactory.create( "life-icon" )
	img.x = prev.x + x_offset; img.y = y_base
	group:insert( img )
	table.insert( self.lifeIcons, img )
	prev = img

	img = GameObjectFactory.create( "life-icon" )
	img.x = prev.x + x_offset; img.y = y_base
	group:insert( img )
	table.insert( self.lifeIcons, img )


	-- SCORE DISPLAY
	txt = display.newText( "0", 470, 22, "Helvetica-Bold", 52 )
	txt:setTextColor( 255, 255, 255, 255 )	--> white
	txt.xScale = 0.5; txt.yScale = 0.5	--> for clear retina display text
	--txt.x = ( 480 - ( txt.contentWidth * 0.5 ) ) - 15
	txt.y = 20

	group:insert( txt )
	hudRefs[ "score-text" ] = txt
	self.gameScore = 0


	-- TAP TO CONTINUE DISPLAY
	txt = display.newText( "TAP TO CONTINUE", 240, 18, "Helvetica", 36 )
	txt:setTextColor( 249, 203, 64, 255 )
	txt.xScale = 0.5; txt.yScale = 0.5
	txt.x = 240; txt.y = 18
	--txt.isVisible = false

	group:insert( txt )
	hudRefs[ "continue-text" ] = txt

	-- PAUSE BUTTON HUD
	img = HUDFactory.create( "pausescreen-hud" )
	group:insert( img.display )

	hudRefs[ "pause-hud" ] = img
	hudRefs[ "pause-hud-func" ] = Utils.createObjectCallback( self, self.pauseHUDTouchHandler )
	img:addEventListener( "change", hudRefs[ "pause-hud-func" ] )

end

function GameEngine:_removeGameDetailsHUD()

	local hudRefs = self.hudRefs
	local group = self.layer.details
	local obj

	-- Pause Button HUD
	obj = hudRefs[ "pause-hud" ]
	hudRefs[ "pause-hud" ] = nil
	obj:removeEventListener( "change", Utils.createObjectCallback( self, self.pauseScreenTouchHandler ) )
	--obj:removeSelf() TODO: after removeSelf is done in pause hud
	obj:removeSelf()

	-- continue text
	obj = hudRefs[ "continue-text" ]
	hudRefs[ "continue-text" ] = nil
	obj:removeSelf()

	-- score text
	obj = hudRefs[ "score-text" ]
	hudRefs[ "score-text" ] = nil
	obj:removeSelf()

	hudRefs = nil

	-- life icons
	local t = self.lifeIcons
	for i = #t, 1, -1 do
		t[i]:removeSelf()
		table.remove( t, i )
	end
	self.lifeIcons = nil

	-- black rectangles
	for i = group.numChildren, 1, -1 do
		group:remove( i )
	end

end




function GameEngine:pauseHUDTouchHandler( event )
	--print("GameEngine:pauseHUDTouchHandler()")

	if event.label == "pause" then
		-- in this sense, "active" means "pause is activated"
		self.gameIsActive = ( event.state ~= "active" )

	elseif event.label == "menu" then
		self:_stopPhysics()

		local gameEngineEvent = {
			name = GameEngine.GAME_EXIT_EVENT,
		}
		self:dispatchEvent( gameEngineEvent )

	end

	return true
end




--== Getters and Setters ==--

-- gameLives
--
function GameEngine.__getters:gameLives()
	return self._gameLives
end
function GameEngine.__setters:gameLives( value )

	-- clean up value
	if value < 0 then value = 0 end
	self._gameLives = value

	-- update icons
	for i, item in ipairs( self.lifeIcons ) do
		if i > self._gameLives then
			item.alpha = 0.3
		end
	end
end

-- gameScore
--
function GameEngine.__getters:gameScore()
	return self._gameScore
end
function GameEngine.__setters:gameScore( value )

	-- clean up value
	if value < 0 then value = 0 end
	self._gameScore = value

	-- update scoreboard
	local txtHud = self.hudRefs[ "score-text" ]
	txtHud.text = comma_value( value )
	txtHud.x = ( 480 - ( txtHud.contentWidth * 0.5 ) ) - 15
end

-- bestScore
--
function GameEngine.__getters:bestScore()
	local bestScoreFilename = self.game_data.info.restartLevel .. ".data"
	if self._bestScore == -1 then
		self._bestScore =  tonumber( loadValue( bestScoreFilename ) )
	end
	return self._bestScore
end
function GameEngine.__setters:bestScore( value )
	local bestScoreFilename = self.game_data.info.restartLevel .. ".data"

	-- clean up value
	if value < 0 then value = 0 end
	self._bestScore = value

	saveValue( bestScoreFilename, tostring( self.bestScore ) )
end

-- isContinueTextBlinking
--
function GameEngine.__getters:isContinueTextBlinking()
	return ( self._continueTextTimer ~= nil )
end
function GameEngine.__setters:isContinueTextBlinking( value )
	--print("GameEngine.__setters:isContinueTextBlinking")

	local continueText = self.hudRefs[ "continue-text" ]

	-- stop any flashing currently happening
	if self._continueTextTimer ~= nil then
		timer.cancel( self._continueTextTimer )
		self._continueTextTimer = nil
	end

	if not value then
		continueText.isVisible = false
	else
		local continueBlink = function()

			local startBlinking = function()
				continueText.isVisible = not continueText.isVisible
			end
			self._continueTextTimer = timer.performWithDelay( 350, startBlinking, 0 )
		end
		timer.performWithDelay( 300, continueBlink, 1 )
	end

end

-- gameIsActive
--
function GameEngine.__getters:gameIsActive()
	return self._gameIsActive
end
function GameEngine.__setters:gameIsActive( value )

	self._gameIsActive = value

	if value == true then
		self:_startPhysics()
	else
		self:_pausePhysics()
	end

	self:_dispatchAnEvent( GameEngine.GAME_ISACTIVE, { value = value } )

end


-- panCamera()
--
-- ( left/right, time, callback )
--
function GameEngine:panCamera( direction, duration, params )
	--print( "GameEngine:panCamera" )

	-- params - callback, transition
	local params = params or {}

	local xvalue
	if direction == "left" then
		xvalue = 0
	else
		xvalue = -480
	end

	local f = function()
		local c = params.callback
		self._isPanning = false
		self._screenPosition = direction
		if c then c() end
	end

	self._isPanning = true
	transition.to( self.layer.gameGroup, { time=duration, x=xvalue, transition=params.transition, onComplete=f } )

end



--======================================================--
--== START: GAME ENGINE STATE MACHINE                 ==--

function GameEngine:updateState( state, data )
	--print("GameEngine:updateState")
	local f = self[ state ]
	if f then
		f( self, data )
	else
		print( "\n\nERROR: " .. tostring( state ) .. "\n\n")
	end

end



function GameEngine:state_initialize( data )
	--print("GameEngine.STATE_INIT")
	self.gameIsActive = true

	self.layer.gameGroup.x = -480
	self._screenPosition = "right"
	self.gameLives = 4 -- DEBUG

	self.hudRefs[ "pause-hud" ].isVisible = false

	self._current_state = GameEngine.STATE_INIT
	self:updateState( GameEngine.TO_NEW_ROUND )
	self.isContinueTextBlinking = false
end
function GameEngine:trans_new_round( data )
	--print("GameEngine.TO_NEW_ROUND")

	self._current_state = GameEngine.TO_NEW_ROUND

	local f2 = function( e )

		self._screenPosition = "left"

		-- create new ghost
		local g = self:_createGhost()
		g:toBack()

		audio.play( newRoundSound )
	end

	-- pans to left
	local f1 = function( e )
		self:panCamera( "left", 1000, { callback=f2, transition=easing.inOutExpo } )
	end

	timer.performWithDelay( 1000, f1, 1 )
end
function GameEngine:state_new_round( data )
	--print("GameEngine.STATE_NEW_ROUND")

	self.hudRefs[ "pause-hud" ].isVisible = true
	self._character:toFront()

	self._current_state = GameEngine.STATE_NEW_ROUND
end
function GameEngine:trans_aiming_shot( data )
	--print("GameEngine.TO_AIMING_SHOT")

	local orb = self.layer.shot[1]
	local arrow = self.layer.shot[2]
	local char = self._character

	--self.layer.shot.isVisible = true

	self:_dispatchAnEvent( GameEngine.AIMING_SHOT )

	-- orb stuff
	orb.x = char.x; orb.y = char.y
	orb.xScale = 0.1; orb.yScale = 0.1
	orb.isVisible = true

	-- arrow stuff
	arrow.isVisible = true

	self._current_state = GameEngine.TO_AIMING_SHOT
	self:updateState( GameEngine.AIMING_SHOT )
end
function GameEngine:state_aiming_shot( data )
	--print("GameEngine.AIMING_SHOT")

	self._current_state = GameEngine.AIMING_SHOT

end
function GameEngine:trans_shot_in_play( data )
	--print("GameEngine.TO_SHOT_IN_PLAY")

	local shotOrb = self.layer.shot[1]
	local f1 = function()
		self:updateState( GameEngine.STATE_SHOT_IN_PLAY, data )
	end

	audio.play( blastOffSound )
	transition.to( shotOrb, { time=175, xScale=0.1, yScale=0.1, onComplete=f1 })

	self._current_state = GameEngine.TO_SHOT_IN_PLAY
end
function GameEngine:state_shot_in_play( data )
	--print("GameEngine.STATE_SHOT_IN_PLAY")

	local orb = self.layer.shot[1]
	local arrow = self.layer.shot[2]
	local char = self._character

	-- remove aiming feedback
	orb.isVisible = false
	arrow.isVisible = false

	char:applyForce( data.xForce, data.yForce, char.x, char.y )

	self.hudRefs[ "pause-hud" ].isVisible = false

	self._current_state = GameEngine.STATE_SHOT_IN_PLAY
end
function GameEngine:trans_end_round( data )
	--print("GameEngine.TO_END_ROUND")
	self._current_state = GameEngine.TO_END_ROUND

	-- remove the character from us
	self._character = nil

	-- move camera to see what we've done
	self:panCamera( "right", 500, { callback=function() self:updateState( GameEngine.STATE_END_ROUND ) end })
end
function GameEngine:state_end_round( data )
	--print("GameEngine.STATE_END_ROUND")

	self.isContinueTextBlinking = true

	self._current_state = GameEngine.STATE_END_ROUND
end
function GameEngine:trans_call_round( data )
	--print("GameEngine.TO_CALL_ROUND")
	self._current_state = GameEngine.TO_CALL_ROUND

	self.isContinueTextBlinking = false

	if self._enemyCount == 0 then
		-- WIN
		timer.performWithDelay( 200, function() self:updateState( GameEngine.STATE_END_GAME, "win" ); end, 1 )

	elseif self._enemyCount > 0 and self._gameLives == 0 then
		-- LOSE
		timer.performWithDelay( 200, function() self:updateState( GameEngine.STATE_END_GAME, "lose" ); end, 1 )

	else
		-- NEXT ROUND
		timer.performWithDelay( 200, function() self:updateState( GameEngine.TO_NEW_ROUND ); end, 1 )
	end

end
function GameEngine:state_end_game( data )
	--print("GameEngine.STATE_END_GAME")

	-- Give score bonus depending on how many ghosts left
	local ghostBonus = self.gameLives * 20000
	self.gameScore = self.gameScore + ghostBonus

	-- Check High Score
	if self.gameScore > self.bestScore then
		self.bestScore = self.gameScore
	end

	-- hide HUD groups
	self.hudRefs[ "pause-hud" ].isVisible = false
	self.hudRefs[ "continue-text" ].isVisible = false
	self.hudRefs[ "score-text" ].isVisible = false


	-- dispatch game over event
	local gameEngineEvent = {
		name = GameEngine.GAME_OVER_EVENT,
		outcome = data,
		bestScore = self.bestScore,
		score = self.gameScore
	}
	self:dispatchEvent( gameEngineEvent )

	-- stop game action
	self.gameIsActive = false

	self._current_state = GameEngine.STATE_END_GAME
end

--== END: GAME ENGINE STATE MACHINE                   ==--
--======================================================--


function GameEngine:isTrackingCharacter( value )
	--print("GameEngine:isTrackingCharacter " .. tostring( value ))

	local trailGroup = self.layer.trailGroup

	if value then
		-- clear the last trail
		for i = trailGroup.numChildren,1,-1 do
			local child = trailGroup[i]
			child.parent:remove( child )
			child = nil
		end

		-- start making new dots
		local startDots = function()
			local odd = true
			local char = self._character
			local dotTimer

			local createDot = function()
				local trailDot
				local size = ( odd and 1.5 ) or 2.5
				trailDot = display.newCircle( trailGroup, char.x, char.y, size )
				trailDot:setFillColor( 255, 255, 255, 255 )

				--trailGroup:insert( trailDot )
				odd = not odd
			end

			self._trackingTimer = timer.performWithDelay( 50, createDot, 50 )
		end
		startDots()

	else
		if self._trackingTimer then timer.cancel( self._trackingTimer ) end
	end
end




function GameEngine:touch( event )
	--print("GameEngine:onScreenTouchHandler")

	local mCeil = math.ceil
	local mAtan2 = math.atan2
	local mPi = math.pi
	local mSqrt = math.sqrt

	local phase = event.phase
	local curr_state = self._current_state

	local ghostObject = self._character

	--== TOUCH HANDLING, active game
	if self.gameIsActive then

		-- BEGINNING OF AIM
		if phase == "began" and curr_state == GameEngine.STATE_NEW_ROUND and event.xStart > 115 and event.xStart < 180 and event.yStart > 160 and event.yStart < 230 and self._screenPosition == "left" then

			self:updateState( GameEngine.TO_AIMING_SHOT )

		-- RELEASE THE DUDE
		elseif phase == "ended" and curr_state == GameEngine.AIMING_SHOT then

			local x = event.x
			local y = event.y
			local xF = (-1 * (x - ghostObject.x)) * 2.15	--> 2.75
			local yF = (-1 * (y - ghostObject.y)) * 2.15	--> 2.75

			local data = { xForce=xF, yForce=yF  }
			self:updateState( GameEngine.TO_SHOT_IN_PLAY, data )

		-- SWIPE SCREEN
		elseif phase == "ended" and curr_state == GameEngine.STATE_NEW_ROUND and not self._isPanning then

			local newPosition, diff

			-- check which direction we're swiping
			if event.xStart > event.x then
				newPosition = "right"
			elseif event.xStart < event.x then
				newPosition = "left"
			end

			-- update screen
			if newPosition == "right" and self._screenPosition == "left" then
				diff = event.xStart - event.x
				if diff >= 100 then
					self:panCamera( newPosition, 700 )
				else
					self:panCamera( self._screenPosition, 100 )
				end
			else
				diff = event.x - event.xStart
				if diff >= 100 then
					self:panCamera( newPosition, 700 )
				else
					self:panCamera( self._screenPosition, 100 )
				end
			end

		-- PROCESS TAP during "Tap To Continue"
		elseif phase == "ended" and curr_state == GameEngine.STATE_END_ROUND then
			self:updateState( GameEngine.TO_CALL_ROUND )

		end
	end


	--== AIMING ORB and ARROW

	if curr_state == GameEngine.AIMING_SHOT then

		local shotOrb = self.layer.shot[1]
		local shotArrow = self.layer.shot[2]

		local xOffset = ghostObject.x
		local yOffset = ghostObject.y

		-- Formula math.sqrt( ((event.y - yOffset) ^ 2) + ((event.x - xOffset) ^ 2) )
		local distanceBetween = mCeil(mSqrt( ((event.y - yOffset) ^ 2) + ((event.x - xOffset) ^ 2) ))

		shotOrb.xScale = -distanceBetween * 0.02
		shotOrb.yScale = -distanceBetween * 0.02

		-- Formula: 90 + (math.atan2(y2 - y1, x2 - x1) * 180 / PI)
		local angleBetween = mCeil(mAtan2( (event.y - yOffset), (event.x - xOffset) ) * 180 / mPi) + 90

		ghostObject.rotation = angleBetween + 180
		shotArrow.rotation = ghostObject.rotation
	end

	--== SWIPE START

	if not self._isPanning and curr_state == GameEngine.STATE_NEW_ROUND then

		local gameGroup = self.layer.gameGroup

		if self._screenPosition == "left" then
			-- Swipe left to go right
			if event.xStart > 180 then
				gameGroup.x = event.x - event.xStart

				if gameGroup.x > 0 then
					gameGroup.x = 0
				end
			end

		elseif self._screenPosition == "right" then
			-- Swipe right to go to the left
			gameGroup.x = (event.x - event.xStart) - 480

			if gameGroup.x < -480 then
				gameGroup.x = -480
			end
		end
	end

	return true
end

function GameEngine:enterFrame( event )

	local char = self._character
	local gameGroup = self.layer.gameGroup
	local state = self._current_state

	if self.gameIsActive then

		if char then
			-- CAMERA CONTROL
			if char.x > 240 and char.x < 720 and state == GameEngine.STATE_SHOT_IN_PLAY then
				gameGroup.x = -char.x + 240
			end

			-- CHECK IF GHOST GOES PAST SCREEN
			if not char.isOffscreen and state == GameEngine.STATE_SHOT_IN_PLAY and ( char.x < 0 or char.x >= 960 ) then
				char.isOffscreen = true
			end

		end

	end

	return true
end



return GameEngine

