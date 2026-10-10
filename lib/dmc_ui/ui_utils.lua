
--====================================================================--
--== DMC UI Setup
--====================================================================--


local dmc_ui_data = _G.__dmc_ui
local dmc_ui_func = dmc_ui_data.func
local ui_find = dmc_ui_func.find


--====================================================================--
--== Imports


local uiConst = require( ui_find( 'ui_constants' ) )


--====================================================================--
--== Setup, Constants


local tinsert = table.insert


--====================================================================--
--== DMC Corona UI : UI Utils
--====================================================================--



local Utils = {}

-- http://lua-users.org/wiki/FunctionalLibrary

local function returnItem( item )
	return item
end
-- filter(function, table)
-- e.g: filter(is_even, {1,2,3,4}) -> {2,4}
function Utils.filter(func, tbl, proc)
	assert( type(func)=='function', "missing function for filter" )
	assert( type(tbl)=='table', "missing table for data" )
	proc = proc or returnItem

	local list = {}
	for i,v in ipairs(tbl) do
		if func(v) then
			tinsert( list, proc(v) )
		end
	end
	return list
end


-- takes in key,
-- returns list with all data
-- or empty list
function Utils.filterTableByName( tbl, name )
	assert( type(tbl)=='table', "missing table for data" )
	assert( type(name)=='string', "missing name for filter" )

	local function genTest( n )
		assert( n )
		-- sources, name
		return function( s )
			-- source, from filter()
			return (s[n]~=nil) -- has name
		end
	end
	local function getChild( n )
		assert( n )
		return function( s )
			return s[n]
		end
	end

	local test, process = genTest( name ), getChild( name )
	return Utils.filter( test, tbl, process )

end


-- adapted from:
-- https://coronalabs.com/blog/2014/12/02/tutorial-sizing-text-input-fields/
--
function Utils.getNativeFontSize( font, fontSize )
	-- print( "Utils.getNativeFontSize", fontSize )

	local platform = uiConst.PLATFORM
	local model = uiConst.MODEL
	local dpW = display.pixelWidth
	local nativeScaledFontSize = fontSize / display.contentScaleY

	local measureText = function( f, fS )
		local txtTmp = display.newText( "X", 0, 0, f, fS )
		local txtHeight = txtTmp.contentHeight
		txtTmp:removeSelf()
		textToMeasure = nil
		return txtHeight
	end

	if platform == 'Mac OS X' then
		if model == 'iPad' then
			nativeScaledFontSize = fontSize
		else
			-- @TODO
			nativeScaledFontSize = nativeScaledFontSize / ( dpW / 320 )
		end

	elseif platform == 'iPhone OS' then
		if model == 'iPad' or model == 'iPad Simulator' then
			nativeScaledFontSize = nativeScaledFontSize / ( dpW / 768 )
		else
			nativeScaledFontSize = nativeScaledFontSize / ( dpW / 320 )
		end

	elseif platform == 'Android' then
		nativeScaledFontSize = nativeScaledFontSize / ( system.getInfo( 'androidDisplayApproximateDpi' ) / 160 )
	end

	return nativeScaledFontSize
end



return Utils
