--====================================================================--
-- lib/app_utils.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Ghost vs Monsters : GvsM Utils
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Utils
--====================================================================--


local Utils = {}



--======================================================--
-- Utils.comma_value

function Utils.comma_value( value )
	local formatted = value
	while true do
		formatted, k = string.gsub( formatted, "^(-?%d+)(%d%d%d)", '%1,%2' )
		if k==0 then break end
	end
	return formatted
end



--======================================================--
-- Utils.imageButtonStyle

-- the style for a DMC-Corona-UI button made of two images,
-- one for each of its states
--
-- params: width, height, file, active_file
--
function Utils.imageButtonStyle( params )
	local function background( file )
		return {
			type='image',
			view={ imagePath=file }
		}
	end
	return {
		width=params.width,
		height=params.height,
		inactive={ background=background( params.file ) },
		active={ background=background( params.active_file ) }
	}
end





return Utils
