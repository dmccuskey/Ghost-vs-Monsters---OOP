--====================================================================--
-- service/megaphone.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2015 David McCuskey. All Rights Reserved.
--====================================================================--



--====================================================================--
--== Ghost vs Monsters : Megaphone
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Megaphone = require 'lib.dmc_corona.dmc_megaphone'



--====================================================================--
--== Megaphone Message Setup
--====================================================================--


--======================================================--
-- Pause Gameplay Message

--[[

Overview

this message is to be used when gameplay is to be paused
this is typically used by the App Controller during
System Events such as 'applicationSuspend' and 'applicationResume'

Data

None. there is no data sent with message

--]]

Megaphone.PAUSE_GAMEPLAY = 'pause-gameplay'


--======================================================--
-- Resume Gameplay Message

--[[

Overview

this message is to be used when gameplay is to be resume
this is typically used by the App Controller during
System Events such as 'applicationSuspend' and 'applicationResume'

Data

None. there is no data sent with message

--]]

Megaphone.RESUME_GAMEPLAY = 'resume-gameplay'




return Megaphone
