local BaseState = require("src.state.BaseState")

---Return to home/wander radius state for soul entities.
---@class SoulReturnState : BaseState
---@field stateName string
---@field soul Soul
local SoulReturnState = {}
SoulReturnState.__index = SoulReturnState
setmetatable(SoulReturnState, { __index = BaseState })

SoulReturnState.STATE_NAME = "returnHome"

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function SoulReturnState:enterState(opts)
	self.soul:setIsAnimating(true)
	self.soul:refreshAnimation()
end

---Advance movement while this state is active.
---@param dt number Delta time in seconds
---@return nil
function SoulReturnState:update(dt)
	if self.soul:isAIType("chase") and self.soul:canDetectAIChaseTarget() then
		self.soul:changeState("chase")
		return
	end

	local x, y = self.soul:getPosition()

	if not self.soul:isOutsideAIWanderRadius(x, y) then
		self.soul:changeState("wander")
		return
	end

	local dx = self.soul.ai.homeX - x
	local dy = self.soul.ai.homeY - y
	self.soul:setAIMoveVector(dx, dy)

	-- TODO: need logic so that if soul gets stuck on return, it changes dir to try to get around object, otherwise it remains stuck walking forever
	local speed = self.soul.speed * 100
	local vx = self.soul.ai.moveDirX * speed
	local vy = self.soul.ai.moveDirY * speed
	self.soul.vessel:setLinearVelocity(vx, vy)
end

---Create a new SoulReturnState
---@param soul Soul
---@return SoulReturnState
function SoulReturnState.new(soul)
	local self = BaseState.new(SoulReturnState)
	self.stateName = SoulReturnState.STATE_NAME
	self.soul = soul
	return self
end

return SoulReturnState
