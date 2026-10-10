--====================================================================--
-- dmc_ui/dmc_widget/widget_text.lua
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
--== DMC Corona UI : Text Widget
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find



--====================================================================--
--== DMC UI : newText
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )



--====================================================================--
--== Setup, Constants


local mfloor = math.floor
local newText = display.newText
local sbyte = string.byte
local ssub = string.sub

--== To be set in initialize()
local dUI = nil
local FontMgr = nil



--====================================================================--
--== Support Functions


local function testTextLength( text, params )
	-- print( "Text:testTextLength", text, params.width )
	local w = params.width
	local f = params.font
	local fs = params.fontSize
	local fsm = params.fontSizeMinimum
	local _ssub = ssub
	local _newText = newText

	--== check size with defaults

	local o = _newText{
		text=text,
		font=f,
		fontSize=fs
	}
	local tw = o.width
	o:removeSelf()
	if tw < w then return text, fs end

	--== check for font minimum

	if fsm~=0 then
		local cfs = fs-1 -- current font size
		while cfs>=fsm do
			local o = _newText{
				text=text,
				font=f,
				fontSize=cfs
			}
			local tw = o.width
			o:removeSelf()
			if tw > w then
				cfs = cfs-1
			else
				break
			end
		end
		if cfs<fsm then
			-- text too big, shorten with '...'
			fs=fsm
		else
			return text, cfs
		end
	end

	--== check for ellipses

	-- the longest start of the text that fits with '...': a binary search
	-- (the whole text doesn't fit), cut at the end of a whole UTF-8 character
	local function fits( n )
		local o = _newText{
			text=_ssub( text, 1, n )..'...',
			font=f,
			fontSize=fs
		}
		local tw = o.width
		o:removeSelf()
		return tw <= w
	end
	local lo, hi = 0, #text
	while hi-lo > 1 do
		local mid = mfloor( (lo+hi)/2 )
		if fits( mid ) then lo = mid else hi = mid end
	end
	-- back off while the next byte continues a character (10xxxxxx)
	local b = sbyte( text, lo+1 )
	while lo > 0 and b and b >= 0x80 and b < 0xC0 do
		lo = lo-1 ; b = sbyte( text, lo+1 )
	end
	return _ssub( text, 1, lo )..'...', fs
end



--====================================================================--
--== Text Widget Class
--====================================================================--


--- Text Widget Module.
-- displays text content. this widget wraps the a Corona OpenGL Text component to provide its core functionality.
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- **Style Object:** <br>
-- * @{Style.Text}
--
-- @classmod Widget.Text
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newText()

local Text = newClass( WidgetBase, { name="Text Widget" } )

--- Class Constants.
-- @section

--== Class Constants

--- Constant for 'left'
Text.LEFT = 'left'

--- Constant for 'center'
Text.CENTER = 'center'

--- Constant for 'right'
Text.RIGHT = 'right'


--== Style/Theme Constants

Text.STYLE_CLASS = nil -- added later
Text.STYLE_TYPE = uiConst.TEXT

-- TODO: hook up later
-- Text.DEFAULT = 'default'

-- Text.THEME_STATES = {
-- 	Text.DEFAULT,
-- }

--== Event Constants

Text.EVENT = 'text-widget-event'

Text.DIMENSION_CHANGED = 'dimension-changed-event'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function Text:__init__( params )
	-- print( "Text:__init__", params )
	params = params or {}
	if params.text==nil then params.text="" end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties in this class

	self._text = params.text
	self._text_dirty=true

	-- properties from style

	-- virtual
	self._displayWidth_dirty=true
	self._displayHeight_dirty=true
	self._rectBgWidth_dirty=true
	self._rectBgHeight_dirty=true

	self._align_dirty=true
	self._fillColor_dirty = true
	self._font_dirty=true
	self._fontSize_dirty=true
	self._fontSizeMinimum_dirty=true
	self._marginX_dirty=true
	self._marginY_dirty=true
	self._strokeColor_dirty=true
	self._strokeWidth_dirty=true

	self._textColor_dirty=true
	self._textObject_dirty=true

	-- virtual
	self._textX_dirty=true
	self._textY_dirty=true

	--== Object References ==--

	self._txtText = nil -- our text object
	self._rectBg = nil -- our background object

end

--[[
function Text:__undoInit__()
	-- print( "Text:__undoInit__" )
	--==--
		self:superCall( '__undoInit__' )
end
--]]

--== createView

function Text:__createView__()
	-- print( "Text:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o = display.newRect( 0,0,0,0 )
	o.anchorX, o.anchorY = 0.5, 0.5
	self:insert( o )
	self._rectBg = o
end

function Text:__undoCreateView__()
	-- print( "Text:__undoCreateView__" )
	self._rectBg:removeSelf()
	self._rectBg=nil
	--==--
	self:superCall( '__undoCreateView__' )
end

--== initComplete

--[[
function Text:__initComplete__()
	-- print( "Text:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
end
--]]

function Text:__undoInitComplete__()
	--print( "Text:__undoInitComplete__" )
	self:_removeText()
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function Text.initialize( manager )
	-- print( "Text.initialize" )
	dUI = manager
	local Widget = nil

	FontMgr = dUI.FontMgr

	local Style = dUI.Style
	Text.STYLE_CLASS = Style.Text

	Style.registerWidget( Text )
end



--====================================================================--
--== Public Methods


--== .align

--- [**style**] set/get align.
-- values are 'left', 'center', 'right'
--
-- @within Properties
-- @function .align
-- @usage widget.align = 'center'
-- @usage print( widget.align )

Text.__getters.align = WidgetHelp.__getters.align
Text.__setters.align = WidgetHelp.__setters.align

--== .fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage style.fillColor = '#ff0000'
-- @usage print( style.fillColor )

Text.__getters.fillColor = WidgetHelp.__getters.fillColor
Text.__setters.fillColor = WidgetHelp.__setters.fillColor

--== .font

--- [**style**] set/get font.
-- can either be Corona font (eg, native.systemFont) or one installed in system (eg, 'Helvetica-Grande')
--
-- @within Properties
-- @function .font
-- @usage widget.font = native.systemFont
-- @usage print( widget.font )

Text.__getters.font = WidgetHelp.__getters.font
Text.__setters.font = WidgetHelp.__setters.font

--== .fontSize

--- [**style**] set/get fontSize.
-- set the font size of the text.
--
-- @within Properties
-- @function .fontSize
-- @usage widget.fontSize = 18
-- @usage print( widget.fontSize )

Text.__getters.fontSize = WidgetHelp.__getters.fontSize
Text.__setters.fontSize = WidgetHelp.__setters.fontSize

--== .marginX

--- [**style**] set/get marginX.
-- set the margin inset of the widget. this value is *subtracted* from the widget width.
--
-- @within Properties
-- @function .marginX
-- @usage widget.marginX = 18
-- @usage print( widget.marginX )

Text.__getters.marginX = WidgetHelp.__getters.marginX
Text.__setters.marginX = WidgetHelp.__setters.marginX

--== .strokeWidth

--- [**style**] set/get strokeWidth.
-- set stroke width for the simple background.
--
-- @within Properties
-- @function .strokeWidth
-- @usage widget.strokeWidth = 18
-- @usage print( widget.strokeWidth )

Text.__getters.strokeWidth = WidgetHelp.__getters.strokeWidth
Text.__setters.strokeWidth = WidgetHelp.__setters.strokeWidth

--== .textColor

--- [**style**] set/get textColor.
-- set the font size of the text.
--
-- @within Properties
-- @function .textColor
-- @usage widget.textColor = 18
-- @usage print( widget.textColor )

Text.__getters.textColor = WidgetHelp.__getters.textColor
Text.__setters.textColor = WidgetHelp.__setters.textColor


--[[
we use custom getters for width/height
without width/height, we just use dimensions
from text object after creation
--]]

--== .width (custom)

--- [**style**] set/get width.
-- Note: this property changes both the width of the DMC Text Widget and the encapsulated Corona Text widget. If the style is unset, then the width value is the width of the encapsulated Corona Text widget. If the style value is set, then then the width for both will change to that value.
--
-- @within Properties
-- @function .width
-- @usage widget.width = 5
-- @usage print( widget.width )

function Text.__getters:width()
	-- print( 'Text.__getters:width' )
	local style = self.curr_style
	local w = style.width
	if w==0 then
		self:_commitNow()
		local t = self._txtText
		if t then w=t.width+style.marginX*2 end
	end
	return w
end
function Text.__setters:width( value )
	-- print( 'Text.__setters:width', value )
	self.curr_style.width = value
end

--== .height (custom)

--- [**style**] set/get height.
-- Note: this property *doesn't* change the height of the actual *Corona Text widget*, that remains constant. If the style is unset, then the height value is the height of the encapsulated Corona Text widget. If the style value is set, then then the height is that value, even if the height of the Corona Text widget is different. (If the height of the Corona Text widget is set then it becomes a multi-line text widget.)
--
-- @within Properties
-- @function .height
-- @usage widget.height = 5
-- @usage print( widget.height )

function Text.__getters:height()
	-- print( 'Text.__getters:height' )
	local style = self.curr_style
	local h = style.height
	if h==0 then
		h = self:getTextHeight()+style.marginY*2
	end
	return h
end
function Text.__setters:height( value )
	-- print( 'Text.__setters:height', value )
	self.curr_style.height = value
end

--== .text

--- set/get widget text.
--
-- @within Properties
-- @function .text
-- @usage widget.text = 5
-- @usage print( widget.text )

function Text.__getters:text()
	return self._text
end
function Text.__setters:text( value )
	-- print( 'Text.__setters:text', value )
	assert( type(value)=='string' )
	--==--
	if self._text == value then return end
	self._text = value
	self._text_dirty=true
	self:__invalidateProperties__()
end



--- get height of Corona Text object.
-- return the height of the encapsulated Corona text object, not height of the DMC Text Widget.
--
-- @within Methods
-- @function :getTextHeight
-- @treturn number height of Corona Text object
-- @usage print( widget:getTextHeight() )

function Text:getTextHeight()
	-- print( "Text:getTextHeight", self._txtText )
	self:_commitNow()
	local val = 0
	local o = self._txtText
	if o then val = o.height end
	return val
end



--== .setFillColor

--- set the fill color of the simple background.
--
-- @within Methods
-- @function :setFillColor
-- @usage
-- widget:setFillColor( grey )
-- widget:setFillColor( grey, a )
-- widget:setFillColor( r, g, b, a )
-- widget:setFillColor( gradient )

Text.setFillColor = WidgetHelp.setFillColor

--== .setStrokeColor

--- set stroke color of the simple background.
--
-- @within Methods
-- @function :setStrokeColor
-- @usage
-- widget:setStrokeColor( grey )
-- widget:setStrokeColor( grey, a )
-- widget:setStrokeColor( r, g, b, a )
-- widget:setStrokeColor( gradient )

Text.setStrokeColor = WidgetHelp.setStrokeColor

--== .setTextColor

--- set color of text.
--
-- @within Methods
-- @function :setTextColor
-- @usage
-- widget:setTextColor( grey )
-- widget:setTextColor( grey, a )
-- widget:setTextColor( r, g, b, a )
-- widget:setTextColor( gradient )

Text.setTextColor = WidgetHelp.setTextColor



--====================================================================--
--== Private Methods


-- a size that comes from the text needs the text object up to date: commit
-- pending changes now rather than next frame (a no-op during a commit)
function Text:_commitNow()
	if self.__commit_dirty then self:__validate__() end
end

function Text:_removeText()
	-- print( "Text:_removeText" )
	local o = self._txtText
	if not o then return end
	o:removeSelf()
	self._txtText = nil
end

function Text:_createText()
	-- print( "Text:_createText" )
	local style = self.curr_style
	local o -- object

	self:_removeText()

	local w, h = style.width, style.height
	local font, fontSize = style.font, style.fontSize
	local text = self._text
	local tw
	if w==0 then
		tw=nil
	else
		tw = w - style.marginX*2
		text, fontSize = testTextLength( text, {
			width=tw, font=font,
			fontSize=fontSize,
			fontSizeMinimum=style.fontSizeMinimum
		})
	end
	o = newText{
		x=0, y=0,

		width=tw,
		-- don't use height, turns into multi-line
		height=nil,

		text=text,
		align=style.align,
		font=font,
		fontSize=fontSize,
	}

	self:insert( o )
	self._txtText = o

	--== Reset properties

	-- the new object: place it, and size the background to it
	self._rectBgWidth_dirty=true
	self._rectBgHeight_dirty=true
	self._textX_dirty=true
	self._textY_dirty=true
	if w==0 or h==0 then
		self._textDimension_dirty=true
	end

	self._text_dirty=false
	self._textColor_dirty=true
end


function Text:__commitProperties__()
	-- print( 'Text:__commitProperties__' )
	local style = self.curr_style
	-- local metric = FontMgr:getFontMetric( style.font, style.fontSize )
	-- metric={offsetX=0,offsetY=0}

	if self._width_dirty then
		self._width_dirty=false

		self._anchorX_dirty=true
		self._displayWidth_dirty=true
		self._rectBgWidth_dirty=true
		self._textObject_dirty=true
	end
	if self._height_dirty then
		self._height_dirty=false

		self._anchorY_dirty=true
		self._displayHeight_dirty=true
		self._rectBgHeight_dirty=true
	end

	-- create new text if necessary
	if self._align_dirty or self._font_dirty or self._fontSize_dirty
		or self._fontSizeMinimum_dirty or self._text_dirty or self._textObject_dirty
	then
		self:_createText()
		self._align_dirty=false
		self._font_dirty=false
		self._fontSize_dirty=false
		self._fontSizeMinimum_dirty=false
		self._textObject_dirty=false
	end

	local view = self.view
	local bg = self._rectBg
	local txt = self._txtText

	--== position sensitive

	if self._marginX_dirty then
		self._marginX_dirty=false

		self._displayWidth_dirty=true
		self._rectBgWidth_dirty=true
		self._textX_dirty=true
	end
	if self._marginY_dirty then
		--== Reminder, we don't set text height ==--
		self._marginY_dirty=false

		self._displayHeight_dirty=true
		self._rectBgHeight_dirty=true
		self._textY_dirty=true
	end

	-- bg width/height

	if self._rectBgWidth_dirty then
		bg.width = self.width -- use getter
		self._rectBgWidth_dirty=false
	end
	if self._rectBgHeight_dirty then
		bg.height = self.height -- use getter
		self._rectBgHeight_dirty=false
	end

	if self._displayWidth_dirty then
		self._displayWidth_dirty=false
	end
	if self._displayHeight_dirty then
		--== !! DO NOT SET HEIGHT OF TEXT !! ==--
		--[[
		-- -- txt.height = self.height
		--]]
		self._displayHeight_dirty=false
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		bg.anchorX = style.anchorX
		self._anchorX_dirty=false

		self._x_dirty=true
		self._textX_dirty=true
	end
	if self._anchorY_dirty then
		bg.anchorY = style.anchorY
		self._anchorY_dirty=false

		self._y_dirty=true
		self._textY_dirty=true
	end

	-- x/y

	if self._x_dirty then
		view.x = self._x
		self._x_dirty = false

		self._textX_dirty=true
	end
	if self._y_dirty then
		view.y = self._y
		self._y_dirty = false

		self._textY_dirty=true
	end

	-- text align x/y

	if self._textX_dirty then
		local align = style.align
		local width = self.width -- use getter, it's smart
		local offset
		if align == self.LEFT then
			txt.anchorX = 0
			offset = -width*(style.anchorX)+style.marginX
			txt.x=offset
		elseif align == self.RIGHT then
			txt.anchorX = 1
			offset = width*(1-style.anchorX)-style.marginX
			txt.x=offset
		else
			txt.anchorX = 0.5
			offset = width*(0.5-style.anchorX)
			txt.x=offset
		end
		self._textX_dirty = false
	end

	if self._textY_dirty then
		local height = self.height -- use getter
		local offset
		txt.anchorY = 0.5
		offset = height/2-height*(style.anchorY)
		txt.y=offset
		self._textY_dirty=false
	end


	--== non-position sensitive

	-- textColor/fillColor

	if self._fillColor_dirty or self._debugOn_dirty then
		if style.debugOn==true then
			bg:setFillColor( 1,0,0,0.2 )
		else
			bg:setFillColor( unpack( style.fillColor ))
		end
		self._fillColor_dirty=false
		self._debugOn_dirty=false
	end
	if self._strokeColor_dirty then
		bg:setStrokeColor( unpack( style.strokeColor ))
		self._strokeColor_dirty=false
	end
	if self._strokeWidth_dirty then
		bg.strokeWidth = style.strokeWidth
		self._strokeWidth_dirty=false
	end
	if self._textColor_dirty then
		txt:setTextColor( unpack( style.textColor ) )
		self._textColor_dirty=false
	end

	if self._textDimension_dirty then
		self:dispatchEvent( self.DIMENSION_CHANGED, {width=self.width,height=self.height}, {merge=true} )
		self._textDimension_dirty=false
	end

end



--====================================================================--
--== Event Handlers


function Text:stylePropertyChangeHandler( event )
	-- print( "Text:stylePropertyChangeHandler", event.type, event.property )
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

		self._align_dirty=true
		self._fillColor_dirty = true
		self._font_dirty=true
		self._fontSize_dirty=true
		self._fontSizeMinimum_dirty=true
		self._marginX_dirty=true
		self._marginY_dirty=true
		self._strokeColor_dirty=true
		self._strokeWidth_dirty=true

		self._text_dirty=true
		self._textColor_dirty=true

		property = etype

	else
		if property=='debugOn' then
			self._debugOn_dirty=true
		elseif property=='width' then
			self._width_dirty=true
		elseif property=='height' then
			self._height_dirty=true
		elseif property=='anchorX' then
			self._anchorX_dirty=true
		elseif property=='anchorY' then
			self._anchorY_dirty=true

		elseif property=='align' then
			self._align_dirty=true
		elseif property=='fillColor' then
			self._fillColor_dirty=true
		elseif property=='font' then
			self._font_dirty=true
		elseif property=='fontSize' then
			self._fontSize_dirty=true
		elseif property=='fontSizeMinimum' then
			self._fontSizeMinimum_dirty=true
		elseif property=='marginX' then
			self._marginX_dirty=true
		elseif property=='marginY' then
			self._marginY_dirty=true
		elseif property=='strokeColor' then
			self._strokeColor_dirty=true
		elseif property=='strokeWidth' then
			self._strokeWidth_dirty=true
		elseif property=='text' then
			self._text_dirty=true
		elseif property=='textColor' then
			self._textColor_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return Text
