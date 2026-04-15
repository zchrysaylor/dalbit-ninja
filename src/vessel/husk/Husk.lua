---@class Husk
---@field vessel Vessel
---@field collider collider
---@field x number
---@field y number
---@field width number
---@field height number
---@field spriteSheet love.Image
---@field animations? table
---@field stateMachine StateMachine
---@field grid any
local Husk = {}
Husk.__index = Husk

function Husk:createAnimations(animations)
	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.animations = nil
	-- TODO: not implemented yet
	if animations then
		self.animations = animations.animations
		self.animations.current = animations.current
	end
end

function Husk:createStateMachine()
	self.stateMachine = StateMachine.new({
		["idle"] = function()
			return HuskIdleState.new(self)
		end,
	})
end

---Transition this Husk to a new state.
---@param state string State key (e.g. "idle", "walk")
---@param opts? table Optional arguments forwarded to the state's enterState()
function Husk:changeState(state, opts)
	self.stateMachine:changeState(state, opts)
end

---Destroy the underlying Vessel (and its physics body).
function Husk:destroy()
	self.vessel:destroy()
end

---@param dt number Delta time in seconds
function Husk:update(dt)
	if self.animations and self.animations.current then
		self.animations.current:update(dt)
	end
	self.stateMachine:update(dt)
end

---Draw the current animation frame centered at (x, y).
function Husk:draw()
	if self.animations and self.animations.current then
		self.animations.current:draw(
			self.spriteSheet,
			self.x,
			self.y, -- body center position
			nil, -- rotation
			1, -- scaleX
			nil, -- scaleY (defaults to scaleX)
			self.width / 2, -- originX: centered (half of sprite width)
			self.height / 2 -- originY: centered (half of sprite height)
		)
	end
end

---Create a new Husk.
---@generic T : Husk
---@param def {x: number, y: number, width: number, height: number, spriteSheet: love.Image, physics: physics, animations?: table, tags?: string[]}
---@return T
function Husk.new(def)
	assert(def.physics, "Husk must have a physics instance")
	assert(def.spriteSheet, "Husk must have a spriteSheet")
	local self = setmetatable({}, Husk)
	self.x = def.x
	self.y = def.y
	self.width = def.width
	self.height = def.height
	self.spriteSheet = def.spriteSheet

	local vesselOpts = {
		x = def.x,
		y = def.y,
		width = def.width,
		height = def.height,
		physics = def.physics,
		tags = def.tags or { "husk" },
	}
	self.vessel = Vessel.new(vesselOpts)
	self.collider = self.vessel.collider

	self:createAnimations(def.animations)
	self:createStateMachine()
	self:changeState("idle")

	return self
end

return Husk
