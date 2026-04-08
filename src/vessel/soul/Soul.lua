--@class Soul
local Soul = {}
Soul.__index = Soul

function Soul:createAnimations()
	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.animations.down = Anim8.newAnimation(self.grid("1-4", 1), 0.1)
	self.animations.left = Anim8.newAnimation(self.grid("1-4", 2), 0.1)
	self.animations.right = Anim8.newAnimation(self.grid("1-4", 3), 0.1)
	self.animations.up = Anim8.newAnimation(self.grid("1-4", 4), 0.1)
	self.animations.current = self.animations.down
end

function Soul:createCollision(world)
	local shapeWidth = self.width * self.scale
	local shapeHeight = self.height * self.scale
	local shapeCornerCutSize = 3 * self.scale
	-- TODO: figure out why adjusting height doesn't work as expected
	self.collision = Collision.newOctagon(world, self.x, self.y, shapeWidth - 2, shapeHeight, shapeCornerCutSize)
end

function Soul:update(dt)
	self.animations.current:update(dt)
end

function Soul:draw()
	self.animations.current:draw(
		self.spriteSheet,
		self.x,
		self.y, -- body center position
		nil, -- rotation
		self.scale, -- scaleX
		nil, -- scaleY (defaults to scaleX)
		self.width / 2, -- originX: centered (half of sprite width)
		self.height / 2 -- originY: centered (half of sprite height)
	)
end

function Soul.new(def, subclass)
	local self = setmetatable({}, subclass or Soul)
	self.x = def.x
	self.y = def.y
	self.width = def.width
	self.height = def.height
	self.speed = def.speed
	self.scale = def.scale
	self.spriteSheet = def.spriteSheet
	self.animations = {}
	self.stateMachine = {}
	self:createAnimations()
	self:createCollision(def.world)
	return self
end

return Soul
