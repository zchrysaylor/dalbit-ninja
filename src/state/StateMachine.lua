---Generic state machine used for both game screens (GStateMachine) and per-entity states.
---States are registered as factory functions so a fresh instance is created on each transition.
---@class StateMachine
---@field states table<string, fun(): BaseState> Map of state key → factory function
---@field currentState BaseState The currently active state instance
local StateMachine = {}
StateMachine.__index = StateMachine

---Transition to a new state by key.
---@param state string Key of the target state (must exist in self.states)
---@param args? table Optional arguments forwarded to the new state's enterState()
function StateMachine:changeState(state, args)
	assert(self.states[state])
	self.currentState:exitState()
	self.currentState = self.states[state]()
	self.currentState:enterState(args)
end

---Delegate update to the active state.
---@param dt number Delta time in seconds
function StateMachine:update(dt)
	self.currentState:update(dt)
end

---Delegate draw to the active state.
function StateMachine:draw()
	self.currentState:draw()
end

---Create a new StateMachine with the given state factory map.
---@param states table<string, fun(): BaseState> Map of state key → factory function
---@return StateMachine
function StateMachine.new(states)
	local self = setmetatable({}, StateMachine)
	self.states = states or {}
	-- TODO: can replace with BaseState.new()?
	self.emptyState = {
		update = function() end,
		draw = function() end,
		enterState = function() end,
		exitState = function() end,
	}
	self.currentState = self.emptyState
	return self
end

return StateMachine
