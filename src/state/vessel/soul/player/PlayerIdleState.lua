local SoulIdleState = require("src.state.vessel.soul.SoulIdleState")

local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = SoulIdleState })

function PlayerIdleState:update(dt)
	if
		love.keyboard.isDown(KEY_UP)
		or love.keyboard.isDown(KEY_DOWN)
		or love.keyboard.isDown(KEY_LEFT)
		or love.keyboard.isDown(KEY_RIGHT)
	then
		self.player:changeState("walk")
	end

	-- TODO: implement spacebar action
	-- if love.keyboard.wasPressed("space") then
	-- 	self.player:changeState("")
	-- end
end

function PlayerIdleState.new(player)
	local self = SoulIdleState.new(player)
	self.player = player
	return self
end

return PlayerIdleState
