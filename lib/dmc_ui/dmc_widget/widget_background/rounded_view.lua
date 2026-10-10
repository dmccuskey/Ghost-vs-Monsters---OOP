--====================================================================--
-- dmc_widget/widget_background/rounded_view.lua
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
--== DMC Corona Widgets : Rounded Background View
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
--== DMC Widgets : newRoundedBackground
--====================================================================--



--====================================================================--
--== Imports


local uiConst = require( ui_find( 'ui_constants' ) )

local Objects = require 'dmc_objects'

local WidgetBase = require( ui_find( 'core.widget' ) )



--====================================================================--
--== Setup, Constants


local newRoundedRect = display.newRoundedRect
local unpack = unpack

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== Rounded Background View Class
--====================================================================--


--- Rounded Background View Class.
--
-- @classmod Widget.Background.Rounded
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newRoundedBackground()

local RoundedView = newClass( WidgetBase, {name="Rounded Background View"} )

--- Class Constants.
-- @section

--== Class Constants

RoundedView.TYPE = uiConst.ROUNDED

--== Theme Constants

RoundedView.STYLE_CLASS = nil -- added later
RoundedView.STYLE_TYPE = uiConst.ROUNDED

-- TODO: hook up later
-- RoundedView.DEFAULT = 'default'

-- RoundedView.THEME_STATES = {
-- 	RoundedView.DEFAULT,
-- }


--======================================================--
-- Start: Setup DMC Objects

--== Init

function RoundedView:__init__( params )
	-- print( "RoundedView:__init__", params )
	params = params or {}

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties stored in Style

	self._cornerRadius_dirty=true
	self._fillColor_dirty=true
	self._strokeColor_dirty=true
	self._strokeWidth_dirty=true

	--== Object References ==--

	self._rndBg = nil -- our rounded rect object

end

--[[
function RoundedView:__undoInit__()
	-- print( "RoundedView:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]

--== createView

function RoundedView:__createView__()
	-- print( "RoundedView:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o = newRoundedRect( 0,0,0,0,1 )
	self._dgBg:insert( o )
	self._rndBg = o
end

function RoundedView:__undoCreateView__()
	-- print( "RoundedView:__undoCreateView__" )
	self._rndBg:removeSelf()
	self._rndBg=nil
	--==--
	self:superCall( '__undoCreateView__' )
end

--== initComplete

--[[
function RoundedView:__initComplete__()
	-- print( "RoundedView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
end

function RoundedView:__undoInitComplete__()
	--print( "RoundedView:__undoInitComplete__" )
	--==--
	self:superCall( '__undoInitComplete__' )
end
--]]

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function RoundedView.initialize( manager )
	-- print( "RoundedView.initialize" )
	dUI = manager

	local Style = dUI.Style
	local StyleFactory = Style.BackgroundFactory
	RoundedView.STYLE_CLASS = StyleFactory.Rounded

	Style.registerWidget( RoundedView )
end



--====================================================================--
--== Public Methods


function RoundedView:localToContent( ... )
	return self._rndBg:localToContent(...)
end



--====================================================================--
--== Private Methods


function RoundedView:__commitProperties__()
	-- print( 'RoundedView:__commitProperties__' )
	local style = self.curr_style
	local view = self.view
	local bg = self._rndBg

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
		bg.width=style.width
		self._width_dirty=false
	end
	if self._height_dirty then
		bg.height=style.height
		self._height_dirty=false
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		bg.anchorX = style.anchorX
		self._anchorX_dirty=false
	end
	if self._anchorY_dirty then
		bg.anchorY = style.anchorY
		self._anchorY_dirty=false
	end

	-- fills/colors

	if self._cornerRadius_dirty then
		bg.path.radius = style.cornerRadius
		self._cornerRadius_dirty=false
	end
	if self._fillColor_dirty then
		if style.debugOn==true then
			bg:setFillColor( 1,0,0,0.5 )
		else
			local color = style.fillColor
			if color and color.type then
				bg:setFillColor( color )
			else
				bg:setFillColor( unpack( color ) )
			end
		end
		self._fillColor_dirty=false
	end
	if self._strokeColor_dirty then
		bg:setStrokeColor( unpack( style.strokeColor ))
		self._strokeColor_dirty=false
	end
	if self._strokeWidth_dirty then
		bg.strokeWidth = style.strokeWidth
		self._strokeWidth_dirty=false
	end

end



--====================================================================--
--== Event Handlers


function RoundedView:stylePropertyChangeHandler( event )
	-- print( "RoundedView:stylePropertyChangeHandler", event )
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

		self._cornerRadius_dirty=true
		self._fillColor_dirty=true
		self._strokeColor_dirty=true
		self._strokeWidth_dirty=true

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

		elseif property=='cornerRadius' then
			self._cornerRadius_dirty=true
		elseif property=='fillColor' then
			self._fillColor_dirty=true
		elseif property=='strokeColor' then
			self._strokeColor_dirty=true
		elseif property=='strokeWidth' then
			self._strokeWidth_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return RoundedView
