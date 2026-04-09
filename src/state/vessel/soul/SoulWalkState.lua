local BaseState = require("src.state.BaseState")

---@class SoulWalkState : BaseState
---@field soul Soul
local SoulWalkState = {}
SoulWalkState.__index = SoulWalkState
setmetatable(SoulWalkState, { __index = BaseState })

function SoulWalkState:enterState()
	self.soul.animations.current:resume()
end

function SoulWalkState:update(dt)
	if self.soul.direction == "up" then
		self.soul.y = self.soul.y - self.soul.speed * dt
	elseif self.soul.direction == "down" then
		self.soul.y = self.soul.y + self.soul.speed * dt
	elseif self.soul.direction == "left" then
		self.soul.x = self.soul.x - self.soul.speed * dt
	elseif self.soul.direction == "right" then
		self.soul.x = self.soul.x + self.soul.speed * dt
	end
end

function SoulWalkState:simulate()
	-- TODO: AI logic here
end

---@param soul Soul
---@return SoulWalkState
function SoulWalkState.new(soul)
	local self = BaseState.new(SoulWalkState)
	self.soul = soul
	self.walkTimer = 0
	self.walkDuration = 0
	return self
end

return SoulWalkState
