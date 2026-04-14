---@class Vessel
---@field x number
---@field y number
---@field width number
---@field height number
---@field scale number
---@field spriteSheet love.Image
---@field collision CollisionData
local Vessel = {}
Vessel.__index = Vessel

---Create the collision body for this Vessel.
---Default implementation creates a dynamic octagon (suitable for Souls).
---Subclasses can override for different shapes/body types.
---@param world love.World
function Vessel:createCollision(world)
	local shapeWidth = self.width * self.scale
	local shapeHeight = self.height * self.scale
	local shapeCornerCutSize = 3 * self.scale
	-- TODO: figure out why adjusting height doesn't work as expected
	self.collision = Collision.newOctagon(world, self.x, self.y, shapeWidth - 2, shapeHeight, shapeCornerCutSize)
end

---Set the position of this Vessel's physics body.
---@param x number
---@param y number
function Vessel:setPosition(x, y)
	self.collision.body:setPosition(x, y)
end

---Get the position of this Vessel's physics body.
---@return number x
---@return number y
function Vessel:getPosition()
	return self.collision.body:getPosition()
end

---Set the linear velocity of this Vessel's physics body.
---@param vx number
---@param vy number
function Vessel:setLinearVelocity(vx, vy)
	self.collision.body:setLinearVelocity(vx, vy)
end

---Get the linear velocity of this Vessel's physics body.
---@return number vx
---@return number vy
function Vessel:getLinearVelocity()
	return self.collision.body:getLinearVelocity()
end

---Destroy this Vessel's physics body.
function Vessel:destroy()
	self.collision.body:destroy()
end

---@param dt number Delta time in seconds
function Vessel:update(dt) end

---Draw the Vessel's sprite at its position.
---Base implementation draws the full spriteSheet image centered at (x, y).
---Soul overrides this with animation-based rendering.
function Vessel:draw()
	-- TODO: can possibly remove if both Soul and Husk override to use animation-based rendering
	love.graphics.draw(
		self.spriteSheet,
		self.x,
		self.y,
		nil, -- rotation
		self.scale, -- scaleX
		nil, -- scaleY (defaults to scaleX)
		self.width / 2, -- originX: centered
		self.height / 2 -- originY: centered
	)
end

---Create a new Vessel
---@generic T : Vessel
---@param def table {x, y, width, height, scale, spriteSheet, world}
---@param subclass? T Metatable for subclass (defaults to Vessel)
---@return T
function Vessel.new(def, subclass)
	local self = setmetatable({}, subclass or Vessel)
	assert(def.world, "Vessel requires a world")
	assert(def.spriteSheet, "Vessel requires a spriteSheet")
	self.x = def.x or 0
	self.y = def.y or 0
	self.width = def.width or 16
	self.height = def.height or 16
	self.scale = def.scale or 1
	self.spriteSheet = def.spriteSheet
	self:createCollision(def.world)
	return self
end

return Vessel
