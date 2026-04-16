local Soul = require("src.vessel.soul.Soul")

---@class Player : Soul
---@field dirX number  -1, 0, or 1
---@field dirY number  -1, 0, or 1
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

local ANIMATION_SPEED = 0.1
local INTERACT_RADIUS = 12
local INTERACT_OFFSET = 12

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

function Player:interact()
	local world = self.collider.body:getWorld()
	local px, py = self.collider:getPosition()

	-- offset the query circle in the direction the player faces
	local offX = self.dirX * INTERACT_OFFSET
	local offY = self.dirY * INTERACT_OFFSET
	if offX ~= 0 and offY ~= 0 then
		local diag = 1 / math.sqrt(2)
		offX = offX * diag
		offY = offY * diag
	end

	local x = px + offX
	local y = py + offY
	local interactables = Collision.queryCircleArea(world, x, y, INTERACT_RADIUS, function(c)
		return c:hasTag("interactable")
	end)

	for _, c in ipairs(interactables) do
		if c.owner and c.owner.interact then
			c.owner:interact()
		end
	end
end

---Create a new Player.
---Delegates to Soul.new then disables linear damping so velocity is fully player-controlled.
---@param def {x: number, y: number, width: number, height: number, scale: number, speed: number, spriteSheet: love.Image, physics: physics, dirX?: number, dirY?: number}
---@return Player
function Player.new(def)
	local self = Soul.new(def, Player)
	self.collider:setLinearDamping(0) -- no friction; player controls velocity directly
	self.dirX = def.dirX or 0
	self.dirY = def.dirY or 1
	return self
end

return Player
