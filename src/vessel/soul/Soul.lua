local Vessel = require("src.vessel.Vessel")

---@class Soul : Vessel
---@field speed number Movement speed multiplier
---@field animations table Directional animation set (keys: "down", "left", "right", "up", "current")
---@field stateMachine StateMachine Per-entity state machine managing idle/walk transitions
local Soul = {}
Soul.__index = Soul
setmetatable(Soul, { __index = Vessel })

---Build the animation grid and directional animations from the sprite sheet.
---Populates self.animations with "down", "left", "right", "up", and "current".
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

---Transition this Soul to a new state.
---@param state string State key (e.g. "idle", "walk")
---@param args? table Optional arguments forwarded to the state's enterState()
function Soul:changeState(state, args)
	self.stateMachine:changeState(state, args)
end

---Update the current animation frame and delegate to the active state.
---@param dt number Delta time in seconds
function Soul:update(dt)
	self.animations.current:update(dt)
	self.stateMachine:update(dt)
end

---Draw the current animation frame centered at (x, y).
---Overrides Vessel:draw() to use animation-based rendering.
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
---@param def table {x, y, width, height, scale, speed, spriteSheet, world}
---@param subclass? T Metatable for subclass (defaults to Soul)
---@return T
function Soul.new(def, subclass)
	local self = Vessel.new(def, subclass or Soul)
	self.speed = def.speed
	self.animations = {}
	self:createStateMachine()
	self:createAnimations()
	self:changeState("idle")
	return self
end

return Soul
