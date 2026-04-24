local BaseState = require("src.state.BaseState")

---Generic state machine used for both game screens (GStateMachine) and per-entity states.
---States are registered as factory functions so a fresh instance is created on each transition.
---@class StateMachine
---@field states table<string, fun(): BaseState> Map of state key → state factory
---@field currentState BaseState The currently active state instance
---@field emptyState BaseState No-op placeholder state used before the first transition
local StateMachine = {}
StateMachine.__index = StateMachine

---Transition to a new state by key.
---@param state string Key of the target state (must exist in self.states)
---@param opts? table Optional options forwarded to the new state's enterState()
function StateMachine:changeState(state, opts)
	assert(self.states[state])
	self.currentState:exitState()
	self.currentState = self.states[state]()
	self.currentState:enterState(opts)
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

---Create a new StateMachine
---@param states? table<string, fun(): BaseState> Map of state key -> state factory
---@return StateMachine
function StateMachine.new(states)
	local self = setmetatable({}, StateMachine)
	self.states = states or {}
	self.emptyState = BaseState.new()
	self.currentState = self.emptyState
	return self
end

return StateMachine
