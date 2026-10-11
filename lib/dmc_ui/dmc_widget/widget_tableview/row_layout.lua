--====================================================================--
-- dmc_ui/dmc_widget/widget_tableview/row_layout.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2013-2015 David McCuskey

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
--== DMC Corona UI : TableView Row Layout
--====================================================================--


--[[
where the rows of a TableView are: how many, the top and height of
each, which ones are in a part of the list, how high they are together.

two layouts with the same methods. the TableView picks one at
reloadData() and doesn't care which it has:

* Uniform: every row has one height. nothing is kept for a row: its
  top is a multiplication, the row at a position a division.
* Variable: each row has its own height. the heights and the tops
  (a running sum) are kept, and a row is found by binary search.

plain Lua, no display objects.
--]]


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Setup, Constants


local mceil = math.ceil
local mfloor = math.floor
local tinsert = table.insert
local tremove = table.remove



--====================================================================--
--== Uniform Layout
--====================================================================--


local Uniform = {}
Uniform.__index = Uniform

Uniform.isUniform = true

-- @param count the number of rows
-- @param rowHeight the height of each
--
function Uniform.new( count, rowHeight )
	assert( type(count)=='number' and count>=0 )
	assert( type(rowHeight)=='number' and rowHeight>0 )
	return setmetatable( { _count=count, _rowHeight=rowHeight }, Uniform )
end

function Uniform:count()
	return self._count
end

function Uniform:top( index )
	return ( index-1 ) * self._rowHeight
end

function Uniform:height( index )
	return self._rowHeight
end

function Uniform:totalHeight()
	return self._count * self._rowHeight
end

-- the first and last row which are in, or touch, the part of the
-- list from yMin to yMax. nil if there is none
--
function Uniform:range( yMin, yMax )
	local count, height = self._count, self._rowHeight
	local first = mceil( yMin/height )
	local last = mfloor( yMax/height ) + 1
	if first < 1 then first = 1 end
	if last > count then last = count end
	if first > last then return nil end
	return first, last
end

-- a row was added at index. 'height' is not used: it has the one height
--
function Uniform:insert( index, height )
	self._count = self._count + 1
end

function Uniform:remove( index )
	self._count = self._count - 1
end

-- not here: every row has the one height
--
function Uniform:setHeight( index, height )
end



--====================================================================--
--== Variable Layout
--====================================================================--


local Variable = {}
Variable.__index = Variable

Variable.isUniform = false

-- set the tops of the rows from 'index' on, from the heights
--
local function sumTops( self, index )
	local heights, tops = self._heights, self._tops
	local top = 0
	if index > 1 then top = tops[index-1] + heights[index-1] end
	for i = index, #heights do
		tops[i] = top
		top = top + heights[i]
	end
	self._total = top
end

-- @param heights array with the height of each row. it is kept
--
function Variable.new( heights )
	assert( type(heights)=='table' )
	local o = setmetatable( { _heights=heights, _tops={}, _total=0 }, Variable )
	sumTops( o, 1 )
	return o
end

function Variable:count()
	return #self._heights
end

function Variable:top( index )
	return self._tops[ index ]
end

function Variable:height( index )
	return self._heights[ index ]
end

function Variable:totalHeight()
	return self._total
end

-- the first and last row which are in, or touch, the part of the
-- list from yMin to yMax. nil if there is none
--
function Variable:range( yMin, yMax )
	local heights, tops = self._heights, self._tops
	local count = #heights
	local low, high, mid, first, last

	-- the first row whose bottom is at yMin or below it
	low, high = 1, count
	while low <= high do
		mid = mfloor( ( low+high )*0.5 )
		if tops[mid]+heights[mid] < yMin then
			low = mid + 1
		else
			high = mid - 1
		end
	end
	first = low

	-- the last row whose top is at yMax or above it
	low, high = first, count
	while low <= high do
		mid = mfloor( ( low+high )*0.5 )
		if tops[mid] > yMax then
			high = mid - 1
		else
			low = mid + 1
		end
	end
	last = high

	if first > last then return nil end
	return first, last
end

function Variable:insert( index, height )
	assert( type(height)=='number' and height>0 )
	tinsert( self._heights, index, height )
	tinsert( self._tops, index, 0 )
	sumTops( self, index )
end

function Variable:remove( index )
	tremove( self._heights, index )
	tremove( self._tops, index )
	sumTops( self, index )
end

function Variable:setHeight( index, height )
	assert( type(height)=='number' and height>0 )
	self._heights[ index ] = height
	sumTops( self, index )
end



return {
	Uniform=Uniform,
	Variable=Variable,
}
