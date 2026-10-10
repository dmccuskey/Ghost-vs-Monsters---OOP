--====================================================================--
-- dmc_ui/core/style_help.lua
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
--== DMC Corona UI : Widget Helpers
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Kolor = require 'dmc_kolor'



--====================================================================--
--== Widget Help Table
--====================================================================--


local WidgetHelp = {
	['__getters']={},
	['__setters']={}
}


--== .align

--- [**style**] set/get Style value for Widget text alignment.
-- values are 'left', 'center', 'right'
--
-- @within Properties
-- @function .align
-- @usage style.align = 'center'
-- @usage print( style.align )

-- CLASS.__getters.align = WidgetHelp.__getters.align
-- CLASS.__setters.align = WidgetHelp.__setters.align

function WidgetHelp.__getters:align()
	return self.curr_style.align
end
function WidgetHelp.__setters:align( value )
	-- print( 'WidgetHelp.__setters:align', value )
	self.curr_style.align = value
end


--== .delegate

--- set/get delegate for item.
--
-- @within Properties
-- @function .delegate
-- @usage widget.delegate = <delegate object>
-- @usage print( widget.delegate )

-- CLASS.__getters.delegate = WidgetHelp.__getters.delegate
-- CLASS.__setters.delegate = WidgetHelp.__setters.delegate

function WidgetHelp.__getters:delegate()
	-- print( "WidgetHelp.__getters:delegate" )
	return self._delegate
end
function WidgetHelp.__setters:delegate( value )
	-- print( "WidgetHelp.__setters:delegate", value )
	self._delegate = value
end


--== .fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage style.fillColor = '#ff0000'
-- @usage print( style.fillColor )

-- CLASS.__getters.fillColor = WidgetHelp.__getters.fillColor
-- CLASS.__setters.fillColor = WidgetHelp.__setters.fillColor

function WidgetHelp.__getters:fillColor()
	-- print( "WidgetHelp.__getters:fillColor", self, self._fillColor )
	return self.curr_style.fillColor
end
function WidgetHelp.__setters:fillColor( value )
	-- print( "WidgetHelp.__setters:fillColor", self._fillColor, value, self._isClearing )
	self.curr_style.fillColor = value
end


--== .font

--- [**style**] set/get font.
-- can either be Corona font (eg, native.systemFont) or one installed in system (eg, 'Helvetica-Grande')
--
-- @within Properties
-- @function .font
-- @usage widget.font = native.systemFont
-- @usage print( widget.font )

-- CLASS.__getters.font = WidgetHelp.__getters.font
-- CLASS.__setters.font = WidgetHelp.__setters.font

function WidgetHelp.__getters:font()
	return self.curr_style.font
end
function WidgetHelp.__setters:font( value )
	-- print( 'WidgetHelp.__setters:font', value )
	self.curr_style.font = value
end


--== .fontSize

--- [**style**] set/get fontSize.
-- set the font size of the text.
--
-- @within Properties
-- @function .fontSize
-- @usage widget.fontSize = 18
-- @usage print( widget.fontSize )

-- CLASS.__getters.fontSize = WidgetHelp.__getters.fontSize
-- CLASS.__setters.fontSize = WidgetHelp.__setters.fontSize

function WidgetHelp.__getters:fontSize()
	return self.curr_style.fontSize
end
function WidgetHelp.__setters:fontSize( value )
	-- print( 'WidgetHelp.__setters:fontSize', value )
	self.curr_style.fontSize = value
end


--== .marginX

--- [**style**] set/get marginX.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginX
-- @usage widget.marginX = 18
-- @usage print( widget.marginX )

-- CLASS.__getters.marginX = WidgetHelp.__getters.marginX
-- CLASS.__setters.marginX = WidgetHelp.__setters.marginX

function WidgetHelp.__getters:marginX()
	return self.curr_style.marginX
end
function WidgetHelp.__setters:marginX( value )
	-- print( 'WidgetHelp.__setters:marginX', value )
	self.curr_style.marginX = value
end


--== .marginY

--- [**style**] set/get marginY.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginX
-- @usage widget.marginX = 18
-- @usage print( widget.marginX )

-- CLASS.__getters.marginY = WidgetHelp.__getters.marginY
-- CLASS.__setters.marginY = WidgetHelp.__setters.marginY

function WidgetHelp.__getters:marginY()
	return self.curr_style.marginY
end
function WidgetHelp.__setters:marginY( value )
	-- print( 'WidgetHelp.__setters:marginY', value )
	self.curr_style.marginY = value
end


--== .strokeWidth

--- [**style**] set/get strokeWidth.
-- set stroke width for the simple background.
--
-- @within Properties
-- @function .strokeWidth
-- @usage widget.strokeWidth = 18
-- @usage print( widget.strokeWidth )

-- CLASS.__getters.strokeWidth = WidgetHelp.__getters.strokeWidth
-- CLASS.__setters.strokeWidth = WidgetHelp.__setters.strokeWidth

function WidgetHelp.__getters:strokeWidth()
	return self.curr_style.strokeWidth
end
function WidgetHelp.__setters:strokeWidth( value )
	-- print( 'WidgetHelp.__setters:strokeWidth', value )
	self.curr_style.strokeWidth = value
end


--== .textColor

--- [**style**] set/get textColor.
-- set the font size of the text.
--
-- @within Properties
-- @function .textColor
-- @usage widget.textColor = 18
-- @usage print( widget.textColor )

-- CLASS.__getters.textColor = WidgetHelp.__getters.textColor
-- CLASS.__setters.textColor = WidgetHelp.__setters.textColor

function WidgetHelp.__getters:textColor()
	return self.curr_style.textColor
end
function WidgetHelp.__setters:textColor( value )
	print( 'WidgetHelp.__setters:textColor', value )
	self.curr_style.textColor = value
end



--== :setFillColor

--- set the fill color of the background.
--
-- @within Methods
-- @function :setFillColor
-- @usage
-- widget:setFillColor( grey )
-- widget:setFillColor( grey, a )
-- widget:setFillColor( r, g, b, a )
-- widget:setFillColor( gradient )

-- CLASS.setFillColor = WidgetHelp.setFillColor
-- CLASS.setFillColor = WidgetHelp.setFillColor

function WidgetHelp:setFillColor( ... )
	-- print( 'WidgetHelp:setFillColor' )
	self.curr_style.fillColor = {...}
end


--== :setStrokeColor

--- set stroke color of the background.
--
-- @within Methods
-- @function :setStrokeColor
-- @usage
-- widget:setStrokeColor( grey )
-- widget:setStrokeColor( grey, a )
-- widget:setStrokeColor( r, g, b, a )
-- widget:setStrokeColor( gradient )

-- CLASS.setStrokeColor = WidgetHelp.setStrokeColor
-- CLASS.setStrokeColor = WidgetHelp.setStrokeColor

function WidgetHelp:setStrokeColor( ... )
	-- print( 'WidgetHelp:setStrokeColor' )
	self.curr_style.strokeColor = {...}
end


--== :setTextColor

--- set color of text.
--
-- @within Methods
-- @function :setTextColor
-- @usage
-- widget:setTextColor( grey )
-- widget:setTextColor( grey, a )
-- widget:setTextColor( r, g, b, a )
-- widget:setTextColor( gradient )

-- CLASS.setTextColor = WidgetHelp.setTextColor
-- CLASS.setTextColor = WidgetHelp.setTextColor

function WidgetHelp:setTextColor( ... )
	-- print( 'WidgetHelp:setTextColor' )
	self.curr_style.textColor = {...}
end




return WidgetHelp
