---Stack of active game states.
---Only the top state updates, but all states render in stack order.
---@class StateStack
---@field states BaseState[] Active states from bottom to top
local StateStack = {}
StateStack.__index = StateStack

-- TODO: consider implementing contains(stateName) or popUntil(stateName) methods

---Push a state onto the stack and enter it immediately.
---@param state BaseState State instance to activate
---@param opts? table Optional data forwarded to `state:enterState`
function StateStack:push(state, opts)
	table.insert(self.states, state)
	state:enterState(opts)
end

---Exit and remove the top state from the stack.
function StateStack:pop()
	if #self.states == 0 then
		return
	end
	self.states[#self.states]:exitState()
	table.remove(self.states)
end

---Peek at the top-most state without removing it.
---@return BaseState|nil
function StateStack:peek()
	return self.states[#self.states]
end

---Check whether the top-most state matches the given state name.
---@param stateName string
---@return boolean
function StateStack:isTop(stateName)
	local topState = self.states[#self.states]
	if topState and topState.stateName == stateName then
		return true
	end
	return false
end

---Update only the top-most active state.
---@param dt number Delta time in seconds
function StateStack:update(dt)
	if #self.states == 0 then
		return
	end
	self.states[#self.states]:update(dt)
end

---Draw all active states from bottom to top.
function StateStack:draw()
	for _, state in ipairs(self.states) do
		state:draw()
	end
end

---Remove all states from the stack without calling `exitState`.
function StateStack:clear()
	self.states = {}
end

---Create a new StateStack.
---@return StateStack
function StateStack.new()
	local self = setmetatable({}, StateStack)
	self.states = {}
	return self
end

return StateStack
