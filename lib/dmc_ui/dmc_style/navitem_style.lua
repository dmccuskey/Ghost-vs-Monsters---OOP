--====================================================================--
-- dmc_widget/widget_style/navitem_style.lua
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
--== DMC Corona UI : Nav Item Widget Style
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
--== DMC UI : newNavItemStyle
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'
local uiConst = require( ui_find( 'ui_constants' ) )

local BaseStyle = require( ui_find( 'core.style' ) )



--====================================================================--
--== Setup, Constants


local sfmt = string.format
local tinsert = table.insert

--== To be set in initialize()
local Style = nil



--====================================================================--
--== NavItem Style Class
--====================================================================--


local NavItemStyle = newClass( BaseStyle, {name="NavItem Style"} )

--== Class Constants

NavItemStyle.TYPE = uiConst.NAVITEM

NavItemStyle.__base_style__ = nil

NavItemStyle._CHILDREN = {
	title=true,
	backButton=true,
	leftButton=true,
	rightButton=true,
}

NavItemStyle._VALID_PROPERTIES = {
	debugOn=true,
	width=true,
	height=true,
	anchorX=true,
	anchorY=true,
}

NavItemStyle._EXCLUDE_PROPERTY_CHECK = {
	background=true,
}

NavItemStyle._STYLE_DEFAULTS = {
	name='textfield-default-style',
	debugOn=false,
	width=80,
	height=40,
	anchorX=0.5,
	anchorY=0.5,

	backButton={
		anchorX=0,
		anchorY=0.5,
		align='center',
		hitMarginX=0,
		hitMarginY=0,
		isHitActive=true,
		marginX=0,
		marginY=0,

		inactive={
			label={
				textColor='#007BFF'
			},
			background={
				type='rectangle',
				view={
					height=20,
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		},

		active={
			label={
				textColor={ '#007BFF', 0.5 },
			},
			background={
				type='rectangle',
				view={
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		},

		disabled={
			label={
				textColor={ 0.6,0.6,0.6,0.8 },
			},
			background={
				type='rectangle',
				view={
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		}
	},

	leftButton={
		anchorX=0,
		anchorY=0.5,
		align='center',
		hitMarginX=0,
		hitMarginY=0,
		isHitActive=true,
		marginX=0,
		marginY=0,

		inactive={
			label={
				textColor='#007BFF'
			},
			background={
				type='rectangle',
				view={
					height=20,
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		},

		active={
			label={
				textColor={ '#007BFF', 0.5 },
			},
			background={
				type='rectangle',
				view={
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		},

		disabled={
			label={
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
		}

	},
	rightButton={
		anchorX=1,
		anchorY=0.5,
		align='center',
		hitMarginX=0,
		hitMarginY=0,
		isHitActive=true,
		marginX=0,
		marginY=0,

		inactive={
			label={
				textColor='#007BFF'
			},
			background={
				type='rectangle',
				view={
					height=20,
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		},

		active={
			label={
				textColor={ '#007BFF', 0.5 },
			},
			background={
				type='rectangle',
				view={
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		},

		disabled={
			label={
				textColor={ 0.6,0.6,0.6,0.8 },
			},
			background={
				type='rectangle',
				view={
					fillColor={ 0,0,0,0 },
					strokeWidth=0,
					strokeColor={ 0,0,0,0 },
				}
			}
		}
	},
	title={
		debugOn=false,
		anchorX=0.5,
		anchorY=0.5,
		width=0,
		height=0,

		align='center',
		fillColor={0,0,0,0},
		font=native.systemFont,
		fontSize=16,
		fontSizeMinimum=0,
		marginX=0,
		marginY=0,
		textColor={0,0,0,1},

		strokeColor={0,0,0,0},
		strokeWidth=0,
	},
}


NavItemStyle._TEST_DEFAULTS = {
	name='textfield-default-style',
	debugOn=false,
	width=200,
	height=40,
	anchorX=0.5,
	anchorY=0.5,

	backButton={
	align='center',
	hitMarginX=0,
	hitMarginY=0,
	isHitActive=true,
	marginX=0,
	marginY=0,

	inactive={
		label={
			textColor={0,0,0},
		},
		background={
			type='rounded',
			view={
				cornerRadius=9,
				fillColor={
					type='gradient',
					color1={ 0.9,0.9,0.9 },
					color2={ 0.5,0.5,0.5 },
					direction='down'
				},
				strokeWidth=2,
				strokeColor={0.2,0.2,0.2,1},
			}
		}
	},
	active={
		label={
			textColor={0,0,0},
		},
		background={
			type='rounded',
			view={
				cornerRadius=9,
				fillColor={
					type='gradient',
					color1={ 0.9,0.9,0.9 },
					color2={ 0.5,0.5,0.5 },
					direction='down'
				},
				strokeWidth=2,
				strokeColor={0.2,0.2,0.2,1},
			}
		}

	},
	disabled={
		label={
			textColor={0,0,0},
		},
		background={
			type='rounded',
			view={
				cornerRadius=9,
				fillColor={
					type='gradient',
					color1={ 0.9,0.9,0.9 },
					color2={ 0.5,0.5,0.5 },
					direction='down'
				},
				strokeWidth=2,
				strokeColor={0.2,0.2,0.2,1},
			}
		}
	}
	},
	leftButton={
		align='center',
		hitMarginX=0,
		hitMarginY=0,
		isHitActive=true,
		marginX=0,
		marginY=0,

		inactive={
			label={
				textColor={0,0,0},
			},
			background={
				type='rounded',
				view={
					cornerRadius=9,
					fillColor={
						type='gradient',
						color1={ 0.9,0.9,0.9 },
						color2={ 0.5,0.5,0.5 },
						direction='down'
					},
					strokeWidth=2,
					strokeColor={0.2,0.2,0.2,1},
				}
			}

		},
		active={
			label={
				textColor={0,0,0},
			},
			background={
				type='rounded',
				view={
					cornerRadius=9,
					fillColor={
						type='gradient',
						color1={ 0.9,0.9,0.9 },
						color2={ 0.5,0.5,0.5 },
						direction='down'
					},
					strokeWidth=2,
					strokeColor={0.2,0.2,0.2,1},
				}
			}

		},
		disabled={
			label={
				textColor={0,0,0},
			},
			background={
				type='rounded',
				view={
					cornerRadius=9,
					fillColor={
						type='gradient',
						color1={ 0.9,0.9,0.9 },
						color2={ 0.5,0.5,0.5 },
						direction='down'
					},
					strokeWidth=2,
					strokeColor={0.2,0.2,0.2,1},
				}
			}
		}

	},
	rightButton={
		align='center',
		hitMarginX=0,
		hitMarginY=0,
		isHitActive=true,
		marginX=0,
		marginY=0,

		inactive={
			label={
				textColor={0,0,0},
			},
			background={
				type='rounded',
				view={
					cornerRadius=9,
					fillColor={
						type='gradient',
						color1={ 0.9,0.9,0.9 },
						color2={ 0.5,0.5,0.5 },
						direction='down'
					},
					strokeWidth=2,
					strokeColor={0.2,0.2,0.2,1},
				}
			}

		},
		active={
			label={
				textColor={0,0,0},
			},
			background={
				type='rounded',
				view={
					cornerRadius=9,
					fillColor={
						type='gradient',
						color1={ 0.9,0.9,0.9 },
						color2={ 0.5,0.5,0.5 },
						direction='down'
					},
					strokeWidth=2,
					strokeColor={0.2,0.2,0.2,1},
				}
			}

		},
		disabled={
			label={
				textColor={0,0,0},
			},
			background={
				type='rounded',
				view={
					cornerRadius=9,
					fillColor={
						type='gradient',
						color1={ 0.9,0.9,0.9 },
						color2={ 0.5,0.5,0.5 },
						direction='down'
					},
					strokeWidth=2,
					strokeColor={0.2,0.2,0.2,1},
				}
			}
		}

	},
	title={

		anchorX=0.5,
		anchorY=0.5,

		align='center',
		fillColor={0,0,0,0},
		font=native.systemFont,
		fontSize=16,
		marginX=0,
		marginY=0,
		textColor={0,0,0,1},

		strokeColor={0,0,0,0},
		strokeWidth=0,
	},
}

NavItemStyle.MODE = uiConst.RUN_MODE
NavItemStyle._DEFAULTS = NavItemStyle._STYLE_DEFAULTS

--== Event Constants

NavItemStyle.EVENT = 'navbar-style-event'


--======================================================--
-- Start: Setup DMC Objects

function NavItemStyle:__init__( params )
	-- print( "NavItemStyle:__init__", params )
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

	--== Object Refs ==--

	-- these are other style objects
	self._title = nil -- text Style
	self._backButton = nil -- button Style
	self._leftButton = nil -- button Style
	self._rightButton = nil -- button Style

end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Static Methods


function NavItemStyle.initialize( manager, params )
	-- print( "NavItemStyle.initialize", manager )
	params = params or {}
	if params.mode==nil then params.mode=uiConst.RUN_MODE end
	--==--
	Style = manager

	if params.mode==uiConst.TEST_MODE then
		NavItemStyle.MODE = params.mode
		NavItemStyle._DEFAULTS = NavItemStyle._TEST_DEFAULTS
	end
	local defaults = NavItemStyle._DEFAULTS

	NavItemStyle._setDefaults( NavItemStyle, {defaults=defaults} )

end


function NavItemStyle.createStyleStructure( src )
	-- print( "NavItemStyle.createStyleStructure", src )
	src = src or {}
	--==--
	local ButtonStyleClass = Style.Button
	return {
		title=Style.Text.createStyleStructure( src.title ),
		backButton=ButtonStyleClass.createStyleStructure( src.backButton ),
		leftButton=ButtonStyleClass.createStyleStructure( src.leftButton ),
		rightButton=ButtonStyleClass.createStyleStructure( src.rightButton ),
	}
end


function NavItemStyle.addMissingDestProperties( dest, src )
	-- print( "NavItemStyle.addMissingDestProperties", dest, src )
	assert( dest )
	--==--
	local srcs = { NavItemStyle._DEFAULTS }
	if src then tinsert( srcs, 1, src ) end

	dest = BaseStyle.addMissingDestProperties( dest, src )

	-- for i=1,#srcs do
	-- 	local src = srcs[i]
	-- end

	dest = NavItemStyle._addMissingChildProperties( dest, src )

	return dest
end


-- _addMissingChildProperties()
-- copy properties to sub-styles
--
function NavItemStyle._addMissingChildProperties( dest, src )
	-- print("NavItemStyle._addMissingChildProperties", dest, srcs )
	assert( dest )
	src = dest
	--==--
	local eStr = "ERROR: Style (NavItemStyle) missing property '%s'"
	local StyleClass, child

	child = dest.title
	assert( child, sfmt( eStr, 'title' ) )
	StyleClass = Style.Text
	dest.title = StyleClass.addMissingDestProperties( child, src )

	StyleClass = Style.Button

	child = dest.backButton
	assert( child, sfmt( eStr, 'backButton' ) )
	dest.backButton = StyleClass.addMissingDestProperties( child, src )

	child = dest.leftButton
	assert( child, sfmt( eStr, 'leftButton' ) )
	dest.leftButton = StyleClass.addMissingDestProperties( child, src )

	child = dest.rightButton
	assert( child, sfmt( eStr, 'rightButton' ) )
	dest.rightButton = StyleClass.addMissingDestProperties( child, src )

	return dest
end


function NavItemStyle.copyExistingSrcProperties( dest, src, params)
	-- print( "NavItemStyle.copyMissingProperties", dest, src )
	assert( dest )
	if not src then return end
	params = params or {}
	if params.force==nil then params.force=false end
	--==--
	local force=params.force

	dest = BaseStyle.copyExistingSrcProperties( dest, src, params )

	return dest
end


function NavItemStyle._verifyStyleProperties( src, exclude )
	-- print("NavItemStyle._verifyStyleProperties", src, exclude )
	assert( src, "NavItemStyle:verifyStyleProperties requires source" )
	--==--
	local emsg = "Style (NavItemStyle) requires property '%s'"

	local is_valid = BaseStyle._verifyStyleProperties( src, exclude )

	local child, StyleClass

	child = src.title
	if not child then
		print( "NavItemStyle child test skipped for 'title'" )
		is_valid=false
	else
		StyleClass = Style.Text
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	StyleClass = Style.Button

	child = src.backButton
	if not child then
		print( "NavItemStyle child test skipped for 'backButton'" )
		is_valid=false
	else
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.leftButton
	if not child then
		print( "NavItemStyle child test skipped for 'leftButton'" )
		is_valid=false
	else
		if not StyleClass._verifyStyleProperties( child, exclude ) then
			is_valid=false
		end
	end

	child = src.rightButton
	if not child then
		print( "NavItemStyle child test skipped for 'rightButton'" )
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

--== Title

function NavItemStyle.__getters:title()
	-- print( "NavItemStyle.__getters:title", data )
	return self._title
end
function NavItemStyle.__setters:title( data )
	-- print( "NavItemStyle.__setters:title", data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Text
	local inherit = self._inherit and self._inherit._title or self._inherit

	self._title = StyleClass:createStyleFrom{
		name=nil,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== Back Button

function NavItemStyle.__getters:backButton()
	-- print( 'NavItemStyle.__getters:backButton', self._backButton )
	return self._backButton
end
function NavItemStyle.__setters:backButton( data )
	-- print( 'NavItemStyle.__setters:backButton', data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Button
	local inherit = self._inherit and self._inherit._backButton or self._inherit

	self._backButton = StyleClass:createStyleFrom{
		name=nil,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== Left Button

function NavItemStyle.__getters:leftButton()
	-- print( 'NavItemStyle.__getters:leftButton', self._leftButton )
	return self._leftButton
end
function NavItemStyle.__setters:leftButton( data )
	-- print( 'NavItemStyle.__setters:leftButton', data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Button
	local inherit = self._inherit and self._inherit._leftButton or self._inherit

	self._leftButton = StyleClass:createStyleFrom{
		name=nil,
		inherit=inherit,
		parent=self,
		data=data
	}
end

--== Right Button

function NavItemStyle.__getters:rightButton()
	-- print( 'NavItemStyle.__getters:rightButton', self._rightButton )
	return self._rightButton
end
function NavItemStyle.__setters:rightButton( data )
	-- print( 'NavItemStyle.__setters:rightButton', data )
	assert( data==nil or type( data )=='table' )
	--==--
	local StyleClass = Style.Button
	local inherit = self._inherit and self._inherit._rightButton or self._inherit

	self._rightButton = StyleClass:createStyleFrom{
		name=nil,
		inherit=inherit,
		parent=self,
		data=data
	}
end



--====================================================================--
--== Private Methods


function NavItemStyle:_doChildrenInherit( value )
	-- print( "NavItemStyle:_doChildrenInherit", value )
	if not self._isInitialized then return end

	self._title.inherit = value and value.title or value
	self._backButton.inherit = value and value.backButton or value
	self._leftButton.inherit = value and value.leftButton or value
	self._rightButton.inherit = value and value.rightButton or value
end


function NavItemStyle:_clearChildrenProperties( style, params )
	-- print( "NavItemStyle:_clearChildrenProperties", style, self )
	assert( style==nil or type(style)=='table' )
	if style and type(style.isa)=='function' then
		assert( style:isa(NavItemStyle) )
	end
	--==--
	local substyle

	substyle = style and style.title
	self._title:_clearProperties( substyle, params )

	substyle = style and style.backButton
	self._backButton:_clearProperties( substyle, params )

	substyle = style and style.leftButton
	self._leftButton:_clearProperties( substyle, params )

	substyle = style and style.rightButton
	self._rightButton:_clearProperties( substyle, params )
end


function NavItemStyle:_destroyChildren()
	self._title:removeSelf()
	self._title=nil

	self._backButton:removeSelf()
	self._backButton=nil

	self._leftButton:removeSelf()
	self._leftButton=nil

	self._rightButton:removeSelf()
	self._rightButton=nil
end


function NavItemStyle:_prepareData( data, dataSrc, params )
	-- print("NavItemStyle:_prepareData", data, self )
	params = params or {}
	--==--
	-- local inherit = params.inherit
	local StyleClass
	local src, dest, tmp

	if not data then
		data = NavItemStyle.createStyleStructure( dataSrc )
	end

	src, dest = data, nil

	--== make sure we have structure for children

	StyleClass = Style.Text
	if not src.title then
		tmp = dataSrc and dataSrc.title
		src.title = StyleClass.createStyleStructure( tmp )
	end

	StyleClass = Style.Button
	if not src.backButton then
		tmp = dataSrc and dataSrc.backButton
		src.backButton = StyleClass.createStyleStructure( tmp )
	end
	if not src.leftButton then
		tmp = dataSrc and dataSrc.leftButton
		src.leftButton = StyleClass.createStyleStructure( tmp )
	end
	if not src.rightButton then
		tmp = dataSrc and dataSrc.rightButton
		src.rightButton = StyleClass.createStyleStructure( tmp )
	end

	--== process children

	dest = src.title
	src.title = Style.Text.copyExistingSrcProperties( dest, src )

	dest = src.backButton
	src.backButton = StyleClass.copyExistingSrcProperties( dest, src )

	dest = src.leftButton
	src.leftButton = StyleClass.copyExistingSrcProperties( dest, src )

	dest = src.rightButton
	src.rightButton = StyleClass.copyExistingSrcProperties( dest, src )

	return data
end



--====================================================================--
--== Event Handlers


-- none




return NavItemStyle
