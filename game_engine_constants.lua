--====================================================================--
-- game_engine_constants.lua
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
--====================================================================--


local GameEngineConstants = {}


--== Game Engine Event and Event Types
GameEngineConstants.GAME_ENGINE_EVENT = "gameEngineEvent"

GameEngineConstants.GAME_ISACTIVE = "gameIsActive"
GameEngineConstants.GAME_OVER_EVENT = "gameOverEvent"
GameEngineConstants.GAME_EXIT_EVENT = "gameExitEvent"
GameEngineConstants.CHARACTER_REMOVED = "characterIsRemoved"


--== Game Engine States and Transitions
GameEngineConstants.STATE_INIT = "state_initialize"

GameEngineConstants.TO_NEW_ROUND = "trans_new_round"
GameEngineConstants.STATE_NEW_ROUND = "state_new_round"

GameEngineConstants.TO_AIMING_SHOT = "trans_aiming_shot"
GameEngineConstants.AIMING_SHOT = "state_aiming_shot"

GameEngineConstants.TO_SHOT_IN_PLAY = "trans_shot_in_play"
GameEngineConstants.STATE_SHOT_IN_PLAY = "state_shot_in_play"

GameEngineConstants.TO_END_ROUND = "trans_end_round"
GameEngineConstants.STATE_END_ROUND = "state_end_round"

GameEngineConstants.TO_CALL_ROUND = "trans_call_round"
GameEngineConstants.STATE_END_GAME = "state_end_game"


return GameEngineConstants
