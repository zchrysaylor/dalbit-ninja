local BaseState = require("src.state.BaseState")

---@class SoulWalkState : BaseState
---@field entity Soul
local SoulWalkState = {}
SoulWalkState.__index = SoulWalkState
setmetatable(SoulWalkState, { __index = BaseState })

function SoulWalkState:enterState()
	self.entity.animations.current:resume()
end

function SoulWalkState:update(dt)
	if self.entity.direction == "up" then
		self.entity.y = self.entity.y - self.entity.speed * dt
	elseif self.entity.direction == "down" then
		self.entity.y = self.entity.y + self.entity.speed * dt
	elseif self.entity.direction == "left" then
		self.entity.x = self.entity.x - self.entity.speed * dt
	elseif self.entity.direction == "right" then
		self.entity.x = self.entity.x + self.entity.speed * dt
	end
end

function SoulWalkState:simulate()
	-- TODO: AI logic here
end

---@param entity Soul
---@return SoulWalkState
function SoulWalkState.new(entity)
	local self = BaseState.new(SoulWalkState)
	self.entity = entity
	self.walkTimer = 0
	self.walkDuration = 0
	return self
end

return SoulWalkState
