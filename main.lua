--====================================================================--
-- Ghosts vs Monsters sample project, OOP version
--
-- OOP version by David McCuskey
-- Original designed and created by Jonathan and Biffy Beebe of Beebe Games exclusively for Ansca, Inc.
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
-- Imports
--====================================================================--

local HUDFactory = require( "hud_objects" )
local director = require("director")
local levelMgr	-- will be a require, used for testing

-- Uncomment below code and replace init() arguments with valid ones to enable openfeint
--[[
local openfeint = require ("openfeint")
openfeint.init( "App Key Here", "App Secret Here", "Ghosts vs. Monsters", "App ID Here" )
]]--


--====================================================================--
-- Setup, Constants
--====================================================================--

--Hide status bar from the beginning
display.setStatusBar( display.HiddenStatusBar )

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


--== Override base functionality

local oldTimerCancel = timer.cancel
timer.cancel = function(t) if t then oldTimerCancel(t) end end


--====================================================================--
-- Main
--====================================================================--



local function onSystem( event )

	if event.type == "applicationSuspend" then
		if app_token.gameEngine then
			app_token.gameEngine:pauseGamePlay()
		end

	elseif event.type == "applicationExit" then
		if system.getInfo( "environment" ) == "device" then
			-- prevents iOS 4+ multi-tasking crashes
			os.exit()
		end
	end
end


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


-- testing structure
if ( true ) then

	main()

else
	levelMgr = require( "level_manager" )

	initialize()

	test( "scene-menu", app_token )
	app_token.data = levelMgr:getLevelData( 'level1' )
	--test( "scene-game", app_token )

end

