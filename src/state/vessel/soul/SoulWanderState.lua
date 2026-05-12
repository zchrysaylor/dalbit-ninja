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
---@param opts? table Optional options.
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
	if self.soul:tryChangeToAIChaseState() then
		return
	end

	local speed = self.soul.speed
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
	local isBlocked
	self.blockedFrames, isBlocked = self.soul:updateAIBlockedFrames(dt, self.blockedFrames)
	if isBlocked then
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
