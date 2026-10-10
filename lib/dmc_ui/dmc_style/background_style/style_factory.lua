--====================================================================--
-- dmc_widget/widget_background/style_factory.lua
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


local BaseStyle = require( ui_find( 'core.style' ) )
local Image = require( ui_find( 'dmc_style.background_style.image_style' ) )
local NineSlice = require( ui_find( 'dmc_style.background_style.nine_slice_style' ) )
local Rectangle = require( ui_find( 'dmc_style.background_style.rectangle_style' ) )
local Rounded = require( ui_find( 'dmc_style.background_style.rounded_style' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format

--== To be set in initialize()
local Style = nil -- set later


--====================================================================--
--== Support Functions


local function initializeFactory( manager, params )
	-- print( "StyleFactory.initializeFactory" )
	Style = manager

	Image.initialize( Style, params )
	NineSlice.initialize( Style, params )
	Rectangle.initialize( Style, params )
	Rounded.initialize( Style, params )
end


local function getStyleNames()
	-- print( "StyleFactory.getStyleNames" )
	return {
		Image.TYPE,
		NineSlice.TYPE,
		Rectangle.TYPE,
		Rounded.TYPE
	}
end

local function getStyleClasses()
	-- print( "StyleFactory.getStyleClasses" )
	return {
		Image,
		NineSlice,
		Rectangle,
		Rounded
	}
end


local function getStyleClass( style_type )
	-- print( "StyleFactory.getStyleClass", style_type )
	if style_type==Image.TYPE then
		return Image
	elseif style_type==NineSlice.TYPE then
		return NineSlice
	elseif style_type==Rectangle.TYPE then
		return Rectangle
	elseif style_type==Rounded.TYPE then
		return Rounded
	else
		error( sfmt( "StyleFactory: Unknown style type '%s'", tostring( style_type )))
	end
end


local function createStyle( style_type, params )
	-- print( "StyleFactory.createStyle", style_type )
	local StyleClass = getStyleClass( style_type )
	return StyleClass:new( params )
end



--====================================================================--
--== Background Style Factory Facade
--====================================================================--


return {

	initialize=initializeFactory,

	Style={
		Base=BaseStyle,
		Image=Image,
		NineSlice=NineSlice,
		Rectangle=Rectangle,
		Rounded=Rounded,
	},

	Image=Image,
	NineSlice=NineSlice,
	Rectangle=Rectangle,
	Rounded=Rounded,

	create=createStyle,
	getClass=getStyleClass,

	getStyleNames=getStyleNames,
	getStyleClasses=getStyleClasses
}
