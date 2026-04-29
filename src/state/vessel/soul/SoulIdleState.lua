local BaseState = require("src.state.BaseState")

---Idle state for soul entities.
---@class SoulIdleState : BaseState
---@field stateName string
---@field soul Soul
---@field idleTimer number
local SoulIdleState = {}
SoulIdleState.__index = SoulIdleState
setmetatable(SoulIdleState, { __index = BaseState })

SoulIdleState.STATE_NAME = "idle"

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function SoulIdleState:enterState(opts)
	self.soul.vessel:setLinearVelocity(0, 0)
	self.soul:setIsAnimating(false)
	self.soul:refreshAnimation()

	if not self.soul:isAI() then
		return
	end

	self.idleTimer = self.soul:getRandomIdleDuration()
end

---Advance idle timing and transition AI souls into chase or wander.
---@param dt number Delta time in seconds
---@return nil
function SoulIdleState:update(dt)
	if not self.soul:isAI() then
		return
	end

	if self.soul:isAIType("chase") and self.soul:canDetectAIChaseTarget() then
		self.soul:changeState("chase")
		return
	end

	if self.idleTimer > 0 then
		self.idleTimer = self.idleTimer - dt
	else
		self.soul:changeState("wander")
		return
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
	self.idleTimer = 0
	return self
end

return SoulIdleState
