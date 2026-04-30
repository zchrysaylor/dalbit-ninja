local BaseState = require("src.state.BaseState")

---Return to home/wander radius state for soul entities.
---@class SoulReturnState : BaseState
---@field stateName string
---@field soul Soul
---@field blockedFrames number
---@field recoveryTimer number
---@field isRecovering boolean
local SoulReturnState = {}
SoulReturnState.__index = SoulReturnState
setmetatable(SoulReturnState, { __index = BaseState })

SoulReturnState.STATE_NAME = "returnHome"
SoulReturnState.RECOVERY_DURATION = 0.35

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function SoulReturnState:enterState(opts)
	self.soul:setIsAnimating(true)
	self.soul:refreshAnimation()
	self.blockedFrames = 0
	self.recoveryTimer = 0
	self.isRecovering = false
end

---Pick a temporary sidestep vector so the soul can slide around an obstacle
---while still remaining committed to returning home.
---@return nil
function SoulReturnState:startRecovery()
	local x, y = self.soul:getPosition()
	local dx = self.soul.ai.homeX - x
	local dy = self.soul.ai.homeY - y
	local side = love.math.random(0, 1) == 0 and -1 or 1
	local recoveryDirX = -dy * side
	local recoveryDirY = dx * side

	if recoveryDirX == 0 and recoveryDirY == 0 then
		recoveryDirX = side
		recoveryDirY = 0
	end

	self.soul:setAIMoveVector(recoveryDirX, recoveryDirY)
	self.recoveryTimer = SoulReturnState.RECOVERY_DURATION
	self.isRecovering = true
	self.blockedFrames = 0
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

	if self.isRecovering then
		self.recoveryTimer = self.recoveryTimer - dt
		if self.recoveryTimer <= 0 then
			self.recoveryTimer = 0
			self.isRecovering = false
		end
	else
		local dx = self.soul.ai.homeX - x
		local dy = self.soul.ai.homeY - y
		self.soul:setAIMoveVector(dx, dy)
	end

	local speed = self.soul.speed * 100
	local vx = self.soul.ai.moveDirX * speed
	local vy = self.soul.ai.moveDirY * speed
	self.soul.vessel:setLinearVelocity(vx, vy)
end

---Trigger recovery movement if Soul is blocked while returning home.
---@param dt number Delta time in seconds
---@return nil
function SoulReturnState:postPhysicsUpdate(dt)
	if self.isRecovering then
		self.blockedFrames = 0
		return
	end

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
		self:startRecovery()
		return
	end
end

---Create a new SoulReturnState
---@param soul Soul
---@return SoulReturnState
function SoulReturnState.new(soul)
	local self = BaseState.new(SoulReturnState)
	self.stateName = SoulReturnState.STATE_NAME
	self.soul = soul
	self.blockedFrames = 0
	self.recoveryTimer = 0
	self.isRecovering = false
	return self
end

return SoulReturnState
