--====================================================================--
-- hud_objects.lua
--
-- by David McCuskey
--
-- Sample code is MIT licensed, the same license which covers Lua itself
-- http://en.wikipedia.org/wiki/MIT_License
-- Copyright (C) 2011 David McCuskey. All Rights Reserved.
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--====================================================================--

--====================================================================--
-- Imports
--====================================================================--

local Objects = require( "dmc_objects" )
local Utils = require( "dmc_utils" )
local Buttons = require( "dmc_buttons" )
local BinaryButton = Buttons.BinaryButton
--local facebook = require( "facebook" )

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local CoronaBase = Objects.CoronaBase


--====================================================================--
-- Setup, Constants
--====================================================================--

local tapSound = audio.loadSound( "assets/sounds/tapsound.wav" )


--====================================================================--
-- Support Functions
--====================================================================--

-- comma_value()
--
local function comma_value( amount )
	local formatted = amount
	while true do
		formatted, k = string.gsub( formatted, "^(-?%d+)(%d%d%d)", '%1,%2' )
		if ( k==0 ) then
			break
		end
	end

	return formatted
end


--====================================================================--
-- Load Screen HUD class
--====================================================================--

local LoadScreenHUD = inheritsFrom( CoronaBase )
LoadScreenHUD.NAME = "Load Screen HUD"

LoadScreenHUD.BAR_WIDTH = 300
LoadScreenHUD.BAR_HEIGHT = 10

-- _init()
--
-- one of the base methods to override for dmc_objects
--
function LoadScreenHUD:_init( options )

	-- don't forget this !!!
	self:superCall( "_init" )

	--==  Create Properties  ==--
	self.timer = nil
	self._text = ""
	self._percentComplete = 0
	self._refs = {}

end
-- _init()
--
function LoadScreenHUD:_undoInit()
	timer.cancel( self.timer )
	self.timer = nil
	self.percentComplete = 0
	Utils.destroy( self._refs )
end

-- _createView()
--
-- one of the base methods to override for dmc_objects
--
function LoadScreenHUD:_createView()

	local refs = self._refs
	local bar_y = 100
	local img

	img = display.newImageRect( "assets/backgrounds/loading.png", 480, 320 )

	self:insert( img )

	-- loading bar
	img = display.newRect( 0, 0, LoadScreenHUD.BAR_WIDTH, LoadScreenHUD.BAR_HEIGHT )
	img.strokeWidth = 0
	img:setStrokeColor( 0, 0, 0, 0 )
	img:setFillColor( 255, 255, 255, 255 )

	refs.bar = img

	self:insert( img )
	img:setReferencePoint( display.CenterLeftReferencePoint )
	--img.x = ( 480 - LoadScreenHUD.BAR_WIDTH ) / 2 ; img.y = 85
	img.y = bar_y

	-- loading bar outline
	img = display.newRect( 0, 0, LoadScreenHUD.BAR_WIDTH, LoadScreenHUD.BAR_HEIGHT )
	img.strokeWidth = 2
	img:setStrokeColor( 200, 200, 200, 255 )
	img:setFillColor( 0, 0, 0, 0 )

	refs.outline = img

	self:insert( img )
	img.x = 0 ; img.y = bar_y

end
-- _undoCreateView()
--
function LoadScreenHUD:_undoCreateView()
	for i=self.display.numChildren, 1, -1 do
		self.display[ i ]:removeSelf()
	end
end

-- _initComplete()
--
function LoadScreenHUD:_initComplete()
	self.x = 240 ; self.y = 160
	self:clear()
end

--== Class Methods


-- gameLives
--
function LoadScreenHUD.__getters:percentComplete()
	return self._percentComplete
end
function LoadScreenHUD.__setters:percentComplete( value )
	local refs = self._refs
	local width = 480

	-- sanitize
	if value < 0 then value = 0 end
	if value > 100 then value = 100 end

	self._percentComplete = value

	-- calculate bar coords
	local width = LoadScreenHUD.BAR_WIDTH * ( value / 100 )

	if width == 0 then
		refs.bar.isVisible = false
	else
		refs.bar.isVisible = true
		refs.bar.width = width

		refs.bar.x = - (LoadScreenHUD.BAR_WIDTH / 2 ) - ( LoadScreenHUD.BAR_WIDTH - refs.bar.width ) / 2
	end

	if self._percentComplete >= 100 then
		self:dispatchEventComplete()
	end
end


-- clear()
--
-- initialize load screen to beginnings
--
function LoadScreenHUD:clear()
	self.percentComplete = 0
	self.text = ""
end

-- dispatchEventComplete
--
function LoadScreenHUD:dispatchEventComplete()
	--print( "LoadScreenHUD:dispatchEventComplete " )

	self:dispatchEvent( { name="complete" } )

end


--====================================================================--
-- Pause Screen class
--====================================================================--


local PauseScreenHUD = inheritsFrom( CoronaBase )
PauseScreenHUD.NAME = "Pause Screen"


-- _init()
--
-- one of the base methods to override for dmc_objects
--
function PauseScreenHUD:_init( options )

	-- don't forget this !!!
	self:superCall( "_init" )

	--==  Create Properties  ==--
	self._toggleItems = nil
	self._toggleButton = nil
	self._pauseIsActive = false

end
-- _undoInit()
--
function PauseScreenHUD:_undoInit( options )
	--print( "PauseScreenHUD:_undoInit" )
	self._toggleItems = nil
	self._toggleButton = nil
	self._pauseIsActive = false
end

-- _createView()
--
-- one of the base methods to override for dmc_objects
--
function PauseScreenHUD:_createView()

	local img, btn
	local d = display.newGroup()

	self:insert( d )

	-- shade rectangle
	img = display.newRect( 0, 0, 480, 320 )
	img:setFillColor( 0, 0, 0, 255 )
	img.alpha = 0.5

	d:insert( img )
	self._toggleItems = d

	-- main menu button
	btn = Buttons.create( "push", {
		id="menu-button",
		width=44, height=44,
		defaultSrc = "assets/buttons/pausemenubtn.png",
		downSrc = "assets/buttons/pausemenubtn-over.png",
	})
	btn:addEventListener( "touch", Utils.createObjectCallback( self, self.buttonHandler ) )

	d:insert( btn.display )
	btn.x = 38 ; btn.y = 288

	-- pause button
	btn = Buttons.create( "toggle", {
		id="pause-button",
		width=44, height=44,
		defaultSrc = "assets/buttons/pausebtn.png",
		activeSrc = "assets/buttons/pausebtn-over.png",
	})
	btn:addEventListener( "touch", Utils.createObjectCallback( self, self.buttonHandler ) )

	self:insert( btn.display )
	btn.x = 442 ; btn.y = 288

	self.pauseIsActive = ( btn.state == "active" )

	self:hide()
end
-- _undoCreateView()
--
function PauseScreenHUD:_undoCreateView()
	--print( "PauseScreenHUD:_undoCreateView" )
	for i=self._toggleItems.numChildren, 1, -1 do
		self._toggleItems[ i ]:removeSelf()
	end
	for i=self.display.numChildren, 1, -1 do
		self.display[ i ]:removeSelf()
	end
end

-- _initComplete()
--
function PauseScreenHUD:_initComplete()
	self:show()
end
-- _undoInitComplete()
--
function PauseScreenHUD:_undoInitComplete()
	self:hide()
end


--== Class Methods


-- pauseIsActive
--
function PauseScreenHUD.__getters:pauseIsActive()
	return self._pauseIsActive
end
function PauseScreenHUD.__setters:pauseIsActive( value )
	self._pauseIsActive = value
	self._toggleItems.isVisible = value
end


function PauseScreenHUD:menuConfirmation( event )

	if "clicked" == event.action then
		local i = event.index
		if i == 1 then
			-- Player clicked Yes, go to main menu
			self:dispatchEvent( { name="change", label="menu" } )
		end
	end
end

function PauseScreenHUD:buttonHandler( event )

	local btn = event.target

	if event.phase == btn.PHASE_RELEASE then
		audio.play( tapSound )

		-- process menu button
		if event.id == "menu-button" then
			local alert = native.showAlert( "Are You Sure?", "Your current game will end.", { "Yes", "Cancel" }, Utils.createObjectCallback( self, self.menuConfirmation ) )

		-- process Pause Button
		elseif event.id == "pause-button" then
			--Utils.print( event )
			self.pauseIsActive = ( event.state == "active" )
			self:dispatchEvent( { name="change", label="pause", state=event.state } )
		end
	end

	return true
end




--====================================================================--
-- Game Over HUD class
--====================================================================--


local GameOverHUD = inheritsFrom( CoronaBase )
GameOverHUD.NAME = "Game Over HUD"

GameOverHUD.BUTTON_EVENT = "gameOverHUDButtonEvent"

GameOverHUD.YOU_WIN_SOUND = audio.loadSound( "assets/sounds/youwin.wav" )
GameOverHUD.YOU_LOSE_SOUND = audio.loadSound( "assets/sounds/youlose.wav" )


-- _init()
--
-- one of the base methods to override for dmc_objects
--
function GameOverHUD:_init( options )

	-- don't forget this !!!
	self:superCall( "_init" )

	--==  Create Properties  ==--
	self._imgRefs = {}

end
-- _undoInit()
--
function GameOverHUD:_undoInit()
	print( "GameOverHUD:_undoInit" )

	Utils.destroy( self._imgRefs )

end


-- _createView()
--
-- one of the base methods to override for dmc_objects
--
function GameOverHUD:_createView()

	local img, btn, txt
	local imgRefs = self._imgRefs

	local d = self.display

	--self:insert( d )

	-- shade rectangle
	img = display.newRect( 0, 0, 480, 320 )
	img:setFillColor( 0, 0, 0, 255 )
	img.alpha = 0.5

	d:insert( img )
	imgRefs[ "background" ] = img


	-- SCORE DISPLAY
	txt = display.newText( "0", 470, 22, "Helvetica-Bold", 52 )
	txt:setTextColor( 255, 255, 255, 255 )	--> white
	txt.xScale = 0.5; txt.yScale = 0.5	--> for clear retina display text
	--txt.x = ( 480 - ( txt.contentWidth * 0.5 ) ) - 15
	txt.y = 30

	d:insert( txt )
	imgRefs[ "score-txt" ] = txt

	-- Best SCORE DISPLAY
	txt = display.newText( "0", 10, 300, "Helvetica-Bold", 32 )
	txt:setTextColor( 228, 228, 228, 255 )
	txt.xScale = 0.5; txt.yScale = 0.5	--> for clear retina display text
	txt.y = 304

	d:insert( txt )
	imgRefs[ "bestscore-txt" ] = txt

	-- Open Feint button
	btn = Buttons.create( "push", {
		id="openfeint-button",
		width=168, height=40,
		defaultSrc = "assets/buttons/openfeintbtn.png",
		downSrc = "assets/buttons/openfeintbtn-over.png",
	})
	btn.x = 168 ; btn.y = 110
	d:insert( btn.display )
	imgRefs[ "openfeint-btn" ] = btn

	imgRefs[ "openfeint-btn-func" ] = Utils.createObjectCallback( self, self.openFeintButtonHandler )
	btn:addEventListener( "touch", imgRefs[ "openfeint-btn-func" ] )


	-- Facebook button
	btn = Buttons.create( "push", {
		id="facebook-button",
		width=302, height=40,
		defaultSrc = "assets/buttons/facebookbtn.png",
		downSrc = "assets/buttons/facebookbtn-over.png",
	})
	btn.x = 240 ; btn.y = 220
	d:insert( btn.display )
	imgRefs[ "facebook-btn" ] = btn

	imgRefs[ "facebook-btn-func" ] = Utils.createObjectCallback( self, self.facebookButtonHandler )
	btn:addEventListener( "touch", imgRefs[ "facebook-btn-func" ] )


	-- "you win" background
	img = display.newImageRect( "assets/backgrounds/youwin.png", 390, 154 )
	img.x = 240 ; img.y = 165
	img.isVisible = true

	d:insert( img )
	imgRefs[ "win" ] = img

	-- "you lose" background
	img = display.newImageRect( "assets/backgrounds/youlose.png", 390, 154 )
	img.x = 240 ; img.y = 165
	img.isVisible = true
	d:insert( img )

	imgRefs[ "lose" ] = img

	-- menu button
	btn = Buttons.create( "push", {
		id="menu-button",
		width=60, height=60,
		defaultSrc = "assets/buttons/menubtn.png",
		downSrc = "assets/buttons/menubtn-over.png",
	})
	btn.x = 0 ; btn.y = 186
	d:insert( btn.display )
	imgRefs[ "menu-btn" ] = btn

	imgRefs[ "menu-btn-func" ] = Utils.createObjectCallback( self, self.buttonHandler )
	btn:addEventListener( "touch", imgRefs[ "menu-btn-func" ] )


	-- restart button
	btn = Buttons.create( "push", {
		id="restart-button",
		width=60, height=60,
		defaultSrc = "assets/buttons/restartbtn.png",
		downSrc = "assets/buttons/restartbtn-over.png",
	})
	d:insert( btn.display )
	btn.x = 0 ; btn.y = 186
	imgRefs[ "restart-btn" ] = btn

	imgRefs[ "restart-btn-func" ] = Utils.createObjectCallback( self, self.buttonHandler )
	btn:addEventListener( "touch", imgRefs[ "restart-btn-func" ] )


	-- next button
	btn = Buttons.create( "push", {
		id="nextlevel-button",
		width=60, height=60,
		defaultSrc = "assets/buttons/nextlevelbtn.png",
		downSrc = "assets/buttons/nextlevelbtn-over.png",
	})
	d:insert( btn.display )
	btn.x = 0 ; btn.y = 186
	imgRefs[ "nextlevel-btn" ] = btn

	imgRefs[ "nextlevel-btn-func" ] = Utils.createObjectCallback( self, self.buttonHandler )
	btn:addEventListener( "touch", imgRefs[ "nextlevel-btn-func" ] )

end
-- _undoCreateView()
--
function GameOverHUD:_undoCreateView()
	print( "GameOverHUD:_undoCreateView" )

	local imgRefs = self._imgRefs
	local o

	-- next button
	o = imgRefs[ "nextlevel-btn" ]
	o:removeEventListener( "touch", imgRefs[ "nextlevel-btn-func" ] )
	self:remove( o.display )
	imgRefs[ "nextlevel-btn" ] = nil
	imgRefs[ "nextlevel-btn-func" ]  = nil

	-- restart button
	o = imgRefs[ "restart-btn" ]
	o:removeEventListener( "touch", imgRefs[ "restart-btn-func" ] )
	self:remove( o.display )
	imgRefs[ "restart-btn" ] = nil
	imgRefs[ "restart-btn-func" ]  = nil

	-- menu button
	o = imgRefs[ "menu-btn" ]
	o:removeEventListener( "touch", imgRefs[ "menu-btn-func" ] )
	self:remove( o.display )
	imgRefs[ "menu-btn" ] = nil
	imgRefs[ "menu-btn-func" ]  = nil

	-- you lose bg
	o = imgRefs[ "lose" ]
	self:remove( o )
	imgRefs[ "lose" ] = nil

	-- you win bg
	o = imgRefs[ "win" ]
	self:remove( o )
	imgRefs[ "win" ] = nil

	-- facebook button
	o = imgRefs[ "facebook-btn" ]
	o:removeEventListener( "touch", imgRefs[ "facebook-btn-func" ] )
	self:remove( o.display )
	imgRefs[ "facebook-btn" ] = nil
	imgRefs[ "facebook-btn-func" ]  = nil

	-- open feint button
	o = imgRefs[ "openfeint-btn" ]
	o:removeEventListener( "touch", imgRefs[ "openfeint-btn-func" ] )
	self:remove( o.display )
	imgRefs[ "openfeint-btn" ] = nil
	imgRefs[ "openfeint-btn-func" ]  = nil

	-- best score display
	o = imgRefs[ "bestscore-txt" ]
	self:remove( o )
	imgRefs[ "bestscore-txt" ] = nil

	-- score display
	o = imgRefs[ "score-txt" ]
	self:remove( o )
	imgRefs[ "score-txt" ] = nil

	-- shade rectangle
	o = imgRefs[ "background" ]
	self:remove( o )
	imgRefs[ "background" ] = nil

end

-- _initComplete()
--
function GameOverHUD:_initComplete()
	--self:show( { outcome="win", bestScore=10234, score=1235 } )
	--self:show( { outcome="lose", bestScore=10234, score=1235 } )
	self:hide()
end


--== Class Methods


-- "win" / "lose"
function GameOverHUD:show( params )

	self:superCall( "show" )

	local imgRefs = self._imgRefs
	local btnPadding = 72
	local outcome = params.outcome
	local bestScore = params.bestScore
	local score = params.score

	-- WE WON !!
	if outcome == "win" then
		audio.play( GameOverHUD.YOU_WIN_SOUND )
		imgRefs[ "win" ].isVisible = true
		imgRefs[ "lose" ].isVisible = false

		imgRefs[ "menu-btn" ].x = 227

		-- Score Text
		local scoreTxt = imgRefs[ "score-txt" ]
		scoreTxt.text = "Score: " .. comma_value( score )
		timer.performWithDelay( 1000, function() scoreTxt.isVisible = true; end, 1 )
		scoreTxt.x = ( 480 - ( scoreTxt.contentWidth * 0.5 ) ) - 15

		-- Next Level Button
		imgRefs[ "nextlevel-btn" ].isVisible = true
		imgRefs[ "nextlevel-btn" ].alpha = 0
		transition.to( imgRefs[ "nextlevel-btn" ], { time=500, alpha=1 } )

		-- Facebook Button
		imgRefs[ "facebook-btn" ].isVisible = true
		transition.to( imgRefs[ "facebook-btn" ], { time=500, alpha=1, y=255, transition=easing.inOutExpo } )

	-- WE LOST
	elseif outcome == "lose" then
		audio.play( GameOverHUD.YOU_LOSE_SOUND )
		imgRefs[ "win" ].isVisible = false
		imgRefs[ "lose" ].isVisible = true

		-- Facebook Button
		imgRefs[ "facebook-btn" ].isVisible = true

		imgRefs[ "nextlevel-btn" ].isVisible = false
		imgRefs[ "menu-btn" ].x = 266
	end

	-- Background
	imgRefs[ "background" ].alpha = 0
	transition.to( imgRefs[ "background" ], { time=200, alpha=0.65 } )

	-- Score Text
	imgRefs[ "score-txt" ].isVisible = false

	-- Best Score Text
	local bestScoreTxt = imgRefs[ "bestscore-txt" ]
	bestScoreTxt.text = "Best Score For This Level: " .. comma_value( bestScore )
	bestScoreTxt.x = ( bestScoreTxt.contentWidth * 0.5 ) + 15

	-- Game Over image
	imgRefs[ outcome ].alpha = 0
	transition.to( imgRefs[ outcome ], { time=500, alpha=1 } )

	-- Menu Button (must be before Restart)
	imgRefs[ "menu-btn" ].alpha = 0
	transition.to( imgRefs[ "menu-btn" ], { time=500, alpha=1 } )

	-- Restart Button (must be before Next Level)
	imgRefs[ "restart-btn" ].x = imgRefs[ "menu-btn" ].x + btnPadding
	imgRefs[ "restart-btn" ].alpha = 0
	transition.to( imgRefs[ "restart-btn" ], { time=500, alpha=1 } )

	-- Next Level Button
	imgRefs[ "nextlevel-btn" ].x = imgRefs[ "restart-btn" ].x + btnPadding

	-- Facebook Button
	imgRefs[ "facebook-btn" ].alpha = 0

	-- Open Feint Button
	imgRefs[ "openfeint-btn" ].alpha = 0
	transition.to( imgRefs[ "openfeint-btn" ], { time=500, alpha=1, y=68, transition=easing.inOutExpo } )

end

-- "win" / "lose"
function GameOverHUD:hide( outcome )

	self:superCall( "hide" )

	self._imgRefs[ "win" ].isVisible = false
	self._imgRefs[ "lose" ].isVisible = false

end


function GameOverHUD:buttonHandler( event )
	--print( "GameOverHUD:buttonHandler" )

	local btn = event.target

	if event.phase == btn.PHASE_RELEASE then
		audio.play( tapSound )

		local e = {
			name=GameOverHUD.BUTTON_EVENT,
			id = event.id,
		}
		-- Menu button
		if event.id == "menu-button" then
			self:doDispatchEvent( e )

		-- Restart Button
		elseif event.id == "restart-button" then
			self:doDispatchEvent( e )

		-- Next Level Button
		elseif event.id == "nextlevel-button" then
			self:doDispatchEvent( e )

		end	-- if event.id
	end	-- if event.phase

	return true
end

function GameOverHUD:doDispatchEvent( e )
	self:dispatchEvent( e )
end

function GameOverHUD:openFeintButtonHandler( event )
	print( "GameOverHUD:openFeintButtonHandler" )

	if event.phase == "release" then
		audio.play( tapSound )

		-- Launch OpenFeint Leaderboards Panel:
		--openfeint.launchDashboard("leaderboards")
	end
end

function GameOverHUD:facebookButtonHandler( event )
	print( "GameOverHUD:facebookButtonHandler" )

	if event.phase == "release" then
		audio.play( tapSound )

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

end


--====================================================================--
-- Game Object Factory
--====================================================================--

local HUDFactory = {}

function HUDFactory.create( param )

	local o
	if param == "loadscreen-hud" then
		o = LoadScreenHUD:new()
	elseif param == "pausescreen-hud" then
		o = PauseScreenHUD:new()
	elseif param == "gameover-hud" then
		o = GameOverHUD:new()
	end
	return o

end

return HUDFactory
