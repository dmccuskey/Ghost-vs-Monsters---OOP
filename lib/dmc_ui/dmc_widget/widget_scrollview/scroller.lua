--====================================================================--
-- dmc_ui/dmc_widget/widget_scrollview/scroller.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (C) 2015 David McCuskey. All Rights Reserved.

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
--== DMC Corona UI : UI View Base
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Corona UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI :
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local uiConst = require( ui_find( 'ui_constants' ) )
local Utils = require 'dmc_utils'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

-- local mabs = math.abs
-- local sfmt = string.format
-- local tinsert = table.insert
-- local tremove = table.remove
-- local tstr = tostring



--====================================================================--
--== Scroller View Class
--====================================================================--


local Scroller = newClass( ComponentBase, {name="Scroller"} )


--======================================================--
-- Start: Setup DMC Objects

function Scroller:__init__( params )
	-- print( "Scroller:__init__" )
	params = params or {}
	if params.x_offset==nil then params.x_offset = 0 end
	if params.y_offset==nil then params.y_offset = 0 end

	self:superCall( '__init__', params )
	--==--

	self._width = params.width
	self._height = params.height

	self._x_offset = params.x_offset
	self._y_offset = params.y_offset

	self._rectBg = nil
	self._dgMain = nil

end

--== createView

function Scroller:__createView__()
	-- print( "Scroller:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local W,H = self._width, self._height
	local dg, o
	-- scrollview scroll area

	o = display.newRect( 0,0,W,H )
	o.anchorX, o.anchorY = 0, 0
	o:setFillColor( 1,1,1,0 )
	self.view:insert( o )
	self._rectBg = o

	dg = display.newGroup()
	self.view:insert( dg )
	self._dgMain = dg

end

function Scroller:__undoCreateView__()
	-- print( "Scroller:__undoCreateView__" )
	self._rectBg:removeSelf()
	self._rectBg=nil
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function Scroller.__setters:debugOn( value )
	-- print( "Scroller.__setters:debugOn" )
	if value then
		self._rectBg:setFillColor( 1,1,1,0.1 )
	else
		self._rectBg:setFillColor( 0,0,0,0 )
	end
end


function Scroller.__getters:width()
	-- print( "Scroller.__getters:width" )
	return self._width
end
function Scroller.__setters:width( value )
	-- print( "Scroller.__setters:width" )
	self._width = value
	self._rectBg.width=value
end
function Scroller.__getters:height()
	-- print( "Scroller.__getters:height" )
	return self._height
end
function Scroller.__setters:height( value )
	-- print( "Scroller.__setters:height", value )
	self._height = value
	self._rectBg.height=value
end

function Scroller.__getters:x( value )
	-- print( "Scroller.__getters:x" )
	return ( self.view.x - self._x_offset )
end
function Scroller.__setters:x( value )
	-- print( "Scroller.__setters:x", value )
	self.view.x = ( value + self._x_offset )
end
function Scroller.__getters:y( value )
	-- print( "Scroller.__getters:y" )
	return ( self.view.y - self._y_offset )
end
function Scroller.__setters:y( value )
	-- print( "Scroller.__setters:y" )
	self.view.y = ( value + self._y_offset )
end
function Scroller.__setters:x_offset( value )
	-- print( "Scroller.__setters:x_offset" )
	self._x_offset = value
end
function Scroller.__getters:x_offset()
	-- print( "Scroller.__getters:x_offset" )
	return self._x_offset
end
function Scroller.__setters:y_offset( value )
	-- print( "Scroller.__setters:y_offset" )
	self._y_offset = value
end
function Scroller.__getters:y_offset()
	-- print( "Scroller.__getters:y_offset" )
	return self._y_offset
end


function Scroller:insertItem( item )
	-- print( "Scroller:insertItem", item )
	return self._dgMain:insert( item )
end

function Scroller:removeItem( item )
	-- print( "Scroller:removeItem" )
end



return Scroller
