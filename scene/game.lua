--====================================================================--
-- scene/game.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Ghost vs Monsters : Game Scene
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Imports


local composer = require 'composer'

local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

--== Components

local GameView = require 'scene.game.game_view'
-- local GameOverOverlay = require 'scene.game.gameover_overlay'
local LoadOverlay = require 'component.load_overlay'



--====================================================================--
--== Setup, Constants


local scene = nil -- composer scene



--====================================================================--
--== Game Scene Class
--====================================================================--



local GameScene = {}

StatesMixModule.patch( GameScene )

GameScene.view = nil -- set in composer

--== State Constants

GameScene.STATE_CREATE = 'state_create'
GameScene.STATE_INIT = 'state_init'
GameScene.STATE_LOADING = 'state_loading'
GameScene.STATE_PLAY = 'state_play'
GameScene.STATE_GAME_OVER = 'state_game_over'
GameScene.STATE_COMPLETE = 'state_complete'


--======================================================--
-- Start: Emulate DMC Setup

function GameScene:__init__( params )
	-- print( "GameScene:__init__", params )
	--==--

	--== Properties ==--

	self._width = params.width
	self._height = params.height

	self._level_data = params.level_data

	--== Services ==--

	self._level_mgr = gService.level_mgr
	self._sound_mgr = gService.sound_mgr

	--== Display Objects ==--

	self._dg_main = nil
	self._dg_overlay = nil

	self._view_game = nil
	self._view_game_f = nil
	self._view_gameover = nil
	self._view_gameover_f = nil
	self._view_load = nil
	self._view_load_f = nil

	self:setState( GameScene.STATE_CREATE )
end


function GameScene:__createView__()
	-- print( "GameScene:__createView__" )

	-- local W, H = self._width , self._height
	-- local H_CENTER, V_CENTER = W*0.5, H*0.5
	local view = self.view
	local o -- object

	-- main group

	o = display.newGroup()
	view:insert( o )
	self._dg_main = o

	-- overlay group

	o = display.newGroup()
	view:insert( o )
	self._dg_overlay = o

end

function GameScene:__undoCreateView__()
	-- print( "GameScene:__undoCreateView__" )

	local o

	o = self._dg_overlay
	o:removeSelf()
	self._dg_overlay = nil

	o = self._dg_main
	o:removeSelf()
	self._dg_main = nil
end

function GameScene:__initComplete__()
	-- print( "GameScene:__initComplete__" )
	self:_createGameView()
	self:gotoState( self.STATE_LOADING )
end

function GameScene:__undoInitComplete__()
	-- print( "GameScene:__undoInitComplete__" )
	self:_destroyGameView()
end

-- End: Emulate DMC Setup
--======================================================--



--====================================================================--
--== Public Methods


-- getGameView()
--
-- setup as part of communication example
--
function GameScene:getGameView()
	return self._view_game
end



--====================================================================--
--== Private Methods


function GameScene:_createLoadOverlay()
	-- print( "GameScene:_createLoadOverlay" )
	if self._view_load then self:_destroyLoadOverlay() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_overlay
	local o, f

	o = LoadOverlay:new{
	width=W, height=H
	}
	o.x, o.y = H_CENTER, 0

	dg:insert( o.view )
	self._view_load = o

	f = Utils.createObjectCallback( self, self._loadViewEvent_handler )
	o:addEventListener( o.EVENT, f )

	self._view_load_f = f

	-- testing
	timer.performWithDelay( 500, function() o.percent_complete=25 end )
	timer.performWithDelay( 1000, function() o.percent_complete=50 end )
	timer.performWithDelay( 1500, function() o.percent_complete=75 end )
	timer.performWithDelay( 2000, function() o.percent_complete=100 end )
end

function GameScene:_destroyLoadOverlay()
	-- print( "GameScene:_destroyLoadOverlay" )
	local o, f = self._view_load, self._view_load_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_load_f = nil
	end
	if o then
		o:removeSelf()
		self._view_load = nil
	end
end


function GameScene:_createGameOverOverlay()
	-- print( "GameScene:_createGameOverOverlay" )
	if self._view_gameover then self:_destroyLoadOverlay() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_overlay
	local o, f

	-- o = LoadOverlay:new{
	-- width=W, height=H
	-- }
	-- o.x, o.y = H_CENTER, 0

	-- dg:insert( o.view )
	-- self._view_gameover = o

	-- f = Utils.createObjectCallback( self, self._loadViewEvent_handler )
	-- o:addEventListener( o.EVENT, f )

	-- self._view_gameover_f = f

	-- -- testing
	-- timer.performWithDelay( 500, function() o.percent_complete=25 end )
	-- timer.performWithDelay( 1000, function() o.percent_complete=50 end )
	-- timer.performWithDelay( 1500, function() o.percent_complete=75 end )
	-- timer.performWithDelay( 2000, function() o.percent_complete=100 end )
end

function GameScene:_destroyGameOverOverlay()
	-- print( "GameScene:_destroyGameOverOverlay" )
	local o, f = self._view_gameover, self._view_gameover_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_gameover_f = nil
	end
	if o then
		o:removeSelf()
		self._view_gameover = nil
	end
end


function GameScene:_createGameView()
	-- print( "GameScene:_createGameView" )
	if self._view_game then self:_destroyGameView() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_main
	local o, f

	o = GameView:new{
		width=W, height=H,
		level_data=self._level_data
	}
	o.x, o.y = 0, 0

	dg:insert( o.view )
	self._view_game = o

	f = Utils.createObjectCallback( self, self._gameViewEvent_handler )
	o:addEventListener( o.EVENT, f )

	self._view_game_f = f
end

function GameScene:_destroyGameView()
	-- print( "GameScene:_destroyGameView" )
	local o, f = self._view_game, self._view_game_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_game_f = nil
	end
	if o then
		o:removeSelf()
		self._view_game = nil
	end
end



--====================================================================--
--== Event Handlers


-- event handler for the Load Overlay
--
function GameScene:_loadViewEvent_handler( event )
	-- print( "GameScene:_loadViewEvent_handler: ", event.type )
	local target = event.target

	if event.type == target.COMPLETE then
		self:gotoState( self.STATE_PLAY )
	else
		print( "[WARNING] GameScene:_loadViewEvent_handler", event.type )
	end

end


-- event handler for the Game View
--
function GameScene:_gameViewEvent_handler( event )
	-- print( "GameScene:_gameViewEvent_handler: ", event.type )
	local target = event.target

	if event.type == target.GAME_ACTIVE_EVENT then
		-- pass

	elseif event.type == target.AIMING_EVENT then
		-- pass

	elseif event.type == target.GAME_OVER_EVENT then
		-- create game over display
		self:gotoState( self.STATE_COMPLETE )

	elseif event.type == target.GAME_EXIT_EVENT then
		self:gotoState( self.STATE_COMPLETE )

	else
		print( "[WARNING] GameScene:_gameViewEvent_handler", event.type )
	end

end


-- event handler for the Game Over Overlay
--
function GameScene:_gameOverEvent_handler( event )
	-- print( "GameScene:_gameOverEvent_handler: ", event.type )
	local target = event.target
	-- menu button, goto menu
	-- restart button, start
	-- next-level buton, get new level, start loading game
	-- start loading, show loading screen, clear, show
	if event.type == target.COMPLETE then
		self:gotoState( self.STATE_PLAY )
	else
		-- print( "[WARNING] GameScene:_gameOverEvent_handler", event.type )
	end

end



--======================================================--
-- START: STATE MACHINE

--== State Create ==--

function GameScene:state_create( next_state, params )
	-- print( "GameScene:state_create: >> ", next_state )

	if next_state == GameScene.STATE_LOADING then
		self:do_state_loading( params )
	elseif next_state == GameScene.STATE_PLAY then
		self:do_state_play( params )
	else
		print( "[WARNING] GameScene:state_create", tostring( next_state ) )
	end
end


--== State Loading ==--

function GameScene:do_state_loading( params )
	-- print( "GameScene:do_state_loading" )
	params = params or {}
	--==--
	self:setState( GameScene.STATE_LOADING )

	if params.level then
		self._level_data = params.level
	end
	self:_createLoadOverlay()
end

function GameScene:state_loading( next_state, params )
	-- print( "GameScene:state_loading: >> ", next_state )
	if next_state == GameScene.STATE_LOADING then
		-- pass
	elseif next_state == GameScene.STATE_PLAY then
		self:do_state_play( params )
	else
		print( "[WARNING] GameScene:state_loading", tostring( next_state ) )
	end
end


--== State Play ==--

function GameScene:do_state_play( params )
	-- print( "GameScene:do_state_play" )
	params = params or {}
	--==--
	self:setState( GameScene.STATE_PLAY )
	self:_destroyLoadOverlay()
	self._view_game:startGamePlay()
end

function GameScene:state_play( next_state, params )
	-- print( "GameScene:state_play: >> ", next_state )
	if next_state == GameScene.STATE_PLAY then
		self:do_state_play( params )
	elseif next_state == GameScene.STATE_COMPLETE then
		self:do_state_complete( params )
	else
		print( "[WARNING] GameScene:state_game_over", tostring( next_state ) )
	end
end


--== State Complete ==--

function GameScene:do_state_complete( params )
	-- print( "GameScene:do_state_complete" )
	params = params or {}
	--==--
	self:setState( GameScene.STATE_COMPLETE )

	self:_destroyLoadOverlay()
	self:_destroyGameOverOverlay()

	scene:dispatchEvent{
		name=scene.EVENT,
		type=scene.GAME_COMPLETE
	}
end

function GameScene:state_complete( next_state, params )
	-- print( "GameScene:state_complete: >> ", next_state )
	if next_state == GameScene.STATE_LOADING then
		self:do_state_loading( params )
	else
		print( "[WARNING] GameScene:state_complete", tostring( next_state ) )
	end
end

-- END: STATE MACHINE
--======================================================--




--====================================================================--
--== Composer Scene
--====================================================================--


scene = composer.newScene()

--== Event Constants

scene.EVENT = 'scene-event'
scene.GAME_COMPLETE = 'game-complete'

--======================================================--
-- START: composer scene setup

function scene:create( event )
	-- print( "Game Scene:create" )
	GameScene.view = self.view
	GameScene:__init__( event.params )
	GameScene:__createView__()
	GameScene:__initComplete__()
end

function scene:show( event )
	-- print( "Game Scene:show" )
	local params = event.params
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		-- event information:
		-- event.width, event.height, event.level_data
		GameScene:gotoState( GameScene.STATE_LOADING, {level=event.level_data} )
	end
end

function scene:hide( event )
	-- print( "Game Scene:hide" )
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

function scene:destroy( event )
	-- print( "Game Scene:destroy" )
	GameScene:__undoInitComplete__()
	GameScene:__undoCreateView__()
	GameScene:__undoInit__()
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )

-- END: composer scene setup
--======================================================--



--====================================================================--
--== Public Methods


-- getGameView()
--
-- setup as part of communication example
--
function scene:getGameView()
	return GameScene:getGameView()
end




return scene
