local BaseState = require("src.state.BaseState")

---Walking state for the player character.
---@class PlayerWalkState : BaseState
---@field stateName string
---@field player Player
local PlayerWalkState = {}
PlayerWalkState.__index = PlayerWalkState
setmetatable(PlayerWalkState, { __index = BaseState })

PlayerWalkState.STATE_NAME = "walk"

---Called when this state becomes active.
---@param opts? table Optional options.
---@return nil
function PlayerWalkState:enterState(opts)
	self.player:setIsAnimating(true)
	self.player:refreshAnimation()

	-- set immediately to walking frame for accurate animation on key press
	self.player.animations.current:gotoFrame(2)
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
	if not self.player:applyInputDirection() then
		self.player.vessel:setLinearVelocity(0, 0)
		self.player:changeState(PlayerIdleState.STATE_NAME)
		return
	end

	-- build velocity from direction
	local speed = self.player.speed
	local vx = self.player.dirX * speed
	local vy = self.player.dirY * speed

	-- normalize diagonal movement so the player doesn't move faster on diagonals
	if vx ~= 0 and vy ~= 0 then
		local diagonalFactor = 1 / math.sqrt(2)
		vx = vx * diagonalFactor
		vy = vy * diagonalFactor
	end

	-- move the body with physics and animations
	self.player.vessel:setLinearVelocity(vx, vy)
	self.player:refreshAnimation()
end

---Create a new PlayerWalkState
---@param player Player
---@return PlayerWalkState
function PlayerWalkState.new(player)
	local self = BaseState.new(PlayerWalkState)
	self.stateName = PlayerWalkState.STATE_NAME
	self.player = player
	return self
end

return PlayerWalkState
