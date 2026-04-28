local SoulWalkState = require("src.state.vessel.soul.SoulWalkState")

---Walking state for the player character.
---@class PlayerWalkState : SoulWalkState
---@field stateName string
---@field soul Player
local PlayerWalkState = {}
PlayerWalkState.__index = PlayerWalkState
setmetatable(PlayerWalkState, { __index = SoulWalkState })

PlayerWalkState.STATE_NAME = "walk"

---Called when this state becomes active.
---@param opts? table Optional options
function PlayerWalkState:enterState(opts)
	-- resume paused animation
	SoulWalkState.enterState(self, opts)

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

---Update player movement from the current input state.
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
	self.soul:setFacingFromVector(dirX, dirY)

	-- build velocity from direction
	local speed = self.soul.speed * 100 -- velocity in pixels/sec
	local vx = self.soul.dirX * speed
	local vy = self.soul.dirY * speed

	-- normalize diagonal movement so the player doesn't move faster on diagonals
	if vx ~= 0 and vy ~= 0 then
		local diagonalFactor = 1 / math.sqrt(2)
		vx = vx * diagonalFactor
		vy = vy * diagonalFactor
	end

	-- move the body with physics and animations
	self.soul.vessel:setLinearVelocity(vx, vy)
	self.soul:refreshAnimation()
end

---Create a new PlayerWalkState
---@param player Player
---@return PlayerWalkState
function PlayerWalkState.new(player)
	return SoulWalkState.new(player, PlayerWalkState)
end

return PlayerWalkState
