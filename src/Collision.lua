---@class Collision
---@field body love.Body
---@field shape love.Shape
---@field fixture love.Fixture
local Collision = {}
Collision.__index = Collision

---Set the position of a collision.
---@param number x
---@param number y
function Collision:setPosition(x, y)
	return self.body:setPosition(x, y)
end

---Get the position of a collision.
---@return number x
---@return number y
function Collision:getPosition()
	return self.body:getPosition()
end

---Set the linear velocity of a collision.
---@param number vx Horizontal velocity in pixels/sec
---@param number vy Vertical velocity in pixels/sec
function Collision:setLinearVelocity(vx, vy)
	self.body:setLinearVelocity(vx, vy)
end

---Get the linear velocity of a collision.
---@return number vx Horizontal velocity in pixels/sec
---@return number vy Vertical velocity in pixels/sec
function Collision:getLinearVelocity()
	return self.body:getLinearVelocity()
end

---Create a standard rectangle collider.
---@param world love.World
---@param x number Center X position
---@param y number Center Y position
---@param w number Width in pixels
---@param h number Height in pixels
---@param bodyType? love.BodyType Body type (default "static")
---@return Collision
local function newRectangleCollision(world, x, y, w, h, bodyType)
	local self = setmetatable({}, Collision)
	bodyType = bodyType or "static"

	self.body = love.physics.newBody(world, x, y, bodyType)
	self.shape = love.physics.newRectangleShape(w, h)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self.body:setFixedRotation(true)

	return self
end

---Create an octagon (beveled/corner-cut rectangle) collision.
---@param world love.World
---@param x number Center X position
---@param y number Center Y position
---@param w number Width in pixels
---@param h number Height in pixels
---@param s? number Corner cut size (default 4)
---@param bodyType? love.BodyType Body type (default "dynamic")
---@return Collision
local function newOctagonCollision(world, x, y, w, h, s, bodyType)
	local self = setmetatable({}, Collision)
	s = s or 4
	bodyType = bodyType or "dynamic"

	self.body = love.physics.newBody(world, x, y, bodyType)
	self.shape = love.physics.newPolygonShape(
		-w / 2,
		-h / 2 + s,
		-w / 2 + s,
		-h / 2,
		w / 2 - s,
		-h / 2,
		w / 2,
		-h / 2 + s,
		w / 2,
		h / 2 - s,
		w / 2 - s,
		h / 2,
		-w / 2 + s,
		h / 2,
		-w / 2,
		h / 2 - s
	)
	self.fixture = love.physics.newFixture(self.body, self.shape, 1)
	self.body:setFixedRotation(true)

	return self
end

---Draw collision outlines for debugging.
---@param world love.World
---@param alpha? number The optional alpha value to make collision outlines semi-transparent (decimal value from 0 to 1)
local function drawCollisions(world, alpha)
	-- save current colors to reset since love.graphics.setColor() is global state
	local r, g, b, a = love.graphics.getColor()

	-- set collision border colors, alpha value is optional
	alpha = alpha or 1
	-- TODO: add note why must mulitply by 255
	love.graphics.setColor(love.math.colorFromBytes(64, 39, 81, alpha * 255))

	local bodies = world:getBodies()
	for _, body in ipairs(bodies) do
		local fixtures = body:getFixtures()
		for _, fixture in ipairs(fixtures) do
			if fixture:getShape():type() == "PolygonShape" then
				love.graphics.polygon("line", body:getWorldPoints(fixture:getShape():getPoints()))
			end
		end
	end

	-- reset global colors
	love.graphics.setColor(r, g, b, a)
end

return {
	newRectangleCollision = newRectangleCollision,
	newOctagonCollision = newOctagonCollision,
	drawCollisions = drawCollisions,
}
