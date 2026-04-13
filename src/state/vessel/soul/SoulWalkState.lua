local BaseState = require("src.state.BaseState")

---@class SoulWalkState : BaseState
---@field soul Soul
---@field walkTimer number
---@field walkDuration number
local SoulWalkState = {}
SoulWalkState.__index = SoulWalkState
setmetatable(SoulWalkState, { __index = BaseState })

---Resume the current animation when entering walk.
---@param args? table Optional arguments
function SoulWalkState:enterState(args)
	self.soul.animations.current:resume()
end

---Called when this state is deactivated. Halt the soul's physics velocity when leaving walk.
function SoulWalkState:exitState()
	self.soul:setLinearVelocity(0, 0)
end

---Apply velocity in the soul's current direction each frame.
---Used by NPC souls whose direction is set externally (e.g. by AI or scripted movement).
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
	self.soul:setLinearVelocity(vx, vy)
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
	self.soul = soul
	self.walkTimer = 0
	self.walkDuration = 0
	return self
end

return SoulWalkState
