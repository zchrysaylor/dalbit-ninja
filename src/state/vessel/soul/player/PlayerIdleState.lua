local BaseState = require("src.state.BaseState")

---Idle state for the player character.
---@class PlayerIdleState : BaseState
---@field stateName string
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = BaseState })

PlayerIdleState.STATE_NAME = "idle"

---Called when this state becomes active.
---Clears transient movement input while preserving persisted facing.
---@param opts? table Optional options
---@return nil
function PlayerIdleState:enterState(opts)
	self.soul.dirX = 0
	self.soul.dirY = 0
	self.soul:setIsAnimating(false)
	self.soul:refreshAnimation()
end

---Transition the player to walking when directional input is pressed.
---@param dt number Delta time in seconds
---@return nil
function PlayerIdleState:update(dt)
	local dirX, dirY, isMoving = Input.getDirection()
	if isMoving then
		-- Set direction before transitioning
		self.soul.dirX = dirX
		self.soul.dirY = dirY
		self.soul:setFacingFromVector(dirX, dirY)
		self.soul:changeState("walk")
		return
	end
end

---Create a new PlayerIdleState
---@param player Player
---@return PlayerIdleState
function PlayerIdleState.new(player)
	local self = BaseState.new(PlayerIdleState)
	self.stateName = PlayerIdleState.STATE_NAME
	self.soul = player
	return self
end

return PlayerIdleState
