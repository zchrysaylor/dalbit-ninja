local SoulIdleState = require("src.state.vessel.soul.SoulIdleState")

---@class PlayerIdleState : SoulIdleState
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = SoulIdleState })

function PlayerIdleState:enterState(args)
	SoulIdleState.enterState(self, args)
	self.soul.collision:setLinearVelocity(0, 0)
end

function PlayerIdleState:update(dt)
	SoulIdleState.update(self, dt)

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
	local self = SoulIdleState.new(player)
	setmetatable(self, PlayerIdleState)
	return self
end

return PlayerIdleState
