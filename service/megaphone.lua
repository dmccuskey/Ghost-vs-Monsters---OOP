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

local VERSION = "0.1.1"



--====================================================================--
--== Imports


local Megaphone = require 'lib.dmc_corona.dmc_megaphone'



--====================================================================--
--== Megaphone Message Setup
--====================================================================--


--======================================================--
-- Pause Gameplay Message

Megaphone.PAUSE_GAMEPLAY = 'pause-gameplay'

--[[

Overview

this message is to be used when gameplay is to be paused
this is used by the App Controller when it has received
the System Event 'applicationSuspend'

Sequence
App Controller >> Component

Data
None (there is no data sent with message)

--]]


--======================================================--
-- Resume Gameplay Message

Megaphone.RESUME_GAMEPLAY = 'resume-gameplay'

--[[

Overview

this message is to be used when gameplay is to be paused
this is used by the App Controller when it has received
the System Event 'applicationResume'

Sequence
App Controller >> Component

Data
None (there is no data sent with message)

--]]





return Megaphone
