--====================================================================--
-- dmc_widget/font_manager.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2015 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]



--====================================================================--
--== DMC Corona Widgets : Font Manager
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC Widgets : Font Mgr
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase

local FontMgrSingleton = nil

local LOCAL_DEBUG = true



--====================================================================--
--== FontMgr Widget Class
--====================================================================--


local FontMgr = newClass( ObjectBase, {name="Font Manager"}  )


--======================================================--
--== Start: Setup DMC Objects

function FontMgr:__init__( params )
	-- print( "FontMgr:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--
	-- keyed on font name/user data
	self._font_metrix = {}

	self._font_cache = {}
end
function FontMgr:__undoInit__()
	-- print( "FontMgr:__undoInit__" )
	self._font_metrix=nil
	--==--
	self:superCall( '__undoInit__' )
end

--[[
function FontMgr:__initComplete__()
	-- print( "FontMgr:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
end
--]]
--[[
function FontMgr:__undoInitComplete__()
	--print( "FontMgr:__undoInitComplete__" )
	--==--
	self:superCall( '__undoInitComplete__' )
end
--]]

--== END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function FontMgr:setFontMetric( font, value )
	-- print( 'FontMgr:setFontMetric', font, value )
	assert( type(font)=='string' or type(font)=='userdata' )
	assert( value )
	--==--
	self._font_metrix[ font ] = value
end

function FontMgr:getFontMetric( font, font_size )
	-- print( 'FontMgr:getFontMetric', font )
	assert( type(font)=='string' or type(font)=='userdata' )
	assert( type(font_size)=='number' )
	--==--
	local metrix, metric

	-- see if we have font
	metrix = self._font_metrix[ font ]
	if not metrix then
		return {offsetX=0,offsetY=0}
	end

	-- try from cache
	metric = self:_getFromCache( font, font_size )
	if metric then return metric end

	-- look through metrix
	local sizes = metrix.sizes
	local size

	local count = 0
	repeat
		count = count + 1
		size = sizes[ count ]
		-- print( count, #sizes, size, font_size )
	until count >= #sizes or sizes[count+1] > font_size

	-- print( 'found metric', size )
	-- print( metrix[ size ] )

	return metrix[ size ]
end



--====================================================================--
--== Private Methods


function FontMgr:_getCacheKey( font, font_size )
	return tostring(font).."::"..tostring(font_size)
end

function FontMgr:_addToCache( font, font_size, value )
	-- print( 'FontMgr:setFontMetric', font, value )
	local key = self:_getCacheKey( font, font_size )
	self._font_cache[ key ] = value
end

function FontMgr:_getFromCache( font, font_size )
	-- print( 'FontMgr:setFontMetric', font, value )
	local key = self:_getCacheKey( font, font_size )
	return self._font_cache[ key ]
end



--====================================================================--
--== Event Handlers


-- none




FontMgrSingleton = FontMgr:new()


return FontMgrSingleton
