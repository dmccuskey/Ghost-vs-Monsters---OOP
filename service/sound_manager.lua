--====================================================================--
-- service/sound_manager.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Ghost vs Monsters : Sound Manager
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

local LOCAL_DEBUG = true



--====================================================================--
--== Sound Manager Class
--====================================================================--


local SoundMgr = newClass( ObjectBase, {name="Sound Manager"} )

SoundMgr.BLAST_OFF='blast-off-sound'
SoundMgr.IMPACT='impact-sound'
SoundMgr.NEW_ROUND='new-round-sound'
SoundMgr.POOF='poof-sound'
SoundMgr.TAP='tap-sound'
SoundMgr.WEE='wee-sound'

SoundMgr._SOUNDS = {
	{ SoundMgr.BLAST_OFF, 'assets/sounds/blastoff.wav' },
	{ SoundMgr.IMPACT, 'assets/sounds/blastoff.wav' },
	{ SoundMgr.NEW_ROUND, 'assets/sounds/newround.wav' },
	{ SoundMgr.POOF, 'assets/sounds/ghostpoof.wav' },
	{ SoundMgr.TAP, 'assets/sounds/tapsound.wav' },
	{ SoundMgr.WEE, 'assets/sounds/wee.wav' }
}


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function SoundMgr:__init__( params )
	self:superCall( '__init__', params )
	params = params or {}
	--==--

	--== Properties

	-- sound table, keyed on sound names
	self._sounds = {}
end

--[[
function SoundMgr:__undoInit__()
	self._sounds = nil
	--==--
	self:superCall( '__undoInit__' )
end
--]]


-- __initComplete__()
--
function SoundMgr:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self:_loadSounds( self._SOUNDS )
end

-- __undoInitComplete__()
--
function SoundMgr:__undoInitComplete__()
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function SoundMgr:play( name )
	-- print( "SoundMgr:play", name )
	assert( type(name)=='string', "SoundMgr.play(): incorrect type for name" )
	--==--
	local sounds = self._sounds
	assert( sounds[name], string.format( "SoundMgr.play(): unknown sound '%s'", tostring(name) ))
	audio.play( sounds[name] )
end



--====================================================================--
--== Private Methods


-- _insertSound()
--
-- name, key used for sound reference
-- file, path for sound file
--
function SoundMgr:_insertSound( name, file )
	-- print( "SoundMgr:_insertSound", name, file )
	local sounds = self._sounds
	local snd = audio.loadSound( file )
	assert( snd, string.format( "SoundMgr._insertSound(): error loading sound file '%s'", tostring(file) ))
	sounds[ name ] = snd
end


-- _loadSounds()
--
-- data is array of sound info
-- sound info is array: {name, file_path}
--
function SoundMgr:_loadSounds( data )
	for _, info in ipairs( data ) do
		-- print( info[1], info[2] )
		self:_insertSound( unpack( info ) )
	end
end



--====================================================================--
--== Event Handlers


-- none



return SoundMgr
