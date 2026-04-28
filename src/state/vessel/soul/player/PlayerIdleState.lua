local SoulIdleState = require("src.state.vessel.soul.SoulIdleState")

---Idle state for the player character.
---@class PlayerIdleState : SoulIdleState
---@field stateName string
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = SoulIdleState })

PlayerIdleState.STATE_NAME = "idle"

---Called when this state becomes active.
---@param opts? table Optional options
function PlayerIdleState:enterState(opts)
	self.soul.dirX = 0
	self.soul.dirY = 0
	SoulIdleState.enterState(self, opts)
	self.soul.vessel:setLinearVelocity(0, 0)
end

---Transition the player to walking when directional input is pressed.
---@param dt number Delta time in seconds
function PlayerIdleState:update(dt)
	local dirX, dirY, isMoving = Input.getDirection()
	if isMoving then
		-- Set direction before transitioning
		self.soul.dirX = dirX
		self.soul.dirY = dirY
		self.soul:setFacingFromVector(dirX, dirY)
		self.soul:changeState("walk")
	end
end

---Create a new PlayerIdleState
---@param player Player
---@return PlayerIdleState
function PlayerIdleState.new(player)
	return SoulIdleState.new(player, PlayerIdleState)
end

return PlayerIdleState
