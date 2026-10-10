--====================================================================--
-- dmc_ui/dmc_widget/widget_pageindicator.lua
--
-- Documentation: https://github.com/dmccuskey/DMC-Corona-UI
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2026 David McCuskey

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
--== DMC Corona UI : PageIndicator Widget
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
--== DMC UI : newPageIndicator
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass

local newCircle = display.newCircle
local newRect = display.newRect
local mfloor = math.floor
local mmax = math.max
local mmin = math.min
local type = type
local unpack = unpack

-- a touch on the widget stays with it. a tap does too: Solar2D sends
-- 'tap' apart from 'touch', and it would reach what lies behind
local function touchBlock_handler( event )
	return true
end

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== PageIndicator Widget Class
--====================================================================--


--- PageIndicator Widget.
-- a row of dots, one for each page, with the dot of the current page
-- in another color. a tap left or right of that dot moves one page
-- and tells the delegate. it knows nothing of what shows the pages
-- (eg, a SlideView): the app ties the two together.
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- **Style Object:** <br>
-- * @{Style.PageIndicator}
--
-- @classmod Widget.PageIndicator
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newPageIndicator{ numberOfPages=5 }

local PageIndicator = newClass( WidgetBase, {name="PageIndicator Widget"} )

--- Class Constants.
-- @section

--== Style/Theme Constants

PageIndicator.STYLE_CLASS = nil -- added later
PageIndicator.STYLE_TYPE = uiConst.PAGEINDICATOR

--== Event Constants

--- PageIndicator event constant.
-- the name of the events given to the delegate
--
-- @usage
-- if event.name==widget.EVENT then ... end

PageIndicator.EVENT = 'pageindicator-widget-event'

--- the type of the event given to `didChangePage`.
PageIndicator.PAGE_CHANGED = 'page-changed'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function PageIndicator:__init__( params )
	-- print( "PageIndicator:__init__", params )
	params = params or {}
	if params.numberOfPages==nil then params.numberOfPages=0 end
	if params.currentPage==nil then params.currentPage=1 end
	if params.hidesForSinglePage==nil then params.hidesForSinglePage=false end

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._pi_tmp_params = params -- tmp

	--== Create Properties ==--

	-- properties stored in Class

	self._numberOfPages = 0
	self._currentPage = 1
	self._hidesForSinglePage = false

	-- "Virtual" properties

	self._dots_dirty=true -- their number or size
	self._layout_dirty=true -- their places, the touch area
	self._dotColor_dirty=true
	self._isHidden_dirty=true

	--== Display Groups ==--

	self._dgDots = nil

	--== Object References ==--

	self._rctHit = nil -- touch area
	self._dots = {} -- the circles, by page

	self._tap_f = nil
end

--[[
function PageIndicator:__undoInit__()
	-- print( "PageIndicator:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]

--== createView

function PageIndicator:__createView__()
	-- print( "PageIndicator:__createView__" )
	self:superCall( '__createView__' )
	--==--
	local o

	-- touch area
	o = newRect( 0,0,0,0 )
	o:setFillColor( 0,0,0,0 )
	o.isHitTestable = true
	o.anchorX, o.anchorY = 0.5, 0.5
	self._dgBg:insert( o )
	self._rctHit = o

	o = display.newGroup()
	self._dgViews:insert( o )
	self._dgDots = o
end

function PageIndicator:__undoCreateView__()
	-- print( "PageIndicator:__undoCreateView__" )
	self:_removeDots()

	self._dgDots:removeSelf()
	self._dgDots=nil

	self._rctHit:removeSelf()
	self._rctHit=nil
	--==--
	self:superCall( '__undoCreateView__' )
end

--== initComplete

function PageIndicator:__initComplete__()
	-- print( "PageIndicator:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local tmp = self._pi_tmp_params
	self._pi_tmp_params = nil

	self._tap_f = self:createCallback( PageIndicator._tap_handler )
	self._rctHit:addEventListener( 'touch', touchBlock_handler )
	self._rctHit:addEventListener( 'tap', self._tap_f )

	--== Use Setters
	if tmp.width~=nil then self.width = tmp.width end
	if tmp.height~=nil then self.height = tmp.height end
	self.numberOfPages = tmp.numberOfPages
	self.currentPage = tmp.currentPage
	self.hidesForSinglePage = tmp.hidesForSinglePage
end

function PageIndicator:__undoInitComplete__()
	-- print( "PageIndicator:__undoInitComplete__" )
	self._rctHit:removeEventListener( 'tap', self._tap_f )
	self._rctHit:removeEventListener( 'touch', touchBlock_handler )
	self._tap_f = nil
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function PageIndicator.initialize( manager, params )
	-- print( "PageIndicator.initialize" )
	dUI = manager

	local Style = dUI.Style
	PageIndicator.STYLE_CLASS = Style.PageIndicator

	Style.registerWidget( PageIndicator )
end



--====================================================================--
--== Public Methods


--== .currentDotColor

--- [**style**] set/get the color of the dot of the current page.
--
-- @within Properties
-- @function .currentDotColor
-- @usage widget.currentDotColor = { 1, 1, 1, 1 }
-- @usage print( widget.currentDotColor )

function PageIndicator.__getters:currentDotColor()
	return self.curr_style.currentDotColor
end
function PageIndicator.__setters:currentDotColor( value )
	self.curr_style.currentDotColor = value
end

--== .currentPage

--- set/get the current page, from 1.
-- a value outside of the pages is brought to the first or the last
-- one. setting it doesn't call the delegate: only a tap does.
--
-- @within Properties
-- @function .currentPage
-- @usage widget.currentPage = 3
-- @usage print( widget.currentPage )

function PageIndicator.__getters:currentPage()
	return self._currentPage
end
function PageIndicator.__setters:currentPage( value )
	-- print( "PageIndicator.__setters:currentPage", value )
	assert( type(value)=='number', "PageIndicator.currentPage expected a number" )
	--==--
	value = self:_clampPage( mfloor( value ) )
	if value==self._currentPage then return end
	self._currentPage = value
	self._dotColor_dirty=true
	self:__invalidateProperties__()
end

--== .delegate

--- set/get the delegate, a table or object with the method `didChangePage`.
--
-- @within Properties
-- @function .delegate
-- @usage widget.delegate = <delegate object>
-- @usage print( widget.delegate )

PageIndicator.__getters.delegate = WidgetHelp.__getters.delegate
PageIndicator.__setters.delegate = WidgetHelp.__setters.delegate

--== .dotColor

--- [**style**] set/get the color of the dots of the other pages.
--
-- @within Properties
-- @function .dotColor
-- @usage widget.dotColor = { 1, 1, 1, 0.4 }
-- @usage print( widget.dotColor )

function PageIndicator.__getters:dotColor()
	return self.curr_style.dotColor
end
function PageIndicator.__setters:dotColor( value )
	self.curr_style.dotColor = value
end

--== .height

--- [**style**] set/get the height of the widget, its touch area.
-- with a style height of 0 it is the height of a dot and its margins.
--
-- @within Properties
-- @function .height
-- @usage widget.height = 44
-- @usage print( widget.height )

function PageIndicator.__getters:height()
	local style = self.curr_style
	local h = style.height
	if h==0 then h = style.dotSize + 2*style.marginY end
	return h
end

--== .hidesForSinglePage

--- set/get whether the dots are hidden when there is one page, or none.
-- default is `false`.
--
-- @within Properties
-- @function .hidesForSinglePage
-- @usage widget.hidesForSinglePage = true
-- @usage print( widget.hidesForSinglePage )

function PageIndicator.__getters:hidesForSinglePage()
	return self._hidesForSinglePage
end
function PageIndicator.__setters:hidesForSinglePage( value )
	-- print( "PageIndicator.__setters:hidesForSinglePage", value )
	assert( type(value)=='boolean', "PageIndicator.hidesForSinglePage expected a boolean" )
	--==--
	if value==self._hidesForSinglePage then return end
	self._hidesForSinglePage = value
	self._isHidden_dirty=true
	self:__invalidateProperties__()
end

--== .isHidden

--- get whether the dots are hidden (read only): `hidesForSinglePage`
-- is on and there is at most one page.
--
-- @within Properties
-- @function .isHidden
-- @usage print( widget.isHidden )

function PageIndicator.__getters:isHidden()
	return ( self._hidesForSinglePage and self._numberOfPages<=1 )
end

--== .numberOfPages

--- set/get the number of pages, a dot for each.
-- the current page stays inside of them.
--
-- @within Properties
-- @function .numberOfPages
-- @usage widget.numberOfPages = 5
-- @usage print( widget.numberOfPages )

function PageIndicator.__getters:numberOfPages()
	return self._numberOfPages
end
function PageIndicator.__setters:numberOfPages( value )
	-- print( "PageIndicator.__setters:numberOfPages", value )
	assert( type(value)=='number' and value>=0, "PageIndicator.numberOfPages expected a number, 0 or more" )
	--==--
	value = mfloor( value )
	if value==self._numberOfPages then return end
	self._numberOfPages = value
	self._currentPage = self:_clampPage( self._currentPage )
	self._dots_dirty=true
	self._isHidden_dirty=true
	self:__invalidateProperties__()
end

--== .width

--- [**style**] set/get the width of the widget, its touch area.
-- with a style width of 0 it is the width of the row of dots and its margins.
--
-- @within Properties
-- @function .width
-- @usage widget.width = 320
-- @usage print( widget.width )

function PageIndicator.__getters:width()
	local style = self.curr_style
	local w = style.width
	if w==0 then w = self:_getRowWidth() + 2*style.marginX end
	return w
end



--====================================================================--
--== Private Methods


-- the page inside of the pages which is closest to 'page'
--
function PageIndicator:_clampPage( page )
	return mmax( 1, mmin( page, self._numberOfPages ) )
end

-- the width of the dots and the spaces between them
--
function PageIndicator:_getRowWidth()
	local style = self.curr_style
	local num = self._numberOfPages
	if num<1 then return 0 end
	return num*style.dotSize + (num-1)*style.dotSpacing
end

-- the middle of the widget, from its reference point
--
function PageIndicator:_getCenter()
	local style = self.curr_style
	return (0.5-style.anchorX)*self.width, (0.5-style.anchorY)*self.height
end

-- the middle of the dot of 'page', left to right, from the middle of the widget
--
function PageIndicator:_getDotOffset( page )
	local style = self.curr_style
	local size = style.dotSize
	return -self:_getRowWidth()*0.5 + size*0.5 + (page-1)*(size+style.dotSpacing)
end


function PageIndicator:_removeDots()
	-- print( "PageIndicator:_removeDots" )
	local dots = self._dots
	for i=#dots, 1, -1 do
		dots[i]:removeSelf()
		dots[i] = nil
	end
end

function PageIndicator:_createDots()
	-- print( "PageIndicator:_createDots" )
	self:_removeDots()

	local dots = self._dots
	local dg = self._dgDots
	local radius = self.curr_style.dotSize*0.5
	for i=1, self._numberOfPages do
		local o = newCircle( 0, 0, radius )
		dg:insert( o )
		dots[i] = o
	end
end


-- move by one page, after a tap: 'direction' is -1 or 1.
-- at the first or the last page there is nowhere to go
--
function PageIndicator:_changePage( direction )
	-- print( "PageIndicator:_changePage", direction )
	local previous = self._currentPage
	local page = self:_clampPage( previous + direction )
	if page==previous then return end

	self.currentPage = page
	self:_dispatchPageChanged( page, previous )
end


--======================================================--
-- Event Dispatch

function PageIndicator:_dispatchPageChanged( page, previous )
	-- print( "PageIndicator:_dispatchPageChanged", page, previous )
	local delegate = self._delegate
	local f = delegate and delegate.didChangePage
	if not f then return end
	f( delegate, {
		name=PageIndicator.EVENT,
		type=PageIndicator.PAGE_CHANGED,

		target=self,
		page=page,
		previousPage=previous,
	})
end


--======================================================--
-- DMC Lifecycle Methods

function PageIndicator:__commitProperties__()
	-- print( "PageIndicator:__commitProperties__" )

	if not self.isRendered then return end

	local style = self.curr_style
	local view = self.view
	local hit = self._rctHit
	local dots = self._dots

	-- x/y

	if self._x_dirty then
		view.x = self._x
		self._x_dirty = false
	end
	if self._y_dirty then
		view.y = self._y
		self._y_dirty = false
	end

	-- dots

	if self._dots_dirty then
		self:_createDots()
		self._dots_dirty=false

		self._layout_dirty=true
		self._dotColor_dirty=true
	end

	-- width/height, anchorX/anchorY

	if self._width_dirty or self._height_dirty
		or self._anchorX_dirty or self._anchorY_dirty then
		self._width_dirty=false
		self._height_dirty=false
		self._anchorX_dirty=false
		self._anchorY_dirty=false

		self._layout_dirty=true
	end

	if self._layout_dirty then
		local x, y = self:_getCenter()
		hit.x, hit.y = x, y
		hit.width, hit.height = self.width, self.height
		for i=1, #dots do
			local o = dots[i]
			o.x, o.y = x + self:_getDotOffset( i ), y
		end
		self._layout_dirty=false
	end

	if self._dotColor_dirty then
		local current = self._currentPage
		local color, currentColor = style.dotColor, style.currentDotColor
		for i=1, #dots do
			dots[i]:setFillColor( unpack( i==current and currentColor or color ) )
		end
		self._dotColor_dirty=false
	end

	-- hidden, with its touch area

	if self._isHidden_dirty then
		local isShown = not self.isHidden
		self._dgDots.isVisible = isShown
		hit.isVisible = isShown
		self._isHidden_dirty=false
	end

	-- debug on

	if self._debugOn_dirty then
		if style.debugOn==true then
			hit:setFillColor( 1,1,0,0.3 )
		else
			hit:setFillColor( 0,0,0,0 )
		end
		self._debugOn_dirty=false
	end

end



--====================================================================--
--== Event Handlers


-- a tap in the touch area: left of the current dot is
-- the page before it, right of it the page after it
--
function PageIndicator:_tap_handler( event )
	-- print( "PageIndicator:_tap_handler", event.x, event.y )
	if self._numberOfPages > 1 then
		local hit = self._rctHit
		local x = hit:contentToLocal( event.x, event.y )
		local dotX = self:_getDotOffset( self._currentPage )
		local radius = self.curr_style.dotSize*0.5
		if x < dotX-radius then
			self:_changePage( -1 )
		elseif x > dotX+radius then
			self:_changePage( 1 )
		end
	end
	return true
end


function PageIndicator:stylePropertyChangeHandler( event )
	-- print( "PageIndicator:stylePropertyChangeHandler", event.type, event.property )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- print( "Style Changed", etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty=true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._dots_dirty=true
		self._layout_dirty=true
		self._dotColor_dirty=true

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

		elseif property=='currentDotColor' or property=='dotColor' then
			self._dotColor_dirty=true
		elseif property=='dotSize' then
			self._dots_dirty=true
		elseif property=='dotSpacing' or property=='marginX' or property=='marginY' then
			self._layout_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return PageIndicator
