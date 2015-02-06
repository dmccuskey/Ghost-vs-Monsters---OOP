--====================================================================--
-- scene/game/gameover_overlay.lua
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011-2015 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--

--[[
the anchor for this view is Top Center
--]]

--====================================================================--
--== Ghost vs Monsters : Game Over Overlay
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.0"



--====================================================================--
--== Imports


local AppUtils = require 'lib.app_utils'
local Objects = require 'lib.dmc_corona.dmc_objects'
local Utils = require 'lib.dmc_corona.dmc_utils'
local Widgets = require 'lib.dmc_widgets'



--====================================================================--
--== Setup, Constants


local newClass = Objects.newClass
local ComponentBase = Objects.ComponentBase

local tinsert = table.insert
local tremove = table.remove

local LOCAL_DEBUG = false



--====================================================================--
--== Level Screen Class
--====================================================================--


local GameOver = newClass( ComponentBase, {name="Game Over Overlay"} )

--== Class Constants

GameOver.WIN_GAME = 'win'
GameOver.LOSE_GAME = 'lose'


--== Event Constants

GameOver.EVENT = 'game-over-event'

GameOver.FACEBOOK = 'facebook-selected'
GameOver.MENU = 'menu-selected'
GameOver.NEXT = 'next-selected'
GameOver.OPEN_FEINT = 'open-feint-selected'
GameOver.REPLAY = 'replay-selected'


--======================================================--
-- Start: Setup DMC Objects

-- __init__()
--
-- one of the base methods to override for dmc_objects
--
function GameOver:__init__( params )
	self:superCall( '__init__', params )
	params = params or {}
	--==--

	--== Sanity Check

	assert( params.width and params.height, "Level Overlay requires params 'width' & 'height'")


	--== Properties

	self._width = params.width
	self._height = params.height

	self._outcome = "" -- WIN_GAME/LOSE_GAME
	self._bestscore = 2000
	self._score = 2000

	--== Objects

	self._sound_mgr = gService.sound_mgr

	--== Display Objects

	self._primer = nil -- test

	self._shade = nil

	self._txt_score = nil
	self._txt_best = nil

	self._btn_feint = nil
	self._btn_facebook = nil

	self._img_win = nil
	self._img_lose = nil

	self._btn_menu = nil
	self._btn_replay = nil
	self._btn_next = nil

end


-- __createView__()
--
-- one of the base methods to override for dmc_objects
--
function GameOver:__createView__()
	self:superCall( '__createView__' )
	--==--
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5

	local o, tmp

	-- setup display primer

	o = display.newRect( 0, 0, W, 10)
	o.anchorX, o.anchorY = 0.5, 0
	o:setFillColor(0,0,0,0)
	if LOCAL_DEBUG then
		o:setFillColor(1,0,0,0.75)
	end
	o.x, o.y = 0, 0

	self:insert( o )
	self._primer = o

	-- Shading

	o = display.newRect( 0, 0, W, H )
	o.anchorX, o.anchorY = 0.5, 0
	o:setFillColor( 0, 0, 0, 0.8 )
	o.x, o.y = 0, 0

	self:insert( o )
	self._shade = o

	-- Score display

	o = display.newText( "0", 470, 22, "Helvetica-Bold", 52 )
	o:setTextColor( 1,1,1,1 ) --> white
	o.xScale, o.yScale = 0.5, 0.5	--> for clear retina display text
	o.anchorX, o.anchorY = 0.5, 0
	--txt.x = ( 480 - ( txt.contentWidth * 0.5 ) ) - 15
	o.y = 30

	self:insert( o )
	self._txt_score = o

	-- Best SCORE DISPLAY
	o = display.newText( "0", 10, 300, "Helvetica-Bold", 32 )
	o:setTextColor( 228, 228, 228, 255 )
	o.xScale, o.yScale = 0.5, 0.5	--> for clear retina display text

	self:insert( o )
	self._txt_best = o

	-- Open Feint button

	o = Widgets.newPushButton{
		id='feint-button',
		view='image',
		file='assets/buttons/openfeintbtn.png',
		width=168, height=40,
		active={
			file='assets/buttons/openfeintbtn-over.png'
		}
	}

	self:insert( o.view )
	self._btn_feint = o


	-- facebook Button

	o = Widgets.newPushButton{
		id='facebook-button',
		view='image',
		file='assets/buttons/facebookbtn.png',
		width=302, height=40,
		active={
			file='assets/buttons/facebookbtn-over.png'
		}
	}

	self:insert( o.view )
	self._btn_facebook = o

	-- "you win" background

	o = display.newImageRect( 'assets/backgrounds/youwin.png', 390, 154 )
	o.anchorX, o.anchorY = 0.5, 0

	self:insert( o )
	self._img_win = o

	-- "you lose" background

	o = display.newImageRect( 'assets/backgrounds/youlose.png', 390, 154 )
	o.anchorX, o.anchorY = 0.5, 0

	self:insert( o )
	self._img_lose = o

	-- menu Button

	o = Widgets.newPushButton{
		id='menu-button',
		view='image',
		file='assets/buttons/menubtn.png',
		width=60, height=60,
		active={
			file='assets/buttons/menubtn-over.png'
		}
	}
	o.x, o.y = 0, 186

	self:insert( o.view )
	self._btn_menu = o

	-- replay Button

	o = Widgets.newPushButton{
		id='replay-button',
		view='image',
		file='assets/buttons/restartbtn.png',
		width=60, height=60,
		active={
			file='assets/buttons/restartbtn-over.png'
		}
	}
	o.x, o.y = 0, 186

	self:insert( o.view )
	self._btn_replay = o

	-- next Button

	o = Widgets.newPushButton{
		id='next-button',
		view='image',
		file='assets/buttons/nextlevelbtn.png',
		width=60, height=60,
		active={
			file='assets/buttons/nextlevelbtn-over.png'
		}
	}
	o.x, o.y = 0, 186

	self:insert( o.view )
	self._btn_next = o

end
-- __undoCreateView__()
--
-- one of the base methods to override for dmc_objects
--
function GameOver:__undoCreateView__()
	local o

	o = self._btn_next
	o:removeSelf()
	self._btn_next = nil

	o = self._btn_replay
	o:removeSelf()
	self._btn_replay = nil

	o = self._btn_menu
	o:removeSelf()
	self._btn_menu = nil

	o = self._img_lose
	o:removeSelf()
	self._img_lose = nil

	o = self._img_win
	o:removeSelf()
	self._img_win = nil

	o = self._btn_facebook
	o:removeSelf()
	self._btn_facebook = nil

	o = self._btn_feint
	o:removeSelf()
	self._btn_feint = nil

	o = self._txt_best
	o:removeSelf()
	self._txt_best = nil

	o = self._txt_score
	o:removeSelf()
	self._txt_score = nil

	o = self._shade
	o:removeSelf()
	self._shade = nil

	o = self._primer
	o:removeSelf()
	self._primer = nil

	--==--
	self:superCall( '__undoCreateView__' )
end


-- __initComplete__()
--
function GameOver:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	self._btn_facebook.onRelease = self:createCallback( self._buttonEvent_handler )
	self._btn_menu.onRelease = self:createCallback( self._buttonEvent_handler )
	self._btn_next.onRelease = self:createCallback( self._buttonEvent_handler )
	self._btn_replay.onRelease = self:createCallback( self._buttonEvent_handler )
	self._btn_feint.onRelease = self:createCallback( self._buttonEvent_handler )

	-- self:hide()
end

-- __undoInitComplete__()
--
function GameOver:__undoInitComplete__()
	self._btn_feint.onRelease = nil
	self._btn_facebook.onRelease = nil
	self._btn_menu.onRelease = nil
	self._btn_replay.onRelease = nil
	self._btn_next.onRelease = nil
	--==--
	self:superCall( '__undoCreateView__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function GameOver:show( params )
	-- print( "GameOver:show", params )
	params = params or {}
	self:superCall( 'show', params )
	--==--
	assert( type(params.outcome)=='string' )
	assert( type(params.score)=='number' )
	assert( type(params.bestscore)=='number' )

	self:_updateView( params )

	if params.outcome==GameOver.WIN_GAME then
		self._sound_mgr:play( self._sound_mgr.YOU_WIN )
	else
		self._sound_mgr:play( self._sound_mgr.YOU_LOSE )
	end

end

-- function GameOver:hide()
-- 	print( "GameOver:hide" )
-- end


--====================================================================--
--== Private Methods


function GameOver:_updateWin( params )
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5
	local H_MARGIN, V_MARGIN = 10, 5
	local PAD = 15
	local o, tmp

	-- score text
	o = self._txt_score
	o.isVisible = false
	o.text = "Score: "..tostring( AppUtils.comma_value(params.score) )
	o.anchorX, o.anchorY = 1, 0
	o.x, o.y = H_CENTER-H_MARGIN, V_MARGIN
	timer.performWithDelay( 1000, function() self._txt_score.isVisible = true; end )

	-- facebook button
	o = self._btn_facebook
	o.x, o.y = 0, 200
	o.isVisible = true
	o.alpha = 0
	transition.to( o, { time=500, alpha=1, y=250, transition=easing.inOutExpo } )

	-- menu button
	o = self._btn_menu
	o.x, o.y = -10, V_CENTER+20

	-- replay button
	tmp = self._btn_menu
	o = self._btn_replay
	o.x, o.y = tmp.x+tmp.width+PAD,tmp.y

	-- next button
	tmp = self._btn_replay
	o = self._btn_next
	o.x, o.y = tmp.x+tmp.width+PAD,tmp.y
	o.isVisible = true
	o.alpha = 0
	transition.to( o, { time=500, alpha=1 } )

	--== Win/Lose image
	o = self._img_lose
	o.isVisible = false

	o = self._img_win
	o.isVisible = true
	o.alpha = 0
	transition.to( o, { time=200, alpha=1 } )

end
function GameOver:_updateLose()
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5
	local PAD = 15
	local o, tmp

	-- score text
	o = self._txt_score
	o.isVisible = false

	-- facebook button
	o = self._btn_facebook
	o.isVisible = false

	-- menu button
	o = self._btn_menu
	o.x, o.y = 25, V_CENTER+20

	-- replay button
	tmp = self._btn_menu
	o = self._btn_replay
	o.x, o.y = tmp.x+tmp.width+PAD,tmp.y

	-- next button
	o = self._btn_next
	o.isVisible = false

	--== Win/Lose image
	o = self._img_win
	o.isVisible = false

	o = self._img_lose
	o.isVisible = true
	o.alpha = 0
	transition.to( o, { time=200, alpha=1 } )

end

-- this can be called whenever
--
function GameOver:_updateView( params )
	-- print( "GameOver:_updateView", params )
	local W, H = self._width , self._height
	local H_CENTER, V_CENTER = W*0.5, H*0.5
	local H_MARGIN, V_MARGIN = 10, 5
	local PAD = 72

	local o, tmp

	o=self._img_lose
	o.x, o.y = 0, V_CENTER-o.height/2
	o=self._img_win
	o.x, o.y = 0, V_CENTER-o.height/2

	if params.outcome==GameOver.WIN_GAME then
		self:_updateWin( params )
	else
		self:_updateLose( params )
	end

	-- background
	o = self._shade
	o.alpha = 0
	transition.to( o, { time=200, alpha=0.65 } )

	-- best score text
	o = self._txt_best
	o.text = "Best Score For This Level: "..tostring( AppUtils.comma_value(params.bestscore ))
	o.anchorX, o.anchorY = 0, 1
	o.x, o.y = -H_CENTER+H_MARGIN, H-V_MARGIN

	-- menu button
	o = self._btn_menu
	o.alpha = 0
	transition.to( o, { time=500, alpha=1 } )

	-- replay button
	tmp = self._btn_menu
	o = self._btn_replay
	o.alpha = 0
	transition.to( o, { time=500, alpha=1 } )

	-- feint button
	o = self._btn_feint
	o.isVisible = true
	o.x, o.y = -o.width/2+20, 110
	o.alpha = 1
	transition.to( o, { time=500, alpha=1, y=68, transition=easing.inOutExpo } )

end


function GameOver:_doOpenFeintRequest()

	-- Launch OpenFeint Leaderboards Panel:
	--openfeint.launchDashboard("leaderboards")
end


function GameOver:_doFacebookRequest()
	-- Code to Post Status to Facebook (don't forget the 'require "facebook"' line at top of module)
	-- The Code below is fully functional as long as you replace the fbAppID var with valid app ID.

	--[[
	local fbAppID = "1234567890"	--> (string) Your FB App ID from facebook developer's panel

	local facebookListener = function( event )
		if ( "session" == event.type ) then
			-- upon successful login, update their status
			if ( "login" == event.phase ) then

				local scoreToPost = comma_value(gameScore)

				local statusUpdate = "just scored a " .. gameScore .. " on Ghosts v.s Monsters!"

				facebook.request( "me/feed", "POST", {
					message=statusUpdate,
					name="Download Ghosts vs. Monsters to Compete with Me!",
					caption="Ghosts vs. Monsters - Sample app created with the Corona SDK by Ansca Mobile.",
					link="http://itunes.apple.com/us/app/your-app-name/id382456881?mt=8",
					picture="http://www.yoursite.com/link-to-90x90-image.png" } )
			end
		end
	end

	facebook.login( fbAppID, facebookListener, { "publish_stream" } )
	]]--
end



--====================================================================--
--== Event Handlers


function GameOver:_buttonEvent_handler( event )
	-- print( "GameOver:_buttonEvent_handler" )
	local id = event.id
	self._sound_mgr:play( self._sound_mgr.TAP )

	if id=='facebook-button' then
		self:_doFacebookRequest()
		self:dispatchEvent( self.FACEBOOK )

	elseif id=='menu-button' then
		self:dispatchEvent( self.MENU )

	elseif id=='next-button' then
		self:dispatchEvent( self.NEXT )

	elseif id=='feint-button' then
		self:_doOpenFeintRequest()
		self:dispatchEvent( self.OPEN_FEINT )

	elseif id=='replay-button' then
		self:dispatchEvent( self.REPLAY )

	end
end




return GameOver
