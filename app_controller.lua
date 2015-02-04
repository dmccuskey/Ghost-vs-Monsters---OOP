--====================================================================--
-- app_controller.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



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

local Objects = require 'lib.dmc_corona.dmc_objects'
local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

--== App Services ==--

local LevelMgr = require 'service.level_manager'
local SoundMgr = require 'service.sound_manager'

--== App Components ==--

local LoadOverlay = require 'component.load_overlay'

-- local HUDFactory = require 'component.hud_components'



--====================================================================--
--== Setup, Constants


local sformat = string.format

local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase
local StatesMix = StatesMixModule.StatesMix

local AppSingleton = nil -- singleton, created in static run()

local appGroup -- groups for all items

-- this is used to pass information around to each Director scene
-- ie, no globals
local app_token = {
	token_id = 4,
	mainGroup = nil,
	hudGroup = nil,
	loadScreenHUD = nil,
	gameEngine = nil, -- ref to Game Engine, if it is running
	--openfeint = openfeint,
}

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

	--== Services ==--

	self._levelMgr = nil
	self._soundMgr = nil

	--== Display Groups ==--

	-- for section views, Storyboard group is here
	self._dg_main = nil

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

	local W, H = self._width, self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, tmp

	-- create main group, holds Composer layer, controls and main block
	o = display.newGroup()
	o.x, o.y = 0,0

	self:insert( o )
	self._dg_main = o

	-- setting the Composer layer to another one
	self._dg_main:insert( composer.stage )

end
-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
--
function AppController:__undoCreateView__()
	local o

	o = self._dg_main
	o:removeSelf()
	self._dg_main = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function AppController:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--

	self._system_f = self:createCallback( self._systemEvent_handler )
	self._current_scene_f = self:createCallback( self._currentScene_handler )

	-- kick off the action !
	self:gotoState( AppController.STATE_INIT )
end

-- __undoInitComplete__()
--
function AppController:__undoInitComplete__()
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
	return self._levelMgr
end

-- getter: sound_mgr
-- returns app sound manager
--
function AppController.__getters:sound_mgr()
	return self._soundMgr
end




--======================================================--
--== START: State Machine

-- state_create()
--
function AppController:state_create( next_state, params )
	-- print( "AppController:state_create: >> ", next_state )
	if next_state == AppController.STATE_INIT then
		self:do_state_initialize( params )
	else
		print( "WARNING::state_create : " .. tostring( next_state ) )
	end
end


-- do_state_initialize()
-- initialize different parts of the application
--
function AppController:do_state_initialize( params )
	-- print( "AppController:do_state_initialize", params )

	local W, H = self._width, self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, p, f  -- object, params, function


	--== Start Initialization ==--

	-- watch for system events
	-- Runtime:addEventListener( 'system', self._system_f )

	-- set status bar

	Utils.setStatusBarDefault( Utils.STATUS_BAR_TRANSLUCENT )
	Utils.setStatusBar( 'hide' )

	-- Init Level Manager

	self._levelMgr = LevelMgr:new()

	-- Init Sound Manager

	self._soundMgr = SoundMgr:new()

	--== End Initialization ==--

	-- set state, goto next
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
	print( "AppController:state_initialize: >> ", next_state, params )

	if next_state == AppController.STATE_MENU then
		self:do_state_menu( params )
	else
		print( "WARNING::state_initialize : " .. tostring( next_state ) )
	end
end



-- do_state_menu()
-- initialize different parts of the application
--
function AppController:do_state_menu( params )
	print( "AppController:do_state_menu", params )

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

-- state_menu()
-- showing app menu
--
function AppController:state_menu( next_state, params )
	print( "AppController:state_menu: >> ", next_state, params )

	if next_state == AppController.STATE_GAME then
		self:do_state_game( params )
	else
		print( "WARNING::state_menu : " .. tostring( next_state ) )
	end
end



--====================================================================--
--== Private Methods


-- _gotoScene()
--
-- does actual Storyboard switching to new scenes
-- does setup to receive event messages from each scene
--
function AppController:_addSceneHandler( scene )
	print( "AppController:_addSceneHandler: ", scene )
	if not scene or not scene.EVENT then return end
	scene:addEventListener( scene.EVENT, self._current_scene_f )
end

function AppController:_removeSceneHandler( scene )
	print( "AppController:_removeSceneHandler: ", scene )
	if not scene or not scene.EVENT then return end
	scene:removeEventListener( scene.EVENT, self._current_scene_f )
end



-- _gotoScene()
--
-- does actual Storyboard switching to new scenes
-- does setup to receive event messages from each scene
--
function AppController:_gotoScene( name, options )
	print( "AppController:_gotoScene: ", name )
	options = options or {}
	--==--
	local o, f = self._current_scene, self._current_scene_f

	if composer.getSceneName( 'current' ) == name then return end

	assert( options.params.width and options.params.height, 'ERROR: app sections must be given width and height params' )

	self:_removeSceneHandler( o )

	print( ">1", o )
	composer.gotoScene( name, options )
	print( ">2", o )
	o = composer.getScene( name )
	print( ">>", o )
	assert( o, sformat( "ERROR: missing scene '%s'", tostring(name) ) )

	self._current_scene = o
	self:_addSceneHandler( o )
end






--====================================================================--
--== Event Handlers



function AppController:_systemEvent_handler( event )
	print( "AppController:_systemEvent_handler", event.type )
	local e_type = event.type

	if e_type == 'applicationStart' then
		-- pass

	elseif e_type == 'applicationSuspend' then
		if app_token.gameEngine then
			app_token.gameEngine:pauseGamePlay()
		end

	elseif e_type == 'applicationExit' then
		if system.getInfo( 'environment' ) == 'device' then
			-- prevents iOS 4+ multi-tasking crashes
			os.exit()
		end
	end
end


function AppController:_currentScene_handler( event )
	print( "AppController:_currentScene_handler" )
	--==--
	local cs = self._current_scene

	--== Events from Menu Scene

	if event.type == cs.LANDING_COMPLETE then

		local section = AppController.section.HOME_FEED
		self:gotoState( AppController.STATE_NORMAL, { section=section }  )


	--== Events from Game Scene

	elseif event.type == cs.SHOW_TALENT_BUILDER then

		self:_toggleTalentBuilder( 'show' )

	else
		print( "WARNING AppController:_currentScene_handler : " .. tostring( event.type ) )
	end
end




-- Uncomment below code and replace init() arguments with valid ones to enable openfeint
--[[
local openfeint = require ("openfeint")
openfeint.init( "App Key Here", "App Secret Here", "Ghosts vs. Monsters", "App ID Here" )
]]--





-- initialize()
--
local function initialize()

	-- Create display groups
	appGroup = display.newGroup()
	app_token.mainGroup = display.newGroup()
	app_token.hudGroup = display.newGroup()

	appGroup:insert( app_token.mainGroup )
	appGroup:insert( app_token.hudGroup )

	-- loading screen
	local loadScreenHUD = HUDFactory.create( "loadscreen-hud" )
	app_token.hudGroup:insert( loadScreenHUD.display )
	app_token.loadScreenHUD = loadScreenHUD

	-- system events
	Runtime:addEventListener( "system", onSystem )

end

-- test()
-- test out individual screens
--
local function test( screen_name, params )

	local test_screen = require( screen_name )
	test_screen.new( params )

end

-- main()
--
local function main()

	initialize()

	-- Add the group from director class
	app_token.mainGroup:insert( director.directorView )

	director:changeScene( app_token, "scene-menu" )

end


-- -- testing structure
-- if ( true ) then

-- 	main()

-- else
-- 	levelMgr = require( "level_manager" )

-- 	initialize()

-- 	test( "scene-menu", app_token )
-- 	app_token.data = levelMgr:getLevelData( 'level1' )
-- 	--test( "scene-game", app_token )

-- end



return AppController
