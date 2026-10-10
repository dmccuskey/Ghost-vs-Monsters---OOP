--====================================================================--
-- dmc_ui/dmc_widget/widget_scrollview.lua
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
--== DMC Corona UI : ScrollView Widget
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
--== DMC UI : newScrollView
--====================================================================--



--====================================================================--
--== Imports


local AxisMotion = require( ui_find( 'dmc_widget.widget_scrollview.axis_motion' ) )
local Gesture = require 'dmc_gestures'
local Objects = require 'dmc_objects'
local Patch = require 'dmc_patch'
local ScaleMotion = require( ui_find( 'dmc_widget.widget_scrollview.scale_motion' ) )
local TouchMgr = require 'dmc_touchmanager'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )
local WidgetHelp = require( ui_find( 'core.widget_helper' ) )
local Scroller = require( ui_find( 'dmc_widget.widget_scrollview.scroller' ) )



--====================================================================--
--== Setup, Constants


Patch.addPatch( 'print-output' )

local newRect = display.newRect
local mmax = math.max
local mmin = math.min
local sfmt = string.format
local tcancel = timer.cancel
local tdelay = timer.performWithDelay
local type = _G.type

-- a tap on the scroll view stays with it: Solar2D sends 'tap' apart from
-- 'touch', and it would reach what lies behind the widget. the content
-- is in front of this background, so its own tap listeners come first
local function tapBlock_handler( event )
	return true
end

--== To be set in initialize()
local dUI = nil



--====================================================================--
--== ScrollView Widget Class
--====================================================================--

--- ScrollView Widget.
-- a container view which can scroll independently on two axis (X/Y).
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- @classmod Widget.ScrollView
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newScrollView()

local ScrollView = newClass( WidgetBase, { name="ScrollView" } )

--- Class Constants.
-- @section

--== Class Constants

ScrollView.HIT_TOP_LIMIT = 'top_limit_hit'
ScrollView.HIT_BOTTOM_LIMIT = 'bottom_limit_hit'
ScrollView.HIT_LEFT_LIMIT = 'left_limit_hit'
ScrollView.HIT_RIGHT_LIMIT = 'right_limit_hit'

--== Scroll Indicators

ScrollView.INDICATOR_THICKNESS = 3
ScrollView.INDICATOR_MARGIN = 3 -- from the edges of the view
ScrollView.INDICATOR_MIN_LENGTH = 24
ScrollView.INDICATOR_FADE_DELAY = 150 -- after the content stops
ScrollView.INDICATOR_FADE_TIME = 300
ScrollView.INDICATOR_FLASH_TIME = 800 -- flashScrollIndicators()
ScrollView.INDICATOR_COLOR = { 0, 0, 0, 0.4 } -- if the style has none

--== Style/Theme Constants

ScrollView.STYLE_CLASS = nil -- added later
ScrollView.STYLE_TYPE = uiConst.SCROLLVIEW

-- TODO: hook up later
-- ScrollView.DEFAULT = 'default'

-- ScrollView.THEME_STATES = {
-- 	ScrollView.DEFAULT,
-- }


--== Event Constants

--- ScrollView event constant.
-- used when setting up event listeners.
--
-- @usage
-- widget:addEventListener( widget.EVENT, listener )

ScrollView.EVENT = 'scrollview-widget-event'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function ScrollView:__init__( params )
	-- print( "ScrollView:__init__", params )
	params = params or {}
	if params.bounceIsActive==nil then params.bounceIsActive=true end
	if params.decelerateTransitionTime==nil then params.decelerateTransitionTime=uiConst.SCROLLVIEW_DECELERATE_TIME end
	if params.horizontalScrollEnabled==nil then params.horizontalScrollEnabled=true end
	if params.isPagingEnabled==nil then params.isPagingEnabled=false end
	if params.lowerHorizontalOffset==nil then params.lowerHorizontalOffset = 0 end
	if params.lowerVerticalOffset==nil then params.lowerVerticalOffset = 0 end
	if params.width==nil then params.width=dUI.WIDTH end
	if params.height==nil then params.height=dUI.HEIGHT end
	if params.scrollWidth==nil then params.scrollWidth=params.width end
	if params.scrollHeight==nil then params.scrollHeight=params.height end
	if params.showHorizontalScrollIndicator==nil then params.showHorizontalScrollIndicator=true end
	if params.showVerticalScrollIndicator==nil then params.showVerticalScrollIndicator=true end
	if params.upperHorizontalOffset==nil then params.upperHorizontalOffset = 0 end
	if params.upperVerticalOffset==nil then params.upperVerticalOffset = 0 end
	if params.verticalScrollEnabled==nil then params.verticalScrollEnabled=true end

	self:superCall( '__init__', params )
	--==--

	-- save params for later
	self._sv_tmp_params = params -- tmp

	-- with autoMask, the view is a container, sized with the widget
	self._autoMask = params.autoMask

	--== Create Properties ==--

	-- properties in this class

	-- self._width = params.width
	-- self._height = params.height

	self._contentPosition = {x=0,y=0}
	self._contentPosition_dirty=true

	-- self._enterFrameIterator = nil

	self._autoAlign = true

	self._hasMoved = false
	self._isMoving = false

	-- which axes are scrolling, for the delegate's scroll methods
	self._scrollingAxes = { x=false, y=false }

	-- smallest scale to fit current scroll dimensions
	self._minScale = 1.0
	self.__zoomScale = 1.0
	self._zoomScale_dirty=true
	self._zoomView = nil

	self._canScroll = false

	self._scrollWidth = -1
	self._scrollWidth_dirty=true
	self._scrollHeight = -1
	self._scrollHeight_dirty=true

	-- scroll dimensions might be adjusted if
	-- values are too small to fill viewport
	self._actualScrollH = 0
	self._actualScrollW = 0

	-- controlled by Directional Lock Enabled
	self._scrollBlockedH = false
	self._scrollBlockedV = false

	self._returnFocus = nil -- return focus callback
	self._returnFocusCancel = nil -- return focus callback
	self._returnFocus_t = nil -- return focus timer

	-- properties from style

	self._alwaysBounceVertically = false
	self._alwaysBounceHorizontally = false

	self._isDirectionalLockEnabled = false

	self._showHorizontalScrollIndicator = params.showHorizontalScrollIndicator
	self._showVerticalScrollIndicator = params.showVerticalScrollIndicator

	-- scroll indicators, by axis id ('x', 'y'). each is
	-- { view=<rounded rect>, canShow=<bool>, isShown=<bool>, trans=<fade> }
	self._indicators = {}
	self._indicatorColor_dirty=true

	self._stopMotion = false

	--== Display Groups ==--

	--== Object References ==--

	self._axis_f = nil -- axis event handler (both)
	self._axisX = nil -- y-axis motion
	self._axisY = nil -- x-axis motion

	self._scale_f = nil -- pinch motion handler
	self._scaleMotion = nil -- pinch motion

	self._gesture_f = nil -- callback
	self._panGesture = nil
	self._pinchGesture = nil

	self._rectBg = nil -- background object, touch area

	self._scroller = nil -- our scroll area
	self._scroller_dirty=true

	self._dgIndicators = nil -- scroll indicators, over the scroll area
end

--[[
function ScrollView:__undoInit__()
	-- print( "ScrollView:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]

--== createView

function ScrollView:__createView__()
	-- print( "ScrollView:__createView__" )
	self:superCall( '__createView__' )
	--==--
	-- local background, gesture hit area
	local o = newRect( 0,0,0,0 )
	o.anchorX, o.anchorY = 0, 0
	o:setFillColor( 1,0,0,0.4 )
	self._dgBg:insert( o )
	self._rectBg = o
end

function ScrollView:__undoCreateView__()
	-- print( "ScrollView:__undoCreateView__" )
	self._rectBg:removeSelf()
	self._rectBg=nil
	--==--
	self:superCall( '__undoCreateView__' )
end

--== initComplete

function ScrollView:__initComplete__()
	-- print( "ScrollView:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local tmp = self._sv_tmp_params
	self._sv_tmp_params = nil

	local o, f

	local delegate = {
		shouldRecognizeWith=function( self, gr_rec, gr_fail )
			return true
		end
	}

	f = self:createCallback( self._gestureEvent_handler )
	o = Gesture.newPanGesture( self._rectBg, { touches=1, threshold=0, id='pan' } )
	o.delegate=delegate
	o:addEventListener( o.EVENT, f )
	self._panGesture = o

	o = Gesture.newPinchGesture( self._rectBg, { id='pinch' } )
	-- o.test_mode=false
	o.delegate=delegate
	o:addEventListener( o.EVENT, f )
	self._pinchGesture = o

	self._gesture_f = f

	self._rectBg:addEventListener( 'tap', tapBlock_handler )

	-- after the scroller is in the view (superCall), to be above it
	self:_createScrollIndicators()

	-- before axis creation
	self.width = tmp.width
	self.height = tmp.height
	self.scrollWidth = tmp.scrollWidth
	self.scrollHeight = tmp.scrollHeight

	self._axis_f = self:createCallback( self._axisEvent_handler )
	self:_createAxisMotionX()
	self:_createAxisMotionY()

	self._scale_f = self:createCallback( self._scaleEvent_handler )
	self:_createScaleMotion()

	--== Use Setters, after motion objects are created

	self.bounceIsActive = tmp.bounceIsActive

	self.minimumZoom = tmp.minimumZoom
	self.maximumZoom = tmp.maximumZoom
	-- no zoomScale option: the view to zoom is added after creation,
	-- use setZoomScale() then

	self.decelerateTransitionTime = tmp.decelerateTransitionTime
	self.isPagingEnabled = tmp.isPagingEnabled

	self.horizontalScrollEnabled = tmp.horizontalScrollEnabled
	self.upperHorizontalOffset = tmp.upperHorizontalOffset
	self.lowerHorizontalOffset = tmp.lowerHorizontalOffset

	self.verticalScrollEnabled = tmp.verticalScrollEnabled
	self.upperVerticalOffset = tmp.upperVerticalOffset
	self.lowerVerticalOffset = tmp.lowerVerticalOffset

end

function ScrollView:__undoInitComplete__()
	-- print( "ScrollView:__undoInitComplete__" )
	local o, f

	self:_removeScrollIndicators()

	self:_removeScaleMotion()
	self._scale_f = nil

	self:_removeAxisMotionX()
	self:_removeAxisMotionY()
	self._axis_f = nil

	o = self._panGesture
	o:removeEventListener( o.EVENT, self._gesture_f )
	o:removeSelf()
	self._panGesture = nil

	o = self._pinchGesture
	o:removeEventListener( o.EVENT, self._gesture_f )
	o:removeSelf()
	self._pinchGesture = nil

	self._gesture_f = nil

	self._rectBg:removeEventListener( 'tap', tapBlock_handler )

	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods

--
function ScrollView.initialize( manager, params )
	-- print( "ScrollView.initialize" )
	dUI = manager

	local Style = dUI.Style
	ScrollView.STYLE_CLASS = Style.ScrollView

	Style.registerWidget( ScrollView )
end



--[[
--== width

function ScrollView.__getters:width()
	-- print( 'StyleMix.__getters:width' )
	return self._width
end
function ScrollView.__setters:width( value )
	-- print( 'StyleMix.__setters:width', value )
	self._width = value
end

--== height

function ScrollView.__getters:height()
	-- print( 'StyleMix.__getters:height' )
	return self._height
end
function ScrollView.__setters:height( value )
	-- print( 'StyleMix.__setters:height', value )
	self._height = value
end
--]]





--====================================================================--
--== Public Methods

-- override x/y to can give location to Axis Motion controls
-- we sidestep use of localToContent()

function ScrollView.__setters:x( value )
	WidgetBase.__setters.x( self, value )
	self._axisX.location = value
end

function ScrollView.__setters:y( value )
	WidgetBase.__setters.y( self, value )
	self._axisY.location = value
end

--== .alwaysBounceHorizontally

-- set/get activate rebound action when hitting a scroll-limit.
-- defaults to true.
-- @TODO
-- @within Properties
-- @function .alwaysBounceHorizontally
-- @usage widget.alwaysBounceHorizontally = true
-- @usage print( widget.alwaysBounceHorizontally )

function ScrollView.__getters:alwaysBounceHorizontally()
	-- print( "ScrollView.__getters:bounceIsActive" )
	return ( self._axisX.alwaysBounceHorizontally and self._axisY.alwaysBounceHorizontally )
end
function ScrollView.__setters:alwaysBounceHorizontally( value )
	-- print( "ScrollView.__setters:alwaysBounceHorizontally", value )
	self._axisX.alwaysBounceHorizontally = value
	self._axisY.alwaysBounceHorizontally = value
end

--== .alwaysBounceVertically

-- set/get activate rebound action when hitting a scroll-limit.
-- defaults to true.
-- @TODO
-- @within Properties
-- @function .alwaysBounceVertically
-- @usage widget.alwaysBounceVertically = true
-- @usage print( widget.alwaysBounceVertically )

function ScrollView.__getters:alwaysBounceVertically()
	-- print( "ScrollView.__getters:bounceIsActive" )
	return ( self._axisX.alwaysBounceVertically and self._axisY.alwaysBounceVertically )
end
function ScrollView.__setters:alwaysBounceVertically( value )
	-- print( "ScrollView.__setters:alwaysBounceVertically", value )
	self._axisX.alwaysBounceVertically = value
	self._axisY.alwaysBounceVertically = value
end

--== .bounceIsActive

--- set/get activate rebound action when hitting a scroll-limit.
-- defaults to true.
--
-- @within Properties
-- @function .bounceIsActive
-- @usage widget.bounceIsActive = true
-- @usage print( widget.bounceIsActive )

function ScrollView.__getters:bounceIsActive()
	-- print( "ScrollView.__getters:bounceIsActive" )
	return ( self._axisX.bounceIsActive and self._axisY.bounceIsActive )
end
function ScrollView.__setters:bounceIsActive( value )
	-- print( "ScrollView.__setters:bounceIsActive", value )
	self._axisX.bounceIsActive = value
	self._axisY.bounceIsActive = value
end

function ScrollView.__getters:decelerateTransitionTime()
	-- print( "ScrollView.__getters:decelerateTransitionTime" )
	return self._axisX.decelerateTransitionTime
end
function ScrollView.__setters:decelerateTransitionTime( value )
	-- print( "ScrollView.__setters:decelerateTransitionTime", value )
	self._axisX.decelerateTransitionTime = value
	self._axisY.decelerateTransitionTime = value
end

--== .delegate

--- set/get delegate for item.
--
-- @within Properties
-- @function .delegate
-- @usage widget.delegate = <delegate object>
-- @usage print( widget.delegate )

ScrollView.__getters.delegate = WidgetHelp.__getters.delegate
ScrollView.__setters.delegate = WidgetHelp.__setters.delegate

--== .fillColor

--- [**style**] set/get Style value for Widget fill color.
--
-- @within Properties
-- @function .fillColor
-- @usage style.fillColor = '#ff0000'
-- @usage print( style.fillColor )

ScrollView.__getters.fillColor = WidgetHelp.__getters.fillColor
ScrollView.__setters.fillColor = WidgetHelp.__setters.fillColor


--== .lowerHorizontalOffset

--- set/get the lower horizontal offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .lowerHorizontalOffset
-- @usage widget.lowerHorizontalOffset = 30
-- @usage print( widget.lowerHorizontalOffset )

function ScrollView.__getters:lowerHorizontalOffset()
	-- print( "ScrollView.__getters:lowerHorizontalOffset" )
	return self._axisX.lowerOffset
end
function ScrollView.__setters:lowerHorizontalOffset( value )
	-- print( "ScrollView.__setters:lowerHorizontalOffset", value )
	self._axisX.lowerOffset = value
	self:_updateScrollIndicator( 'x' )
end

--== .lowerVerticalOffset

--- set/get the lower vertical offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .lowerVerticalOffset
-- @usage widget.lowerVerticalOffset = 30
-- @usage print( widget.lowerVerticalOffset )

function ScrollView.__getters:lowerVerticalOffset()
	-- print( "ScrollView.__getters:lowerVerticalOffset" )
	return self._axisY.lowerOffset
end
function ScrollView.__setters:lowerVerticalOffset( value )
	-- print( "ScrollView.__setters:lowerVerticalOffset", value )
	self._axisY.lowerOffset = value
	self:_updateScrollIndicator( 'y' )
end

--== .isDirectionalLockEnabled

-- set/get whether bouncing on edges (TBD).
-- @TODO
-- @within Properties
-- @function .directionalLockEnabled
-- @usage widget.directionalLockEnabled = true
-- @usage print( widget.directionalLockEnabled )

function ScrollView.__getters:isDirectionalLockEnabled()
	-- print( "ScrollView.__getters:isDirectionalLockEnabled" )
	return self._isDirectionalLockEnabled
end
function ScrollView.__setters:isDirectionalLockEnabled( value )
	-- print( "ScrollView.__setters:isDirectionalLockEnabled", value )
	self._isDirectionalLockEnabled = value
end

--== .horizontalScrollEnabled

--- set/get control ScrollView horizontal motion.
-- setting to false will disable scrolling in X-axis.
--
-- @within Properties
-- @function .horizontalScrollEnabled
-- @usage widget.horizontalScrollEnabled = true
-- @usage print( widget.horizontalScrollEnabled )

function ScrollView.__getters:horizontalScrollEnabled()
	-- print( "ScrollView.__getters:horizontalScrollEnabled" )
	return self._axisX.scrollIsEnabled
end
function ScrollView.__setters:horizontalScrollEnabled( value )
	-- print( "ScrollView.__setters:horizontalScrollEnabled", value )
	self._axisX.scrollIsEnabled = value
	self:_updateScrollIndicator( 'x' )
end

--== .isPagingEnabled

--- set/get whether the ScrollView stops on pages.
-- a page is the size of the view. a drag ends on the nearest page, and a flick on the next one in its direction, one page for each touch. defaults to false.
--
-- @within Properties
-- @function .isPagingEnabled
-- @usage widget.isPagingEnabled = true
-- @usage print( widget.isPagingEnabled )

function ScrollView.__getters:isPagingEnabled()
	-- print( "ScrollView.__getters:isPagingEnabled" )
	return self._axisX.pagingIsEnabled
end
function ScrollView.__setters:isPagingEnabled( value )
	-- print( "ScrollView.__setters:isPagingEnabled", value )
	assert( type(value)=='boolean', "ScrollView.isPagingEnabled expected a boolean" )
	--==--
	self._axisX.pagingIsEnabled = value
	self._axisY.pagingIsEnabled = value
end

--== .horizontalAxisAutoAlign

function ScrollView.__getters:horizontalAxisAutoAlign()
	return self._axisX.autoAlign
end
function ScrollView.__setters:horizontalAxisAutoAlign( value )
	self._axisX.autoAlign = value
end

--== .verticalAxisAutoAlign

function ScrollView.__getters:verticalAxisAutoAlign()
	return self._axisY.autoAlign
end
function ScrollView.__setters:verticalAxisAutoAlign( value )
	self._axisY.autoAlign = value
end


function ScrollView.__getters:maximumZoom()
	-- print( "ScrollView.__getters:maximumZoom" )
	return self._scaleMotion.maximumZoom
end
function ScrollView.__setters:maximumZoom( value )
	-- print( "ScrollView.__setters:maximumZoom", value )
	self._scaleMotion.maximumZoom = value
	self:_updateCanZoom()
end


function ScrollView.__getters:minimumZoom()
	-- print( "ScrollView.__getters:minimumZoom" )
	local scale = self._scaleMotion and self._scaleMotion.minimumZoom or 1.0
	return scale
end
function ScrollView.__setters:minimumZoom( value )
	-- print( "ScrollView.__setters:minimumZoom", value, self._minScale )
	if value and value < self._minScale then value=self._minScale end
	self._scaleMotion.minimumZoom = value
	self:_updateCanZoom()
end


function ScrollView.__getters:scroller()
	-- print( "ScrollView.__getters:scroller" )
	return self._scroller
end


function ScrollView.__getters:zoomScale()
	-- print( "ScrollView.__getters:zoomScale" )
	return self._scaleMotion.zoomScale
end
function ScrollView:setZoomScale( value, params )
	local zView = self._zoomView
	if not zView then
		zView = self:_getZoomView()
		self._zoomView = zView
	end
	if not zView then return end
	return self._scaleMotion:setZoomScale( value, params )
end


function ScrollView.__getters:isZooming()
	-- print( "ScrollView.__getters:isZooming" )
	return self._scaleMotion.isZooming
end

function ScrollView:_updateCanZoom()
	-- print( "ScrollView.__getters:_updateCanZoom" )
	self._canZoom = self._scaleMotion.zoomIsActive
end

--== .verticalScrollEnabled

--- set/get control ScrollView vertical motion.
-- setting to false will disable scrolling in Y-axis.
--
-- @within Properties
-- @function .verticalScrollEnabled
-- @usage widget.verticalScrollEnabled = true
-- @usage print( widget.verticalScrollEnabled )

function ScrollView.__getters:verticalScrollEnabled()
	-- print( "ScrollView.__getters:verticalScrollEnabled" )
	return self._axisY.scrollIsEnabled
end
function ScrollView.__setters:verticalScrollEnabled( value )
	-- print( "ScrollView.__setters:verticalScrollEnabled", value )
	self._axisY.scrollIsEnabled = value
	self:_updateScrollIndicator( 'y' )
end

--== .showHorizontalScrollIndicator

--- set/get whether the horizontal scroll indicator is shown while scrolling.
-- defaults to true.
--
-- @within Properties
-- @function .showHorizontalScrollIndicator
-- @usage widget.showHorizontalScrollIndicator = false
-- @usage print( widget.showHorizontalScrollIndicator )

function ScrollView.__getters:showHorizontalScrollIndicator()
	return self._showHorizontalScrollIndicator
end
function ScrollView.__setters:showHorizontalScrollIndicator( value )
	assert( type(value)=='boolean' )
	--==--
	self._showHorizontalScrollIndicator = value
	self:_updateScrollIndicator( 'x' )
end

--== .showVerticalScrollIndicator

--- set/get whether the vertical scroll indicator is shown while scrolling.
-- defaults to true.
--
-- @within Properties
-- @function .showVerticalScrollIndicator
-- @usage widget.showVerticalScrollIndicator = false
-- @usage print( widget.showVerticalScrollIndicator )

function ScrollView.__getters:showVerticalScrollIndicator()
	return self._showVerticalScrollIndicator
end
function ScrollView.__setters:showVerticalScrollIndicator( value )
	assert( type(value)=='boolean' )
	--==--
	self._showVerticalScrollIndicator = value
	self:_updateScrollIndicator( 'y' )
end

--== .panGesture

--- get reference to pan gesture. read-only
--
-- @within Properties
-- @function .panGesture
-- @usage print( widget.panGesture )

function ScrollView.__getters:panGesture()
	-- print( "ScrollView.__setters:panGesture" )
	return self._panGesture
end

--== .pinchGesture

--- get reference to pinch gesture. read-only
--
-- @within Properties
-- @function .pinchGesture
-- @usage print( widget.pinchGesture )

function ScrollView.__getters:pinchGesture()
	-- print( "ScrollView.__setters:pinchGesture" )
	return self._pinchGesture
end


--== .setFillColor

ScrollView.setFillColor = WidgetHelp.setFillColor



--== .scrollWidth

--- set/get width of scroll area.
-- this is the total scroll area, not just the scroll view port.
-- value must be greater than zero.
--
-- @within Properties
-- @function .scrollWidth
-- @usage widget.scrollWidth = 1000
-- @usage print( widget.scrollWidth )

function ScrollView.__getters:scrollWidth()
	-- print( "ScrollView.__getters:scrollWidth" )
	return self._scrollWidth * self.__zoomScale
end
function ScrollView.__setters:scrollWidth( value )
	-- print( "ScrollView.__setters:scrollWidth", value )
	assert( type(value)=='number' and value>=0 )
	--==--
	local width = self.width
	if value < width then value=width end
	if self._scrollWidth==value then return end
	self._scrollWidth = value
	self._scrollWidth_dirty=true
	self:__invalidateProperties__()

	self:_calculateMinScale()
end

--== .scrollHeight

--- set/get height of scroll area.
-- this is the total scroll area, not just the scroll view port.
-- value must be greater than zero.
--
-- @within Properties
-- @function .scrollHeight
-- @usage widget.scrollHeight = 1000
-- @usage print( widget.scrollHeight )

function ScrollView.__getters:scrollHeight()
	-- print( "ScrollView.__getters:scrollHeight" )
	return self._scrollHeight * self.__zoomScale
end
function ScrollView.__setters:scrollHeight( value )
	-- print( "ScrollView.__setters:scrollHeight", value )
	assert( type(value)=='number' and value>=0 )
	--==--
	local height = self.height
	if value < height then value=height end
	if self._scrollHeight==value then return end
	self._scrollHeight = value
	self._scrollHeight_dirty=true
	self:__invalidateProperties__()

	self:_calculateMinScale()
end


function ScrollView:_calculateMinScale()
	local scaleW = self.width / self._scrollWidth
	local scaleH = self.height / self._scrollHeight
	local minScale = mmin( scaleW, scaleH )

	self._minScale = minScale
	if self.minimumZoom < minScale then
		pnotice( sfmt( "ScrollView minimum scale being set to: %s", minScale ) )
		self.minimumZoom = minScale
	end
end


--== .upperHorizontalOffset

--- set/get the upper horizontal offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .upperHorizontalOffset
-- @usage widget.upperHorizontalOffset = 30
-- @usage print( widget.upperHorizontalOffset )

function ScrollView.__getters:upperHorizontalOffset()
	-- print( "ScrollView.__getters:upperHorizontalOffset" )
	return self._axisX.upperOffset
end
function ScrollView.__setters:upperHorizontalOffset( value )
	-- print( "ScrollView.__setters:upperHorizontalOffset", value )
	self._axisX.upperOffset = value
	self:_updateScrollIndicator( 'x' )
end

--== .upperVerticalOffset

--- set/get the upper vertical offset for the ScrollView.
-- value must be a number, can be negative or positive. defaults to zero.
--
-- @within Properties
-- @function .upperVerticalOffset
-- @usage widget.upperVerticalOffset = 30
-- @usage print( widget.upperVerticalOffset )

function ScrollView.__getters:upperVerticalOffset()
	-- print( "ScrollView.__getters:upperVerticalOffset" )
	return self._axisY.upperOffset
end
function ScrollView.__setters:upperVerticalOffset( value )
	-- print( "ScrollView.__setters:upperVerticalOffset", value )
	self._axisY.upperOffset = value
	self:_updateScrollIndicator( 'y' )
end


--======================================================--
-- Methods

--== .contentPosition

--- Returns the x and y coordinates of the ScrollView content.
--
-- @within Methods
-- @function :getContentPosition
-- @treturn number x
-- @treturn number y
-- @usage local x, y = widget:getContentPosition()

function ScrollView:getContentPosition()
	-- print( "ScrollView.__getters:contentPosition" )
	return self._axisX.value, self._axisY.value
end

--- Scroll to a specific x and/or y position.
-- Moves content position to x/y over a certain time duration. negative values are up and left, positive values are down and right.
--
-- @within Methods
-- @function :setContentPosition
-- @tab params table of coordinates (Though x or y are optional, at least one of them must be specified)
-- @number[opt] params.x x position
-- @number[opt] params.y y position
-- @number[opt=500] params.time duration of animation
-- @func[opt] params.onComplete function reference to call after animation

function ScrollView:setContentPosition( params )
	-- print( "ScrollView:setContentPosition", params )
	local _type = type
	assert( _type(params)=='table' )
	--==--
	local xIsNum = (_type(params.x)=='number')
	local yIsNum = (_type(params.y)=='number')
	assert( xIsNum or _type(params.x)=='nil' )
	assert( yIsNum or _type(params.y)=='nil' )

	local tcf -- transition complete func
	if params.onComplete then
		if xIsNum and yIsNum then
			tcf = Utils.getTransitionCompleteFunc( 2, params.onComplete )
		else
			tcf = params.onComplete
		end
	end
	if xIsNum then
		self._axisX:scrollToPosition( params.x, {
			onComplete=tcf, time=params.time
		})
	end
	if yIsNum then
		self._axisY:scrollToPosition( params.y, {
			onComplete=tcf, time=params.time
		})
	end
end


--- show the scroll indicators for a moment.
-- eg, when a view comes on screen, to show that it scrolls.
--
-- @within Methods
-- @function :flashScrollIndicators
-- @usage widget:flashScrollIndicators()

function ScrollView:flashScrollIndicators()
	-- print( "ScrollView:flashScrollIndicators" )
	for id in pairs( self._indicators ) do
		self:_updateScrollIndicator( id )
		self:_showScrollIndicator( id )
		self:_hideScrollIndicator( id, ScrollView.INDICATOR_FLASH_TIME )
	end
end


-- completes process of giving up focus.
-- the main point it to terminate any touch action on ScrollView
--
function ScrollView:relinquishFocus( event )
	-- print( "ScrollView:relinquishFocus" )
	event.phase='cancelled'
	self._rectBg:dispatchEvent( event )
end

--- give touch focus to the ScrollView.
-- the ScrollView will take the touch event and set the focus to itself. _event must be from DMC TouchManager_.
--
-- @within Methods
-- @function :takeFocus
-- @param event Touch Event from DMC TouchManager
-- @usage widget:takeFocus( event )

function ScrollView:takeFocus( event )
	TouchMgr.setFocus( self._rectBg, event.id )

	-- stop existing returnFocus timer, if any
	if self._returnFocusCancel then self._returnFocusCancel() end

	self._tmpTouchEvt = event

	if event.returnFocus then
		-- we have returnFocus request, so do setup for it

		local rFCallback = event.returnFocus
		local rFTarget = event.returnTarget
		assert( rFTarget and rFCallback )

		local returnFocus_f, cancelFocus_f

		-- returns focus back to initiator
		-- this is set on timer, either it gets cancelled
		-- or the timer goes off and initiates returnFocus
		--
		returnFocus_f = function( state )
			-- print( "ScrollView: returnFocus" )

			cancelFocus_f()

			local e = self._tmpTouchEvt

			local evt = {
				name=e.name,
				id=e.id,
				time=e.time,
				x=e.x,
				y=e.y,
				xStart=e.xStart,
				yStart=e.yStart,
			}

			if state then
				-- coming from end touch
				-- make event 'ended'
				evt.phase = state
			else
				-- coming from timer
				-- terminate current touch action
				-- then send 'began' event
				self:relinquishFocus( e )
				evt.phase = 'began'
			end

			evt.target = rFTarget
			rFCallback( evt )
		end

		cancelFocus_f = function()
			-- print( 'ScrollerBase: cancelFocus' )

			if self._returnFocus_t then
				tcancel( self._returnFocus_t )
				self._returnFocus_t = nil
			end

			self._returnFocus = nil
			self._returnFocusCancel = nil
		end

		self._returnFocus = returnFocus_f
		self._returnFocusCancel = cancelFocus_f
		self._returnFocus_t = tdelay( 100, function(e) returnFocus_f() end )

	end

	-- remove previous focus, if any

	TouchMgr.unsetFocus( event.target, event.id )
	-- send new event through touch area
	event.phase='began'
	event.target=self._rectBg
	event.target:dispatchEvent( event )
end



--====================================================================--
--== Private Methods

function ScrollView:_getZoomView()
	local delegate = self._delegate
	local zF = delegate and delegate.getViewForZoom
	local zView
	if zF then zView = zF( delegate, {target=self} ) end
	return zView
end

function ScrollView.__setters:_zoomScale( value )
	-- print( "ScrollView.__setters:_zoomScale", value )
	assert( type(value)=='number' )
	--==--
	if self.__zoomScale==value then return end
	self.__zoomScale = value
	self._axisX.scale = value
	self._axisY.scale = value
	self._zoomScale_dirty=true
	self:__invalidateProperties__()
end


function ScrollView:_removeAxisMotionX()
	-- print( "ScrollView:_removeAxisMotionX" )
	local o = self._axisX
	if not o then return end
	o:removeSelf()
	self._axisX = nil
end

function ScrollView:_createAxisMotionX()
	-- print( "ScrollView:_createAxisMotionX" )
	self:_removeAxisMotionX()
	local o = AxisMotion:new{
		id='x',
		length=self.width,
		scrollLength=self._actualScrollW,
		callback=self._axis_f
	}
	self._axisX = o
end


function ScrollView:_removeAxisMotionY()
	-- print( "ScrollView:_removeAxisMotionY" )
	local o = self._axisY
	if not o then return end
	o:removeSelf()
	self._axisY = nil
end

function ScrollView:_createAxisMotionY()
	-- print( "ScrollView:_createAxisMotionY" )
	self:_removeAxisMotionY()
	local o = AxisMotion:new{
		id='y',
		length=self.height,
		scrollLength=self._actualScrollH,
		callback=self._axis_f
	}
	self._axisY = o
end


function ScrollView:_removeScaleMotion()
	-- print( "ScrollView:_removeScaleMotion" )
	local o = self._scaleMotion
	if not o then return end
	o:removeSelf()
	self._scaleMotion = nil
end

function ScrollView:_createScaleMotion()
	-- print( "ScrollView:_createScaleMotion" )
	self:_removeScaleMotion()
	local o = ScaleMotion:new{
		-- minimumZoom=self._minZoom,
		-- maximumZoom=self._maxZoom,
		callback=self._scale_f
	}
	self._scaleMotion = o
end


function ScrollView:_removeScroller()
	-- print( "ScrollView:_removeScroller", self )
	local o = self._scroller
	if not o then return end
	o:removeSelf()
	self._scroller = nil
end

function ScrollView:_createScroller()
	-- print( "ScrollView:_createScroller" )
	self:_removeScroller()
	local o = Scroller:new{
		width=self._actualScrollW,
		height=self._actualScrollH
	}
	self:_addSubView( o )
	self._scroller = o
end


--== Scroll Indicators

function ScrollView:_removeScrollIndicators()
	-- print( "ScrollView:_removeScrollIndicators" )
	for id, ind in pairs( self._indicators ) do
		if ind.trans then transition.cancel( ind.trans ) end
		ind.view:removeSelf()
	end
	self._indicators = {}
	local dg = self._dgIndicators
	if dg then
		dg:removeSelf()
		self._dgIndicators = nil
	end
end

function ScrollView:_createScrollIndicators()
	-- print( "ScrollView:_createScrollIndicators" )
	self:_removeScrollIndicators()
	local T = ScrollView.INDICATOR_THICKNESS
	local dg = display.newGroup()
	self.view:insert( dg )
	self._dgIndicators = dg

	for _, id in ipairs( { 'x', 'y' } ) do
		local o = display.newRoundedRect( 0, 0, T, T, T*0.5 )
		o.anchorX, o.anchorY = 0, 0
		o.alpha = 0
		dg:insert( o )
		self._indicators[ id ] = { view=o, canShow=false, isShown=false, trans=nil }
	end
end

-- size and place the indicator of an axis ('x', 'y') from the
-- position of the content, and decide if it has anything to show
--
function ScrollView:_updateScrollIndicator( id )
	-- print( "ScrollView:_updateScrollIndicator", id )
	local ind = self._indicators[ id ]
	local axis, show
	if id=='x' then
		axis, show = self._axisX, self._showHorizontalScrollIndicator
	else
		axis, show = self._axisY, self._showVerticalScrollIndicator
	end
	if not ind or not axis then return end

	local T = ScrollView.INDICATOR_THICKNESS
	local M = ScrollView.INDICATOR_MARGIN
	local MIN = ScrollView.INDICATOR_MIN_LENGTH

	local length = axis.length -- of the view
	local content = axis.scaledScrollLength
	-- the track: the view less its margins, and less the offsets
	-- (eg, what a navigation bar covers)
	local upper = mmax( 0, axis.upperOffset )
	local lower = mmax( 0, axis.lowerOffset )
	local track = length - upper - lower - 2*M

	local canShow = ( show and axis.scrollIsEnabled and content > length and track >= MIN )
	ind.canShow = canShow
	if not canShow then
		self:_hideScrollIndicator( id, 0, true )
		return
	end

	local bar = mmax( MIN, track * length/content )
	local value = axis.value
	local top = axis.upperOffset -- limits of 'value'
	local bottom = ( length - content ) - axis.lowerOffset
	local pos

	if value > top then
		-- pulled past the start: the bar is squeezed against it
		bar = mmax( T*2, bar - ( value - top ) )
		pos = 0
	elseif value < bottom then
		bar = mmax( T*2, bar - ( bottom - value ) )
		pos = track - bar
	else
		local range = top - bottom
		pos = ( range > 0 ) and ( top - value )/range * ( track - bar ) or 0
	end
	pos = upper + M + pos

	local o = ind.view
	if id=='x' then
		o.path.width = bar
		o.x, o.y = pos, self.height - T - M
	else
		o.path.height = bar
		o.x, o.y = self.width - T - M, pos
	end
end

function ScrollView:_showScrollIndicator( id )
	local ind = self._indicators[ id ]
	if not ind or not ind.canShow then return end
	if ind.trans then
		transition.cancel( ind.trans )
		ind.trans = nil
	end
	ind.view.alpha = 1
	ind.isShown = true
end

-- fade an indicator out after 'delay', or hide it at once ('now')
--
function ScrollView:_hideScrollIndicator( id, delay, now )
	local ind = self._indicators[ id ]
	if not ind then return end
	if now then
		-- also one which is fading
		if ind.trans then
			transition.cancel( ind.trans )
			ind.trans = nil
		end
		ind.isShown = false
		ind.view.alpha = 0
		return
	end
	if not ind.isShown then return end
	ind.isShown = false
	if ind.trans then
		transition.cancel( ind.trans )
		ind.trans = nil
	end
	ind.trans = transition.to( ind.view, {
		alpha=0,
		delay=delay or ScrollView.INDICATOR_FADE_DELAY,
		time=ScrollView.INDICATOR_FADE_TIME,
		onComplete=function() ind.trans = nil end
	})
end

-- an axis moved, or stopped: its indicator follows.
-- called with the events of the Axis Motion objects
--
function ScrollView:_scrollIndicatorEvent( event )
	local id = event.id
	self:_updateScrollIndicator( id )
	if event.state==AxisMotion.SCROLLING then
		self:_showScrollIndicator( id )
	else
		self:_hideScrollIndicator( id )
	end
end


-- the scroll limit the content is at or past on an axis, if any
-- (none when the axis is off or its content fits)
--
function ScrollView:_scrollLimitFor( id )
	local axis, upperLimit, lowerLimit
	if id=='x' then
		axis = self._axisX
		upperLimit, lowerLimit = ScrollView.HIT_LEFT_LIMIT, ScrollView.HIT_RIGHT_LIMIT
	else
		axis = self._axisY
		upperLimit, lowerLimit = ScrollView.HIT_TOP_LIMIT, ScrollView.HIT_BOTTOM_LIMIT
	end
	local length, scrollLength = axis.length, axis.scaledScrollLength
	if not axis.scrollIsEnabled or scrollLength<=length then return nil end

	local value = axis.value
	if value >= axis.upperOffset then
		return upperLimit
	elseif value <= (length-scrollLength) - axis.lowerOffset then
		return lowerLimit
	end
	return nil
end


-- tell the delegate about scrolling, from the events of the axes:
-- willBeginScrolling, didScroll (for each move), didEndScrolling
-- once every axis is at rest
--
function ScrollView:_scrollDelegateEvent( event )
	local delegate = self._delegate
	local scrolling = self._scrollingAxes
	local id = event.id
	local isScrolling = ( event.state==AxisMotion.SCROLLING )
	local wasAtRest = not ( scrolling.x or scrolling.y )

	scrolling[ id ] = isScrolling
	if not delegate then return end

	local f
	local e = {
		target=self,
		x=self._axisX.value,
		y=self._axisY.value,
		horizontalLimit=self:_scrollLimitFor( 'x' ),
		verticalLimit=self:_scrollLimitFor( 'y' ),
	}

	if wasAtRest then
		f = delegate.willBeginScrolling
		if f then f( delegate, e ) end
	end

	f = delegate.didScroll
	if f then f( delegate, e ) end

	if not ( scrolling.x or scrolling.y ) then
		f = delegate.didEndScrolling
		if f then f( delegate, e ) end
	end
end


function ScrollView:_loadViews()
	self:_createScroller()
end

function ScrollView:_unloadViews()
	self:_removeScroller()
end


function ScrollView:__commitProperties__()
	-- print( 'ScrollView:__commitProperties__' )
	local style = self.curr_style

	local view = self.view
	local bg = self._rectBg
	local scr = self._scroller

	--== position sensitive

	-- set text string

	if self._text_dirty then
		self._text_dirty=false

		self._width_dirty=true
		self._height_dirty=true
	end

	if self._zoomScale_dirty then
		self._zoomScale_dirty = false

		self._actualScrollW_dirty=true
		self._actualScrollH_dirty=true
	end

	if self._align_dirty then
		self._align_dirty = false
	end

	if self._width_dirty then
		local width = self.width
		bg.width = width
		if self._autoMask then view.width = width end
		self._axisX.length = width
		-- scroll area is never smaller than the view
		if self._scrollWidth < width then
			self._scrollWidth = width
			self._scrollWidth_dirty=true
		end
		self:_calculateMinScale()
		self._width_dirty=false
	end
	if self._height_dirty then
		local height = self.height
		bg.height = height
		if self._autoMask then view.height = height end
		self._axisY.length = height
		if self._scrollHeight < height then
			self._scrollHeight = height
			self._scrollHeight_dirty=true
		end
		self:_calculateMinScale()
		self._height_dirty=false
	end



	if self._scrollWidth_dirty then
		self._axisX.scrollLength = self._scrollWidth
		self._scrollWidth_dirty=false

		self._actualScrollW_dirty=true
	end
	if self._scrollHeight_dirty then
		self._axisY.scrollLength = self._scrollHeight
		self._scrollHeight_dirty=false

		self._actualScrollH_dirty=true
	end

	if self._actualScrollW_dirty then
		local value = self._axisX.scaledScrollLength
		self._actualScrollW = value
		scr.width = value
		self._actualScrollW_dirty=false
	end
	if self._actualScrollH_dirty then
		local value = self._axisY.scaledScrollLength
		self._actualScrollH = value
		scr.height = value
		self._actualScrollH_dirty=false
	end


	if self._marginX_dirty then
		self._marginX_dirty=false

		self._rectBgWidth_dirty=true
		self._textX_dirty=true
		self._displayWidth_dirty=true
	end
	if self._marginY_dirty then
		-- reminder, we don't set text height
		self._marginY_dirty=false

		self._rectBgHeight_dirty=true
		self._textY_dirty=true
		self._displayHeight_dirty=true
	end

	-- bg width/height

	if self._rectBgWidth_dirty then
		self._rectBgWidth_dirty=false
	end
	if self._rectBgHeight_dirty then
		self._rectBgHeight_dirty=false
	end


	-- anchorX/anchorY

	if self._anchorX_dirty then
		-- bg.anchorX = style.anchorX
		self._anchorX_dirty=false

		self._x_dirty=true
		self._textX_dirty=true
	end
	if self._anchorY_dirty then
		-- bg.anchorY = style.anchorY
		self._anchorY_dirty=false

		self._y_dirty=true
		self._textY_dirty=true
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

	-- if self._contentPosition_dirty then
	-- 	scr.x = self._contentPosition.x
	-- 	scr.y = self._contentPosition.y
	-- 	self._contentPosition_dirty=false
	-- end

	--== non-position sensitive

	-- textColor/fillColor

	if self._fillColor_dirty or self._debugOn_dirty then
		local debug = style.debugOn
		if debug==true then
			bg:setFillColor( 1,0,0,0.2 )
		else
			bg:setFillColor( unpack( style.fillColor ))
		end
		scr.debugOn = debug
		self._fillColor_dirty=false
		self._debugOn_dirty=false
	end
	if self._strokeColor_dirty then
		-- bg:setStrokeColor( unpack( style.strokeColor ))
		self._strokeColor_dirty=false
	end
	if self._strokeWidth_dirty then
		-- bg.strokeWidth = style.strokeWidth
		self._strokeWidth_dirty=false
	end
	if self._textColor_dirty then
		-- display:setScrollViewColor( unpack( style.textColor ) )
		self._textColor_dirty=false
	end

	--== scroll indicators

	if self._indicatorColor_dirty then
		local color = style.indicatorColor or ScrollView.INDICATOR_COLOR
		for _, ind in pairs( self._indicators ) do
			ind.view:setFillColor( unpack( color ) )
		end
		self._indicatorColor_dirty=false
	end
	-- sizes, scale or scroll area may have changed
	self:_updateScrollIndicator( 'x' )
	self:_updateScrollIndicator( 'y' )

end



--====================================================================--
--== Event Handlers


function ScrollView:stylePropertyChangeHandler( event )
	-- print( "ScrollView:stylePropertyChangeHandler", event.type, event.property )
	local style = event.target
	local etype= event.type
	local property= event.property
	local value = event.value

	-- print( "Style Changed", self, etype, property, value )

	if etype==style.STYLE_RESET then
		self._debugOn_dirty = true
		self._width_dirty=true
		self._height_dirty=true
		self._anchorX_dirty=true
		self._anchorY_dirty=true

		self._align_dirty=true
		self._fillColor_dirty = true
		self._indicatorColor_dirty = true
		self._font_dirty=true
		self._fontSize_dirty=true
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
		elseif property=='indicatorColor' then
			self._indicatorColor_dirty=true
		elseif property=='font' then
			self._font_dirty=true
		elseif property=='fontSize' then
			self._fontSize_dirty=true
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


-- take output from gesture recognizers and put into
-- motion controllers
--
function ScrollView:_gestureEvent_handler( event )
	-- print( "ScrollView:_gestureEvent_handler", event.phase )
	local etype = event.type
	local phase = event.phase
	local gesture = event.target
	local f = self._returnFocusCancel

	-- print( "ScrollView:_gestureEvent_handler", phase, gesture._id )

	-- Utils.print( event )
	local evt = {
		name='touch',
		phase='tbd',
		time=event.time,
		value=0, -- this is holder for x/y
		start=0, -- this is holder for xStart/yStart
	}

	if etype == gesture.GESTURE then
		if phase=='began' then
			evt.phase = 'began' -- convert Gesture to Motion

			if self._axisX then
				evt.value = event.x
				evt.start = event.xStart
				self._axisX:touch( evt )
			end
			if self._axisY then
				evt.value = event.y
				evt.start = event.yStart
				self._axisY:touch( evt )
			end

			if event.gesture=='pinch' and self._canZoom then
				local zView = self:_getZoomView()
				if zView then
					evt.value = event.scale
					evt.start = event.start
					self._zoomView = zView
					self._scaleMotion:touch( evt )
				end
			end


		elseif phase=='changed' then
			-- if changed, then already know movement was enough
			-- because Pan Gesture will filter movement
			f = self._returnFocusCancel
			if f then f() end
			evt.phase = 'moved' -- convert Gesture to Motion

			if self._axisX then
				evt.value = event.x
				evt.start = event.xStart
				self._axisX:touch( evt )
			end
			if self._axisY then
				evt.value = event.y
				evt.start = event.yStart
				self._axisY:touch( evt )
			end

			if event.gesture=='pinch' and self._zoomView then
				evt.value = event.scale
				evt.start = event.start
				self._scaleMotion:touch( evt )
			end


		else
			evt.phase = 'ended' -- convert Gesture to Motion

			if self._axisX then
				evt.value = event.x
				evt.start = event.xStart
				self._axisX:touch( evt )
			end
			if self._axisY then
				evt.value = event.y
				evt.start = event.yStart
				self._axisY:touch( evt )
			end

			if event.gesture=='pinch' and self._zoomView then
				evt.value = event.scale
				evt.start = event.start
				self._scaleMotion:touch( evt )
			end

			-- if ended (quickly), like a tap
			-- then give back to the initiator
			f = self._returnFocus
			if f then f( 'ended' ) end

		end
	end
end


-- handle events from Axis Motion objects
--
function ScrollView:_axisEvent_handler( event )
	-- print( "ScrollView:_axisEvent_handler", event.state )
	if event.id=='x' then
		self._scroller.x = event.value -- *self.__zoomScale
	else
		self._scroller.y = event.value -- *self.__zoomScale
	end
	self:_scrollIndicatorEvent( event )
	self:_scrollDelegateEvent( event )
end


-- handle events from Scale Motion object
--
function ScrollView:_scaleEvent_handler( event )
	-- print( "ScrollView:_scaleEvent_handler", event.state )
	local delegate = self._delegate
	local scale = event.scale
	local state = event.state
	local target = event.target
	local zView = self._zoomView
	local zF

	self._zoomScale = scale -- setter

	if state==target.WILL_ZOOM then
		zView.xScale, zView.yScale = scale, scale
		zF = delegate and delegate.willBeginZooming
		if zF then zF( delegate, {target=self,view=zView,scale=scale} ) end

	elseif state==target.ZOOMING then
		zView.xScale, zView.yScale = scale, scale
		zF = delegate and delegate.didZoom
		if zF then zF( delegate, {target=self,view=zView,scale=scale} ) end

	elseif state==target.DID_ZOOM then
		zView.xScale, zView.yScale = scale, scale
		zF = delegate and delegate.didEndZooming
		if zF then zF( delegate, {target=self,view=zView,scale=scale} ) end
		self._zoomView = nil

	end

end




return ScrollView
