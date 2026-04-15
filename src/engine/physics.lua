--- Factory and instance methods for Box2D colliders. Owns the Box2D world.
---@class physics
---@field world love.World
local physics = {}
physics.__index = physics

---Thin wrapper around a Box2D body/shape/fixture triple with a tag system.
---@class collider
---@field body love.Body
---@field shape love.Shape
---@field fixture love.Fixture
---@field tags table<string, boolean>
local collider = {}
collider.__index = collider

---Set the world position of the collider's body.
---@param x number
---@param y number
function collider:setPosition(x, y)
	self.body:setPosition(x, y)
end

---Get the world position of the collider's body.
---@return number x
---@return number y
function collider:getPosition()
	return self.body:getPosition()
end

---Set the linear velocity of the collider's body.
---@param vx number Horizontal velocity in pixels/sec
---@param vy number Vertical velocity in pixels/sec
function collider:setLinearVelocity(vx, vy)
	self.body:setLinearVelocity(vx, vy)
end

---Get the linear velocity of the collider's body.
---@return number vx
---@return number vy
function collider:getLinearVelocity()
	return self.body:getLinearVelocity()
end

---Set the linear damping (drag) on the collider's body.
---@param ld number Damping coefficient (0 = no drag)
function collider:setLinearDamping(ld)
	self.body:setLinearDamping(ld)
end

---Get the linear damping of the collider's body.
---@return number ld
function collider:getLinearDamping()
	return self.body:getLinearDamping()
end

---Attach arbitrary data to the collider's body (e.g. warp metadata).
---@param data any
function collider:setUserData(data)
	self.body:setUserData(data)
end

---Retrieve data previously attached with setUserData.
---@return any
function collider:getUserData()
	return self.body:getUserData()
end

---Destroy the underlying Box2D body, removing it from the world.
function collider:destroy()
	self.body:destroy()
end

---Return true if this collider's body has been destroyed.
---@return boolean
function collider:isDestroyed()
	return self.body:isDestroyed()
end

---Add one or more string tags to this collider.
---@param ... string Tag names
function collider:addTags(...)
	for _, tag in ipairs({ ... }) do
		if tag then
			self.tags[tag] = true
		end
	end
end

---Remove one or more string tags from this collider.
---@param ... string Tag names
function collider:removeTags(...)
	for _, tag in ipairs({ ... }) do
		if tag then
			self.tags[tag] = nil
		end
	end
end

---Return true if this collider has the given tag.
---@param tag string
---@return boolean
function collider:hasTag(tag)
	return self.tags[tag] == true
end

---Create a new collider in the physics world.
---@param x number Center X position in pixels
---@param y number Center Y position in pixels
---@param opts? {width?: number, height?: number, bevel?: number, bodyType?: love.BodyType, shape?: "rectangle"|"octagon", density?: number, restitution?: number, tags?: string[]}
---@return collider
function physics:collider(x, y, opts)
	opts = opts or {}
	local w = opts.width or 16
	local h = opts.height or 16
	local s = opts.bevel or 4
	local bodyType = opts.bodyType or "dynamic"
	local shape = opts.shape or "rectangle"
	local density = opts.density or 1

	local body = love.physics.newBody(self.world, x, y, bodyType)
	body:setFixedRotation(true)

	-- TODO: refactor shape definitions to common file, maybe collision.lua
	local physicsShape
	if shape == "octagon" then
		physicsShape = love.physics.newPolygonShape(
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
	else -- "rectangle" default
		physicsShape = love.physics.newRectangleShape(w, h)
	end

	local fixture = love.physics.newFixture(body, physicsShape, density)

	-- TODO: can later be defined in a vessel tag (i.e. tag "bouncy" sets restitution to a certain number)
	if opts.restitution then
		fixture:setRestitution(opts.restitution)
	end

	local coll = setmetatable({
		body = body,
		shape = physicsShape,
		fixture = fixture,
		tags = {},
	}, collider)

	-- Registers the returned collider as the fixture's user data so spatial
	-- queries can recover this wrapper from raw Box2D fixtures.
	fixture:setUserData(coll)

	return coll
end

-- TODO: add vector normalization function to account for diagonal speed

---Create a new Physics instance wrapping the given Box2D world.
---@param world love.World
---@return physics
function physics.new(world)
	local self = setmetatable({}, physics)
	self.world = world
	return self
end

return physics
