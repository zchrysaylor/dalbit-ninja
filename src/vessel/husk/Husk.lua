---@class Husk
---@field vessel Vessel
---@field collider collider
---@field x number
---@field y number
---@field width number
---@field height number
---@field spriteSheet love.Image
---@field animOpts? {frames: string, row: integer, interval: number, paused?: boolean}
---@field animations? {current: any}
---@field grid? any Only set when animOpts is provided
---@field stateMachine StateMachine
local Husk = {}
Husk.__index = Husk

---Build the Anim8 grid and animation from self.animOpts.
---No-op if animOpts is nil (static sprite mode).
---@return nil
function Husk:createAnimations()
	if not self.animOpts then
		return
	end

	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	local animation = Anim8.newAnimation(self.grid(self.animOpts.frames, self.animOpts.row), self.animOpts.interval)
	self.animations = { current = animation }
end

---Build the state machine with an "idle" state.
---Subclasses override this to register additional state factories.
---@return nil
function Husk:createStateMachine()
	self.stateMachine = StateMachine.new({
		[HuskIdleState.STATE_NAME] = function()
			return HuskIdleState.new(self)
		end,
	})
end

---Transition this Husk to a new state.
---@param state string State key (e.g. "idle", "walk")
---@param opts? table Optional arguments forwarded to the state's enterState()
---@return nil
function Husk:changeState(state, opts)
	self.stateMachine:changeState(state, opts)
end

---No-op for non-interactable husks.
---@return nil
function Husk:interact() end

---Destroy the underlying Vessel (and its physics body).
---@return nil
function Husk:destroy()
	self.vessel:destroy()
end

---@param dt number Delta time in seconds
---@return nil
function Husk:update(dt)
	if self.animations and self.animations.current then
		self.animations.current:update(dt)
	end
	self.stateMachine:update(dt)
end

---Draw the current animation frame centered at (x, y).
---@return nil
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
	else
		love.graphics.draw(self.spriteSheet, self.x, self.y, nil, 1, nil, self.width / 2, self.height / 2)
	end
end

---Create a new Husk.
---@generic T : Husk
---@param def {x: number, y: number, width: number, height: number, spriteSheet: love.Image, physics: physics, animOpts?: {frames: string, row: integer, interval: number, paused?: boolean}, tags?: string[]}
---@param subclass? T Metatable to use (defaults to Husk)
---@return T
function Husk.new(def, subclass)
	assert(def.physics, "Husk must have a physics instance")
	assert(def.spriteSheet, "Husk must have a spriteSheet")
	local self = setmetatable({}, subclass or Husk)
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
		shape = "rectangle",
		bodyType = "static",
		tags = def.tags or { "husk" },
	}
	self.vessel = Vessel.new(vesselOpts)
	self.collider = self.vessel.collider
	self.collider.owner = self

	self.animOpts = def.animOpts
	self:createAnimations()
	self:createStateMachine()
	self:changeState(HuskIdleState.STATE_NAME)

	return self
end

return Husk
