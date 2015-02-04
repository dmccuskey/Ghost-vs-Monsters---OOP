--====================================================================--
-- Scene/menu.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Ghost vs Monsters : Menu Scene
--====================================================================--



--====================================================================--
--== Imports


local composer = require 'composer'

local StatesMixModule = require 'lib.dmc_corona.dmc_states_mix'
local Utils = require 'lib.dmc_corona.dmc_utils'

--== Scene Components

local MenuView = require 'scene.menu.main_view'
local LevelOverlay = require 'scene.menu.level_overlay'
local LoadOverlay = require 'component.load_overlay'



--====================================================================--
--== Setup, Constants


local scene = nil -- composer scene



--====================================================================--
--== Support Functions


-- _createView
-- create any of our views
--
local function _createView( key, params )
	print( '_createView' )

	params = params or {}

	local group = Scene.view

	local o, f, p


	if key == State.STATE_HOME_FEED_MAIN then
		params.data_service = sgDataFeedMgr
		params.selection_manager = sgSelectionMgr

		o = HomeFeedView:new( params )
		f = Utils.createObjectCallback( State, State._mainView_handler )
		o:addEventListener( o.EVENT, f )

	else
		error( 'unknown page', 2 )
	end


	if o then
		o:setAnchor( o.TopCenterReferencePoint )

		sgViewMgr:addView( key, o, p )
		sgViewCallbacks[ key ] = f
	end

	return o
end


local function _destroyView( key )
	-- print( '_destroyView ', key )

	local o, f

	o = sgViewMgr:removeView( key )

	if not o then return end -- we never created one

	f = sgViewCallbacks[ key ]
	sgViewCallbacks[ key ] = nil

	o:removeEventListener( o.EVENT, f )
	o:removeSelf()

end


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
MenuScene.STATE_LEVEL = 'state_level'
MenuScene.STATE_COMPLETE = 'state_complete'


function MenuScene:__init__( params )
	print( "MenuScene:__init__", params )

	--== Properties ==--

	self._width = params.width
	self._height = params.height

	--== Services ==--

	self._level_mgr = params.level_mgr
	self._sound_mgr = params.level_mgr

	--== Display Objects ==--

	self._dg_main = nil
	self._dg_overlay = nil

	self._bg = nil

	self._view_main = nil
	self._view_main_f = nil
	self._view_load = nil
	self._view_load_f = nil
	self._view_level = nil
	self._view_level_f = nil

	self:setState( self.STATE_CREATE )
end


function MenuScene:__createView__()
	print( "MenuScene:__createView__" )

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
	print( "MenuScene:__undoCreateView__" )

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
	print( "MenuScene:__initComplete__" )
	self:_createMainView()
	self:gotoState( self.STATE_LOADING )
end

function MenuScene:__undoInitComplete__()
	print( "MenuScene:__undoInitComplete__" )
	self:_destroyMainView()
end



--====================================================================--
--== Private Methods



function MenuScene:_createLoadOverlay()
	print( "MenuScene:_createLoadOverlay" )
	if self._view_load then self:_destroyLoadOverlay() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_overlay
	local o, f

	o = LoadOverlay:new()
	o.x, o.y = H_CENTER, 0

	dg:insert( o.view )
	self._view_load = o

	f = Utils.createObjectCallback( self, self._loadView_handler )
	o:addEventListener( o.EVENT, f )

	self._view_load_f = f

	-- testing
	timer.performWithDelay( 500, function() o.percent_complete=25 end )
	timer.performWithDelay( 1000, function() o.percent_complete=50 end )
	timer.performWithDelay( 1500, function() o.percent_complete=75 end )
	timer.performWithDelay( 2000, function() o.percent_complete=100 end )
end

function MenuScene:_destroyLoadOverlay()
	print( "MenuScene:_destroyLoadOverlay" )
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


function MenuScene:_createMainView()
	print( "MenuScene:_createMainView" )
	if self._view_main then self:_destroyMainView() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_main
	local o, f

	o = MainView:new{
		width=W, height=H,
		soundMgr=self._sound_mgr
	}
	o.x, o.y = H_CENTER, 0

	dg:insert( o.view )
	self._view_main = o

	f = Utils.createObjectCallback( self, self._mainView_handler )
	o:addEventListener( o.EVENT, f )

	self._view_main_f = f
end

function MenuScene:_destroyMainView()
	print( "MenuScene:_destroyMainView" )
	local o, f = self._view_main, self._view_main_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_main_f = nil
	end
	if o then
		o:removeSelf()
		self._view_main = nil
	end
end


function MenuScene:_createLevelOverlay()
	print( "MenuScene:_createLevelOverlay" )
	if self._view_level then self:_destroyLevelOverlay() end

	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local dg = self._dg_overlay
	local o, f

	o = LevelOverlay:new{
		width=W, height=H,
		levelMgr=self._level_mgr,
		soundMgr=self._sound_mgr
	}
	o.x, o.y = H_CENTER, 0

	dg:insert( o.view )
	self._view_level = o

	f = Utils.createObjectCallback( self, self._levelOverlay_handler )
	o:addEventListener( o.EVENT, f )

	self._view_level_f = f
end

function MenuScene:_destroyLevelOverlay()
	print( "MenuScene:_destroyLevelOverlay" )
	local o, f = self._view_level, self._view_level_f
	if o and f then
		o:removeEventListener( o.EVENT, f )
		self._view_level_f = nil
	end
	if o then
		o:removeSelf()
		self._view_level = nil
	end
end


--======================================================--
--== START: STATE MACHINE


function MenuScene:state_create( next_state, params )
	print( "MenuScene:state_create: >> ", next_state )

	if next_state == MenuScene.STATE_INIT then
		self:do_state_init( params )
	elseif next_state == MenuScene.STATE_LOADING then
		self:do_state_loading( params )
	elseif next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	else
		print( "WARNING::state_create : " .. tostring( next_state ) )
	end
end

--== State Init ==--

function MenuScene:do_state_init( params )
	print( "MenuScene:do_state_init" )
	params = params or {}
	--==--
	self:setState( MenuScene.STATE_INIT )
	self:_createMainView()
end

function MenuScene:state_init( next_state, params )
	print( "MenuScene:state_init: >> ", next_state )

	if false then
	else
		print( "WARNING::state_init : " .. tostring( next_state ) )
	end
end


--== State Loading ==--


function MenuScene:do_state_loading( params )
	print( "MenuScene:do_state_loading" )
	-- params = params or {}
	--==--
	self:setState( MenuScene.STATE_LOADING )
	self:_createLoadOverlay()
end

function MenuScene:state_loading( next_state, params )
	print( "MenuScene:state_loading: >> ", next_state )
	if next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	else
		print( "WARNING::state_loading : " .. tostring( next_state ) )
	end
end


--== State Normal ==--


function MenuScene:do_state_normal( params )
	print( "MenuScene:do_state_normal" )
	params = params or {}
	--==--
	self:setState( MenuScene.STATE_NORMAL )
	self:_destroyLoadOverlay()
	self:_destroyLevelOverlay()
end

function MenuScene:state_normal( next_state, params )
	print( "MenuScene:state_normal: >> ", next_state )
	if next_state == MenuScene.STATE_NORMAL then
		self:do_state_level( params )
	else
		print( "WARNING::state_normal : " .. tostring( next_state ) )
	end
end


--== State Level ==--


function MenuScene:do_state_level( params )
	print( "MenuScene:do_state_level" )
	params = params or {}
	--==--
	self:setState( MenuScene.STATE_LEVEL )
	self:_createLevelOverlay()
end

function MenuScene:state_level( next_state, params )
	print( "MenuScene:state_level: >> ", next_state )
	if next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	elseif next_state == MenuScene.STATE_COMPLETE then
		self:do_state_complete( params )
	else
		print( "WARNING::state_level : " .. tostring( next_state ) )
	end
end


--== State Complete ==--


function MenuScene:do_state_complete( params )
	print( "MenuScene:do_state_complete" )
	params = params or {}
	--==--
	assert( params.level )

	self:setState( MenuScene.STATE_COMPLETE )
	self:_destroyLoadOverlay()
	self:_destroyLevelOverlay()

	scene:dispatchEvent{
		name=scene.EVENT,
		type=scene.COMPLETE,
		level=params.level
	}
end

function MenuScene:state_complete( next_state, params )
	print( "MenuScene:state_complete: >> ", next_state )
	if next_state == MenuScene.STATE_NORMAL then
		self:do_state_normal( params )
	else
		print( "WARNING::state_complete : " .. tostring( next_state ) )
	end
end




--== END: STATE MACHINE
--======================================================--




--====================================================================--
--== Event Handlers


-- event handler for the Load Overlay
--
function MenuScene:_mainView_handler( event )
	print( "MenuScene:_mainView_handler: ", event.type )
	local target = event.target

	if event.type == target.SELECTED then
		self:gotoState( self.STATE_LEVEL )
	else
		print( "unknown event", event.type )
	end

end

-- event handler for the Load Overlay
--
function MenuScene:_loadView_handler( event )
	print( "MenuScene:_loadView_handler: ", event.type )
	local target = event.target

	if event.type == target.COMPLETE then
		self:gotoState( self.STATE_NORMAL )
	else
		print( "unknown event", event.type )
	end

end

-- event handler for the Level Overlay
--
function MenuScene:_levelOverlay_handler( event )
	print( "MenuScene:_levelOverlay_handler: ", event.type )
	local target = event.target

	if event.type == target.CANCELED then
		print( "selection canceled" )
		self:gotoState( self.STATE_NORMAL )
	elseif event.type == target.SELECTED then
		local level = event.data
		local p = {level=level}
		print( "level selected", level.name, level.data )
		self:gotoState( self.STATE_COMPLETE, p )
	else
		print( "unknown event", event.type )
	end
end



--====================================================================--
--== Composer Scene
--====================================================================--

scene = composer.newScene()

--== Event Constants

scene.EVENT = 'scene-event'
scene.COMPLETE = 'scene-complete'

--======================================================--
-- START: composer scene setup

function scene:create( event )
	print( "scene:create", self )
	Utils.print( event )

	MenuScene.view = self.view
	MenuScene:__init__( event.params )
	MenuScene:__createView__()
	MenuScene:__initComplete__()

end

function scene:show( event )
	print( "scene:show" )
	Utils.print( event )
end

function scene:hide( event )
	print( "scene:hide" )
	Utils.print( event )

end

function scene:destroy( event )
	print( "scene:destroy" )
	Utils.print( event )

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
