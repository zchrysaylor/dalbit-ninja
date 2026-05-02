local BaseState = require("src.state.BaseState")

---Wander state for soul entities.
---@class SoulWanderState : BaseState
---@field stateName string
---@field soul Soul
---@field wanderBufferTimer number
---@field blockedFrames number
local SoulWanderState = {}
SoulWanderState.__index = SoulWanderState
setmetatable(SoulWanderState, { __index = BaseState })

SoulWanderState.STATE_NAME = "wander"

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function SoulWanderState:enterState(opts)
	self.soul:chooseAIWanderDirection()
	self.soul:setIsAnimating(true)
	self.soul:refreshAnimation()
	self.wanderBufferTimer = self.soul.ai.wanderBufferDuration
	self.blockedFrames = 0
end

---Advance movement while this state is active.
---@param dt number Delta time in seconds
---@return nil
function SoulWanderState:update(dt)
	if self.soul:isAIType("chase") and self.soul:canDetectAIChaseTarget() then
		self.soul:changeState(SoulChaseState.STATE_NAME)
		return
	end

	local speed = self.soul.speed * 100
	local vx = self.soul.ai.moveDirX * speed
	local vy = self.soul.ai.moveDirY * speed
	local x, y = self.soul.vessel:getPosition()
	local nextX = x + vx * dt
	local nextY = y + vy * dt

	if self.wanderBufferTimer > 0 then
		self.wanderBufferTimer = self.wanderBufferTimer - dt
	elseif self.soul:isOutsideAIWanderRadius(nextX, nextY) then
		self.soul:changeState(SoulIdleState.STATE_NAME)
		return
	end

	self.soul.vessel:setLinearVelocity(vx, vy)
end

---Trigger idle state if Soul is blocked by another collider.
---@param dt number Delta time in seconds
---@return nil
function SoulWanderState:postPhysicsUpdate(dt)
	local movedX = self.soul.x - self.soul.previousX
	local movedY = self.soul.y - self.soul.previousY
	local movedDistanceSq = movedX * movedX + movedY * movedY
	local expectedDistance = math.max(self.soul.speed * 100 * dt * 0.2, 0.01)
	local expectedDistanceSq = expectedDistance * expectedDistance

	if movedDistanceSq < expectedDistanceSq then
		self.blockedFrames = self.blockedFrames + 1
	else
		self.blockedFrames = 0
	end

	if self.blockedFrames >= 3 then
		self.soul:changeState(SoulIdleState.STATE_NAME)
		return
	end
end

---Create a new SoulWanderState
---@param soul Soul
---@return SoulWanderState
function SoulWanderState.new(soul)
	local self = BaseState.new(SoulWanderState)
	self.stateName = SoulWanderState.STATE_NAME
	self.soul = soul
	self.wanderBufferTimer = 0
	self.blockedFrames = 0
	return self
end

return SoulWanderState
