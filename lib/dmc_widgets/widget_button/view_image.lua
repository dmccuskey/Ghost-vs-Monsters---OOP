--====================================================================--
-- widget_button/view_image.lua
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
--== DMC Corona Widgets : Image Button Widget
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
--== DMC Widgets : Button Image View
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
local function createImageParams( v_name, params )
	-- print( "createImageParams", v_name, params )
	local v_p = params[ v_name ] -- specific view parameters
	local p = {
		width=params.width,
		height=params.height,
		file=params.file,
		base_dir=params.base_dir,
	}

	-- layer in view specific values
	if v_p then
		p.width = v_p.width == nil and p.width or v_p.width
		p.height = v_p.height == nil and p.height or v_p.height
		p.file = v_p.file == nil and p.file or v_p.file
		p.base_dir = v_p.base_dir == nil and p.base_dir or v_p.base_dir
	end

	return p
end


-- create the actual corona display object
--
local function createImage( v_params )
	-- print( "createImage", v_params )
	if v_params.base_dir then
		return display.newImageRect( v_params.file, v_params.base_dir, v_params.width, 	v_params.height )
	else
		return display.newImageRect( v_params.file, v_params.width, v_params.height )
	end
end



--====================================================================--
--== Button Image View Class
--====================================================================--


local ImageView = newClass( BaseView, {name="Image View"} )

ImageView.TYPE = 'image'


--======================================================--
-- Start: Setup DMC Objects

function ImageView:__init__( params )
	-- print( "ImageView:__init__" )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Sanity Check ==--

	if self.is_class then return end

	assert( type(params.file)=='string', "expected string-type 'file' parameter" )

	--== Create Properties ==--

	self._view_params = createImageParams( self._view_name, params )

	--== Display Groups ==--
	--== Object References ==--
end

-- __createView__()
--
function ImageView:__createView__()
	-- print( "ImageView:__createView__" )
	self:superCall( '__createView__' )
	--==--

	local o   -- object

	--== create background

	o = createImage( self._view_params )
	o.anchorX, o.anchorY = 0.5, 0.5
	o.x, o.y = 0, 0

	self.view:insert( 1, o ) -- insert over background
	self._view = o
end


function ImageView:__undoCreateView__()
	-- print( "ImageView:__undoCreateView__" )
	local o

	o = self._view
	o:removeSelf()
	self._view = nil

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


--none



--====================================================================--
--== Event Handlers


-- none




return ImageView
