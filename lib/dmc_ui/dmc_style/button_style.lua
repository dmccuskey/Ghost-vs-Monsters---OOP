--====================================================================--
-- dmc_widget/widget_style/button_style.lua
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
--== DMC Corona UI : Button Widget Style
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
--== DMC UI : newButtonStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local uiConst = require( ui_find( 'ui_constants' ) )

local BaseStyle = require( ui_find( 'core.style' ) )
local StyleHelp = require( ui_find( 'core.style_helper' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local Style = nil



--====================================================================--
--== Button Style Class
--====================================================================--


--- Button Style Class.
-- a Style object for a Button Widget.
--
-- **Inherits from:** <br>
-- * @{Core.Style}
--
-- @classmod Style.Button
-- @usage
-- local dUI = require 'dmc_ui'
-- local widget = dUI.newButtonStyle{
--   type='rounded',
-- }
--
-- local widget = dUI.newRoundedBackgroundStyle()

local ButtonStyle = newClass( BaseStyle, {name="Button Style"} )

--== Class Constants

ButtonStyle.TYPE = uiConst.BUTTON

ButtonStyle.__base_style__ = nil  -- set in initialize()

ButtonStyle._CHILDREN = {
	inactive=true,
	active=true,
	disabled=true
}

ButtonStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,

	align=true,
	hitMarginX=true,
	hitMarginY=true,
	isHitActive=true,
	marginX=true,
	marginY=true,
	offsetX=true,
	offsetY=true,
}

ButtonStyle._EXCLUDE_PROPERTY_CHECK = {
	-- label/background, they can be copied from
	label=true,
	background=true
}

ButtonStyle._STYLE_DEFAULTS = {
	name='button-default-style',
	debugOn=false,
	width=76,
	height=40,
	anchorX=0.5,
	anchorY=0.5,

	align='center',
	hitMarginX=0,
	hitMarginY=0,
	isHitActive=true,
	marginX=0,
	marginY=0,
	offsetX=0,
	offsetY=0,

	--[[
	TODO: update this
	font=native.systemFontBold,
	fontSize=16,
	--]]

	inactive={ -- << this is a Button Style State
		--[[
		Can be copied from Button
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* align
		* isHitActive
		* marginX/marginY
		* offsetX/offsetY
		--]]
		label={
			--[[
			Can be copied from Button State
			* align
			* font*
			* fontSize
			* marginX/marginY
			* offsetX/offsetY
			* textColor
			--]]
			textColor={0.17,0.24,0.31},
		},
		background={
			type='rounded',
			view={
				cornerRadius=8,
				fillColor={
					type='gradient',
					color1={ 0.99,0.99,0.99 },
					color2={ 0.88,0.89,0.91 },
					direction='down'
				},
				strokeWidth=1,
				strokeColor={0.62,0.66,0.70,1},
			}
		}
	},

	active={
		--[[
		Can be copied from Button
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* align
		* isHitActive
		* marginX/marginY
		* offsetX/offsetY
		--]]
		label={
			textColor={0.94,0.95,0.96,1},
		},
		background={
			type='rounded',
			view={
				cornerRadius=8,
				fillColor={0.36,0.44,0.52,1},
				strokeWidth=1,
				strokeColor={0.62,0.66,0.70,1},
			},
		}
	},

	disabled={
		--[[
		Can be copied from Button
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* align
		* isHitActive
		* marginX/marginY
		* offsetX/offsetY
		--]]
		label={
			textColor={0.62,0.66,0.70,1},
		},
		background={
			type='rounded',
			view={
				cornerRadius=8,
				fillColor={0.93,0.94,0.95,1},
				strokeWidth=1,
				strokeColor={0.80,0.82,0.85,1},
			},
		}
	},

}

ButtonStyle._TEST_DEFAULTS = {
	name='button-test-style',
	debugOn=false,
	width=401,
	height=402,
	anchorX=403,
	anchorY=404,

	align='button-left',
	hitMarginX=401,
	hitMarginY=402,
	isHitActive=true,
	marginX=400,
	marginY=402,
	offsetX=405,
	offsetY=406,

	font=native.systemFontBold,
	fontSize=401,

	inactive={ -- << this is a Button Style State
		align='state-left',
		--[[
		Can be copied from Button
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* align
		* isHitActive
		* marginX/marginY
		* offsetX/offsetY
		--]]
		label={
			--[[
			Can be copied from Button State
			* align
			* font*
			* fontSize
			* marginX/marginY
			* offsetX/offsetY
			* textColor
			--]]
			textColor={410,410,410,410}
		},
		background={
			type='rounded',
			view={
				fillColor={420,420,420,420},
				strokeWidth=420,
				strokeColor={421,421,421,421},
			}
		}
	},

	active={
		--[[
		Can be copied from Button
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* align
		* isHitActive
		* marginX/marginY
		* offsetX/offsetY
		--]]
		label={
			textColor={412,412,412,412},
			font=native.systemFontBold,
			fontSize=412
		},
		background={
			type='rectangle',
			view={
				fillColor={424,424,424,424},
				strokeWidth=430,
				strokeColor={426,426,426,426},
			},
		}
	},

	disabled={
		--[[
		Can be copied from Button
		* debugOn
		* width
		* height
		* anchorX/anchorY
		* align
		* isHitActive
		* marginX/marginY
		* offsetX/offsetY
		--]]
		label={
			textColor={411,431,441,451},
			font=native.systemFontBold,
			fontSize=430
		},
		background={
			type='rounded',
			view={
				cornerRadius=431,
				fillColor={434,434,434,434},
				strokeWidth=434,
				strokeColor={434,434,434,434},
			},
		}
	},

}

ButtonStyle.MODE = uiConst.RUN_MODE
ButtonStyle._DEFAULTS = ButtonStyle._STYLE_DEFAULTS

--== Event Constants

ButtonStyle.EVENT = 'background-style-event'


--======================================================--
-- Start: Setup DMC Objects

function ButtonStyle:__init__( params )
	-- print( "ButtonStyle:__init__", params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Style Properties ==--

	-- self._data
	-- self._inherit
	-- self._widget
	-- self._parent
	-- self._onProperty

	-- self._name
	-- self._debugOn
	-- self._width
	-- self._height
	-- self._anchorX
	-- self._anchorY

	self._align = nil
	self._hitMarginX = nil
	self._hitMarginY = nil
	self._isHitActive = nil
	self._marginX = nil
	self._marginY = nil
	self._offsetX = nil
	self._offsetY = nil

	--== Object Refs ==--

	-- these are other style objects
	-- each Button State Style
	self._inactive = nil
	self._active = nil
	self._disabled = nil

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function ButtonStyle.initialize( manager, params )
	-- print( "ButtonStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		ButtonStyle.MODE = params.mode
		ButtonStyle._DEFAULTS = ButtonStyle._TEST_DEFAULTS
	end
	local defaults = ButtonStyle._DEFAULTS

	ButtonStyle._setDefaults( ButtonStyle, {defaults=defaults} )
end


function ButtonStyle.createStyleStructure( src )
	-- print( "ButtonStyle.createStyleStructure", src )
	src = src or {}
	--==--
	local StyleClass = Style.ButtonState
	return {
		inactive=StyleClass.createStyleStructure( src.inactive ),
		active=StyleClass.createStyleStructure( src.active ),
		disabled=StyleClass.createStyleStructure( src.disabled )
	}
end


function ButtonStyle.addMissingDestProperties( dest, src )
	-- print( "ButtonStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { ButtonStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	for i=1,#srcs do
		local src = srcs[i]

		if dest.align==nil then dest.align=src.align end
		if dest.hitMarginX==nil then dest.hitMarginX=src.hitMarginX end
		if dest.hitMarginY==nil then dest.hitMarginY=src.hitMarginY end
		if dest.isHitActive==nil then dest.isHitActive=src.isHitActive end
		if dest.marginX==nil then dest.marginX=src.marginX end
		if dest.marginY==nil then dest.marginY=src.marginY end
		if dest.offsetX==nil then dest.offsetX=src.offsetX end
		if dest.offsetY==nil then dest.offsetY=src.offsetY end

		--== Additional properties to be handed down to children

		if dest.font==nil then dest.font=src.font end

	end

	dest = ButtonStyle._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function ButtonStyle._addMissingChildProperties( dest, src )
	-- print("ButtonStyle._addMissingChildProperties", dest, src )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style (ButtonStyle) missing property '%s'"
	local StyleClass = Style.ButtonState
	local child

	child = dest.inactive
	-- assert( child, sfmt( eStr, 'inactive' ) )
	dest.inactive = StyleClass.addMissingDestProperties( child, src )

	child = dest.active
	-- assert( child, sfmt( eStr, 'active' ) )
	dest.active = StyleClass.addMissingDestProperties( child, src )

	child = dest.disabled
	-- assert( child, sfmt( eStr, 'disabled' ) )
	dest.disabled = StyleClass.addMissingDestProperties( child, src )

	return dest
end


function ButtonStyle.copyExistingSrcProperties( dest, src, params )
	-- print( "ButtonStyle.copyExistingSrcProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	if (src.align~=nil and dest.align==nil) or force then
		dest.align=src.align
	end
	if (src.hitMarginX~=nil and dest.hitMarginX==nil) or force then
		dest.hitMarginX=src.hitMarginX
	end
	if (src.hitMarginY~=nil and dest.hitMarginY==nil) or force then
		dest.hitMarginY=src.hitMarginY
	end
	if (src.isHitActive~=nil and dest.isHitActive==nil) or force then
		dest.isHitActive=src.isHitActive
	end
	if (src.marginX~=nil and dest.marginX==nil) or force then
		dest.marginX=src.marginX
	end
	if (src.marginY~=nil and dest.marginY==nil) or force then
		dest.marginY=src.marginY
	end
	if (src.offsetX~=nil and dest.offsetX==nil) or force then
		dest.offsetX=src.offsetX
	end
	if (src.offsetY~=nil and dest.offsetY==nil) or force then
		dest.offsetY=src.offsetY
	end

	return dest
end


function ButtonStyle._verifyStyleProperties( src, exclude )
	-- print( "ButtonStyle._verifyStyleProperties", src )
	assert( src, "ButtonStyle:verifyStyleProperties requires source")
	--==--
	local emsg = "Style (ButtonStyle) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	if not src.align then
		print(sfmt(emsg,'align')) ; is_valid=false
	end
	if not src.hitMarginX then
		print(sfmt(emsg,'hitMarginX')) ; is_valid=false
	end
	if not src.hitMarginY then
		print(sfmt(emsg,'hitMarginY')) ; is_valid=false
	end
	if src.isHitActive==nil then
		print(sfmt(emsg,'isHitActive')) ; is_valid=false
	end
	if not src.marginX then
		print(sfmt(emsg,'marginX')) ; is_valid=false
	end
	if not src.marginY then
		print(sfmt(emsg,'marginY')) ; is_valid=false
	end
	if not src.offsetX then
		print(sfmt(emsg,'offsetX')) ; is_valid=false
	end
	if not src.offsetY then
		print(sfmt(emsg,'offsetY')) ; is_valid=false
	end

	local StyleClass = Style.ButtonState
	local child

	child = src.inactive
	if not child then
		print( "ButtonStyle child test skipped for 'inactive'" )
		is_valid=false
	else
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.active
	if not child then
		print( "ButtonStyle child test skipped for 'active'" )
		is_valid=false
	else
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.disabled
	if not child then
		print( "ButtonStyle child test skipped for 'disabled'" )
		is_valid=false
	else
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	return is_valid
end



--====================================================================--
--== Public Methods


--======================================================--
-- Access to sub-styles

--== .inactive

--- get Style object for State 'inactive'.
--
-- @within Properties
-- @function .inactive
-- @usage print( style.inactive )

function ButtonStyle.__getters:inactive()
	-- print( "ButtonStyle.__getters:inactive", self._inactive )
	return self._inactive
end
function ButtonStyle.__setters:inactive( data )
	-- print( "ButtonStyle.__setters:inactive", data )
	assert( data==nil or type(data)=='string' or type( data )=='table' )
	--==--
	local StyleClass = Style.ButtonState
	local inherit = self._inherit and self._inherit._inactive

	self._inactive = StyleClass:createStyleFrom{
		name=ButtonStyle.INACTIVE_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== .active

function ButtonStyle.__getters:active()
	-- print( "ButtonStyle.__getters:active", self._active )
	return self._active
end
function ButtonStyle.__setters:active( data )
	-- print( "ButtonStyle.__setters:active", data )
	assert( data==nil or type(data)=='string' or type( data )=='table' )
	--==--
	local StyleClass = Style.ButtonState
	local inherit = self._inherit and self._inherit._active

	self._active = StyleClass:createStyleFrom{
		name=ButtonStyle.ACTIVE_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== .disabled

function ButtonStyle.__getters:disabled()
	-- print( "ButtonStyle.__getters:disabled", self._disabled )
	return self._disabled
end
function ButtonStyle.__setters:disabled( data )
	-- print( "ButtonStyle.__setters:disabled", data )
	assert( data==nil or type(data)=='string' or type( data )=='table' )
	--==--
	local StyleClass = Style.ButtonState
	local inherit = self._inherit and self._inherit._disabled

	self._disabled = StyleClass:createStyleFrom{
		name=ButtonStyle.DISABLED_NAME,
		inherit=inherit,
		parent=self,
		data=data
	}
end


--======================================================--
-- Access to style properties

--== .align

--- [**style**] set/get Style value for Widget text alignment.
-- values are 'left', 'center', 'right'
--
-- @within Properties
-- @function .align
-- @usage widget.align = 'center'
-- @usage print( widget.align )

ButtonStyle.__getters.align = StyleHelp.__getters.align
ButtonStyle.__setters.align = StyleHelp.__setters.align

--== .hitMarginX

function ButtonStyle.__getters:hitMarginX()
	-- print( "ButtonStyle.__getters:hitMarginX", self._inherit )
	local value = self._hitMarginX
	if value==nil and self._inherit then
		value = self._inherit.hitMarginX
	end
	return value
end
function ButtonStyle.__setters:hitMarginX( value )
	-- print( "ButtonStyle.__setters:hitMarginX", value, self._inherit )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value == self._hitMarginX then return end
	self._hitMarginX = value
	self:_dispatchChangeEvent( 'hitMarginX', value )
end

--== .hitMarginY

function ButtonStyle.__getters:hitMarginY()
	-- print( "ButtonStyle.__getters:hitMarginY" )
	local value = self._hitMarginY
	if value==nil and self._inherit then
		value = self._inherit.hitMarginY
	end
	return value
end
function ButtonStyle.__setters:hitMarginY( value )
	-- print( "ButtonStyle.__setters:hitMarginY", value, self )
	assert( (type(value)=='number' and value>=0) or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value==self._hitMarginY then return end
	self._hitMarginY = value
	self:_dispatchChangeEvent( 'hitMarginY', value )
end

--== .isHitActive

function ButtonStyle.__getters:isHitActive()
	-- print( "ButtonStyle.__getters:isHitActive" )
	local value = self._isHitActive
	if value==nil and self._inherit then
		value = self._inherit.isHitActive
	end
	return value
end
function ButtonStyle.__setters:isHitActive( value )
	-- print( "ButtonStyle.__setters:isHitActive", value )
	assert( type(value)=='boolean' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value == self._isHitActive then return end
	self._isHitActive = value
	self:_dispatchChangeEvent( 'isHitActive', value )
end

--== .marginX

--- [**style**] set/get Style value for Widget X-axis margin.
--
-- @within Properties
-- @function .marginX
-- @usage style.marginX = 10
-- @usage print( style.marginX )

ButtonStyle.__getters.marginX = StyleHelp.__getters.marginX
ButtonStyle.__setters.marginX = StyleHelp.__setters.marginX

--== .marginY

--- [**style**] set/get Style value for Widget Y-axis margin.
--
-- @within Properties
-- @function .marginY
-- @usage style.marginY = 10
-- @usage print( style.marginY )

ButtonStyle.__getters.marginY = StyleHelp.__getters.marginY
ButtonStyle.__setters.marginY = StyleHelp.__setters.marginY

--== .offsetX

--- [**style**] set/get Style value for the label's X-axis offset.
-- handed down to the state styles, which move their label by it.
--
-- @within Properties
-- @function .offsetX
-- @usage style.offsetX = 5
-- @usage print( style.offsetX )

function ButtonStyle.__getters:offsetX()
	-- print( "ButtonStyle.__getters:offsetX" )
	local value = self._offsetX
	if value==nil and self._inherit then
		value = self._inherit.offsetX
	end
	return value
end
function ButtonStyle.__setters:offsetX( value )
	-- print( "ButtonStyle.__setters:offsetX", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value == self._offsetX then return end
	self._offsetX = value
	self:_dispatchChangeEvent( 'offsetX', value )
end

--== .offsetY

--- [**style**] set/get Style value for the label's Y-axis offset.
-- handed down to the state styles, which move their label by it.
--
-- @within Properties
-- @function .offsetY
-- @usage style.offsetY = 5
-- @usage print( style.offsetY )

function ButtonStyle.__getters:offsetY()
	-- print( "ButtonStyle.__getters:offsetY" )
	local value = self._offsetY
	if value==nil and self._inherit then
		value = self._inherit.offsetY
	end
	return value
end
function ButtonStyle.__setters:offsetY( value )
	-- print( "ButtonStyle.__setters:offsetY", value )
	assert( type(value)=='number' or (value==nil and (self:_hasInherit() or self._isClearing)) )
	--==--
	if value == self._offsetY then return end
	self._offsetY = value
	self:_dispatchChangeEvent( 'offsetY', value )
end


--======================================================--
-- Misc

function ButtonStyle:_doChildrenInherit( value )
	-- print( "ButtonStyle:_doChildrenInherit", value, self )
	if not self._isInitialized then return end

	self._inactive.inherit = value and value.inactive or value
	self._active.inherit = value and value.active or value
	self._disabled.inherit = value and value.disabled or value
end


function ButtonStyle:_clearChildrenProperties( style, params )
	-- print( "ButtonStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(ButtonStyle) )
	end
	--==--
	local substyle

	substyle = style and style.inactive
	self._inactive:_clearProperties( substyle, params )

	substyle = style and style.active
	self._active:_clearProperties( substyle, params )

	substyle = style and style.disabled
	self._disabled:_clearProperties( substyle, params )
end



--====================================================================--
--== Private Methods


function ButtonStyle:_destroyChildren()
	-- print( 'ButtonStyle:_destroyChildren', self )

	self._inactive:removeSelf()
	self._inactive=nil

	self._active:removeSelf()
	self._active=nil

	self._disabled:removeSelf()
	self._disabled=nil
end


-- we could have nil, Lua structure, or Instance
--
-- TODO: more work when inheriting, etc (Background Style)
function ButtonStyle:_prepareData( data, dataSrc, params )
	-- print("ButtonStyle:_prepareData", data, self )
	params = params or {}
	--==--
	-- local inherit = params.inherit
	local StyleClass
	local src, dest, tmp

	if not data then
		data = ButtonStyle.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	StyleClass = Style.ButtonState
	if not src.inactive then
		tmp = dataSrc and dataSrc.inactive
		src.inactive = StyleClass.createStyleStructure( tmp )
	end
	if not src.active then
		tmp = dataSrc and dataSrc.active
		src.active = StyleClass.createStyleStructure( tmp )
	end
	if not src.disabled then
		tmp = dataSrc and dataSrc.disabled
		src.disabled = StyleClass.createStyleStructure( tmp )
	end

	--== process children

	dest = src.inactive
	src.inactive = StyleClass.copyExistingSrcProperties( dest, src )

	dest = src.active
	src.active = StyleClass.copyExistingSrcProperties( dest, src )

	dest = src.disabled
	src.disabled = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end



--====================================================================--
--== Event Handlers


-- none




return ButtonStyle
