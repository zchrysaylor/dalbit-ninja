local SoulIdleState = require("src.state.vessel.soul.SoulIdleState")

---@class PlayerIdleState : SoulIdleState
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = SoulIdleState })

---Called when this state becomes active.
---@param args? table Optional arguments
function PlayerIdleState:enterState(args)
	SoulIdleState.enterState(self, args)
	self.soul.vessel:setLinearVelocity(0, 0)
end

---@param dt number Delta time in seconds
function PlayerIdleState:update(dt)
	local dirX, dirY, isMoving = Input.getDirection()
	if isMoving then
		-- Set direction before transitioning
		self.soul.dirX = dirX
		self.soul.dirY = dirY
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
