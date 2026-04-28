local Soul = require("src.vessel.soul.Soul")

---@class Player : Soul
---@field dirX number  -1, 0, or 1
---@field dirY number  -1, 0, or 1
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

local ANIMATION_SPEED = 0.1
local INTERACT_RADIUS = 8
local INTERACT_OFFSET = 6

---Build the 8-directional animation set from the player sprite sheet.
---Overrides Soul:createAnimations() to add diagonal directions.
---@return nil
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
---@return nil
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

---Switch the active animation to match the player's current facing or move vector.
---@return nil
function Player:syncDirectionalAnimation()
	local dirX = self.dirX or 0
	local dirY = self.dirY or 0

	if dirX ~= 0 and dirY ~= 0 then
		if dirY < 0 then
			self.animations.current = dirX < 0 and self.animations.upLeft or self.animations.upRight
		else
			self.animations.current = dirX < 0 and self.animations.downLeft or self.animations.downRight
		end
		return
	end

	if dirY ~= 0 then
		self.animations.current = dirY < 0 and self.animations.up or self.animations.down
		return
	end

	if dirX ~= 0 then
		self.animations.current = dirX < 0 and self.animations.left or self.animations.right
		return
	end

	Soul.syncDirectionalAnimation(self)
end

---@return nil
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
---@param def {x: number, y: number, width: number, height: number, scale: number, speed: number, spriteSheet: love.Image, physics: physics, dirX?: number, dirY?: number}
---@return Player
function Player.new(def)
	local self = Soul.new(def, Player)
	self.collider:setLinearDamping(0) -- no friction; player controls velocity directly
	self.collider.owner = self

	self.dirX = def.dirX or 0
	self.dirY = def.dirY or 1
	self:setFacingFromVector(self.dirX, self.dirY)
	self:syncDirectionalAnimation()

	return self
end

return Player
