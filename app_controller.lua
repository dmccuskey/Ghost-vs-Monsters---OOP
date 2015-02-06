--====================================================================--
-- app_controller.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--

--[[
exports the following globals:
* gService
* gMegaphone
--]]

--====================================================================--
--== Ghost vs Monsters : App Controller
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


--== Corona Libs ==--

local composer = require 'composer'
local json = require 'json'

--== App Lib Imports ==--

local Megaphone = require 'service.megaphone'
local Objects = require 'lib.dmc_corona.dmc_objects'
local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

--== App Services ==--

local LevelMgr = require 'service.level_manager'
local SoundMgr = require 'service.sound_manager'

local OpenFeint = nil

--== App Components ==--

local LoadOverlay = require 'component.load_overlay'



--====================================================================--
--== Setup, Constants


_G.gService = {
	level_mgr=nil,
	sound_mgr=nil,
	open_feint=nil
}
_G.gMegaphone = nil

local sformat = string.format

local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase
local StatesMix = StatesMixModule.StatesMix

local AppSingleton = nil -- singleton, created in static run()

local oldTimerCancel = nil -- patched timer

local LOCAL_DEBUG = true



--====================================================================--
--== Support Functions


-- patchTimer()
-- patch timer cancel, check timer reference before doing cancel
--
local function patchTimer()
	oldTimerCancel = timer.cancel
	timer.cancel = function(t) if t then oldTimerCancel(t) end end
end



--====================================================================--
--== App Controller Class
--====================================================================--


local AppController = newClass( { ComponentBase, StatesMix }, {name="App Controller"} )

--== Class Constants

AppController.RUN_MODE = 'run'
AppController.TEST_MODE = 'test'

--== State Constants

AppController.STATE_CREATE = 'state_create'
AppController.STATE_INIT = 'state_initialize'
AppController.STATE_MENU = 'state_menu'
AppController.STATE_GAME = 'state_game'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function AppController:__init__( params )
	self:superCall( StatesMix, '__init__', params )
	self:superCall( ComponentBase, '__init__', params )
	params = params or {}
	--==--

	--== Sanity Check ==--

	assert( params.mode, "App Controller expected run mode parameter 'mode'" )

	--== Properties ==--

	self._width = display.contentWidth
	self._height = display.contentHeight

	self._run_mode = params.mode

	self._system_f = nil

	self._current_scene = nil
	self._current_scene_f = nil

	self._open_feint = params.open_feint

	--== Services ==--

	self._level_mgr = nil
	self._sound_mgr = nil

	--== Display Groups ==--

	-- -- for section views, Storyboard group is here
	-- self._dg_main = nil

	--== Display Objects ==--

	-- set initial state
	self:setState( AppController.STATE_CREATE )
end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function AppController:__createView__()
	self:superCall( '__createView__' )
	--==--

	-- setting the Composer layer to ours
	self:insert( composer.stage )
end
-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
--
-- function AppController:__undoCreateView__()
-- 	local o
-- 	--==--
-- 	self:superCall( '__undoCreateView__' )
-- end


-- __initComplete__()
--
function AppController:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--

	patchTimer()

	-- create our event callback refs
	self._system_f = self:createCallback( self._systemEvent_handler )
	self._current_scene_f = self:createCallback( self._currentScene_handler )

	-- kick off the action !
	self:gotoState( AppController.STATE_INIT )
end

-- __undoInitComplete__()
--
function AppController:__undoInitComplete__()

	self._system_f = nil
	self._current_scene_f = nil
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


-- @param params table of parameters
-- @params.mode string can be 'run' or 'test'
-- there are two constants on AppController : RUN_MODE and TEST_MODE
--
function AppController.run( params )
	params = params or {}
	if params.mode==nil then params.mode = AppController.RUN_MODE end
	--==--
	if LOCAL_DEBUG then print( "\n\nCreating App Controller\n\n") end
	AppSingleton = AppController:new( params )
	if LOCAL_DEBUG then print( "\n\nApp Controller Creation Complete\n\n") end
end

-- get instance of app controller
--
function AppController.instance()
	return AppSingleton
end



--====================================================================--
--== Public Methods


-- getter: level_mgr
-- returns app level manager
--
function AppController.__getters:level_mgr()
	return self._level_mgr
end

-- getter: sound_mgr
-- returns app sound manager
--
function AppController.__getters:sound_mgr()
	return self._sound_mgr
end



--====================================================================--
--== Private Methods


-- _addSceneHandler()
--
function AppController:_addSceneHandler( scene )
	-- print( "AppController:_addSceneHandler: ", scene )
	if not scene or not scene.EVENT then return end
	scene:addEventListener( scene.EVENT, self._current_scene_f )
end

function AppController:_removeSceneHandler( scene )
	-- print( "AppController:_removeSceneHandler: ", scene )
	if not scene or not scene.EVENT then return end
	scene:removeEventListener( scene.EVENT, self._current_scene_f )
end


-- _gotoScene()
--
-- does actual Storyboard switching to new scenes
-- does setup to receive event messages from each scene
--
function AppController:_gotoScene( name, options )
	-- print( "AppController:_gotoScene: ", name )
	options = options or {}
	--==--
	local o, f = self._current_scene, self._current_scene_f

	if composer.getSceneName( 'current' ) == name then return end

	assert( options.params.width and options.params.height, 'ERROR: app sections must be given width and height params' )

	self:_removeSceneHandler( o )

	composer.gotoScene( name, options )
	o = composer.getScene( name )
	assert( o, sformat( "ERROR: missing scene '%s'", tostring(name) ) )

	self._current_scene = o
	self:_addSceneHandler( o )
end




function AppController:_loadOpenFeint( options )
	OpenFeint = require 'openfeint'
	local params = {
		options.app_key,
		options.app_secret,
		options.app_title,
		options.app_id
	}
	OpenFeint.init( unpack( params ) )

	gService.open_feint = OpenFeint
end



--[[

GLOBAL COMMUNICATION

there are at least two ways to communicate with the Game View, either
* by direct communication, we get the Scene and ask for the Game View
* via global communicator, we send messages via Megaphone

both are setup so you can see the difference.

--]]


function AppController:_pauseGamePlay( options )

	--== direct communication
	--[[
		local game_scene, game_view
		game_scene = composer.getScene( 'scene.game' )
		-- simple output to show details
		if LOCAL_DEBUG and not game_scene then
			print("GameView not yet loaded")
			return
		end
		game_view = game_scene:getGameView()
		if game_view then game_view:pauseGamePlay() end
	--]]

	--== megaphone communication

	gMegaphone:say( gMegaphone.PAUSE_GAMEPLAY )

end

function AppController:_resumeGamePlay( options )

	--== direct communication
	--[[
		local game_scene, game_view
		game_scene = composer.getScene( 'scene.game' )
		-- simple output to show details
		if LOCAL_DEBUG and not game_scene then
			print("GameView not yet loaded")
			return
		end
		game_view = game_scene:getGameView()
		if game_view then game_view:resumeGamePlay() end
	--]]

	--== megaphone communication

	gMegaphone:say( gMegaphone.RESUME_GAMEPLAY )

end





--====================================================================--
--== Event Handlers


function AppController:_systemEvent_handler( event )
	-- print( "AppController:_systemEvent_handler", event.type )
	local e_type = event.type

	if e_type == 'applicationStart' then
		-- pass

	elseif e_type == 'applicationSuspend' then
		self:_pauseGamePlay()

	elseif e_type == 'applicationResume' then
		self:_resumeGamePlay()

	elseif e_type == 'applicationExit' then
		if system.getInfo( 'environment' ) == 'device' then
			-- prevents iOS 4+ multi-tasking crashes
			os.exit()
		end

	else
		print( "[WARNING] AppController:_systemEvent_handler", tostring( event.type ) )
	end
end


function AppController:_currentScene_handler( event )
	-- print( "AppController:_currentScene_handler", event.type )
	--==--
	local cs = self._current_scene

	--== Events from Menu Scene

	if event.type == cs.LEVEL_SELECTED then
		assert( event.level, "AppController: level missing from Menu Scene" )
		self:gotoState( AppController.STATE_GAME, { level=event.level }  )

	--== Events from Game Scene

	elseif event.type == cs.GAME_COMPLETE then
		self:gotoState( AppController.STATE_MENU )

	else
		print( "[WARNING] AppController:_currentScene_handler", tostring( event.type ) )
	end
end



--======================================================--
--== START: State Machine

--== State Create ==--

function AppController:state_create( next_state, params )
	-- print( "AppController:state_create: >> ", next_state )
	if next_state == AppController.STATE_INIT then
		self:do_state_initialize( params )
	else
		print( "[WARNING] AppController:state_create", tostring( next_state ) )
	end
end


--== State Menu ==--

function AppController:do_state_initialize( params )
	-- print( "AppController:do_state_initialize", params )

	local W, H = self._width, self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, p, f  -- object, params, function


	--== Start Initialization ==--

	-- watch for system events
	Runtime:addEventListener( 'system', self._system_f )

	-- set status bar

	Utils.setStatusBarDefault( Utils.STATUS_BAR_TRANSLUCENT )
	Utils.setStatusBar( 'hide' )

	-- Megaphone communicator

	gMegaphone = Megaphone

	-- Level Manager

	o = LevelMgr:new()
	gService.level_mgr = o
	self._level_mgr = o

	-- Sound Manager

	o = SoundMgr:new()
	gService.sound_mgr = o
	self._sound_mgr = o

	-- Open Feint

	if self._open_feint then
		self:_loadOpenFeint( self._open_feint )
	end

	--== End Initialization ==--

	-- set state, then goto next
	self:setState( AppController.STATE_INIT )

	if self._run_mode == AppController.TEST_MODE then
		-- pass
	else
		self:gotoState( AppController.STATE_MENU )
	end

end

-- state_initialize()
-- handles transition effects from app initialization
--
function AppController:state_initialize( next_state, params )
	-- print( "AppController:state_initialize: >> ", next_state, params )

	if next_state == AppController.STATE_MENU then
		self:do_state_menu( params )
	else
		print( "[WARNING] AppController:state_initialize", tostring( next_state ) )
	end
end


--== State Menu ==--

function AppController:do_state_menu( params )
	-- print( "AppController:do_state_menu", params )

	self:setState( AppController.STATE_MENU )

	local scene_options = {
		params = {
			width=self._width, height=self._height,
			-- top_margin = gAppConstants.STATUS_BAR_HEIGHT,
			level_mgr = self.level_mgr,
			sound_mgr = self.sound_mgr
		}
	}
	self:_gotoScene( 'scene.menu', scene_options )

end

function AppController:state_menu( next_state, params )
	-- print( "AppController:state_menu: >> ", next_state, params )

	if next_state == AppController.STATE_GAME then
		self:do_state_game( params )
	else
		print( "[WARNING] AppController:state_menu", tostring( next_state ) )
	end
end


--== State Game ==--

function AppController:do_state_game( params )
	-- print( "AppController:do_state_game", params )
	params = params or {}
	--==--
	self:setState( AppController.STATE_GAME )

	local scene_options = {
		params = {
			width=self._width, height=self._height,
			-- top_margin = gAppConstants.STATUS_BAR_HEIGHT,
			sound_mgr = self.sound_mgr,
			level_data=params.level
		}
	}
	self:_gotoScene( 'scene.game', scene_options )

end

function AppController:state_game( next_state, params )
	-- print( "AppController:state_game: >> ", next_state, params )

	if next_state == AppController.STATE_MENU then
		self:do_state_menu( params )
	else
		print( "[WARNING] AppController:state_game", tostring( next_state ) )
	end
end

--== END: State Machine
--======================================================--




return AppController
