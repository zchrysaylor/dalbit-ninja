local BaseState = require("src.state.BaseState")

---Walking state for soul entities.
---@class SoulWalkState : BaseState
---@field stateName string
---@field soul Soul
---@field walkTimer number
---@field walkDuration number
---@field blockedFrames number
---@field pendingIdle boolean
local SoulWalkState = {}
SoulWalkState.__index = SoulWalkState
setmetatable(SoulWalkState, { __index = BaseState })

SoulWalkState.STATE_NAME = "walk"

---Called when this state becomes active.
---@param opts? table Optional options
function SoulWalkState:enterState(opts)
	self.soul.animations.current:resume()

	if not self.soul:isAI() then
		return
	end

	self.soul:syncDirectionalAnimation()
	self.walkTimer = self.soul:getRandomWalkDuration()
	self.blockedFrames = 0
	self.pendingIdle = false
end

---Called when this state is deactivated.
function SoulWalkState:exitState()
	self.soul.vessel:setLinearVelocity(0, 0)
end

---Advance soul movement while in the walking state.
---@param dt number Delta time in seconds
function SoulWalkState:update(dt)
	-- TODO: remove, not needed
	if not self.soul:isAI() then
		local speed = self.soul.speed * 100
		local vx, vy = 0, 0
		if self.soul.direction == "up" then
			vy = -speed
		elseif self.soul.direction == "down" then
			vy = speed
		elseif self.soul.direction == "left" then
			vx = -speed
		elseif self.soul.direction == "right" then
			vx = speed
		end
		self.soul.vessel:setLinearVelocity(vx, vy)
		return
	end

	local speed = self.soul.speed * 100
	local vx = self.soul.ai.moveDirX * speed
	local vy = self.soul.ai.moveDirY * speed
	local x, y = self.soul.vessel:getPosition()
	local nextX = x + vx * dt
	local nextY = y + vy * dt

	if self.soul:isOutsideAIWanderRadius(nextX, nextY) then
		self.soul:changeState("idle")
		return
	end

	self.walkTimer = self.walkTimer - dt
	if self.walkTimer <= 0 then
		self.pendingIdle = true
	end

	self.soul.vessel:setLinearVelocity(vx, vy)
end

---Validate that an AI soul actually moved after the physics step.
---@param dt number Delta time in seconds
function SoulWalkState:postPhysicsUpdate(dt)
	if not self.soul:isAI() then
		return
	end

	if self.pendingIdle then
		self.soul:changeState("idle")
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
		self.soul:changeState("idle")
	end
end

---Create a new SoulWalkState
---@generic T : SoulWalkState
---@param soul Soul
---@param subclass? T Metatable to use (defaults to SoulWalkState)
---@return T
function SoulWalkState.new(soul, subclass)
	local self = BaseState.new(subclass or SoulWalkState)
	self.stateName = (subclass or SoulWalkState).STATE_NAME
	self.soul = soul
	self.walkTimer = 0
	self.walkDuration = 0
	self.blockedFrames = 0
	self.pendingIdle = false
	return self
end

return SoulWalkState
