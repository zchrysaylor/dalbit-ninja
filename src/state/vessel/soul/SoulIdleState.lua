local BaseState = require("src.state.BaseState")

---@class SoulIdleState : BaseState
---@field soul Soul
local SoulIdleState = {}
SoulIdleState.__index = SoulIdleState
setmetatable(SoulIdleState, { __index = BaseState })

---Called when this state becomes active.
---@param args? table Optional arguments
function SoulIdleState:enterState(args)
	self.soul.animations.current:pauseAtStart()
end

---Create a new SoulIdleState
---@generic T : SoulIdleState
---@param soul Soul
---@param subclass? T Metatable to use (defaults to SoulIdleState)
---@return T
function SoulIdleState.new(soul, subclass)
	local self = BaseState.new(subclass or SoulIdleState)
	self.soul = soul
	return self
end

return SoulIdleState
