--====================================================================--
-- dmc_widgets/button_group.lua
--
-- Documentation: http://docs.davidmccuskey.com/
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014-2015 David McCuskey

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
--== DMC Corona Widgets : Button Group
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== DMC Widgets Setup
--====================================================================--



local dmc_widget_data, dmc_widget_func
dmc_widget_data = _G.__dmc_widget
dmc_widget_func = dmc_widget_data.func



--====================================================================--
--== Button Group Setup
--====================================================================--



--====================================================================--
--== Imports


local Objects = require 'dmc_objects'
local Utils = require 'dmc_utils'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase



--====================================================================--
--== Button Group Base Class
--====================================================================--


local GroupBase = newClass( ObjectBase, {name="Button Group Base"} )

--== Class Events

GroupBase.EVENT = 'button_group_event'

GroupBase.CHANGED = 'group_change'


--======================================================--
-- Start: Setup DMC Objects

function GroupBase:__init__( params )
	-- print( "GroupBase:__init__" )
	params = params or { }
	self:superCall( '__init__', params )
	--==--

	--== Sanity Check ==--

	if self.is_class then return end

	--== Create Properties ==--

	self._set_first_active = params.set_first_active == nil and true or params.set_first_active

	-- container for group buttons
	-- hashed on obj id
	self._buttons = {}
	self._selected = nil -- the selected button object

end

function GroupBase:__undoInit__( params )
	-- print( "GroupBase:__undoInit__" )

	self._selected = nil
	--==--
	self:superCall( '__undoInit__' )
end

-- _initComplete()
--
function GroupBase:__initComplete__()
	--print( "GroupBase:__initComplete__" )
	self:superCall( '__initComplete__' )
	--==--
	self._button_handler = self:createCallback( self._buttonEvent_handler )
end

function GroupBase:__undoInitComplete__()
	--print( "GroupBase:__undoInitComplete__" )
	self:_removeAllButtons()

	self._button_handler = nil
	--==--
	self:superCall( '__undoInitComplete__' )
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


function GroupBase.__getters:selected()
	-- print( "GroupBase.__getters:selected" )
	return self._selected
end


-- we only want items inserted into proper layer
function GroupBase:add( obj, params )
	-- print( "GroupBase:add", obj.NAME, obj.EVENT )
	params = params or {}
	params.set_active = params.set_active == nil and false or params.set_active
	--==--
	local num = Utils.tableSize( self._buttons )

	if params.set_active or ( self._set_first_active and num==0 ) then
		obj:gotoState( obj.STATE_ACTIVE )
		self._selected = obj
	end

	obj:addEventListener( obj.EVENT, self._button_handler )
	local key = tostring( obj )
	self._buttons[ key ] = obj

end

function GroupBase:remove( obj )
	-- print( "GroupBase:remove" )

	local key = tostring( obj )
	self._buttons[ key ] = nil
	obj:removeEventListener( obj.EVENT, self._button_handler )

end


function GroupBase:getButton( id )
	-- print( "GroupBase:getButton", id )
	assert( type(id)=='string', 'getButton: expected string for button id')
	--==--
	local button = nil

	for _, o in pairs( self._buttons ) do
		if o.id == id then
			button = o
			break
		end
	end
	return button
end



--====================================================================--
--== Private Methods


function GroupBase:_setButtonGroupState( state )
	-- print( "GroupBase:_setButtonGroupState" )
	for _, button in pairs( self._buttons ) do
		button:gotoState( state )
	end
end

function GroupBase:_removeAllButtons()
	-- print( "GroupBase:_removeAllButtons" )
	for _, button in pairs( self._buttons ) do
		self:remove( button )
	end
end

function GroupBase:_dispatchChangeEvent( button )
	-- print( "GroupBase:_dispatchChangeEvent" )
	local evt = {
		target=self,
		button=button,
		id=button.id,
		state=button:getState()
	}
	self:dispatchEvent( self.CHANGED, evt )
end



--====================================================================--
--== Event Handlers


function GroupBase:_buttonEvent_handler( event )
	error( "OVERRIDE: GroupBase:_buttonEvent_handler" )
end





--====================================================================--
--== Radio Group Class
--====================================================================--


local RadioGroup = newClass( GroupBase, {name="Radio Group"} )

RadioGroup.TYPE = 'radio'


--======================================================--
-- Start: Setup DMC Objects

function RadioGroup:__init__( params )
	-- print( "RadioGroup:__init__" )
	params = params or { }
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self._set_first_active = true
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function RadioGroup:_buttonEvent_handler( event )
	-- print( "RadioGroup:_buttonEvent_handler", event.phase )
	local button = event.target

	if self._selected == button then return end

	if event.phase ~= button.RELEASED then return end

	self:_setButtonGroupState( button.STATE_INACTIVE )
	button:gotoState( button.STATE_ACTIVE )

	self._selected = button
	self:_dispatchChangeEvent( button )
end




--====================================================================--
--== Toggle Group Class
--====================================================================--


local ToggleGroup = newClass( GroupBase, {name="Toggle Group"} )

ToggleGroup.TYPE = 'toggle'


--======================================================--
-- Start: Setup DMC Objects

function ToggleGroup:__init__( params )
	-- print( "ToggleGroup:__init__" )
	params = params or {}
	self:superCall( '__init__', params )
	--==--

	--== Create Properties ==--

	self._set_first_active = params.set_first_active == nil and false or params.set_first_active
end

-- END: Setup DMC Objects
--======================================================--



--====================================================================--
--== Public Methods


-- none



--====================================================================--
--== Private Methods


-- none



--====================================================================--
--== Event Handlers


function ToggleGroup:_buttonEvent_handler( event )
	-- print( "ToggleGroup:_buttonEvent_handler", event.phase )
	local button = event.target
	local state = button:getState()

	if event.phase ~= button.RELEASED then return end
	if self._selected ~= button and state == button.STATE_ACTIVE then
		self:_setButtonGroupState( button.STATE_INACTIVE )

		self._selected = button
		button:gotoState( button.STATE_ACTIVE )

	elseif self._selected == button and state == button.STATE_INACTIVE then
		self._selected = nil
	end

	self:_dispatchChangeEvent( button )
end





--===================================================================--
--== Button Group Factory
--===================================================================--


local ButtonGroup = {}

-- export class instantiations for direct access
ButtonGroup.GroupBase = GroupBase
ButtonGroup.RadioGroup = RadioGroup
ButtonGroup.ToggleGroup = ToggleGroup

function ButtonGroup.create( params )
	params = params or {}
	assert( params.type, "newButtonGroup: expected param 'type'" )
	--==--
	if params.type == RadioGroup.TYPE then
		return RadioGroup:new( params )

	elseif params.type == ToggleGroup.TYPE then
		return ToggleGroup:new( params )

	else
		error( "newButtonGroup: unknown button type: " .. tostring( params.type ) )

	end
end

return ButtonGroup

