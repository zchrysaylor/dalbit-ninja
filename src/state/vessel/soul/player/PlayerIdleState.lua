local SoulIdleState = require("src.state.vessel.soul.SoulIdleState")

---@class PlayerIdleState : SoulIdleState
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
setmetatable(PlayerIdleState, { __index = SoulIdleState })

---Pause animation and zero out velocity when the player enters idle.
---@param args? table Optional arguments
function PlayerIdleState:enterState(args)
	SoulIdleState.enterState(self, args)
	self.soul:setLinearVelocity(0, 0)
end

---Transition to "walk" if any directional key is held.
---@param dt number Delta time in seconds
function PlayerIdleState:update(dt)
	local moveUp = love.keyboard.isDown(KEY_UP)
	local moveDown = love.keyboard.isDown(KEY_DOWN)
	local moveLeft = love.keyboard.isDown(KEY_LEFT)
	local moveRight = love.keyboard.isDown(KEY_RIGHT)
	if moveUp or moveDown or moveLeft or moveRight then
		-- Set direction before transitioning
		self.soul.dirX = (moveRight and 1 or 0) - (moveLeft and 1 or 0)
		self.soul.dirY = (moveDown and 1 or 0) - (moveUp and 1 or 0)
		self.soul:changeState("walk")
	end

	-- TODO: implement spacebar action (used Signal)
	-- if love.keyboard.wasPressed("space") then
	-- 	self.soul:changeState("")
	-- end
end

---Create a new PlayerIdleState
---@param player Player
---@return PlayerIdleState
function PlayerIdleState.new(player)
	return SoulIdleState.new(player, PlayerIdleState)
end

return PlayerIdleState
