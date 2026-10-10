--====================================================================--
-- dmc_ui/dmc_style.lua
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
--== DMC Corona UI : Style Interface
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
--== DMC UI : Style Interface
--====================================================================--



--====================================================================--
--== Imports


local Kolor = require 'dmc_kolor'
local uiConst = require( ui_find( 'ui_constants' ) )



--====================================================================--
--== Setup, Constants


--== To be set in initialize()
local dUI = nil



--===================================================================--
--== Support Functions


local initKolors = Kolor.initializeKolorSet



--====================================================================--
--== Style Interface
--====================================================================--


local Style = {}



--====================================================================--
--== Style Static Functions


function Style.initialize( manager, params )
	-- print( "Style.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--

	dUI = manager
	-- for the style classes loaded later, on first use
	Style._mode = params.mode

	--== Base Components

	local StyleMgr = require( ui_find( 'dmc_style.style_manager' ) )
	local StyleMixModule = require( ui_find( 'dmc_style.style_mix' ) )

	Style.Manager=StyleMgr
	Style.StyleMix=StyleMixModule.StyleMix

	StyleMixModule.initialize( Style, params )
	StyleMgr.initialize( Style, params )

	--== Add API calls

	-- Style Manager

	dUI.addStyle = Style.addStyle
	dUI.getStyle = Style.getStyle
	dUI.purgeStyles = Style.purgeStyles
	dUI.registerWidget = Style.registerWidget
	dUI.removeStyle = Style.removeStyle

	dUI.activateTheme = Style.activateTheme
	dUI.createTheme = Style.createTheme
	dUI.getActiveThemeId = Style.getActiveThemeId
	dUI.getActiveThemeName = Style.getActiveThemeName
	dUI.getAvailableThemeIds = Style.getAvailableThemeIds
	dUI.loadTheme = Style.loadTheme
	dUI.loadThemes = Style.loadThemes

	-- Style Interface

	dUI.newBackgroundStyle = Style.newBackgroundStyle
	dUI.newNineSliceBackgroundStyle = Style.newNineSliceBackgroundStyle
	dUI.newImageBackgroundStyle = Style.newImageBackgroundStyle
	dUI.newRectangleBackgroundStyle = Style.newRectangleBackgroundStyle
	dUI.newRoundedBackgroundStyle = Style.newRoundedBackgroundStyle

	dUI.newButtonStyle = Style.newButtonStyle
	dUI.newNavBarStyle = Style.newNavBarStyle
	dUI.newNavItemStyle = Style.newNavItemStyle
	dUI.newPageIndicatorStyle = Style.newPageIndicatorStyle
	dUI.newScrollViewStyle = Style.newScrollViewStyle
	dUI.newTableViewStyle = Style.newTableViewStyle
	dUI.newTableViewCellStyle = Style.newTableViewCellStyle
	dUI.newTextFieldStyle = Style.newTextFieldStyle
	dUI.newTextStyle = Style.newTextStyle

end



--====================================================================--
--== Style Public Functions


--======================================================--
-- Base Style Support

function Style.loadBaseStyleSupport( params )
	-- print( "Style.loadBaseStyleSupport" )
	if Style.Base then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	local BaseStyle = require( ui_find( 'core.style' ) )
	Style.Base=BaseStyle
	initKolors(
		function()
			BaseStyle.initialize( Style, params )
		end,
		kmode
	)
end


--======================================================--
-- newBackgroundStyle Support

function Style._loadBackgroundStyleSupport( params )
	-- print( "Style._loadBackgroundStyleSupport" )
	if Style.Background then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )

	--== Components

	local BackgroundStyle = require( ui_find( 'dmc_style.background_style' ) )
	local BackgroundStyleFactory = require( ui_find( 'dmc_style.background_style.style_factory' ) )

	Style.Background=BackgroundStyle
	Style.BackgroundFactory=BackgroundStyleFactory

	initKolors(
		function()
			BackgroundStyleFactory.initialize( Style, params )
			BackgroundStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newBackgroundStyle( style_info, params )
	-- print( "Style.newBackgroundStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.Background then Style._loadBackgroundStyleSupport() end
	return Style.Background:createStyleFrom( params )
end

function Style.newImageBackgroundStyle( style_info, params )
	-- print("Style.newImageBackgroundStyle")
	style_info = style_info or {}
	params = params or {}
	--==--
	if not Style.Background then Style._loadBackgroundStyleSupport() end
	style_info.type = Style.BackgroundFactory.Image.TYPE
	return Style.newBackgroundStyle( style_info, params )
end

function Style.newNineSliceBackgroundStyle( style_info, params )
	-- print("Style.newNineSliceBackgroundStyle")
	style_info = style_info or {}
	params = params or {}
	--==--
	if not Style.Background then Style._loadBackgroundStyleSupport() end
	style_info.type = Style.BackgroundFactory.NineSlice.TYPE
	return Style.newBackgroundStyle( style_info, params )
end

function Style.newRectangleBackgroundStyle( style_info, params )
	style_info = style_info or {}
	params = params or {}
	--==--
	if not Style.Background then Style._loadBackgroundStyleSupport() end
	style_info.type = Style.BackgroundFactory.Rectangle.TYPE
	return Style.newBackgroundStyle( style_info, params )
end

function Style.newRoundedBackgroundStyle( style_info, params )
	style_info = style_info or {}
	params = params or {}
	--==--
	if not Style.Background then Style._loadBackgroundStyleSupport() end
	style_info.type = Style.BackgroundFactory.Rounded.TYPE
	return Style.newBackgroundStyle( style_info, params )
end


--======================================================--
-- newButtonStyle Support

function Style._loadButtonStyleSupport( params )
	-- print( "Style._loadButtonStyleSupport" )
	if Style.Button then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )
	Style._loadBackgroundStyleSupport( params )
	Style._loadTextStyleSupport( params )

	--== Components

	local ButtonStyle = require( ui_find( 'dmc_style.button_style' ) )
	local ButtonStateStyle = require( ui_find( 'dmc_style.button_state' ) )

	Style.Button=ButtonStyle
	Style.ButtonState=ButtonStateStyle

	initKolors(
		function()
			ButtonStateStyle.initialize( Style, params )
			ButtonStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newButtonStyle( style_info, params )
	-- print("Style.newButtonStyle")
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.Button then Style._loadButtonStyleSupport() end
	return Style.Button:createStyleFrom( params )
end


--======================================================--
-- newNavBarStyle Support

function Style._loadNavBarStyleSupport( params )
	-- print( "Style._loadNavBarStyleSupport" )
	if Style.NavBar then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )
	Style._loadBackgroundStyleSupport( params )
	Style._loadButtonStyleSupport( params )

	--== Components

	local NavBarStyle = require( ui_find( 'dmc_style.navbar_style' ) )
	local NavItemStyle = require( ui_find( 'dmc_style.navitem_style' ) )

	Style.NavBar=NavBarStyle
	Style.NavItem=NavItemStyle

	initKolors(
		function()
			NavItemStyle.initialize( Style, params )
			NavBarStyle.initialize( dUI, params )
		end,
		kmode
	)
end

function Style.newNavBarStyle( style_info, params )
	-- print( "Style.newNavBarStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.NavBar then Style._loadNavBarStyleSupport() end
	return Style.NavBar:createStyleFrom( params )
end

function Style.newNavItemStyle( style_info, params )
	-- print( "Style.newNavItemStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.NavItem then Style._loadNavBarStyleSupport() end
	return Style.NavItem:createStyleFrom( params )
end


--======================================================--
-- newPageIndicatorStyle Support

function Style.loadPageIndicatorStyleSupport( params )
	-- print( "Style.loadPageIndicatorStyleSupport" )
	if Style.PageIndicator then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )

	--== Components

	local PageIndicatorStyle = require( ui_find( 'dmc_style.pageindicator_style' ) )

	Style.PageIndicator=PageIndicatorStyle

	initKolors(
		function()
			PageIndicatorStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newPageIndicatorStyle( style_info, params )
	-- print( "Style.newPageIndicatorStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.PageIndicator then Style.loadPageIndicatorStyleSupport() end
	return Style.PageIndicator:createStyleFrom( params )
end


--======================================================--
-- newScrollViewStyle Support

function Style.loadScrollViewStyleSupport( params )
	-- print( "Style.loadScrollViewStyleSupport" )
	if Style.ScrollView then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )

	--== Components

	local ScrollViewStyle = require( ui_find( 'dmc_style.scrollview_style' ) )

	Style.ScrollView=ScrollViewStyle

	initKolors(
		function()
			ScrollViewStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newScrollViewStyle( style_info, params )
	-- print( "Style.newScrollViewStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.ScrollView then Style.loadScrollViewStyleSupport() end
	return Style.ScrollView:createStyleFrom( params )
end


--======================================================--
-- newTableViewStyle Support

function Style.loadTableViewStyleSupport( params )
	-- print( "Style.loadTableViewStyleSupport" )
	if Style.TableView then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadScrollViewStyleSupport( params )

	--== Components

	local TableViewStyle = require( ui_find( 'dmc_style.tableview_style' ) )

	Style.TableView=TableViewStyle

	initKolors(
		function()
			TableViewStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newTableViewStyle( style_info, params )
	-- print( "Style.newTableViewStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.TableView then Style.loadTableViewStyleSupport() end
	return Style.TableView:createStyleFrom( params )
end


--======================================================--
-- newTableViewCellStyle Support

function Style.loadTableViewCellStyleSupport( params )
	-- print( "Style.loadTableViewCellStyleSupport" )
	if Style.TableViewCell then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )
	Style._loadBackgroundStyleSupport( params )
	Style._loadTextStyleSupport( params )

	--== Components

	local TableViewCellStyle = require( ui_find( 'dmc_style.tableviewcell_style' ) )
	local TableViewCellStateStyle = require( ui_find( 'dmc_style.tableviewcell_style.tableviewcell_state' ) )

	Style.TableViewCell=TableViewCellStyle
	Style.TableViewCellState=TableViewCellStateStyle

	initKolors(
		function()
			-- reverse order
			TableViewCellStateStyle.initialize( Style, params )
			TableViewCellStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newTableViewCellStyle( style_info, params )
	-- print( "Style.newTableViewCellStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.TableViewCell then Style.loadTableViewCellStyleSupport() end
	return Style.TableViewCell:createStyleFrom( params )
end


--======================================================--
-- newTextStyle Support

function Style._loadTextStyleSupport( params )
	-- print( "Style._loadTextStyleSupport" )
	if Style.Text then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )

	--== Components

	local TextStyle = require( ui_find( 'dmc_style.text_style' ) )

	Style.Text=TextStyle

	initKolors(
		function()
			TextStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newTextStyle( style_info, params )
	-- print( "Style.newTextStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.Text then Style._loadTextStyleSupport() end
	return Style.Text:createStyleFrom( params )
end


--======================================================--
-- newTextFieldStyle Support

function Style._loadTextFieldStyleSupport( params )
	-- print( "Style._loadTextFieldStyleSupport" )
	if Style.TextField then return end
	params = params or {}
	if params.mode==nil then params.mode=Style._mode or uiConst.RUN_MODE end
	--==--
	local kmode
	if params.mode==uiConst.TEST_MODE then
		kmode = Kolor.hRGBA
	end

	--== Dependencies

	Style.loadBaseStyleSupport( params )
	Style._loadBackgroundStyleSupport( params )
	Style._loadTextStyleSupport( params )

	--== Components

	local TextFieldStyle = require( ui_find( 'dmc_style.textfield_style' ) )

	Style.TextField=TextFieldStyle

	initKolors(
		function()
			TextFieldStyle.initialize( Style, params )
		end,
		kmode
	)
end

function Style.newTextFieldStyle( style_info, params )
	-- print( "Style.newTextFieldStyle" )
	style_info = style_info or {}
	params = params or {}
	--==--
	params.data = style_info
	if not Style.TextField then Style._loadTextFieldStyleSupport() end
	return Style.TextField:createStyleFrom( params )
end



--====================================================================--
--== Private Functions


-- none



--====================================================================--
--== Event Handlers


-- none




return Style
