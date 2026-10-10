--====================================================================--
-- dmc_ui/dmc_widget/widget_background/image_view.lua
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
--== DMC Corona Widgets : Image Background View
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


-- none



--====================================================================--
--== Image Background View Class
--====================================================================--


--- Background Image View Module.
--
-- @classmod Widget.Background.Image
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newImageBackground()

local ImageView = newClass( WidgetBase, {name="Image Background View"} )

--- Class Constants.
-- @section

--== Class Constants

ImageView.TYPE = uiConst.IMAGE

--== Theme Constants

ImageView.STYLE_CLASS = nil -- added later
ImageView.STYLE_TYPE = uiConst.IMAGE

-- TODO: hook up later
-- ImageView.DEFAULT = 'default'

-- ImageView.THEME_STATES = {
-- 	ImageView.DEFAULT,
-- }


--======================================================--
-- Start: Setup DMC Objects

--== Init

function ImageView:__init__( params )
	-- print( "ImageView:__init__", params )
	params = params or {}

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Class

	self._vWidth=0
	self._scaleX=1
	self._vHeight=0
	self._scaleY=1

	-- properties stored in Style

	self._imagePath_dirty=true
	self._offsetBottom_dirty=true
	self._offsetLeft_dirty=true
	self._offsetRight_dirty=true
	self._offsetTop_dirty=true

	-- virtual

	self._backgroundX_dirty=true
	self._backgroundY_dirty=true
	self._backgroundScaleX_dirty=true
	self._backgroundScaleY_dirty=true

	--== Object References ==--

	-- image ref
	self._img = nil

end

--[[
function ImageView:__undoInit__()
	-- print( "ImageView:__undoInit__" )
	--==--
		self:superCall( '__undoInit__' )
end
--]]

--== createView

--[[
function ImageView:__createView__()
	-- print( "ImageView:__createView__" )
	self:superCall( '__createView__' )
	--==--
end

function ImageView:__undoCreateView__()
	-- print( "ImageView:__undoCreateView__" )
	--==--
	self:superCall( '__undoCreateView__' )
end
--]]

--== initComplete

--[[
function ImageView:__initComplete__()
	-- print( "ImageView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
end

function ImageView:__undoInitComplete__()
	--print( "ImageView:__undoInitComplete__" )
	--==--
	self:superCall( '__undoInitComplete__' )
end
--]]

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ImageView.initialize( manager )
	-- print( "ImageView.initialize" )
	dUI = manager

	local Style = dUI.Style
	local StyleFactory = Style.BackgroundFactory
	ImageView.STYLE_CLASS = StyleFactory.Image

	Style.registerWidget( ImageView )
end



--====================================================================--
--== Public Methods


--== .width (custom)

--- [**style**] set/get width.
--
-- @within Properties
-- @function .width
-- @usage widget.width = 5
-- @usage print( widget.width )

function ImageView.__getters:width()
	-- print( 'ImageView.__getters:width' )
	local w = self.curr_style.width
	if w==0 then w = self._vWidth end
	return w
end
function ImageView.__setters:width( value )
	-- print( 'ImageView.__setters:width', value )
	self.curr_style.width = value
end

--== .height (custom)

--- [**style**] set/get height.
--
-- @within Properties
-- @function .height
-- @usage widget.height = 5
-- @usage print( widget.height )

function ImageView.__getters:height()
	-- print( 'ImageView.__getters:height' )
	local h = self.curr_style.height
	if h==0 then h = self._vHeight end
	return h
end
function ImageView.__setters:height( value )
	-- print( 'ImageView.__setters:height', value )
	self.curr_style.height = value
end



--====================================================================--
--== Private Methods


function ImageView:_removeBackgroundImage()
	-- print( "ImageView:_removeBackgroundImage" )
	local o = self._img
	if o then
		o:removeSelf()
		self._img = nil
	end
end


function ImageView:_createBackgroundImage( path )
	-- print( "ImageView:_createBackgroundImage", path )
	self:_removeBackgroundImage()

	local o = newImage( path )
	o.anchorX, o.anchorY = 0,0
	self._dgBg:insert( o )
	self._img = o
end

function ImageView:__commitProperties__()
	-- print( 'ImageView:__commitProperties__' )
	local style = self.curr_style
	local view = self.view
	local offset = {
		bottom=style.offsetBottom,
		left=style.offsetLeft,
		right=style.offsetRight,
		top=style.offsetTop,
	}

	if self._imagePath_dirty then
		self:_createBackgroundImage( style.imagePath )
		self._imagePath_dirty=false

		self._width_dirty=true
		self._height_dirty=true
	end

	local img = self._img
	local dg = self._dgBg

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

		self._anchorX_dirty=true
		self._backgroundScaleX_dirty=true
	end

	if self._height_dirty then
		self._height_dirty=false

		self._anchorY_dirty=true
		self._backgroundScaleY_dirty=true
	end

	if self._offsetLeft_dirty or self._offsetRight_dirty then
		self._vWidth = img.width-(offset.left+offset.right)
		self._offsetLeft_dirty=false
		self._offsetRight_dirty=false

		self._backgroundScaleX_dirty=true
	end
	if self._offsetBottom_dirty or self._offsetTop_dirty then
		img.y = -offset.top
		self._vHeight = img.height-(offset.top+offset.bottom)
		self._offsetBottom_dirty=false
		self._offsetTop_dirty=false

		self._backgroundScaleY_dirty=true
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		self._anchorX_dirty=false

		self._backgroundX_dirty=true
	end
	if self._anchorY_dirty then
		self._anchorY_dirty=false

		self._backgroundY_dirty=true
	end

	if self._backgroundScaleX_dirty then
		local width = style.width
		local scale = 1
		if width~=0 then
			scale = width / self._vWidth
		end
		img.xScale = scale
		img.x = -(offset.left*scale)
		self._scaleX = scale
		self._backgroundScaleX_dirty=false

		self._backgroundX_dirty=true
	end
	if self._backgroundScaleY_dirty then
		local height = style.height
		local scale = 1
		if height~=0 then
			scale = height / self._vHeight
		end
		img.yScale = scale
		img.y = -(offset.top*scale)
		self._scaleY = scale
		self._backgroundScaleY_dirty=false

		self._backgroundY_dirty=true
	end

	if self._backgroundX_dirty then
		local anchorX = style.anchorX
		local width = self._vWidth*self._scaleX
		dg.x = -width*anchorX
		self._backgroundX_dirty=false
	end

	if self._backgroundY_dirty then
		local anchorY = style.anchorY
		local height = self._vHeight*self._scaleY
		dg.y = -height*anchorY
		self._backgroundY_dirty=false
	end

end



--====================================================================--
--== Event Handlers


function ImageView:stylePropertyChangeHandler( event )
	-- print( "ImageView:stylePropertyChangeHandler", event )
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

		self._imagePath_dirty=true
		self._offsetBottom_dirty=true
		self._offsetLeft_dirty=true
		self._offsetRight_dirty=true
		self._offsetTop_dirty=true

		self._backgroundX_dirty=true
		self._backgroundY_dirty=true

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

		elseif property=='imagePath' then
			self._imagePath_dirty=true
		elseif property=='offsetBottom' then
			self._offsetBottom_dirty=true
		elseif property=='offsetLeft' then
			self._offsetLeft_dirty=true
		elseif property=='offsetRight' then
			self._offsetRight_dirty=true
		elseif property=='offsetTop' then
			self._offsetTop_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return ImageView
