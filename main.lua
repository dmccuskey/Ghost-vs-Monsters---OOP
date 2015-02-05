--====================================================================--
-- Ghosts vs Monsters sample project, OOP version
--
-- OOP version by David McCuskey
-- Original designed and created by Jonathan & Biffy Beebe
-- of Beebe Games exclusively for Ansca, Inc.
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--


print( '\n\n##############################################\n\n' )


--====================================================================--
--== Ghost vs Monsters : main
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Setup, Constants


local Controller = nil -- set in main()

local open_feint_params = nil
--[[
-- uncomment this section and put in Open Feint info
-- to enable Open Feint
open_feint_params = nil {
	app_key='your-app-key',
	app_secret='your-app-secret',
	app_title='Ghost vs. Monsters',
	app_id='your-app-id',
}
--]]

_G.gMODE = 'TEST'  -- 'TEST'/'RUN'



--====================================================================--
--== Main
--====================================================================--


if gMODE == 'TEST' then
	Controller = require 'test_controller'
else
	Controller = require 'app_controller'
end

assert( Controller, "GvsM Main: Error loading Controller" )

local params = {
	-- put here any params required for App or Test here
	open_feint=open_feint_params
}
Controller.run( params )
