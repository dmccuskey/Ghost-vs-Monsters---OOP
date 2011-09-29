-- 
-- Abstract: animated sprite or "movieclip" library
-- This library assembles animation sequences from individual image files. For more advanced 
-- texture memory handling, see the "sprite sheet" feature in Corona Game Edition.
--
-- Version: 2.0
-- 
-- Disclaimer: IMPORTANT:  This ANSCA software is supplied to you by ANSCA Inc.
-- ("ANSCA") in consideration of your agreement to the following terms, and your
-- use, installation, modification or redistribution of this ANSCA software
-- constitutes acceptance of these terms.  If you do not agree with these terms,
-- please do not use, install, modify or redistribute this ANSCA software.
-- 
-- In consideration of your agreement to abide by the following terms, and subject
-- to these terms, ANSCA grants you a personal, non-exclusive license, under
-- ANSCA's copyrights in this original ANSCA software (the "ANSCA Software"), to
-- use, reproduce, modify and redistribute the ANSCA Software, with or without
-- modifications, in source and/or binary forms; provided that if you redistribute
-- the ANSCA Software in its entirety and without modifications, you must retain
-- this notice and the following text and disclaimers in all such redistributions
-- of the ANSCA Software.
-- Neither the name, trademarks, service marks or logos of ANSCA Inc. may be used
-- to endorse or promote products derived from the ANSCA Software without specific
-- prior written permission from ANSCA.  Except as expressly stated in this notice,
-- no other rights or licenses, express or implied, are granted by ANSCA herein,
-- including but not limited to any patent rights that may be infringed by your
-- derivative works or by other works in which the ANSCA Software may be
-- incorporated.
-- 
-- The ANSCA Software is provided by ANSCA on an "AS IS" basis.  ANSCA MAKES NO
-- WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
-- WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE, REGARDING THE ANSCA SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
-- COMBINATION WITH YOUR PRODUCTS.
-- 
-- IN NO EVENT SHALL ANSCA BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
-- DISTRIBUTION OF THE ANSCA SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
-- CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
-- ANSCA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

-- movieclip.lua (a convenience library for assembling animated sprites from separate images)

module(..., package.seeall)

function newAnim (imageTable,width,height)

	-- Set up graphics
	local g = display.newGroup()
	local animFrames = {}
	local animLabels = {}
	local limitX, limitY, transpose
	local startX, startY

	local i = 1
	while imageTable[i] do
		animFrames[i] = display.newImageRect(imageTable[i],width,height);
		g:insert(animFrames[i], true)
		animLabels[i] = i -- default frame label is frame number
		animFrames[i].isVisible = false
		i = i + 1
	end

	-- show first frame by default
	animFrames[1].isVisible = true

	-------------------------
	-- Define private methods
	
	local currentFrame = 1
	local totalFrames = #animFrames
	local startFrame = 1
	local endFrame = #animFrames
	local loop = 0
	local loopCount = 0
	local remove = false
	local dragBounds = nil
	local dragLeft, dragTop, dragWidth, dragHeight
	
	-- flag to distinguish initial default case (where no sequence parameters are submitted)
	local inSequence = false
	
	local function resetDefaults()
		currentFrame = 1
		startFrame = 1
		endFrame = #animFrames
		loop = 0
		loopCount = 0
		remove = false
	end
	
	local function resetReverseDefaults()
		currentFrame = #animFrames
		startFrame = #animFrames
		endFrame = 1
		loop = 0
		loopCount = 0
		remove = false
	end
	
	local function nextFrame( self, event )
		animFrames[currentFrame].isVisible = false
		currentFrame = currentFrame + 1
		if (currentFrame == endFrame + 1) then
			if (loop > 0) then
				loopCount = loopCount + 1

				if (loopCount == loop) then
					-- stop looping
					currentFrame = currentFrame - 1
					animFrames[currentFrame].isVisible = true
					Runtime:removeEventListener( "enterFrame", self )

					if (remove) then
						-- delete self (only gets garbage collected if there are no other references)
						self.parent:remove(self)
					end

				else
					currentFrame = startFrame
					animFrames[currentFrame].isVisible = true
				end

			else
				currentFrame = startFrame
				animFrames[currentFrame].isVisible = true
			end
			
		elseif (currentFrame > #animFrames) then
			currentFrame = 1
			animFrames[currentFrame].isVisible = true
			
		else
			animFrames[currentFrame].isVisible = true
			
		end
	end

	
	local function prevFrame( self, event )
		animFrames[currentFrame].isVisible = false
		currentFrame = currentFrame - 1
		
		if (currentFrame == endFrame - 1) then
			if (loop > 0) then
				loopCount = loopCount + 1

				if (loopCount == loop) then 
					-- stop looping
					currentFrame = currentFrame + 1
					animFrames[currentFrame].isVisible = true
					Runtime:removeEventListener( "enterFrame", self )

					if (remove) then
						-- delete self
						self.parent:remove(self)
					end

				else
					currentFrame = startFrame
					animFrames[currentFrame].isVisible = true
				end

			else
				currentFrame = startFrame
				animFrames[currentFrame].isVisible = true
			end
			
		elseif (currentFrame < 1) then
			currentFrame = #animFrames
			animFrames[currentFrame].isVisible = true
			
		else
			animFrames[currentFrame].isVisible = true
			
		end
	end
	
	
	local function dragMe(self, event)
		local onPress = self._onPress
		local onDrag = self._onDrag
		local onRelease = self._onRelease
	
		if event.phase == "began" then
			display.getCurrentStage():setFocus( self )
			startX = g.x
			startY = g.y
			
			if onPress then
				result = onPress( event )
			end
			
		elseif event.phase == "moved" then
	
			if transpose == true then
				-- Note: "transpose" is deprecated now that Corona supports native landscape mode
				-- dragBounds is omitted in transposed mode, but feel free to implement it
				if limitX ~= true then
					g.x = startX - (event.yStart - event.y)
				end
				if limitY ~= true then
					g.y = startY + (event.xStart - event.x)
				end
			else
				if limitX ~= true then
					g.x = startX - (event.xStart - event.x)
					if (dragBounds) then
						if (g.x < dragLeft) then g.x = dragLeft end
						if (g.x > dragLeft + dragWidth) then g.x = dragLeft + dragWidth end
					end
				end
				if limitY ~= true then
					g.y = startY - (event.yStart - event.y)
					if (dragBounds) then
						if (g.y < dragTop) then g.y = dragTop end
						if (g.y > dragTop + dragHeight) then g.y = dragTop + dragHeight end
					end
				end
			end

			if onDrag then
				result = onDrag( event )
			end
				
		elseif event.phase == "ended" then
			display.getCurrentStage():setFocus( nil )

			if onRelease then
				result = onRelease( event )
			end
			
		end
		
		-- stop touch from falling through to objects underneath
		return true
	end


	------------------------
	-- Define public methods

	function g:enterFrame( event )
		self:repeatFunction( event )
	end
	function g:play( params )
		
		Runtime:removeEventListener( "enterFrame", self )

		if ( params ) then
			-- if any parameters are submitted, assume this is a new sequence and reset all default values
			animFrames[currentFrame].isVisible = false
			resetDefaults()				
			inSequence = true
			-- apply optional parameters (with some boundary and type checking)
			if ( params.startFrame and type(params.startFrame) == "number" ) then startFrame=params.startFrame end
			if ( startFrame > #animFrames or startFrame < 1 ) then startFrame = 1 end
	
			if ( params.endFrame and type(params.endFrame) == "number" ) then endFrame=params.endFrame end
			if ( endFrame > #animFrames or endFrame < 1 ) then endFrame = #animFrames end
	
			if ( params.loop and type(params.loop) == "number" ) then loop=params.loop end
			if ( loop < 0 ) then loop = 0 end
		
			if ( params.remove and type(params.remove) == "boolean" ) then remove=params.remove end
			loopCount = 0
		else
			if (not inSequence) then
				-- use default values
				startFrame = 1
				endFrame = #animFrames
				loop = 0
				loopCount = 0
				remove = false
			end			
		end
	
		currentFrame = startFrame
		animFrames[startFrame].isVisible = true 

	
		self.repeatFunction = nextFrame
		--Runtime:addEventListener( "enterFrame", self )
	end
	
	
	function g:reverse( params )
		Runtime:removeEventListener( "enterFrame", self )
		
		if ( params ) then
			-- if any parameters are submitted, assume this is a new sequence and reset all default values
			animFrames[currentFrame].isVisible = false
			resetReverseDefaults()
			inSequence = true
			-- apply optional parameters (with some boundary and type checking)
			if ( params.startFrame and type(params.startFrame) == "number" ) then startFrame=params.startFrame end
			if ( startFrame > #animFrames or startFrame < 1 ) then startFrame = #animFrames end
		
			if ( params.endFrame and type(params.endFrame) == "number" ) then endFrame=params.endFrame end
			if ( endFrame > #animFrames or endFrame < 1 ) then endFrame = 1 end
		
			if ( params.loop and type(params.loop) == "number" ) then loop=params.loop end
			if ( loop < 0 ) then loop = 0 end
		
			if ( params.remove and type(params.remove) == "boolean" ) then remove=params.remove end
		else
			if (not inSequence) then
				-- use default values
				startFrame = #animFrames
				endFrame = 1
				loop = 0
				loopCount = 0
				remove = false
			end
		end
		
		currentFrame = startFrame
		animFrames[startFrame].isVisible = true 
		
		self.repeatFunction = prevFrame
		--Runtime:addEventListener( "enterFrame", self )
	end

	
	function g:nextFrame()
		-- stop current sequence, if any, and reset to defaults
		Runtime:removeEventListener( "enterFrame", self )
		inSequence = false
		
		animFrames[currentFrame].isVisible = false
		currentFrame = currentFrame + 1
		if ( currentFrame > #animFrames ) then
			currentFrame = 1
		end
		animFrames[currentFrame].isVisible = true
	end
	
	
	function g:previousFrame()
		-- stop current sequence, if any, and reset to defaults
		Runtime:removeEventListener( "enterFrame", self )
		inSequence = false
		
		animFrames[currentFrame].isVisible = false
		currentFrame = currentFrame - 1
		if ( currentFrame < 1 ) then
			currentFrame = #animFrames
		end
		animFrames[currentFrame].isVisible = true
	end

	function g:currentFrame()
		return currentFrame
	end
	
	function g:totalFrames()
		return totalFrames
	end
	
	function g:stop()
		Runtime:removeEventListener( "enterFrame", self )
	end

	function g:stopAtFrame(label)
		-- This works for either numerical indices or optional text labels
		if (type(label) == "number") then
			Runtime:removeEventListener( "enterFrame", self )
			animFrames[currentFrame].isVisible = false
			currentFrame = label
			animFrames[currentFrame].isVisible = true
			
		elseif (type(label) == "string") then
			for k, v in next, animLabels do
				if (v == label) then
					Runtime:removeEventListener( "enterFrame", self )
					animFrames[currentFrame].isVisible = false
					currentFrame = k
					animFrames[currentFrame].isVisible = true
				end
			end
		end
	end

	
	function g:playAtFrame(label)
		-- This works for either numerical indices or optional text labels
		if (type(label) == "number") then
			Runtime:removeEventListener( "enterFrame", self )
			animFrames[currentFrame].isVisible = false
			currentFrame = label
			animFrames[currentFrame].isVisible = true
			
		elseif (type(label) == "string") then
			for k, v in next, animLabels do
				if (v == label) then
					Runtime:removeEventListener( "enterFrame", self )
					animFrames[currentFrame].isVisible = false
					currentFrame = k
					animFrames[currentFrame].isVisible = true
				end
			end
		end
		self.repeatFunction = nextFrame
		--Runtime:addEventListener( "enterFrame", self )
	end


	function g:setDrag( params )
		if ( params ) then
			if params.drag == true then
				limitX = (params.limitX == true)
				limitY = (params.limitY == true)
				transpose = (params.transpose == true)
				dragBounds = nil
				
				if ( params.onPress and ( type(params.onPress) == "function" ) ) then
					g._onPress = params.onPress
				end
				if ( params.onDrag and ( type(params.onDrag) == "function" ) ) then
					g._onDrag = params.onDrag
				end
				if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
					g._onRelease = params.onRelease
				end
				if ( params.bounds and ( type(params.bounds) == "table" ) ) then
					dragBounds = params.bounds
					dragLeft = dragBounds[1]
					dragTop = dragBounds[2]
					dragWidth = dragBounds[3]
					dragHeight = dragBounds[4]
				end
				
				g.touch = dragMe
				g:addEventListener( "touch", g )
				
			else
				g:removeEventListener( "touch", g )
				dragBounds = nil
				
			end
		end
	end


	-- Optional function to assign text labels to frames
	function g:setLabels(labelTable)
		for k, v in next, labelTable do
			if (type(k) == "string") then
				animLabels[v] = k
			end
		end		
	end
	
	-- Return instance of anim
	return g

end