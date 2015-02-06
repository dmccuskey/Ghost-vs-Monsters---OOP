--====================================================================--
-- scene/menu.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Ghost vs Monsters : Menu Scene
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Imports


local composer = require 'composer'

local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

--== Components

local MenuView = require 'scene.menu.menu_view'
local LoadOverlay = require 'component.load_overlay'



--====================================================================--
--== Setup, Constants


local scene = nil -- composer scene



--====================================================================--
--== Menu Scene Class
--====================================================================--


local MenuScene = {}

StatesMixModule.patch( MenuScene )

MenuScene.view = nil -- set in composer

--== State Constants

MenuScene.STATE_CREATE = 'state_create'
MenuScene.STATE_INIT = 'state_init'
MenuScene.STATE_LOADING = 'state_loading'
MenuScene.STATE_NORMAL = 'state_normal'
MenuScene.STATE_SELECT = 'state_select'
MenuScene.STATE_COMPLETE = 'state_complete'


--======================================================--
-- Start: Emulate DMC Setup

function MenuScene:__init__( params )
	-- print( "MenuScene:__init__", params )
	--==--

	--== Properties ==--

	self._width = params.width
	self._height = params.height

	--== Services ==--

	self._level_mgr = gService.level_mgr
	self._sound_mgr = gService.sound_mgr

	--== Display Objects ==--

	self._dg_main = nil
	self._dg_overlay = nil

	self._bg = nil

	self._view_menu = nil
	self._view_menu_f = nil
	self._view_load = nil
	self._view_load_f = nil

	self:setState( MenuScene.STATE_CREATE )
end


function MenuScene:__createView__()
	-- print( "MenuScene:__createView__" )

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5
	local view = self.view

	local o, dg -- object, group

	-- main group

	o = display.newGroup()
	view:insert( o )
	self._dg_main = o

	-- overlay group

	o = display.newGroup()
	view:insert( o )
	self._dg_overlay = o

	-- background
	dg = self._dg_main
	o = display.newRect( 0, 0, W, H )
	o:setFillColor( 0.5, 0.5, 0, 0.5 )
	o.anchorX, o.anchorY = 0.5, 0
	o.x, o.y = H_CENTER, 0

	dg:insert( o )
	self._bg = o

end

function MenuScene:__undoCreateView__()
	-- print( "MenuScene:__undoCreateView__" )

	local o

	o = self._bg
	o:removeSelf()
	self._bg = nil

	o = self._dg_overlay
	o:removeSelf()
	self._dg_overlay = nil

	o = self._dg_main
	o:removeSelf()
	self._dg_main = nil
end

function MenuScene:__initComplete__()
	-- print( "MenuScene:__initComplete__" )
	self:_createMenuView()

	-- you can turn on loading if menu requires it
	-- self:gotoState( self.STATE_LOADING )
	self:gotoState( self.STATE_NORMAL )
end

function MenuScene:__undoInitComplete__()
	-- print( "MenuScene:__undoInitComplete__" )
	self:_destroyMenuView()
end

-- End: Emulate DMC Setup
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


function MenuScene:_createLoadOverlay()
	-- print( "MenuScene:_createLoadOverlay" )
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

function MenuScene:_destroyLoadOverlay()
	-- print( "MenuScene:_destroyLoadOverlay" )
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


function MenuScene:_createMenuView()
	-- print( "MenuScene:_createMenuView" )
	if self._view_menu then self:_destroyMenuView() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_main
	local o, f

	o = MenuView:new{
		width=W, height=H,
		level_mgr=self._level_mgr,
		sound_mgr=self._sound_mgr
	}
	o.x, o.y = H_CENTER, 0

	dg:insert( o.view )
	self._view_menu = o

	f = Utils.createObjectCallback( self, self._menuViewEvent_handler )
	o:addEventListener( o.EVENT, f )

	self._view_menu_f = f
end

function MenuScene:_destroyMenuView()
	-- print( "MenuScene:_destroyMenuView" )
	local o, f = self._view_menu, self._view_menu_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_menu_f = nil
	end
	if o then
		o:removeSelf()
		self._view_menu = nil
	end
end



--====================================================================--
--== Event Handlers


-- event handler for the Menu View
--
function MenuScene:_menuViewEvent_handler( event )
	-- print( "MenuScene:_menuViewEvent_handler: ", event.type )
	local target = event.target

	if event.type == target.SELECTED then
		local result = event.data
		self:gotoState( self.STATE_NORMAL, {level=result.level} )
	else
		print( "[WARNING] MenuScene:_menuViewEvent_handler", event.type )
	end

end

-- event handler for the Load Overlay
--
function MenuScene:_loadViewEvent_handler( event )
	-- print( "MenuScene:_loadViewEvent_handler: ", event.type )
	local target = event.target

	if event.type == target.COMPLETE then
		self:gotoState( self.STATE_NORMAL )
	else
		print( "[WARNING] MenuScene:_loadViewEvent_handler", event.type )
	end

end



--======================================================--
-- START: STATE MACHINE

--== State Create ==--

function MenuScene:state_create( next_state, params )
	-- print( "MenuScene:state_create: >> ", next_state )

	if next_state == MenuScene.STATE_LOADING then
		self:do_state_loading( params )
	elseif next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	else
		print( "[WARNING] MenuScene:state_create", tostring( next_state ) )
	end
end


--== State Loading ==--

function MenuScene:do_state_loading( params )
	-- print( "MenuScene:do_state_loading" )
	-- params = params or {}
	--==--
	self:setState( MenuScene.STATE_LOADING )
	self:_createLoadOverlay()
end

function MenuScene:state_loading( next_state, params )
	-- print( "MenuScene:state_loading: >> ", next_state )
	if next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	else
		print( "[WARNING] MenuScene:state_loading", tostring( next_state ) )
	end
end


--== State Normal ==--

function MenuScene:do_state_normal( params )
	-- print( "MenuScene:do_state_normal" )
	params = params or {}
	--==--
	self:setState( MenuScene.STATE_NORMAL )
	self:_destroyLoadOverlay()

	if params.level then
		scene:dispatchEvent{
			name=scene.EVENT,
			type=scene.LEVEL_SELECTED,
			level=params.level
		}
	end

end

function MenuScene:state_normal( next_state, params )
	-- print( "MenuScene:state_normal: >> ", next_state )
	if next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	elseif next_state == MenuScene.STATE_COMPLETE then
		self:do_state_complete( params )
	else
		print( "[WARNING] MenuScene:state_normal", tostring( next_state ) )
	end
end


--== State Complete ==--

function MenuScene:do_state_complete( params )
	-- print( "MenuScene:do_state_complete" )
	params = params or {}
	--==--
	self:setState( MenuScene.STATE_COMPLETE )

	self:_destroyLoadOverlay()
end

function MenuScene:state_complete( next_state, params )
	-- print( "MenuScene:state_complete: >> ", next_state )

	print( "[WARNING] MenuScene:state_complete", tostring( next_state ) )
end

-- END: STATE MACHINE
--======================================================--




--====================================================================--
--== Composer Scene
--====================================================================--


scene = composer.newScene()

--== Event Constants

scene.EVENT = 'scene-event'
scene.LEVEL_SELECTED = 'level-selected'

--======================================================--
-- START: composer scene setup

function scene:create( event )
	-- print( "Menu Scene:create" )
	MenuScene.view = self.view
	MenuScene:__init__( event.params )
	MenuScene:__createView__()
	MenuScene:__initComplete__()
end

function scene:show( event )
	-- print( "Menu Scene:show" )
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

function scene:hide( event )
	-- print( "Menu Scene:hide" )
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

function scene:destroy( event )
	-- print( "Menu Scene:destroy" )
	MenuScene:__undoInitComplete__()
	MenuScene:__undoCreateView__()
	MenuScene:__undoInit__()
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )

-- END: composer scene setup
--======================================================--



return scene
