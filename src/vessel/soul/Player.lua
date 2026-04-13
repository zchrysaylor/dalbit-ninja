local Soul = require("src.vessel.soul.Soul")

---@class Player : Soul
---@field dirX number  -1, 0, or 1
---@field dirY number  -1, 0, or 1
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

local ANIMATION_SPEED = 0.1

---Build the 8-directional animation set from the player sprite sheet.
---Overrides Soul:createAnimations() to add diagonal directions.
function Player:createAnimations()
	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.animations.down = Anim8.newAnimation(self.grid("1-4", 1), ANIMATION_SPEED)
	self.animations.downLeft = Anim8.newAnimation(self.grid("1-4", 2), ANIMATION_SPEED)
	self.animations.left = Anim8.newAnimation(self.grid("1-4", 3), ANIMATION_SPEED)
	self.animations.upLeft = Anim8.newAnimation(self.grid("1-4", 4), ANIMATION_SPEED)
	self.animations.up = Anim8.newAnimation(self.grid("1-4", 5), ANIMATION_SPEED)
	self.animations.upRight = Anim8.newAnimation(self.grid("1-4", 6), ANIMATION_SPEED)
	self.animations.right = Anim8.newAnimation(self.grid("1-4", 7), ANIMATION_SPEED)
	self.animations.downRight = Anim8.newAnimation(self.grid("1-4", 8), ANIMATION_SPEED)
	self.animations.current = self.animations.down
end

---Create the physics body and disable linear damping so velocity is fully player-controlled.
---Overrides Soul:createCollision() to disable linear damping on the resulting body.
---@param world love.World
function Player:createCollision(world)
	Soul.createCollision(self, world)
	self.collision.body:setLinearDamping(0) -- no friction slowdown since you control velocity directly
end

---Build the state machine.
---Overrides Soul:createStateMachine() to wire player-specific states.
function Player:createStateMachine()
	self.stateMachine = StateMachine.new({
		["idle"] = function()
			return PlayerIdleState.new(self)
		end,
		["walk"] = function()
			return PlayerWalkState.new(self)
		end,
	})
end

---Create a new Player
---@param def table {x, y, width, height, scale, speed, spriteSheet, world, dirX, dirY}
---@return Player
function Player.new(def)
	local self = Soul.new(def, Player)
	self.dirX = def.dirX or 0
	self.dirY = def.dirY or 1
	return self
end

return Player
