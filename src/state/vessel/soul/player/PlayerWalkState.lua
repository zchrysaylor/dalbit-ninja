local SoulWalkState = require("src.state.vessel.soul.SoulWalkState")

---@class PlayerWalkState : SoulWalkState
---@field soul Player
local PlayerWalkState = {}
PlayerWalkState.__index = PlayerWalkState
setmetatable(PlayerWalkState, { __index = SoulWalkState })

---@param args? table Optional arguments
function PlayerWalkState:enterState(args)
	-- resume paused animation
	SoulWalkState.enterState(self, args)

	self:animateFromDirection()

	-- set immediately to walking frame for accurate animation on key press
	self.soul.animations.current:gotoFrame(2)
end

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
	local dirX, dirY, isMoving = Input.getDirection()
	if not isMoving then
		self.soul:changeState("idle")
		return
	end

	-- Update direction on player
	self.soul.dirX = dirX
	self.soul.dirY = dirY

	-- build velocity from direction
	local speed = self.soul.speed * 100 -- velocity is pixels/sec
	local vx = self.soul.dirX * speed
	local vy = self.soul.dirY * speed

	-- normalize diagonal movement so the player doesn't move faster on diagonals
	if vx ~= 0 and vy ~= 0 then
		local diagonalFactor = 1 / math.sqrt(2)
		vx = vx * diagonalFactor
		vy = vy * diagonalFactor
	end

	-- move the body with physics and animations
	self.soul:setLinearVelocity(vx, vy)
	self:animateFromDirection()
end

---Select the correct directional animation based on the player vector direction
---Handles 8-way animation: cardinal and diagonal directions.
function PlayerWalkState:animateFromDirection()
	local dirX = self.soul.dirX
	local dirY = self.soul.dirY
	local anims = self.soul.animations

	if dirX ~= 0 and dirY ~= 0 then
		-- diagonal
		if dirY < 0 then
			anims.current = dirX < 0 and anims.upLeft or anims.upRight
		else
			anims.current = dirX < 0 and anims.downLeft or anims.downRight
		end
	elseif dirY ~= 0 then
		anims.current = dirY < 0 and anims.up or anims.down
	elseif dirX ~= 0 then
		anims.current = dirX < 0 and anims.left or anims.right
	end
end

---Create a new PlayerWalkState
---@param player Player
---@return PlayerWalkState
function PlayerWalkState.new(player)
	return SoulWalkState.new(player, PlayerWalkState)
end

return PlayerWalkState
