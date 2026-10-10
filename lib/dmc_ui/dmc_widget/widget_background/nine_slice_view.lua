--====================================================================--
-- dmc_ui/dmc_widget/widget_background/nice_slice_view.lua
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
--== DMC Corona Widgets : 9-Slice Background View
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
--== DMC Widgets : new9SliceBackground
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )



--====================================================================--
--== Setup, Constants


local newImage = display.newImage

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Support Functions


local function loadSpriteSheet( info, image )
	local spriteInfo = require( info )
	return graphics.newImageSheet( image, spriteInfo:getSheet() )
end



--====================================================================--
--== 9-Slice Background View Class
--====================================================================--


--- Background 9-Slice View Module.
--
-- @classmod Widget.Background.9Slice
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.new9SliceBackground()

local NineSliceView = newClass( WidgetBase, {name="9-Slice Background View"} )

--- Class Constants.
-- @section

--== Class Constants

NineSliceView.TYPE = uiConst.NINE_SLICE

--== Theme Constants

NineSliceView.STYLE_CLASS = nil -- added later
NineSliceView.STYLE_TYPE = uiConst.NINE_SLICE

-- TODO: hook up later
-- NineSliceView.DEFAULT = 'default'

-- NineSliceView.THEME_STATES = {
-- 	NineSliceView.DEFAULT,
-- }


--======================================================--
-- Start: Setup DMC Objects

--== Init

function NineSliceView:__init__( params )
	-- print( "NineSliceView:__init__", params )
	params = params or {}

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._sheet = nil
	self._spriteSheet_dirty=true

	-- properties stored in Style

	self._offsetLeft_dirty=true
	self._offsetRight_dirty=true
	self._offsetTop_dirty=true
	self._offsetBottom_dirty=true
	self._sheetInfo_dirty=true
	self._sheetImage_dirty=true
	self._spriteFrames_dirty=true

	-- virtual

	self._sliceLayout_dirty=true
	self._sliceX_dirty=true
	self._sliceY_dirty=true

	--== Object References ==--

	-- display group for slices
	self._dgSlice = nil

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

--[[
function NineSliceView:__undoInit__()
	-- print( "NineSliceView:__undoInit__" )
	--==--
		self:superCall( '__undoInit__' )
end
--]]

--== createView

function NineSliceView:__createView__()
	-- print( "NineSliceView:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local dg = display.newGroup()
	self._dgSlice = dg
	self.view:insert( 2, dg ) -- insert between layers
end

function NineSliceView:__undoCreateView__()
	-- print( "NineSliceView:__undoCreateView__" )
	self._dgSlice:removeSelf()
	self._dgSlice=nil
	--==--
	self:superCall( '__undoCreateView__' )
end

--== initComplete

--[[
function NineSliceView:__initComplete__()
	-- print( "NineSliceView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
end

function NineSliceView:__undoInitComplete__()
	--print( "NineSliceView:__undoInitComplete__" )
	--==--
	self:superCall( '__undoInitComplete__' )
end
--]]

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function NineSliceView.initialize( manager )
	-- print( "NineSliceView.initialize" )
	dUI = manager

	local Style = dUI.Style
	local StyleFactory = Style.BackgroundFactory
	NineSliceView.STYLE_CLASS = StyleFactory.NineSlice

	Style.registerWidget( NineSliceView )
end



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


function NineSliceView:_adjustSliceLayout( width, height, off )
	-- print( "NineSliceView:_adjustSliceLayout", width, height )
	local leftW = self._tl.width-off.L
	local rightW = self._tr.width-off.R
	local topH = self._tl.height-off.T
	local bottomH = self._bl.height-off.B
	-- a size smaller than the corners leaves no room for the middle: hide it
	local midW = math.max( 0, width - leftW - rightW )
	local midH = math.max( 0, height - topH - bottomH )
	-- column and row edges; the offsets lie outside 0..width, 0..height
	local x0, y0 = -off.L, -off.T
	local x1, y1 = x0+self._tl.width, y0+self._tl.height
	local x2, y2 = x1+midW, y1+midH

	local function place( o, x, y, w, h )
		o.x, o.y = x, y
		if w==0 or h==0 then
			o.isVisible=false
			return
		end
		o.isVisible=true
		if w then o.width=w end
		if h then o.height=h end
	end

	place( self._tl, x0, y0 )
	place( self._tm, x1, y0, midW, nil )
	place( self._tr, x2, y0 )

	place( self._ml, x0, y1, nil, midH )
	place( self._mm, x1, y1, midW, midH )
	place( self._mr, x2, y1, nil, midH )

	place( self._bl, x0, y2 )
	place( self._bm, x1, y2, midW, nil )
	place( self._br, x2, y2 )

end

function NineSliceView:_removeImageSlices()
	-- print( "NineSliceView:_removeImageSlices" )
	local o

	o = self._tl
	if o then
		o:removeSelf()
		self._tl = nil
	end

	o = self._tm
	if o then
		o:removeSelf()
		self._tm = nil
	end

	o = self._tr
	if o then
		o:removeSelf()
		self._tr = nil
	end

	o = self._ml
	if o then
		o:removeSelf()
		self._ml = nil
	end

	o = self._mm
	if o then
		o:removeSelf()
		self._mm = nil
	end

	o = self._mr
	if o then
		o:removeSelf()
		self._mr = nil
	end

	o = self._bl
	if o then
		o:removeSelf()
		self._bl = nil
	end

	o = self._bm
	if o then
		o:removeSelf()
		self._bm = nil
	end

	o = self._br
	if o then
		o:removeSelf()
		self._br = nil
	end

end


function NineSliceView:_createImageSlices( sheet, frames )
	-- print( "NineSliceView:_createImageSlices", sheet, frames )
	local dg = self._dgSlice
	local o

	self:_removeImageSlices()

	-- do middle pieces first
	-- put on lower layer for overlap

	-- TL
	o = newImage( sheet, frames.topLeft )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._tl = o

	-- TM
	o = newImage( sheet, frames.topMiddle )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._tm = o

	-- TR
	o = newImage( sheet, frames.topRight )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._tr = o

	-- ML
	o = newImage( sheet, frames.middleLeft )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._ml = o

	-- MM
	o = newImage( sheet, frames.middleMiddle )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._mm = o

	-- MR
	o = newImage( sheet, frames.middleRight )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._mr = o

	-- BL
	o = newImage( sheet, frames.bottomLeft )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._bl = o

	-- BM
	o = newImage( sheet, frames.bottomMiddle )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._bm = o

	-- BR
	o = newImage( sheet, frames.bottomRight )
	o.anchorX, o.anchorY = 0,0
	dg:insert( o )
	self._br = o
end

function NineSliceView:__commitProperties__()
	-- print( 'NineSliceView:__commitProperties__' )
	local style = self.curr_style
	local view = self.view

	if self._sheetInfo_dirty or self._sheetImage_dirty then
		self._sheet = loadSpriteSheet( style.sheetInfo, style.sheetImage )
		self._sheetInfo_dirty=false
		self._sheetImage_dirty=false

		self._spriteSheet_dirty=true
	end

	if self._spriteSheet_dirty then
		self:_createImageSlices( self._sheet, style.spriteFrames )
		self._spriteSheet_dirty=false
	end

	-- x/y

	if self._x_dirty then
		view.x = self._x
		self._x_dirty = false
	end
	if self._y_dirty then
		view.y = self._y
		self._y_dirty = false
	end

	if self._width_dirty then
		self._width_dirty=false

		self._sliceLayout_dirty=true
		self._sliceX_dirty=true
	end

	if self._height_dirty then
		self._height_dirty=false

		self._sliceLayout_dirty=true
		self._sliceY_dirty=true
	end

	if self._sliceLayout_dirty then
		local offsets = {
			L=style.offsetLeft,
			R=style.offsetRight,
			T=style.offsetTop,
			B=style.offsetBottom,
		}
		self:_adjustSliceLayout( style.width, style.height, offsets )
		self._sliceLayout_dirty=false
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		self._anchorX_dirty=false

		self._sliceX_dirty=true
	end
	if self._anchorY_dirty then
		self._anchorY_dirty=false

		self._sliceY_dirty=true
	end

	if self._sliceX_dirty then
		local dg = self._dgSlice
		local anchorX = style.anchorX
		local width = style.width
		local offsetLeft, offsetRight = style.offsetLeft, style.offsetRight
		local anchor = width*anchorX
		dg.x = self._x - anchor
		self._sliceX_dirty=false
	end

	if self._sliceY_dirty then
		local dg = self._dgSlice
		local anchorY = style.anchorY
		local height = style.height
		local offsetTop, offsetBottom = style.offsetTop, style.offsetBottom
		local realH = height - (offsetTop + offsetBottom)
		local anchor = height*anchorY
		dg.y = self._y - anchor
		self._sliceY_dirty=false
	end

end



--====================================================================--
--== Event Handlers


function NineSliceView:stylePropertyChangeHandler( event )
	-- print( "NineSliceView:stylePropertyChangeHandler", event )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- print( "Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty = true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._offsetLeft_dirty=true
		self._offsetRight_dirty=true
		self._offsetTop_dirty=true
		self._offsetBottom_dirty=true
		self._sheetInfo_dirty=true
		self._sheetImage_dirty=true
		self._spriteFrames_dirty=true

		self._sliceLayout_dirty=true
		self._sliceX_dirty=true
		self._sliceY_dirty=true
		self._spriteSheet_dirty=true

		property = etype

	else
		if property=='debugActive' then
			self._debugOn_dirty=true
		elseif property=='width' then
			self._width_dirty=true
		elseif property=='height' then
			self._height_dirty=true
		elseif property=='anchorX' then
			self._anchorX_dirty=true
		elseif property=='anchorY' then
			self._anchorY_dirty=true

		elseif property=='spriteFrames' then
			self._spriteFrames_dirty=true
		elseif property=='offsetLeft' then
			self._offsetLeft_dirty=true
		elseif property=='offsetRight' then
			self._offsetRight_dirty=true
		elseif property=='offsetTop' then
			self._offsetTop_dirty=true
		elseif property=='offsetBottom' then
			self._offsetBottom_dirty=true
		elseif property=='sheetInfo' then
			self._sheetInfo_dirty=true
		elseif property=='sheetImage' then
			self._sheetImage_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return NineSliceView
