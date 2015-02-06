--====================================================================--
-- widget_button/view_9slice.lua
--
-- Documentation: http://docs.davidmccuskey.com/
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014-2015 David McCuskey

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
--== DMC Corona Widgets : 9-Slice Button
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--


local dmc_widget_data, dmc_widget_func
dmc_widget_data = _G.__dmc_widget
dmc_widget_func = dmc_widget_data.func



--====================================================================--
--== DMC Widgets : Button 9-Slice View
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

--== Components

local BaseView = require( dmc_widget_func.find( 'widget_button.view_base' ) )



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass



--====================================================================--
--== Support Functions


-- build parameters for this image
-- get defaults and layer in specific values
--
local function createViewParams( v_name, params )
	-- print( "createViewParams", v_name, params )
	local v_p = params[ v_name ] -- specific view parameters
	local p = {
		width=params.width,
		height=params.height,
		sheet=params.sheet,
		frames=params.frames,
	}

	-- layer in view specific values
	if v_p then
		p.width = v_p.width == nil and p.width or v_p.width
		p.height = v_p.height == nil and p.height or v_p.height
		p.sheet = v_p.sheet == nil and p.sheet or v_p.sheet
		p.frames = v_p.frames == nil and p.frames or v_p.frames
	end

	return p
end



--====================================================================--
--== Button 9-Slice View Class
--====================================================================--


local NineSliceView = newClass( BaseView, {name="9-Slice View"} )

NineSliceView.TYPE = '9-slice'


--======================================================--
-- Start: Setup DMC Objects

function NineSliceView:__init__( params )
	-- print( "NineSliceView:__init__" )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Sanity Check ==--

	if self.is_class then return end

	assert( params.sheet, "expected 'sheet' parameter" )
	assert( type(params.frames)=='table', "expected 'frames' parameter" )

	--== Create Properties ==--

	self._view_params = createViewParams( self._view_name, params )

	--== Display Groups ==--

	self._dg_slices = nil

	--== Object References ==--

	-- image slices
	self._tl = nil
	self._tm = nil
	self._tr = nil
	self._ml = nil
	self._mm = nil
	self._mr = nil
	self._bl = nil
	self._bm = nil
	self._br = nil

end


-- _createView()
--
function NineSliceView:__createView__()
	-- print( "NineSliceView:__createView__" )
	self:superCall( '__createView__' )
	--==--

	local v_params = self._view_params
	local o, dg, tmp   -- object, temp

	dg = display.newGroup()
	self._dg_slices = dg
	self.view:insert( 1, dg ) -- insert over background

	--== create slices

	-- TL
	o = display.newImage( v_params.sheet, v_params.frames.top_left )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._tl = o

	-- TM
	o = display.newImage( v_params.sheet, v_params.frames.top_middle )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._tm = o

	-- TR
	o = display.newImage( v_params.sheet, v_params.frames.top_right )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._tr = o

	-- ML
	o = display.newImage( v_params.sheet, v_params.frames.middle_left )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._ml = o

	-- MM
	o = display.newImage( v_params.sheet, v_params.frames.middle )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._mm = o

	-- MR
	o = display.newImage( v_params.sheet, v_params.frames.middle_right )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._mr = o

	-- BL
	o = display.newImage( v_params.sheet, v_params.frames.bottom_left )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._bl = o

	-- BM
	o = display.newImage( v_params.sheet, v_params.frames.bottom_middle )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._bm = o

	-- BR
	o = display.newImage( v_params.sheet, v_params.frames.bottom_right )
	o.anchorX, o.anchorY = 0,0

	dg:insert( o )
	self._br = o

end

function NineSliceView:__undoCreateView__()
	-- print( "NineSliceView:__undoCreateView__" )
	local o

	self._tl:removeSelf()
	self._tl = nil

	self._tm:removeSelf()
	self._tm = nil

	self._tr:removeSelf()
	self._tr = nil

	self._ml:removeSelf()
	self._ml = nil

	self._mm:removeSelf()
	self._mm = nil

	self._mr:removeSelf()
	self._mr = nil

	self._bl:removeSelf()
	self._bl = nil

	self._bm:removeSelf()
	self._bm = nil

	self._br:removeSelf()
	self._br = nil

	self._dg_slices:removeSelf()
	self._dg_slices = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


function NineSliceView:__initComplete__()
	-- print( "NineSliceView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self:_updateView()
end


-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


function NineSliceView:_updateView()
	-- print( "NineSliceView:_updateView" )

	local middle_w = self._width - ( self._tl.width + self._tr.width )
	local middle_h = self._height - ( self._tl.height + self._bl.height )

	local o, dg, tmp, tmp2

	--== Top

	o = self._tl
	o.x, o.y = 0, 0

	tmp = o
	o = self._tm
	o.x, o.y = tmp.width, 0
	o.width = middle_w

	tmp2 = o
	o = self._tr
	o.x, o.y = tmp2.x+tmp2.width, 0

	--== Middle

	tmp = self._tl
	o = self._ml
	o.height = middle_h
	o.x, o.y = 0, tmp.height

	tmp = o
	o = self._mm
	o.height = middle_h
	o.x, o.y = tmp.x+tmp.width, tmp.y
	o.width = middle_w

	tmp2 = o
	o = self._mr
	o.height = middle_h
	o.x, o.y = tmp2.x+tmp2.width, tmp.y

	--== Bottom

	tmp = self._ml
	o = self._bl
	o.x, o.y = 0, tmp.y+tmp.height

	tmp = o
	o = self._bm
	o.x, o.y = tmp.x+tmp.width, tmp.y
	o.width = middle_w

	tmp2 = o
	o = self._br
	o.x, o.y = tmp2.x+tmp2.width, tmp.y

	-- re-align the background

	dg = self._dg_slices
	dg.x, dg.y = math.floor(-self._width/2), math.floor(-self._height/2)

end



--====================================================================--
--== Event Handlers


-- none




return NineSliceView
