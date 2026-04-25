local BaseState = require("src.state.BaseState")

---Idle state for soul entities.
---@class SoulIdleState : BaseState
---@field stateName string
---@field soul Soul
local SoulIdleState = {}
SoulIdleState.__index = SoulIdleState
setmetatable(SoulIdleState, { __index = BaseState })

SoulIdleState.STATE_NAME = "idle"

---Called when this state becomes active.
---@param opts? table Optional options
function SoulIdleState:enterState(opts)
	self.soul:syncDirectionalAnimation()
	self.soul.animations.current:pauseAtStart()
	if not self.soul:isAI() then
		return
	end

	self.idleTimer = self.soul:getRandomIdleDuration()
end

function SoulIdleState:update(dt)
	if not self.soul:isAI() then
		return
	end

	if self.idleTimer > 0 then
		self.idleTimer = self.idleTimer - dt
	else
		local direction = self.soul:chooseAIDirection()
		self.soul:setAIMoveDirection(direction)
		self.soul.stateMachine:changeState("walk")
	end
end

---Create a new SoulIdleState
---@generic T : SoulIdleState
---@param soul Soul
---@param subclass? T Metatable to use (defaults to SoulIdleState)
---@return T
function SoulIdleState.new(soul, subclass)
	local self = BaseState.new(subclass or SoulIdleState)
	self.stateName = (subclass or SoulIdleState).STATE_NAME
	self.soul = soul
	return self
end

return SoulIdleState
