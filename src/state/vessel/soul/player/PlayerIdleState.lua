local SoulIdleState = require("src.state.vessel.soul.SoulIdleState")

---@class PlayerIdleState : SoulIdleState
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = SoulIdleState })

---Pause animation and zero out velocity when the player enters idle.
---@param args? table Forwarded to SoulIdleState.enterState()
function PlayerIdleState:enterState(args)
	SoulIdleState.enterState(self, args)
	self.soul:setLinearVelocity(0, 0)
end

---Transition to "walk" if any directional key is held.
---@param dt number Delta time in seconds
function PlayerIdleState:update(dt)
	if
		love.keyboard.isDown(KEY_UP)
		or love.keyboard.isDown(KEY_DOWN)
		or love.keyboard.isDown(KEY_LEFT)
		or love.keyboard.isDown(KEY_RIGHT)
	then
		self.soul:changeState("walk")
	end

	-- TODO: implement spacebar action
	-- if love.keyboard.wasPressed("space") then
	-- 	self.soul:changeState("")
	-- end
end

---@param player Player
---@return PlayerIdleState
function PlayerIdleState.new(player)
	return SoulIdleState.new(player, PlayerIdleState)
end

return PlayerIdleState
