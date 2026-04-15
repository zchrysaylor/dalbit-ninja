---@class Soul
---@field vessel Vessel
---@field collider collider
---@field x number
---@field y number
---@field width number
---@field height number
---@field scale number
---@field spriteSheet love.Image
---@field speed number
---@field animations table
---@field stateMachine StateMachine
---@field grid any
---@field direction? string
local Soul = {}
Soul.__index = Soul

---Build animation grid and directional animations from the sprite sheet.
function Soul:createAnimations()
	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.animations.down = Anim8.newAnimation(self.grid("1-4", 1), 0.1)
	self.animations.left = Anim8.newAnimation(self.grid("1-4", 2), 0.1)
	self.animations.right = Anim8.newAnimation(self.grid("1-4", 3), 0.1)
	self.animations.up = Anim8.newAnimation(self.grid("1-4", 4), 0.1)
	self.animations.current = self.animations.down
end

---Build the state machine.
---Subclasses override this to register their own state factories.
function Soul:createStateMachine()
	self.stateMachine = StateMachine.new({
		["idle"] = function()
			return SoulIdleState.new(self)
		end,
		["walk"] = function()
			return SoulWalkState.new(self)
		end,
	})
end

-- TODO: refactor all args to "opts"
---Transition this Soul to a new state.
---@param state string State key (e.g. "idle", "walk")
---@param args? table Optional arguments forwarded to the state's enterState()
function Soul:changeState(state, args)
	self.stateMachine:changeState(state, args)
end

---Sync self.x/self.y from the vessel's physics body position.
---Must be called each frame after the physics world steps.
function Soul:syncPosition()
	self.x, self.y = self.vessel:getPosition()
end

---Destroy the underlying Vessel (and its physics body).
function Soul:destroy()
	self.vessel:destroy()
end

---@param dt number Delta time in seconds
function Soul:update(dt)
	self.animations.current:update(dt)
	self.stateMachine:update(dt)
end

---Draw the current animation frame centered at (x, y).
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

---Create a new Soul.
---@generic T : Soul
---@param def {x: number, y: number, width: number, height: number, scale: number, speed: number, spriteSheet: love.Image, physics: physics, direction?: string, tags?: string[]}
---@param subclass? T Metatable for subclass (defaults to Soul)
---@return T
function Soul.new(def, subclass)
	assert(def.physics, "Soul must have a physics instance")
	assert(def.spriteSheet, "Soul must have a spriteSheet")
	local self = setmetatable({}, subclass or Soul)
	self.x = def.x
	self.y = def.y
	self.width = def.width
	self.height = def.height
	self.scale = def.scale
	self.speed = def.speed
	self.direction = def.direction
	self.spriteSheet = def.spriteSheet

	local vesselOpts = {
		x = def.x,
		y = def.y,
		width = def.width,
		height = def.height,
		scale = def.scale,
		speed = def.speed,
		physics = def.physics,
		tags = def.tags or { "soul" },
	}
	self.vessel = Vessel.new(vesselOpts)
	self.collider = self.vessel.collider

	self.animations = {}
	self:createStateMachine()
	self:createAnimations()
	self:changeState("idle")

	return self
end

return Soul
