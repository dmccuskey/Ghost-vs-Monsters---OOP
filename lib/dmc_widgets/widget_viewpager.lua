--====================================================================--
-- widget_viewpager.lua
--
--
-- by David McCuskey
-- Documentation: http://docs.davidmccuskey.com/display/docs/newViewPager.lua
--====================================================================--

--[[

Copyright (C) 2013-2014 David McCuskey. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in the
Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

--]]


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "1.0.0"



--====================================================================--
-- DMC Widgets : newViewPager
--====================================================================--

local dmc_lib_data, dmc_lib_func
dmc_lib_data = _G.__dmc_library
dmc_lib_func = dmc_lib_data.func



--====================================================================--
-- Imports
--====================================================================--

local Utils = require( dmc_lib_func.find('dmc_utils') )
local Objects = require( dmc_lib_func.find('dmc_objects') )



--====================================================================--
-- Setup, Constants
--====================================================================--

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local CoronaBase = Objects.CoronaBase



--====================================================================--
-- View Pager Widget Class
--====================================================================--

local ViewPager = inheritsFrom( CoronaBase )
ViewPager.NAME = "View Pager Widget Class"

ViewPager.MARGIN = 20
ViewPager.RADIUS = 5



--== EVENT Constants

ViewPager.EVENT = "view_pager_event"

ViewPager.SELECTED = "page_selected"

ViewPager.NEXT_PAGE = "next_page"
ViewPager.SAME_PAGE = "same_page"
ViewPager.PREV_PAGE = "previous_page"


--== Start: Setup DMC Objects


function ViewPager:_init( params )
	--print( "ViewPager:_init" )
	self:superCall( "_init", params )
	--==--

	params = params or { }

	--== Create Properties ==--

	self._pages = 0
	self._current_idx = 0

	self._margin = params.margin
	if self._margin == nil then self._margin = ViewPager.MARGIN end

	self._radius = params.radius
	if self._radius == nil then self._radius = ViewPager.RADIUS end


	--== Display Groups ==--

	self._dg = nil


	--== Object References ==--

	self._active_dots = {}
	self._inactive_dots = {}

end

function ViewPager:_undoInit()
	--print( "ViewPager:_undoInit" )

	self._active_dots = nil
	self._inactive_dots = nil

	--==--
	self:superCall( "_undoInit" )
end



-- _createView()
--
function ViewPager:_createView()
	--print( "ViewPager:_createView" )
	self:superCall( "_createView" )
	--==--

	local o, dg, tmp  -- object, display group, tmp

	o = display.newRect(0,0,0,0)
	o:setFillColor( 0.5, 0.5, 0.5, 0.5 )
	self:insert( o )
	self._primer = o

	dg = display.newGroup()
	self:insert( dg )
	self._dg = dg

	self.anchorX, self.anchorY = 0.5, 0.5


end

function ViewPager:_undoCreateView()
	--print( "ViewPager:_undoCreateView" )

	local o

	o = self._primer
	o:removeSelf()
	self._primer = nil

	o = self._dg
	o:removeSelf()
	self._dg = nil

	--==--
	self:superCall( "_undoCreateView" )
end


-- _initComplete()
--
function ViewPager:_initComplete()
	--print( "ViewPager:_initComplete" )

	self:_addDots()

	--==--
	self:superCall( "_initComplete" )
end

function ViewPager:_undoInitComplete()
	--print( "ViewPager:_undoInitComplete" )

	self:_removeDots()

	--==--
	self:superCall( "_undoInitComplete" )
end


--== END: Setup DMC Objects


--== Public Methods


function ViewPager.__setters:pages( value )
	-- print( 'ViewPager.__setters:pages', value )

	if self._pages == value then return end

	self._pages = value

	self:_removeDots()
	self:_addDots()

end

function ViewPager.__setters:index( value )
	-- print( 'ViewPager__setters:index', value )

	-- check incoming value

	if type(value) ~= 'number' then
		error( 'Widget ViewPager: index must be an integer', 2 )
	end
	if value < 1 or value > self._pages then
		error( 'Widget ViewPager: index must be within range', 2 )
	end

	-- do work

	if self._current_idx == value then return end

	if self._current_idx ~= 0 then
		self._active_dots[ self._current_idx ].isVisible = false
	end

	self._active_dots[ value ].isVisible = true
	self._current_idx = value

end


--== Private Methods


function ViewPager:_addDots()
	-- print( 'ViewPager:_addDots', self._pages )

	if self._pages < 1 then return end

	local RAD = self._radius
	local MARGIN = self._margin

	local o, dg
	local x, y


	-- set background

	o = self._primer
	o.width = (self._pages-1) * ( RAD*2 + MARGIN/2 ) + MARGIN
	o.height = RAD*2 + 10

	o.anchorX, o.anchorY = 0.5, 0.5
	o.x, o.y = 0, 0


	-- create dots

	dg = self._dg
	x, y = -( o.width/2-MARGIN/2 ), 0

	for i=1, self._pages do

		-- create unselected dot

		o = display.newCircle( 0,0, RAD )
		o:setFillColor( 0.5, 0.5, 0.5 )
		o.isVisible = true

		o.anchorX, o.anchorY = 0.5, 0.5
		o.x, o.y = x, y

		o._index = i
		f = self:createCallback( ViewPager._dotSelected_handler )
		o:addEventListener ( 'touch', f )
		o._f = f

		dg:insert( o )
		self._inactive_dots[ i ] = o


		-- create selected dot

		o = display.newCircle( 0,0, RAD )
		o:setFillColor( 1, 1, 1 )
		o.isVisible = false

		o.anchorX, o.anchorY = 0.5, 0.5
		o.x, o.y = x, y

		dg:insert( o )
		self._active_dots[ i ] = o

		x = x + MARGIN
	end

end


function ViewPager:_removeDots()
	-- print( 'ViewPager:_removeDots' )

	for i, o in ipairs( self._inactive_dots ) do
		o:removeEventListener ( 'touch', o._f )
		o._f = nil
		o:removeSelf()
	end

	for i, o in ipairs( self._active_dots ) do
		o:removeSelf()
	end

end




--== Event Handlers



function ViewPager:_dotSelected_handler ( event )
	-- print( "ViewPager:_dotSelected_handler" )

	local phase = event.phase
	local index = event.target._index

	local curr_idx = self._current_idx
	local data = {}

	if phase == 'ended' or phase == 'canceled' then

			if curr_idx < index then
				data.direction = ViewPager.NEXT_PAGE
				data.index = curr_idx + 1

			elseif curr_idx == index then
				data.direction = ViewPager.SAME_PAGE
				data.index = curr_idx

			else
				data.direction = ViewPager.PREV_PAGE
				data.index = curr_idx - 1

			end

			self.index = data.index
			self:_dispatchEvent( ViewPager.SELECTED, data )

	end

	return true
end


function ViewPager:_dispatchEvent( e_type, data )
	--print( "ViewPager:_dispatchEvent" )

	params = params or {}

	-- setup custom event
	local e = {
		name = ViewPager.EVENT,
		type = e_type,
		data = data
	}

	self:dispatchEvent( e )
end





return ViewPager
