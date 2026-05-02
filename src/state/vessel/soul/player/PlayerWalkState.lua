local BaseState = require("src.state.BaseState")

---Walking state for the player character.
---@class PlayerWalkState : BaseState
---@field stateName string
---@field soul Player
local PlayerWalkState = {}
PlayerWalkState.__index = PlayerWalkState
setmetatable(PlayerWalkState, { __index = BaseState })

PlayerWalkState.STATE_NAME = "walk"

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function PlayerWalkState:enterState(opts)
	self.soul:setIsAnimating(true)
	self.soul:refreshAnimation()

	-- set immediately to walking frame for accurate animation on key press
	self.soul.animations.current:gotoFrame(2)
end

---Update player movement from the current input state.
---@param dt number Delta time in seconds
---@return nil
function PlayerWalkState:update(dt)
	self:movePlayer()
end

---Read directional input, compute Box2D velocity, and select the correct animation.
---Transitions back to idle if no directional key is held.
---@return nil
function PlayerWalkState:movePlayer()
	local dirX, dirY, isMoving = Input.getDirection()
	if not isMoving then
		local vx, vy = self.soul.vessel:getLinearVelocity()
		local coastMultiplier = self.soul.releaseCoastMultiplier or 1
		self.soul.vessel:setLinearVelocity(vx * coastMultiplier, vy * coastMultiplier)
		self.soul:changeState(PlayerIdleState.STATE_NAME)
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
	local self = BaseState.new(PlayerWalkState)
	self.stateName = PlayerWalkState.STATE_NAME
	self.soul = player
	return self
end

return PlayerWalkState
