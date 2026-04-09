local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:changeState(state, args)
	assert(self.states[state])
	self.currentState:exitState()
	self.currentState = self.states[state]()
	self.currentState:enterState(args)
end

function StateMachine:update(dt)
	self.currentState:update(dt)
end

function StateMachine:draw()
	self.currentState:draw()
end

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
