local BaseState = require("src.state.BaseState")

---Walking state for soul entities.
---@class SoulWalkState : BaseState
---@field stateName string
---@field soul Soul
---@field walkTimer number
---@field walkDuration number
local SoulWalkState = {}
SoulWalkState.__index = SoulWalkState
setmetatable(SoulWalkState, { __index = BaseState })

SoulWalkState.STATE_NAME = "walk"

---Called when this state becomes active.
---@param opts? table Optional options
function SoulWalkState:enterState(opts)
	self.soul.animations.current:resume()
end

---Called when this state is deactivated.
function SoulWalkState:exitState()
	self.soul.vessel:setLinearVelocity(0, 0)
end

---Advance soul movement while in the walking state.
---@param dt number Delta time in seconds
function SoulWalkState:update(dt)
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
end

---Stub for future NPC AI movement logic.
function SoulWalkState:simulate()
	-- TODO: AI logic here
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
	return self
end

return SoulWalkState
