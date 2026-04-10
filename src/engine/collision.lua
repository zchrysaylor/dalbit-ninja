-- Utility module for creating and debugging Box2D collision bodies.
-- Returns plain tables {body, shape, fixture}; instance methods live on Vessel.

---@alias CollisionData {body: love.Body, shape: love.Shape, fixture: love.Fixture}

local collision = {}

---Create a static rectangle collider.
---@param world love.World
---@param x number Center X position
---@param y number Center Y position
---@param w number Width in pixels
---@param h number Height in pixels
---@param bodyType? love.BodyType Body type (default "static")
---@return CollisionData
function collision.newRectangle(world, x, y, w, h, bodyType)
	bodyType = bodyType or "static"
	local body = love.physics.newBody(world, x, y, bodyType)
	local shape = love.physics.newRectangleShape(w, h)
	local fixture = love.physics.newFixture(body, shape, 1)
	body:setFixedRotation(true)
	return { body = body, shape = shape, fixture = fixture }
end

---Create an octagon (beveled/corner-cut rectangle) collider.
---@param world love.World
---@param x number Center X position
---@param y number Center Y position
---@param w number Width in pixels
---@param h number Height in pixels
---@param s? number Corner cut size in pixels (default 4)
---@param bodyType? love.BodyType Body type (default "dynamic")
---@return CollisionData
function collision.newOctagon(world, x, y, w, h, s, bodyType)
	s = s or 4
	bodyType = bodyType or "dynamic"
	local body = love.physics.newBody(world, x, y, bodyType)
	local shape = love.physics.newPolygonShape(
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
	local fixture = love.physics.newFixture(body, shape, 1)
	body:setFixedRotation(true)
	return { body = body, shape = shape, fixture = fixture }
end

-- TODO: add a queryCircleArea for interactions (https://www.youtube.com/watch?v=2EPBHHE-ZU0&list=PLqPLyUreLV8D3Ckd_9UFNvEpg4xCvbL1a&index=4)

---Draw collision outlines for all bodies in the world. Debug use only.
---@param world love.World
---@param alpha? number Outline opacity from 0 to 1 (default 1)
function collision.drawAll(world, alpha)
	-- save current color to restore after, since love.graphics.setColor() is global state
	local r, g, b, a = love.graphics.getColor()
	alpha = alpha or 1
	love.graphics.setColor(love.math.colorFromBytes(64, 39, 81, alpha * 255))
	local bodies = world:getBodies()
	for _, body in ipairs(bodies) do
		for _, fixture in ipairs(body:getFixtures()) do
			if fixture:getShape():type() == "PolygonShape" then
				love.graphics.polygon("line", body:getWorldPoints(fixture:getShape():getPoints()))
			end
		end
	end
	love.graphics.setColor(r, g, b, a)
end

return collision
