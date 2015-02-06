--====================================================================--
-- service/level_manager.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Ghost vs Monsters : Level Manager
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Objects = require 'lib.dmc_corona.dmc_objects'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase

local tinsert = table.insert
local tremove = table.remove

local LOCAL_DEBUG = false



--====================================================================--
--== Level Manager Class
--====================================================================--


local LevelMgr = newClass( ObjectBase, {name="Level Manager"} )

LevelMgr.DEFAULT_DATA = 'data.levels'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function LevelMgr:__init__( params )
	self:superCall( '__init__', params )
	params = params or {}
	--==--

	--== Properties

	-- array
	self._levels = {}
	self._path = params.path or self.DEFAULT_DATA
end

--[[
function LevelMgr:__undoInit__()
	self._levels = nil
	self._path = nil
	--==--
	self:superCall( '__undoInit__' )
end
--]]


-- __initComplete__()
--
function LevelMgr:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self:_loadLevels( self._path )
end

-- __undoInitComplete__()
--
function LevelMgr:__undoInitComplete__()
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- getLevelData()
--
-- get level data, value can be integer or name
--
function LevelMgr:getLevelData( value )
	-- print( "LevelMgr:getLevelData", value )
	local lvl_type = type(value)
	assert( lvl_type=='number' or lvl_type=='string', "incorrect type for data level name" )
	--==--
	if lvl_type=='number' then
		return self:_getLevelByIndex( value )
	elseif lvl_type=='string' then
		return self:_getLevelByName( value )
	end
end


function LevelMgr:getNextLevelData( currentLevelName )
	-- print( "LevelMgr:getNextLevelData", currentLevelName )
	assert( type(currentLevelName)=='string', "incorrect type for data level name" )
	--==--
	local nextLevelName = Level_Data[ currentLevelName ].info.nextLevel
	return self:getLevelData( nextLevelName )
end



--====================================================================--
--== Private Methods


-- _insertLevelData()
--
-- inserts a level into the level array
--
function LevelMgr:_insertLevelData( data )
	-- print( "LevelMgr:_insertLevelData", data )
	assert( type(data)=='table', 'incorrect type for data' )
	--==--
	tinsert( self._levels, data )
end


-- _updateLevelData()
--
-- updates level data given data structure. matches on name
--
function LevelMgr:_updateLevelData( data )
	-- print( "LevelMgr:_updateLevelData", data )
	assert( type(data)=='table', 'incorrect type for data' )
	--==--
	local levels = self._levels

	for i=1,#levels do
		local lvl = levels[i]
		if lvl.info.name == data.info.name then
			levels[i] = data
			break
		end
	end
end


-- _getLevelByIndex()
--
-- get level by index
--
function LevelMgr:_getLevelByIndex( idx )
	-- print( "LevelMgr:_getLevelByIndex", idx )
	assert( type(idx)=='number', 'incorrect type for idx' )
	--==--
	return self._levels[idx]
end


-- _getLevelByName()
--
-- get level by name
--
function LevelMgr:_getLevelByName( name )
	-- print( "LevelMgr:_getLevelByName", name )
	assert( type(name)=='string', 'incorrect type for name' )
	--==--
	local levels = self._levels
	local result = nil
	for i=1,#levels do
		local lvl = levels[i]
		if lvl.info.name == name then
			result = lvl
			break
		end
	end
	return result
end


function LevelMgr:_loadLevels( path )
	-- print( "LevelMgr:_loadLevels", path )
	local data = require( path )
	for _, level in ipairs( data ) do
		self:_insertLevelData( level )
	end
end



--====================================================================--
--== Event Handlers


-- none




return LevelMgr
