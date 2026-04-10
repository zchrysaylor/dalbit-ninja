local SoulWalkState = require("src.state.vessel.soul.SoulWalkState")

---@class PlayerWalkState : SoulWalkState
---@field soul Player
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

---Delegate per-frame movement to movePlayer().
---@param dt number Delta time in seconds
function PlayerWalkState:update(dt)
	self:movePlayer()
end

---Read directional input, compute Box2D velocity, and select the correct animation.
---Transitions back to "idle" if no directional key is held.
function PlayerWalkState:movePlayer()
	local moveUp = love.keyboard.isDown(KEY_UP)
	local moveLeft = love.keyboard.isDown(KEY_LEFT)
	local moveDown = love.keyboard.isDown(KEY_DOWN)
	local moveRight = love.keyboard.isDown(KEY_RIGHT)

	-- build velocity from input
	local vx, vy = 0, 0
	local speed = self.soul.speed * 100 -- velocity is pixels/sec

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
		self.soul:changeState("idle")
		return
	end

	-- normalize diagonal movement so the player doesn't move faster on diagonals
	if vx ~= 0 and vy ~= 0 then
		local diagonalFactor = 1 / math.sqrt(2)
		vx = vx * diagonalFactor
		vy = vy * diagonalFactor
	end

	-- move the body with physics and animations
	self.soul:setLinearVelocity(vx, vy)
	self:animatePlayer(moveUp, moveDown, moveLeft, moveRight)
end

---Select the correct directional animation based on the active input flags.
---Handles 8-way animation: cardinal and diagonal directions.
---@param moveUp boolean
---@param moveDown boolean
---@param moveLeft boolean
---@param moveRight boolean
function PlayerWalkState:animatePlayer(moveUp, moveDown, moveLeft, moveRight)
	local horizontal = (moveLeft or moveRight) and not (moveLeft and moveRight)
	local vertical = (moveUp or moveDown) and not (moveUp and moveDown)

	-- diagonal movement
	if horizontal and vertical then
		if moveUp and moveLeft then
			self.soul.animations.current = self.soul.animations.upLeft
		elseif moveUp and moveRight then
			self.soul.animations.current = self.soul.animations.upRight
		elseif moveDown and moveLeft then
			self.soul.animations.current = self.soul.animations.downLeft
		elseif moveDown and moveRight then
			self.soul.animations.current = self.soul.animations.downRight
		end
	elseif vertical and not horizontal then
		-- vertical only
		if moveUp then
			self.soul.animations.current = self.soul.animations.up
		else
			self.soul.animations.current = self.soul.animations.down
		end
	elseif horizontal and not vertical then
		-- horizontal only
		if moveLeft then
			self.soul.animations.current = self.soul.animations.left
		else
			self.soul.animations.current = self.soul.animations.right
		end
	end
end

---@param player Player
---@return PlayerWalkState
function PlayerWalkState.new(player)
	return SoulWalkState.new(player, PlayerWalkState)
end

return PlayerWalkState
