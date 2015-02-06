--====================================================================--
-- component/object_factory/cloud.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


--====================================================================--
--== Cloud vs Monsters : Cloud Object
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Objects = require 'lib.dmc_corona.dmc_objects'
local Utils = require 'lib.dmc_corona.dmc_utils'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local PhysicsComponentBase = Objects.PhysicsComponentBase

local LOCAL_DEBUG = false



--====================================================================--
--== Cloud Object Class
--====================================================================--


local Cloud = newClass( PhysicsComponentBase, {name="A Cloud"} )

Cloud.VELOCITY = 0.5

Cloud.TYPE = nil
Cloud.FILE = nil


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function Cloud:__init__( params )
	-- print( "Cloud:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Sanity Check
	if self.is_class then return end
	assert( params.game_engine, "Cloud requires params 'game_engine'")

	--== Properties

	self._is_active = true
	self._file = self.FILE

	self._enterframe_f = nil

	--== Objects

	self._game_engine = params.game_engine
	self._game_engine_f = nil

	self._enterframe_f = nil

	--== Display Objects

	self._mc_ghost = nil
	self._blast = nil
	self._poof = nil
end

-- __undoInit__()
--
-- function Cloud:__undoInit__()
-- 	--==--
-- 	self:superCall( '__undoInit__' )
-- end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function Cloud:__createView__()
	-- print( "Cloud:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o

	o = display.newImageRect( self._file, 480, 320 )
	assert( o )
	self:_setView( o )
end

-- __undoCreateView__()
--
-- function Cloud:__undoCreateView__()
-- 	print( "Cloud:__undoCreateView__" )
-- 	local o
-- 	--==--
-- 	self:superCall( '__undoCreateView__' )
-- end


-- __initComplete__()
--
function Cloud:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	local o, f

	o = self._game_engine
	f = self:createCallback( self._gameViewEvent_handler )
	o:addEventListener( o.EVENT, f )
	self._game_engine_f = f

	f = self:createCallback( self._enterFrameEvent_handler )
	Runtime:addEventListener( 'enterFrame', f )
	self._enterframe_f = f

end

-- __undoInitComplete__()
--
function Cloud:__undoInitComplete__()
	-- print( "Cloud:__undoInitComplete__" )

	local o, f

	f = self._enterframe_f
	Runtime:removeEventListener( 'enterFrame', f )
	self._enterframe_f = nil

	o = self._game_engine
	f = self._game_engine_f
	o:removeEventListener( o.EVENT, f )
	self._game_engine_f = nil

	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


-- event handler for the Game View
--
function Cloud:_gameViewEvent_handler( event )
	-- print( "Cloud:_gameViewEvent_handler: ", event.type )
	if event.type == event.target.GAME_ACTIVE_EVENT then
		self._is_active = event.value
	-- else
	-- 	print( "[WARNING] Cloud::_gameViewEvent_handler", event.type )
	end
end


function Cloud:_enterFrameEvent_handler( event )
	-- print( "Cloud:_enterFrameEvent_handler: ", event.type )
	-- stop motion if is_active is not set
	if not self._is_active then return end
	self.x = self.x - self.VELOCITY
	if self.x <= -240 then
		self.x = 1680
	end
	return true
end



--====================================================================--
--== Left Cloud Object Class
--====================================================================--


local LeftCloud = newClass( Cloud, {name="Left Cloud"} )

LeftCloud.TYPE = 'clouds-left'
LeftCloud.FILE = 'assets/backgrounds/clouds-left.png'



--====================================================================--
--== Right Cloud Object Class
--====================================================================--


local RightCloud = newClass( Cloud, {name="Right Cloud"} )

RightCloud.TYPE = 'clouds-right'
RightCloud.FILE = 'assets/backgrounds/clouds-right.png'




--====================================================================--
--== Cloud Factory
--====================================================================--


local CloudFactory = {}

CloudFactory.LEFT = 'left-cloud'
CloudFactory.RIGHT = 'right-cloud'


function CloudFactory.create( obj_type, params )
	-- print( "CloudFactory.create", obj_type, params )

	if obj_type==CloudFactory.LEFT then
		return LeftCloud:new( params )

	elseif obj_type==CloudFactory.RIGHT then
		return RightCloud:new( params )

	end
end


return CloudFactory
