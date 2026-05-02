local BaseState = require("src.state.BaseState")

---Chase state for soul entities.
---@class SoulChaseState : BaseState
---@field stateName string
---@field soul Soul
local SoulChaseState = {}
SoulChaseState.__index = SoulChaseState
setmetatable(SoulChaseState, { __index = BaseState })

SoulChaseState.STATE_NAME = "chase"

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function SoulChaseState:enterState(opts)
	self.soul:setIsAnimating(true)
	self.soul:refreshAnimation()
end

---Advance movement while this state is active.
---@param dt number Delta time in seconds
---@return nil
function SoulChaseState:update(dt)
	if self.soul:canDetectAIChaseTarget() then
		self.soul:updateAIChaseVector()
	else
		self.soul:changeState("returnHome")
		return
	end

	local vx, vy = self.soul.vessel:getLinearVelocity()
	local currentSpeed = math.sqrt(vx * vx + vy * vy)
	local maxSpeed = self.soul.speed * 100

	if currentSpeed < maxSpeed then
		local force = self.soul.ai.chaseForce or 80
		local fx = self.soul.ai.moveDirX * force
		local fy = self.soul.ai.moveDirY * force
		self.soul.collider.body:applyForce(fx, fy)
	end
end

---Create a new SoulChaseState
---@param soul Soul
---@return SoulChaseState
function SoulChaseState.new(soul)
	local self = BaseState.new(SoulChaseState)
	self.stateName = SoulChaseState.STATE_NAME
	self.soul = soul
	return self
end

return SoulChaseState
