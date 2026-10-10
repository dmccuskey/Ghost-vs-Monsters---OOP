--====================================================================--
-- dmc_ui/ui_palette.lua
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
--== DMC Corona UI : UI Palette
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Palette
--====================================================================--


-- ten colors, each with a darker partner (for a pressed state or a border),
-- as { r, g, b } with values of 0 to 1: use one where a style takes a color
-- ( fillColor=Palette.blue ), or unpack() it for a plain display object.
-- the library's default styles are drawn from slate, gray and cloud

local Palette = {

	red={ 0.86, 0.30, 0.27 },
	redDark={ 0.72, 0.22, 0.20 },

	orange={ 0.91, 0.54, 0.22 },
	orangeDark={ 0.80, 0.43, 0.13 },

	yellow={ 0.95, 0.77, 0.25 },
	yellowDark={ 0.85, 0.65, 0.13 },

	green={ 0.24, 0.70, 0.44 },
	greenDark={ 0.17, 0.57, 0.34 },

	teal={ 0.16, 0.66, 0.65 },
	tealDark={ 0.11, 0.53, 0.53 },

	blue={ 0.22, 0.56, 0.80 },
	blueDark={ 0.15, 0.44, 0.67 },

	purple={ 0.58, 0.36, 0.72 },
	purpleDark={ 0.46, 0.26, 0.60 },

	slate={ 0.24, 0.32, 0.40 },
	slateDark={ 0.17, 0.24, 0.31 },

	gray={ 0.62, 0.66, 0.70 },
	grayDark={ 0.47, 0.51, 0.55 },

	cloud={ 0.94, 0.95, 0.96 },
	cloudDark={ 0.82, 0.84, 0.87 },

}



return Palette
