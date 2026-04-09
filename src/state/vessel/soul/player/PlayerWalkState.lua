local SoulWalkState = require("src.state.vessel.soul.SoulWalkState")

---@class PlayerWalkState : SoulWalkState
---@field entity Player
local PlayerWalkState = {}
PlayerWalkState.__index = PlayerWalkState
setmetatable(PlayerWalkState, { __index = SoulWalkState })

-- If you eventually want shared walk behavior (e.g., footstep sounds, encounter checks), the right pattern would be to extract that into a separate method on SoulWalkState that both implementations call explicitly:
-- -- SoulWalkState.lua
-- function SoulWalkState:onWalking(dt)
--     -- shared: footstep timer, encounter check, etc.
-- end
-- function SoulWalkState:update(dt)
--     self:onWalking(dt)  -- shared behavior
--     -- NPC position-based movement...
-- end
-- -- PlayerWalkState.lua
-- function PlayerWalkState:update(dt)
--     SoulWalkState.onWalking(self, dt)  -- shared behavior
--     self:MovePlayer()  -- player-specific physics movement
-- end

function PlayerWalkState:update(dt)
	self:MovePlayer()
end

function PlayerWalkState:MovePlayer()
	local moveUp = love.keyboard.isDown(KEY_UP)
	local moveLeft = love.keyboard.isDown(KEY_LEFT)
	local moveDown = love.keyboard.isDown(KEY_DOWN)
	local moveRight = love.keyboard.isDown(KEY_RIGHT)

	-- build velocity from input
	local vx, vy = 0, 0
	local speed = self.entity.speed * 100 -- velocity is pixels/sec

	if moveUp and not moveDown then
		vy = -speed
	elseif moveDown and not moveUp then
		vy = speed
	end

	if moveLeft and not moveRight then
		vx = -speed
	elseif moveRight and not moveLeft then
		vx = speed
	end

	if not moveUp and not moveDown and not moveLeft and not moveRight then
		self.entity:changeState("idle")
		return
	end

	-- move the body with physics and animations
	self.entity.collision:setLinearVelocity(vx, vy)
	self:AnimatePlayer(moveUp, moveDown, moveLeft, moveRight)
end

function PlayerWalkState:AnimatePlayer(moveUp, moveDown, moveLeft, moveRight)
	local horizontal = (moveLeft or moveRight) and not (moveLeft and moveRight)
	local vertical = (moveUp or moveDown) and not (moveUp and moveDown)

	-- diagonal movement
	if horizontal and vertical then
		if moveUp and moveLeft then
			self.entity.animations.current = self.entity.animations.upLeft
		elseif moveUp and moveRight then
			self.entity.animations.current = self.entity.animations.upRight
		elseif moveDown and moveLeft then
			self.entity.animations.current = self.entity.animations.downLeft
		elseif moveDown and moveRight then
			self.entity.animations.current = self.entity.animations.downRight
		end
	elseif vertical and not horizontal then
		-- vertical only
		if moveUp then
			self.entity.animations.current = self.entity.animations.up
		else
			self.entity.animations.current = self.entity.animations.down
		end
	elseif horizontal and not vertical then
		-- horizontal only
		if moveLeft then
			self.entity.animations.current = self.entity.animations.left
		else
			self.entity.animations.current = self.entity.animations.right
		end
	end
end

---@param player Player
---@return PlayerWalkState
function PlayerWalkState.new(player)
	local self = SoulWalkState.new(player)
	setmetatable(self, PlayerWalkState)
	return self
end

return PlayerWalkState
