--====================================================================--
-- dmc_ui/dmc_style/style_manager.lua
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
--== DMC Corona UI : Style Manager
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
--== DMC UI : Style Manager
--====================================================================--



--====================================================================--
--== Imports


local EventsMixModule = require 'dmc_events_mix'
local Patch = require 'dmc_patch'
local Path = require 'dmc_path'



--====================================================================--
--== Setup, Constants


Patch.addPatch( { 'table-pop', 'print-output' } )

local sfmt = string.format
local smatch = string.match
local tinsert = table.insert
local tpop = table.pop

--== To be set in initialize()
local Style = nil



--===================================================================--
--== Support Functions




--====================================================================--
--== Style Manager Class
--====================================================================--


local StyleMgr = {}

EventsMixModule.patch( StyleMgr )

--[[
keyed on Style/dUI type, then name
{
	Button={
		'home-page'
	}
	NavBar={
		'home-page'
	}
}
--]]
StyleMgr._style = {}

-- references the theme structure
StyleMgr._activeTheme = nil

-- keyed on theme name
StyleMgr._theme = {}

--[[
	registered widgets and styles
	keyed on widget theme id

	textfield={
	<TextField Style Class>
	<TextField Class>
--]]
StyleMgr._registered = {}


StyleMgr.EVENT = 'style-mgr-event'
StyleMgr.THEME = 'theme-update'


--====================================================================--
--== Static Functions


function StyleMgr.initialize( manager, params )
	-- params = params or {}
	-- if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	--== Add API calls

	Style.addStyle = StyleMgr.addStyle
	Style.getStyle = StyleMgr.getStyle
	Style.purgeStyles = StyleMgr.purgeStyles
	Style.registerWidget = StyleMgr.registerWidget
	Style.removeStyle = StyleMgr.removeStyle

	-- Theme Functions

	Style.activateTheme = StyleMgr.activateTheme
	Style.createTheme = StyleMgr.createTheme
	Style.getActiveThemeId = StyleMgr.getActiveThemeId
	Style.getActiveThemeName = StyleMgr.getActiveThemeName
	Style.getAvailableThemeIds = StyleMgr.getAvailableThemeIds
	Style.loadTheme = StyleMgr.loadTheme
	Style.loadThemes = StyleMgr.loadThemes

end



--====================================================================--
--== Public Functions


--======================================================--
-- Style Functions

function StyleMgr.purgeStyles()
	-- print( "StyleMgr.purgeStyles" )
	StyleMgr._style = {}
end


function StyleMgr.addStyle( style )
	-- print( "StyleMgr.addStyle", style )
	assert( style, "StyleMgr.addStyle missing arg 'style'" )
	assert( style.isa and style:isa(Style.Base), "StyleMgr.addStyle wrong type for 'style'" )
	--==--
	local name = style.name
	local sType = style.TYPE
	local styles

	if type(sType)~='string' then
		pnotice( sfmt( "StyleMgr.addStyle improper TYPE on Style, got '%s'", tostring( type(sType) ) ))
		return
	end
	if type(name)~='string' then
		pnotice( sfmt( "StyleMgr.addStyle expected string name, got '%s'", tostring( type(name) ) ))
		return
	end
	if #name==0 then
		pnotice( sfmt( "StyleMgr.addStyle name too short '%s'", tostring(name) ))
		return
	end

	styles = StyleMgr._style[ sType ]
	if not styles then
		StyleMgr._style[ sType ] = {}
		styles = StyleMgr._style[ sType ]
	end

	if styles[ name ] then
		pnotice( sfmt( "StyleMgr.addStyle already have style with name '%s'", name ))
		return
	end

	styles[ name ] = style
end


function StyleMgr.getStyle( style, name )
	-- print( "StyleMgr.getStyle", name )
	assert( type(style)=='string' or type(style)=='table', sfmt("StyleMgr:getStyle arg 'style' must be a string or table got '%s'", tostring(style) ) )
	assert( type(name)=='string', sfmt("StyleMgr:getStyle arg 'name' must be a string, got '%s'", tostring(name) ) )
	--==--
	local sType
	if type(style)=='string' then
		sType = style
	elseif type(style)=='table' then
		assert( type(style.TYPE)=='string', sfmt("StyleMgr:getStyle arg 'name' must be a string, got '%s'", tostring(name) ) )
		sType = style.TYPE
	end
	-- look for style in theme collection, then style collection
	local found
	if StyleMgr._activeTheme then
		found = ( StyleMgr._activeTheme.style[ sType ] or {} )[ name ]
	end
	if not found then
		found = ( StyleMgr._style[ sType ] or {} )[ name ]
	end
	return found
end


function StyleMgr.removeStyle( style, name )
	-- print( "StyleMgr.removeStyle", style, name )
	assert( type(style)=='string' or type(style)=='table', sfmt("StyleMgr:getStyle arg 'name' must be a string, got '%s'", tostring(name) ) )
	assert( type(name)=='string', "StyleMgr:removeStyle arg 'name' must be string" )
	--==--
	local sType
	if type(style)=='string' then
		sType = style
	elseif type(style)=='table' then
		assert( type(style.TYPE)=='string', sfmt("StyleMgr:getStyle arg 'name' must be a string, got '%s'", tostring(name) ) )
		sType = style.TYPE
	end

	local styles = StyleMgr._style[ sType ] or {}
	-- given a style, only remove it, not another style with its name
	if type(style)=='table' and styles[ name ]~=style then return end
	return tpop( styles, name )
end



--======================================================--
-- Theme Methods


function StyleMgr.activateTheme( themeId )
	-- print( "StyleMgr.activateTheme", themeId )
	local themes = StyleMgr._theme
	local currTheme = StyleMgr._activeTheme
	if currTheme~=nil then
		currTheme.isActive=false
	end
	currTheme = themes[ themeId ]
	currTheme.isActive=true

	StyleMgr._activeTheme = currTheme
	StyleMgr:dispatchEvent( StyleMgr.THEME )
end

function StyleMgr.createTheme( themeId, params )
	-- print( "StyleMgr.createTheme", params.name )
	params = params or {}
	params.id = themeId
	--==--
	local themes = StyleMgr._theme
	local struct = themes[ themeId ]
	if struct then
		return StyleMgr._createThemeInterface( struct )
	end

	struct = StyleMgr._createThemeStruct( params )
	StyleMgr._theme[ themeId ] = struct
	return StyleMgr._createThemeInterface( struct )
end


function StyleMgr.getAvailableThemeIds()
	local themes = StyleMgr._theme
	local list = {}
	for k,_ in pairs( themes ) do
		tinsert( list, k )
	end
	return list
end

function StyleMgr.getActiveThemeId()
	return StyleMgr._activeTheme and StyleMgr._activeTheme.id
end

function StyleMgr.getActiveThemeName()
	return StyleMgr._activeTheme and StyleMgr._activeTheme.name
end

local lfs = require 'lfs'


-- path: 'one/two/three/file.lua'
-- path: 'one\two\three\file.lua'
--
-- parse(path)
-- buildRequire(parts)
-- buildPath(parts)
function StyleMgr.loadTheme( filePath )
	-- print( "StyleMgr.loadTheme", filePath )
	local pathInfo = Path.parse( filePath )
	local reqPath = Path.buildRequire( pathInfo )
	local t = require( reqPath )
	t.initialize( Style )
end

-- local p = path.buildPath( parse )
-- local p = path.buildRequire( parse )

--- loadThemes requires a directory.
--
function StyleMgr.loadThemes( directory )
	-- print( "StyleMgr.loadThemes", directory )
	local dirInfo = Path.parse( directory )

	local resPath, resInfo
	local themePath

	-- resPath = system.pathForFile( '', system.ResourceDirectory )
	--== START TEMP fix for bug in corona ==--
	resPath = system.pathForFile( 'main.lua', system.ResourceDirectory )
	resPath = smatch( resPath, '^(.+)main.lua' )
	--== END TEMP fix for bug in corona ==--
	local resInfo = Path.parse( resPath )
	dirInfo.dir = resInfo.path
	dirInfo.isAbs = resInfo.isAbs
	themePath = Path.buildPath( dirInfo )

	-- reset
	dirInfo.dir = {}
	dirInfo.isAbs = false

	for file in lfs.dir( themePath ) do
		local name = smatch( file, '^(.+)%.lua$' )
		if name then
			dirInfo.name = name
			local reqPath = Path.buildRequire( dirInfo )
			local pathInfo = Path.parse( directory )
			pathInfo.dir = pathInfo.path
			pathInfo.path = {}
			local t = require( reqPath )
			t.initialize( Style, pathInfo )
		end
	end

end


--======================================================--
-- Misc Functions

function StyleMgr.registerWidget( widget )
	-- print( "StyleMgr.registerWidget", widget, widget.STYLE_TYPE )
	assert( widget and type(widget.STYLE_TYPE)=='string' )
	--==--
	local wType = widget.STYLE_TYPE
	StyleMgr._registered[ wType ] = widget
end



--[[

--===================================================================--
--== Theme Methods


function Widget.activateTheme( theme_id )
end

function Widget.availableThemes()
end

function Widget.availableThemeNames()
end

function Widget.availableThemeIds()
end

-- struct or name/dir
function Widget.createTheme( theme, dir )
end

function Widget.getTheme( theme_id )
end

function Widget.getActiveTheme()
end

function Widget.deleteTheme( theme_id )
end

function Widget.addThemeStyle( theme_id, style, name )
	return Widget.StyleMgr:addThemeStyle( theme_id, style, name )
end

function Widget.getThemeStyle( theme_id, style, name )
end

function Widget.removeThemeStyle( theme_id, style, name )
end

function Widget.loadTheme( file )
end

function Widget.unloadTheme( theme_id )
end

function Widget.reloadTheme( theme_id )
end

--]]
--====================================================================--
--== Private Functions



function StyleMgr._addThemeStyle( struct, style, name )
	-- print( "StyleMgr._addThemeStyle", struct, style, name )
	assert( style, "StyleMgr:_addThemeStyle missing arg 'style'" )
	assert( style.isa and style:isa(Style.Base), "StyleMgr:_addThemeStyle wrong type for 'style'" )
	--==--
	local sType = style.TYPE
	local styles = struct.style
	local collection = styles[sType]
	if not collection then
		-- need to create container for this style TYPE
		collection = {}
		styles[ sType ] = collection
	end
	collection[ name ] = style
end


function StyleMgr._createThemeInterface( struct )
	-- print( "StyleMgr._createThemeInterface", struct )
	return {
		addStyle=function( name, style )
			StyleMgr._addThemeStyle( struct, style, name )
		end
	}
end


function StyleMgr._createThemeStruct( params )
	-- print( "StyleMgr._createThemeStruct" )

	return {
		id=params.id,
		name=params.name,
		root=params.root,
		file=params.file,
		isActive=false,
		style = {
			Text={
				-- 'home-text'= style
			}
		}
	}
end


--====================================================================--
--== Event Handlers


-- none



return StyleMgr
