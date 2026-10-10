--====================================================================--
-- dmc_widget/widget_background/view_factory.lua
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
--== DMC Corona Widgets : Widget Background-View Factory
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
--== DMC Widgets : newBackground
--====================================================================--


--====================================================================--
--== Imports


local Image = require( ui_find( 'dmc_widget.widget_background.image_view' ) )
local NineSlice = require( ui_find( 'dmc_widget.widget_background.nine_slice_view' ) )
local Rectangle = require( ui_find( 'dmc_widget.widget_background.rectangle_view' ) )
local Rounded = require( ui_find( 'dmc_widget.widget_background.rounded_view' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format

--== To be set in initialize()
local Widgets = nil



--====================================================================--
--== Support Functions


local function initializeFactory( manager )
	-- print( "ViewFactory.initializeFactory" )
	Widgets = manager

	Image.initialize( manager )
	NineSlice.initialize( manager )
	Rectangle.initialize( manager )
	Rounded.initialize( manager )
end


local function createView( style_type, params )
	-- print( "ViewFactory.createView", style_type )
	if style_type==Image.TYPE then
		return Image:new( params )
	elseif style_type==NineSlice.TYPE then
		return NineSlice:new( params )
	elseif style_type==Rectangle.TYPE then
		return Rectangle:new( params )
	elseif style_type==Rounded.TYPE then
		return Rounded:new( params )
	else
		error( sfmt( "ViewFactory: Unknown style type '%s'", tostring( style_type )))
	end
end


local function getViewClass( style_type )
	-- print( "ViewFactory.getViewClass", style_type )
	if style_type==Image.TYPE then
		return Image
	elseif style_type==NineSlice.TYPE then
		return NineSlice
	elseif style_type==Rectangle.TYPE then
		return Rectangle
	elseif style_type==Rounded.TYPE then
		return Rounded
	else
		error( sfmt( "ViewFactory: Unknown style type '%s'", tostring( style_type )))
	end
end



--====================================================================--
--== Background View Factory Facade
--====================================================================--



return {

	initialize = initializeFactory,

	Image = Image,
	NineSlice = NineSlice,
	Rectangle = Rectangle,
	Rounded = Rounded,

	create = createView,
	getClass = getViewClass
}
