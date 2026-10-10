--====================================================================--
-- dmc_ui/ui_constants.lua
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
--== DMC Corona UI : UI Consstants
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Corona UI : Module Constants
--====================================================================--



--====================================================================--
--== Setup, Constants


local PLATFORM = system.getInfo( 'platformName' )
local MODEL = system.getInfo( 'model' )



--====================================================================--
--== Constants
--====================================================================--


local Constant = {}



--====================================================================--
--== Module


Constant.RUN_MODE = 'run'
Constant.TEST_MODE = 'test'

Constant.PLATFORM = PLATFORM
Constant.MODEL = MODEL


--====================================================================--
--== Platform & OS


Constant.ANDROID = 'Android'
Constant.ANDROID_20 = "2.0.0"
Constant.ANDROID_21 = "2.1.0"

Constant.IOS = 'iOS'
Constant.IOS_7x = "7.0.0"
Constant.IOS_8x = "8.0.0"

Constant.WINDOWS = 'WinPhone'

Constant.IS_IOS = ( PLATFORM=='iPhone OS' or PLATFORM=='Mac OS X' )
Constant.IS_ANDROID = ( PLATFORM=='Android' )
Constant.IS_WINDOWS = ( PLATFORM=='WinPhone' or PLATFORM=='Win' )
Constant.IS_SIMULATOR = ( PLATFORM=='Mac OS X' or PLATFORM=='Win' )

Constant.ANDROID_KEYBOARD = 80
Constant.IOS_KEYBOARD = 80

function Constant.getKeyboardHeight()
	if Constant.IS_IOS then
		return Constant.IOS_KEYBOARD
	else
		return Constant.ANDROID_KEYBOARD
	end
end

function Constant.getSystemSeparator()
	if Constant.IS_WINDOWS then
		return '\\'
	else
		return '/'
	end
end



--====================================================================--
--== Views


Constant.VIEW_LAYOUT_MARGINS = {top=8,left=8,bottom=8,right=8}



--====================================================================--
--== Widgets & Styles


Constant.BACKGROUND = 'Background'
Constant.BUTTON = 'Button'
Constant.BUTTON_STATE = 'Button-State'
Constant.NAVITEM = 'NavItem'
Constant.NAVBAR = 'NavBar'
Constant.PAGEINDICATOR = 'PageIndicator'
Constant.SCROLLVIEW = 'ScrollView'
Constant.TABLEVIEW = 'TableView'
Constant.TABLEVIEWCELL = 'TableViewCell'
Constant.TABLEVIEWCELL_STATE = 'TableViewCell-State'
Constant.TEXT = 'Text'
Constant.TEXTFIELD = 'TextField'


--======================================================--
-- Background Widget

Constant.IMAGE = 'image'
Constant.NINE_SLICE = '9-slice'
Constant.RECTANGLE = 'rectangle'
Constant.ROUNDED = 'rounded'

Constant.DEFAULT_BACKGROUND_TYPE = Constant.ROUNDED


--======================================================--
-- ScrollView Widget

Constant.SCROLLVIEW_DECELERATE_TIME = 200

-- Axis Motion

Constant.AXIS_DECELERATE_TIME = 200
Constant.AXIS_RESTORE_TIME = 400
Constant.AXIS_RESTRAINT_TIME = 400
Constant.AXIS_SCROLLTO_TIME = 500

Constant.AXIS_VELOCITY_STACK_LENGTH = 4
Constant.AXIS_VELOCITY_LIMIT = 1
-- paging: from this speed (pixels per millisecond) a touch ends as a flick
Constant.AXIS_PAGE_FLICK_VELOCITY = 0.15


--======================================================--
-- SlideView Widget

Constant.SLIDEVIEW_TRANSITION_TIME = 400


--======================================================--
-- TableView Widget

Constant.TABLEVIEW_DECELERATE_TIME = 2000


--======================================================--
-- TableViewCell Widget

Constant.TABLEVIEWCELL_DEFAULT_LAYOUT = 'default-layout'
Constant.TABLEVIEWCELL_SUBTITLE_LAYOUT = 'subtitle-layout'

Constant.TABLEVIEWCELL_CHECKMARK = 'checkmark-accessory'
Constant.TABLEVIEWCELL_DETAIL_BUTTON = 'detail-button-accessory'
Constant.TABLEVIEWCELL_DISCLOSURE_INDICATOR = 'disclosure-indicator-accessory'
Constant.TABLEVIEWCELL_NONE = 'no-accessory'



--====================================================================--
--== Controls


-- Transition Times

Constant.NAVBAR_TRANSITION_TIME = 400
Constant.PRESENT_CONTROL_TRANSITION_TIME = 100
Constant.PRESENT_CONTROL_SLIDE_TIME = 300

Constant.TABLEVIEW_TOUCH_THRESHOLD = 10

-- Modal Types

Constant.MODAL = 'modal'
Constant.POPOVER = 'popover'
Constant.POPOVER_PREFERRED_SIZE = {width=320,height=600}
Constant.POPOVER_DIM_COLOR = { 0, 0, 0, 0.2 }

-- Popover Arrow Directions, the way the arrow points

Constant.ARROW_UP = 'up'
Constant.ARROW_DOWN = 'down'
Constant.ARROW_LEFT = 'left'
Constant.ARROW_RIGHT = 'right'
Constant.ARROW_ANY = 'all'

-- Modal Transitions

Constant.SLIDE_UP = 'slide-up'
Constant.FADE = 'fade'
Constant.NO_TRANSITION = 'no-transition'

Constant.PRESENT_CONTROL_DIM_COLOR = { 0, 0, 0, 0.4 }
Constant.PRESENT_CONTROL_PANEL_COLOR = { 1, 1, 1, 1 }




return Constant
