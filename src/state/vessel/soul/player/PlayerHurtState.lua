local BaseState = require("src.state.BaseState")

---@class PlayerHurtState : BaseState
---@field stateName string
---@field player Player
local PlayerHurtState = {}
PlayerHurtState.__index = PlayerHurtState
setmetatable(PlayerHurtState, { __index = BaseState })

PlayerHurtState.STATE_NAME = "hurt"

---Transition the player to walk or idle state after stunTimer completes
---@param dt number Delta time in seconds
---@return nil
function PlayerHurtState:update(dt)
	if self.player.stunTimer <= 0 then
		local dirX, dirY, isMoving = Input.getDirection()
		if isMoving then
			self.player.dirX = dirX
			self.player.dirY = dirY
			self.player:setFacingFromVector(dirX, dirY)
			self.player:changeState(PlayerWalkState.STATE_NAME)
			return
		end

		self.player:changeState(PlayerIdleState.STATE_NAME)
	end
end

---Create a new PlayerHurtState
---@param player Player
---@return PlayerHurtState
function PlayerHurtState.new(player)
	local self = BaseState.new(PlayerHurtState)
	self.stateName = PlayerHurtState.STATE_NAME
	self.player = player
	return self
end

return PlayerHurtState
