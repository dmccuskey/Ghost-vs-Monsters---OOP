--====================================================================--
-- widget_button/view_shape.lua
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
--== DMC Corona Widgets : Shape Button
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
--== DMC Widgets : Button Shape View
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'

--== Components

local BaseView = require( dmc_widget_func.find( 'widget_button.view_base' ) )



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass

--== these are the Corona shapes which can be a button view
local TYPE_RECT = 'rect'
local TYPE_ROUNDED_RECT = 'roundedRect'
local TYPE_CIRCLE = 'circle'
local TYPE_POLYGON = 'polygon'

local VALID_SHAPES = {
	TYPE_RECT,
	TYPE_ROUNDED_RECT,
	TYPE_CIRCLE,
	TYPE_POLYGON,
}


local LOCAL_DEBUG = true



--====================================================================--
--== Support Functions


-- ensure we have a shape-type we know about
--
-- @param name string name of shape type, one of types above
--
local function validateShapeType( name )
	if not Utils.propertyIn( VALID_SHAPES, name ) then
		error( "newButton: unknown shape type: " .. tostring( name ) )
	end
	return name
end


-- build parameters for this shape
-- get defaults and layer in specific values
--
local function createShapeParams( v_type, v_name, params )
	-- print( "createShapeParams", v_type, v_name, params )
	local p
	local v_p = params[ v_name ] -- specific view parameters

	if v_type == TYPE_RECT then
		p = {
			width=params.width,
			height=params.height,
			fill_color=params.fill_color,
			stroke_width=params.stroke_width,
			stroke_color=params.stroke_color
		}

	elseif v_type == TYPE_ROUNDED_RECT then
		p = {
			width=params.width,
			height=params.height,
			fill_color=params.fill_color,
			stroke_width=params.stroke_width,
			stroke_color=params.stroke_color,
			corner_radius=params.corner_radius
		}

	elseif v_type == TYPE_CIRCLE then
		p = {
			width=params.width,
			height=params.height,
			fill_color=params.fill_color,
			stroke_width=params.stroke_width,
			stroke_color=params.stroke_color
		}

	elseif v_type == TYPE_POLYGON then
		p = {
			width=params.width,
			height=params.height,
			fill_color=params.fill_color,
			stroke_width=params.stroke_width,
			stroke_color=params.stroke_color
		}

	else -- default view
		error( "newButton: unknown shape type: " .. tostring( v_type ) )

	end

	-- layer in view specific values
	if v_p then
		p.width = v_p.width == nil and p.width or v_p.width
		p.height = v_p.height == nil and p.height or v_p.height
		p.fill_color = v_p.fill_color == nil and p.fill_color or v_p.fill_color
		p.stroke_color = v_p.stroke_color == nil and p.stroke_color or v_p.stroke_color
		p.stroke_width = v_p.stroke_width == nil and p.stroke_width or v_p.stroke_width
		p.corner_radius = v_p.corner_radius == nil and p.corner_radius or v_p.corner_radius
	end

	return p
end


-- create the actual corona display object
--
local function createShape( v_type, v_params )
	-- print( "createShape", v_type, v_params )

	if v_type == TYPE_RECT then
		return display.newRect( 0, 0, v_params.width, v_params.height )

	elseif v_type == TYPE_ROUNDED_RECT then
		return display.newRoundedRect( 0, 0, v_params.width, v_params.height, v_params.corner_radius )

	elseif v_type == TYPE_CIRCLE then
		-- TODO
		return display.newCircle( 0, 0, v_params.width, v_params.height )

	elseif v_type == TYPE_POLYGON then
		-- TODO
		return display.newPolygon( 0, 0, v_params.width, v_params.height )

	else -- default view
		error( "newButton: unknown shape type: " .. tostring( name ) )

	end
end



--====================================================================--
--== Button Shape View Class
--====================================================================--


local ShapeView = newClass( BaseView, {name="Shape View"} )

ShapeView.TYPE = 'shape'


--======================================================--
-- Start: Setup DMC Objects

function ShapeView:__init__( params )
	-- print( "ShapeView:__init__" )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Sanity Check ==--

	if self.is_class then return end

	assert( type(params.shape)=='string', "expected string-type 'shape' parameter" )

	--== Create Properties ==--

	self._view_type = validateShapeType( params.shape )
	self._view_params = createShapeParams( self._view_type, self._view_name, params )

	--== Display Groups ==--
	--== Object References ==--
end


-- _createView()
--
function ShapeView:__createView__()
	-- print( "ShapeView:__createView__" )
	self:superCall( '__createView__' )
	--==--

	local v_params = self._view_params
	local o, tmp   -- object, temp

	--== create background

	o = createShape( self._view_type, v_params )
	o.x, o.y = 0, 0
	o.anchorX, o.anchorY = 0.5, 0.5
	tmp = v_params.fill_color
	if tmp and tmp.type=='gradient' then
		o:setFillColor( tmp )
	elseif tmp then
		o:setFillColor( unpack( tmp ) )
	end
	o.strokeWidth = v_params.stroke_width
	tmp = v_params.stroke_color
	if tmp and tmp.type=='gradient' then
		o:setStrokeColor( tmp )
	elseif tmp then
		o:setStrokeColor( unpack( tmp ) )
	end

	self.view:insert( 1, o ) -- insert over background
	self._view = o

end

function ShapeView:__undoCreateView__()
	-- print( "ShapeView:__undoCreateView__" )
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


-- none



--====================================================================--
--== Event Handlers


-- none




return ShapeView
