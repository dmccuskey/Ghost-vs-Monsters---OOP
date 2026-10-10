--====================================================================--
-- dmc_widget/widget_text.lua
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
--== DMC Corona UI : TableViewCell Widget
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find
local ui_file = dmc_ui_func.file



--====================================================================--
--== DMC UI : newTableViewCell
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'

local uiConst = require( ui_find( 'ui_constants' ) )

local WidgetBase = require( ui_find( 'core.widget' ) )



--====================================================================--
--== Setup, Constants


local newImageRect = display.newImageRect

-- these are set later
local dUI = nil
local Widget = nil
local FontMgr = nil



--====================================================================--
--== TableViewCell Widget Class
--====================================================================--


--- TableViewCell Widget.
-- a widget to be used as the view in a TableView row.
--
-- **Inherits from:** <br>
-- * @{Core.Widget}
--
-- **Style Object:** <br>
-- * @{Style.TableViewCell}
--
-- @classmod Widget.TableViewCell
-- @usage
-- dUI = require 'dmc_ui'
-- widget = dUI.newTableViewCell()

local TableViewCell = newClass( WidgetBase, { name="TableViewCell" } )

--- Class Constants.
-- @section

--== Class Constants

TableViewCell.LEFT = 'left'
TableViewCell.CENTER = 'center'
TableViewCell.RIGHT = 'right'


--== tableviewcell layouts

--- Layout Constant to specify the Default layout.
-- single row of text. this is usually defined in the @{Style.TableViewCell}.
--
-- @field HELLO
--
-- @usage
-- widget.cellLayout = TableViewCell.DEFAULT

TableViewCell.DEFAULT = uiConst.TABLEVIEWCELL_DEFAULT_LAYOUT

--- Layout Constant to specify the Subtitle layout.
-- layout with two rows of text – Label and Detail. this is usually defined in the .
--
-- @field HELLO
--
-- @usage
-- widget.cellLayout = TableViewCell.SUBTITLE

TableViewCell.SUBTITLE = uiConst.TABLEVIEWCELL_SUBTITLE_LAYOUT

--== tableviewcell accessories

--- Accessory Constant to specify the Checkmark accessory.
-- this is usually defined in the @{Style.TableViewCell}.
--
-- @usage
-- widget.accessory = TableViewCell.CHECKMARK

TableViewCell.CHECKMARK = uiConst.TABLEVIEWCELL_CHECKMARK

--- Accessory Constant to specify the Detail Button accessory.
-- this is usually defined in the @{Style.TableViewCell}.
--
-- @usage
-- widget.accessory = TableViewCell.DETAIL_BUTTON

TableViewCell.DETAIL_BUTTON = uiConst.TABLEVIEWCELL_DETAIL_BUTTON

--- Accessory Constant to specify the Disclosure Indicator accessory.
-- this is usually defined in the @{Style.TableViewCell}.
--
-- @usage
-- widget.accessory = TableViewCell.DISCLOSURE_INDICATOR

TableViewCell.DISCLOSURE_INDICATOR = uiConst.TABLEVIEWCELL_DISCLOSURE_INDICATOR

--- Accessory Constant to specify the no accessory.
-- this is usually defined in the @{Style.TableViewCell}.
--
-- @usage
-- widget.accessory = TableViewCell.NONE

TableViewCell.NONE = uiConst.TABLEVIEWCELL_NONE


TableViewCell.ACCESSORY = {
	[ TableViewCell.CHECKMARK ] = {
		w=114, h=128,
		file=ui_file('dmc_widget/assets/tableviewcell/accessory-checkmark.png' ),
	},
	[ TableViewCell.DETAIL_BUTTON ] = {
		w=108, h=128,
		file=ui_file('dmc_widget/assets/tableviewcell/accessory-detail-button.png' ),
	},
	[ TableViewCell.DISCLOSURE_INDICATOR ] = {
		w=70, h=128,
		file=ui_file('dmc_widget/assets/tableviewcell/accessory-disclose-indicator.png' )
	}
}

--== Style/Theme Constants

TableViewCell.STYLE_CLASS = nil -- added later
TableViewCell.STYLE_TYPE = uiConst.TABLEVIEWCELL

-- TODO: hook up later
-- TableViewCell.DEFAULT = 'default'

-- TableViewCell.THEME_STATES = {
-- 	TableViewCell.DEFAULT,
-- }

--== Event Constants

TableViewCell.EVENT = 'tableviewcell-widget-event'


--======================================================--
-- Start: Setup DMC Objects

--== Init

function TableViewCell:__init__( params )
	-- print( "TableViewCell:__init__", params )
	params = params or {}
	if params.labelText==nil then params.labelText="" end
	if params.detailText==nil then params.detailText="" end

	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	-- properties in this class

	-- save params for later
	self._tvc_tmp_params = params -- tmp

	self._textLabel = params.labelText
	self._textLabel_dirty=true
	self._textDetail = params.detailText
	self._textDetail_dirty=true

	self._activeStateStyle = nil

	self._accessoryObject = nil
	self._highlightIsActive = false
	self._highlightIsActive_dirty=true

	-- properties from style

	self._cellMargin_dirty=true

	self._detailY_dirty=true
	self._labelY_dirty=true

	self._cellAccessory_dirty=true
	self._cellLayout_dirty = true
	self._contentMargin_dirty=true

	-- virtual

	self._accessoryX_dirty=true
	self._imageView_dirty=true
	self._imageViewX_dirty=true

	self._textLabelX_dirty=true
	self._textLabelY_dirty=true
	self._textLabelWidth_dirty=true

	self._textDetailX_dirty=true
	self._textDetailY_dirty=true
	self._textDetailWidth_dirty=true

	self._widgetStyle_dirty=true
	self._wgtBgStyle_dirty=true

	--== Object References ==--

	self._wgtTextLabel = nil -- text widget (for both hint and value display)
	self._wgtTextLabel_f = nil -- widget handler
	self._wgtTextLabel_dirty=true

	self._wgtTextDetail = nil -- text widget (for both hint and value display)
	self._wgtTextDetail_f = nil -- widget handler
	self._wgtTextDetail_dirty=true

	-- @TODO: add background object

	self._wgtBg = nil -- background widget
	self._wgtBg_dirty=true

end

--[[
function TableViewCell:__undoInit__()
	-- print( "TableViewCell:__undoInit__" )
	--==--
	self:superCall( '__undoInit__' )
end
--]]


--== createView

--[[
function TableViewCell:__createView__()
	-- print( "TableViewCell:__createView__" )
	self:superCall( '__createView__' )
	--==--
end

function TableViewCell:__undoCreateView__()
	-- print( "TableViewCell:__undoCreateView__" )
	--==--
	self:superCall( '__undoCreateView__' )
end
--]]


--== initComplete

function TableViewCell:__initComplete__()
	-- print( "TableViewCell:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	local tmp = self._tvc_tmp_params

	self:_createTextLabel()
	self:_createTextDetail()

	self:setAnchor( self.TopLeftReferencePoint )

	--== Use Setters
	if tmp.width~=nil then self.width = tmp.width end
	if tmp.height~=nil then self.height = tmp.height end
	self._wgtTextLabel.text = self._textLabel
	self._wgtTextDetail.text = self._textDetail

	self._tvc_tmp_params = nil
end

function TableViewCell:__undoInitComplete__()
	-- print( "TableViewCell:__undoInitComplete__" )
	self:_removeTextLabel()
	self:_removeTextDetail()
	self:_removeBackground()
	self:_removeAccessory()
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function TableViewCell.initialize( manager )
	-- print( "TableViewCell.initialize" )
	dUI = manager
	Widget = dUI.Widget

	FontMgr = dUI.FontMgr

	local Style = dUI.Style
	TableViewCell.STYLE_CLASS = Style.TableViewCell

	Style.registerWidget( TableViewCell )
end



--====================================================================--
--== Public Methods


--- set/get the accessory for the TableViewCell.
-- this is just a convience property to the style object.
--
-- @within Properties
-- @function .accessory
--
-- @usage widget.accessory = TableViewCell.DISCLOSURE_INDICATOR
-- @usage print( widget.accessory )

function TableViewCell.__getters:accessory()
	return self.curr_style.accessory
end
function TableViewCell.__setters:accessory( value )
	self.curr_style.accessory = value
end


--- set/get the layout for the TableViewCell.
-- this is just a convience property to the style object.
--
-- @within Properties
-- @function .cellLayout
--
-- @usage widget.cellLayout = TableViewCell.SUBTITLE
-- @usage print( widget.cellLayout )

function TableViewCell.__getters:cellLayout()
	return self.curr_style.cellLayout
end
function TableViewCell.__setters:cellLayout( value )
	self.curr_style.cellLayout = value
end


--- set/get the horizontal margin of the TableViewCell.
-- this sets both the left and right side.
-- this is just a convience property to the style object.
--
-- @within Properties
-- @function .cellMargin
--
-- @usage widget.cellMargin=10
-- @usage print( widget.cellMargin )

function TableViewCell.__getters:cellMargin()
	return self.curr_style.cellMargin
end
function TableViewCell.__setters:cellMargin( value )
	self.curr_style.cellMargin = value
end


--- set/get the horizontal margin between the content.
-- this is just a convience property to the style object.
--
-- @within Properties
-- @function .contentMargin
--
-- @usage widget.contentMargin=10
-- @usage print( widget.contentMargin )

function TableViewCell.__getters:contentMargin()
	return self.curr_style.contentMargin
end
function TableViewCell.__setters:contentMargin( value )
	self.curr_style.contentMargin = value
end


--- set/get active highlight.
-- specify whether row is highlighted or not. requires `boolean`.
--
-- @within Properties
-- @function .highlight
--
-- @usage widget.highlight = true
-- @usage print( widget.highlight )

function TableViewCell.__getters:highlight()
	return self._highlightIsActive
end
function TableViewCell.__setters:highlight( value )
	-- print( "TableViewCell.__setters:highlight", value )
	assert( type(value)=='boolean' )
	--==--
	if self._highlightIsActive == value then return end
	self._highlightIsActive = value
	self._highlightIsActive_dirty=true
	self:__invalidateProperties__()
end


--- set the Image View on the TableViewCell object.
-- this is a Corona Image. it is the developers responsibility to size the image, recommended to fit within 26x26. Can be any width. The TableViewCell will position the image, ensure proper anchor points.
--
-- @within Properties
-- @function .imageView
--
-- @usage widget.imageView = display.newImageRect( 'image.jpg', 26, 26 )

function TableViewCell.__getters:imageView()
	return self._imageView
end
function TableViewCell.__setters:imageView( value )
	self._imageView = value
	if value then value.isVisible=false end
	self._imageView_dirty=true
	self:__invalidateProperties__()
end


--- get a reference to the Text Label object.
-- this is a @{Widget.Text} object.
--
-- @within Properties
-- @function .textLabel
--
-- @usage print( widget.textLabel )

function TableViewCell.__getters:textLabel()
	return self._wgtTextLabel
end


--- get a reference to the Text Detail object.
-- this is a @{Widget.Text} object. the Text Detail is only visible with the SUBTITLE layout.
--
-- @within Properties
-- @function .textDetail
--
-- @usage print( widget.textDetail )

function TableViewCell.__getters:textDetail()
	return self._wgtTextDetail
end



--======================================================--
-- Theme Methods

-- afterAddStyle()
--
function TableViewCell:afterAddStyle()
	-- print( "TableViewCell:afterAddStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end

-- beforeRemoveStyle()
--
function TableViewCell:beforeRemoveStyle()
	-- print( "TableViewCell:beforeRemoveStyle", self )
	self._widgetStyle_dirty=true
	self:__invalidateProperties__()
end






--====================================================================--
--== Private Methods



function TableViewCell:_removeAccessory()
	-- print( "TableViewCell:_removeAccessory" )
	local o = self._accessoryObject
	if not o then return end
	o:removeSelf()
	self._accessoryObject = nil
end

function TableViewCell:_loadAccessory( name )
	-- print( "TableViewCell:_loadAccessory", name )
	self:_removeAccessory()
	local tbl = TableViewCell.ACCESSORY
	local info = tbl[ name ]
	local scale = 20/info.h
	return newImageRect( info.file, info.w*scale, info.h*scale )
end


--== Create/Destroy Background Widget

function TableViewCell:_removeBackground()
	-- print( "TableViewCell:_removeBackground" )
	local o = self._wgtBg
	if not o then return end
	o:removeSelf()
	self._wgtBg = nil
end

function TableViewCell:_createBackground()
	-- print( "TableViewCell:_createBackground" )

	self:_removeBackground()

	local o = Widget.newBackground{
		defaultStyle = self.defaultStyle.background
	}
	self._dgBg:insert( o.view )
	self._wgtBg = o

	--== Reset properties

	self._wgtBgStyle_dirty=true
end



function TableViewCell:_removeTextDetail()
	-- print( "TableViewCell:_removeTextDetail" )
	local o = self._wgtTextDetail
	if not o then return end
	o:removeSelf()
	self._wgtTextDetail = nil
end

function TableViewCell:_createTextDetail()
	-- print( "TableViewCell:_createTextDetail" )
	local style = self.curr_style
	local o -- object

	self:_removeTextDetail()

	o = Widget.newText{
		defaultStyle = self.defaultStyle.label
	}
	o:setAnchor( o.CenterLeftReferencePoint )
	self:insert( o.view )
	self._wgtTextDetail = o

	--== Reset properties

	self._textDetailX_dirty=true
	self._textDetailWidth_dirty=true

	self._textColor_dirty=true
end


function TableViewCell:_removeTextLabel()
	-- print( "TableViewCell:_removeTextLabel" )
	local o = self._wgtTextLabel
	if not o then return end
	o:removeSelf()
	self._wgtTextLabel = nil
end

function TableViewCell:_createTextLabel()
	-- print( "TableViewCell:_createTextLabel" )
	local style = self.curr_style
	local o -- object

	self:_removeTextLabel()

	o = Widget.newText{
		defaultStyle = self.defaultStyle.label
	}
	o:setAnchor( o.TopLeftReferencePoint )
	self:insert( o.view )
	self._wgtTextLabel = o

	--== Reset properties

	self._textLabelX_dirty=true
	self._textLabelWidth_dirty=true

	self._textColor_dirty=true
end



function TableViewCell:__commitProperties__()
	-- print( 'TableViewCell:__commitProperties__' )

	--== Update Widget Components ==--

	if self._wgtBg_dirty then
		self:_createBackground()
		self._wgtBg_dirty = false
	end


	local view = self.view
	local bg = self._wgtBg
	local imageView = self._imageView
	local textLabel = self._wgtTextLabel
	local textDetail = self._wgtTextDetail

	local height = self.height
	local width = self.width

	--== position sensitive

	if self._highlightIsActive_dirty then
		local cellStyle = self.curr_style
		local style
		if self._highlightIsActive then
			style=cellStyle.active
		else
			style=cellStyle.inactive
		end
		textLabel:setActiveStyle( style.label, {copy=false} )
		textDetail:setActiveStyle( style.detail, {copy=false} )
		bg:setActiveStyle( style.background, {copy=false} )
		self._activeStateStyle = style
		self._highlightIsActive_dirty=false

		self._cellAccessory_dirty=true
		self._textLabelX_dirty=true
		self._textLabelY_dirty=true
		self._textLabelWidth_dirty=true
		self._textDetailX_dirty=true
		self._textDetailY_dirty=true
		self._textDetailWidth_dirty=true
	end

	local style = self._activeStateStyle
	local contentMargin = style.contentMargin
	local cellLayout = style.cellLayout
	local cellMargin = style.cellMargin

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
		self._width_dirty=false

		self._rectBgWidth_dirty=true
		self._textLabelWidth_dirty=true
		self._textDetailWidth_dirty=true
	end
	if self._height_dirty then
		self._height_dirty=false

		self._anchorY_dirty=true
		self._rectBgHeight_dirty=true
	end

	-- anchorX/anchorY

	if self._anchorX_dirty then
		-- bg.anchorX = style.anchorX
		self._anchorX_dirty=false

		self._x_dirty=true
		self._textLabelX_dirty=true
	end
	if self._anchorY_dirty then
		-- bg.anchorY = style.anchorY
		self._anchorY_dirty=false

		self._y_dirty=true
		self._textLabelY_dirty=true
	end

	-- Virtual

	if self._widgetStyle_dirty then
		self._widgetStyle_dirty=false

		self._wgtBgStyle_dirty=true
	end

	if self._cellMargin_dirty then
		self._cellMargin_dirty=false

		self._textLabelX_dirty=true
		self._textLabelWidth_dirty=true
		self._textDetailX_dirty=true
		self._textDetailWidth_dirty=true
	end

	if self._imageView_dirty then
		self._imageView_dirty=false

		self._imageViewX_dirty=true
		self._textLabelX_dirty=true
		self._textDetailX_dirty=true
	end

	if self._contentMargin_dirty then
		self._contentMargin_dirty=false

		self._imageViewX_dirty=true
		self._textLabelX_dirty=true
		self._textDetailX_dirty=true
		self._accessoryX_dirty=true
	end

	--== Set Styles

	if self._wgtBgStyle_dirty then
		-- bg:setActiveStyle( style.inactive.background, {copy=false} )
		self._wgtBgStyle_dirty=false
	end


	-- bg width/height

	if self._rectBgWidth_dirty then
		self._rectBgWidth_dirty=false
	end
	if self._rectBgHeight_dirty then
		self._rectBgHeight_dirty=false
	end

	-- accessory / accessoryX

	if self._cellAccessory_dirty then
		local accessory = style.accessory
		local accessObj

		if type(accessory)=='string' then
			if accessory==TableViewCell.CHECKMARK then
				accessObj = self:_loadAccessory( accessory )
			elseif accessory==TableViewCell.DETAIL_BUTTON then
				accessObj = self:_loadAccessory( accessory )
			elseif accessory==TableViewCell.DISCLOSURE_INDICATOR then
				accessObj = self:_loadAccessory( accessory )
			else
				accessObj=self:_removeAccessory()
			end
		else
			-- @TODO, allow other accessory objects
			accessObj = accessory
		end
		if accessObj then
			self.view:insert( accessObj )
			self._accessoryX_dirty=true
		end
		self._accessoryObject = accessObj
		self._cellAccessory_dirty=false

		self._textLabelWidth_dirty=true
		self._textDetailWidth_dirty=true
	end

	if self._accessoryX_dirty and self._accessoryObject then
		local accessObj = self._accessoryObject
		accessObj.anchorX, accessObj.anchorY = 1, 0.5
		accessObj.x, accessObj.y = width-cellMargin, height*0.5
		self._accessoryX_dirty=false
	end

	-- imageViewX

	if self._imageViewX_dirty and imageView then
		local height = self.height -- use getter
		local offset = height/2
		imageView.x = cellMargin
		imageView.y = offset
		self._dgViews:insert( imageView )
		imageView.isVisible=true
		imageView.anchorX, imageView.anchorY = 0, 0.5
		self._imageViewX_dirty=false
	end

	-- textLabel/textDetail X/Width

	if self._textLabelX_dirty or self._textDetailX_dirty then
		local margin = cellMargin
		if imageView then
			margin = margin + imageView.width
		end
		margin = margin + contentMargin

		textLabel.x = margin
		textDetail.x = margin
		self._textDetailX_dirty=false
		self._textLabelX_dirty=false
	end

	if self._textLabelWidth_dirty or self._textDetailWidth_dirty then
		local accessObj = self._accessoryObject
		local margin = 2*cellMargin + 2*contentMargin
		if accessObj then
			margin = margin + accessObj.width
		end
		if imageView then
			margin = margin + imageView.width
		end
		textLabel.width = width-margin
		textDetail.width = width-margin
		self._textDetailWidth_dirty=false
		self._textLabelWidth_dirty=false
	end

	if self._cellLayout_dirty then
		local offset
		if cellLayout==TableViewCell.SUBTITLE then
			textDetail.isVisible=true
			textLabel.isVisible=true
		else
			textDetail.isVisible=false
			textLabel.isVisible=true
		end
		self._cellLayout_dirty=false
	end

	if self._textLabelY_dirty then
		textLabel.anchorY=0.5
		textLabel.y=style.labelY
		self._textLabelY_dirty=false
	end

	if self._textDetailY_dirty then
		textDetail.anchorY=0.5
		textDetail.y=style.detailY
		self._textDetailY_dirty=false
	end

	--== non-position sensitive

	-- textColor/fillColor

	if self._debugOn_dirty then
		if style.debugOn==true then
			-- bg:setFillColor( 1,0,0,0.2 )
		else
			-- bg:setFillColor( 0,0,0,0 )
		end
		self._fillColor_dirty=false
		self._debugOn_dirty=false
	end

end




--====================================================================--
--== Event Handlers


function TableViewCell:stylePropertyChangeHandler( event )
	-- print( "TableViewCell:stylePropertyChangeHandler", event.type, event.property )
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

		self._cellAccessory_dirty = true
		self._cellLayout_dirty=true
		self._cellMargin_dirty=true
		self._contentMargin_dirty=true
		self._detailY_dirty=true
		self._labelY_dirty=true

		property = etype

	else
		if property=='debugOn' then
			self._debugOn_dirty=true
		elseif property=='width' then
			self._width_dirty=true
			self._accessoryX_dirty=true
		elseif property=='height' then
			self._height_dirty=true
			self._accessoryX_dirty=true
			self._imageViewX_dirty=true
			elseif property=='anchorX' then
				self._anchorX_dirty=true
			elseif property=='anchorY' then
				self._anchorY_dirty=true

		elseif property=='accessory' then
			self._cellAccessory_dirty=true
		elseif property=='cellLayout' then
			self._cellLayout_dirty=true
		elseif property=='cellMargin' then
			self._cellMargin_dirty=true
		elseif property=='contentMargin' then
			self._contentMargin_dirty=true
		elseif property=='detailY' then
			self._detailY_dirty=true
		elseif property=='labelY' then
			self._labelY_dirty=true
		end

	end

	self:__invalidateProperties__()
	self:__dispatchInvalidateNotification__( property, value )
end




return TableViewCell
