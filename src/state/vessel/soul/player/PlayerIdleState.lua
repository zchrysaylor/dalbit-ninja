local BaseState = require("src.state.BaseState")

---Idle state for the player character.
---@class PlayerIdleState : BaseState
---@field stateName string
---@field player Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = BaseState })

PlayerIdleState.STATE_NAME = "idle"

---Called when this state becomes active.
---Clears transient movement input while preserving persisted facing.
---@param opts? table Optional options
---@return nil
function PlayerIdleState:enterState(opts)
	self.player.dirX = 0
	self.player.dirY = 0
	self.player:setIsAnimating(false)
	self.player:refreshAnimation()
end

---Transition the player to walking when directional input is pressed.
---@param dt number Delta time in seconds
---@return nil
function PlayerIdleState:update(dt)
	if self.player:applyInputDirection() then
		self.player:changeState(PlayerWalkState.STATE_NAME)
		return
	end
end

---Create a new PlayerIdleState
---@param player Player
---@return PlayerIdleState
function PlayerIdleState.new(player)
	local self = BaseState.new(PlayerIdleState)
	self.stateName = PlayerIdleState.STATE_NAME
	self.player = player
	return self
end

return PlayerIdleState
