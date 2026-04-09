local Soul = require("src.vessel.soul.Soul")

local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

local ANIMATION_SPEED = 0.1

function Player:createAnimations()
	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

	self.animations = {}
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

function Player:createCollision(world)
	Soul.createCollision(self, world)
	self.collision.body:setLinearDamping(0) -- no friction slowdown since you control velocity directly
end

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

function Player.new(def)
	return Soul.new(def, Player)
end

return Player
