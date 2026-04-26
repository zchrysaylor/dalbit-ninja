---@class SoulAIConfig
---@field homeX number
---@field homeY number
---@field type string
---@field wanderRadius number
---@field idleDurationMin number
---@field idleDurationMax number
---@field wanderBufferDuration number
---@field moveDirX number
---@field moveDirY number

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
---@field ai? SoulAIConfig
---@field previousX number
---@field previousY number
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

---Return whether this Soul has AI behavior configured.
---@return boolean
function Soul:isAI()
	return self.ai ~= nil and self.ai.type ~= nil
end

---Return whether this Soul is using a specific AI behavior type.
---@param aiType string
---@return boolean
function Soul:isAIType(aiType)
	return self:isAI() and self.ai.type == aiType
end

---Return whether the given point would be outside the Soul's wander radius.
---@param x number
---@param y number
---@return boolean
function Soul:isOutsideAIWanderRadius(x, y)
	assert(self:isAI(), "isOutsideAIWanderRadius called for non-AI soul")

	local dx = x - self.ai.homeX
	local dy = y - self.ai.homeY
	return dx * dx + dy * dy > self.ai.wanderRadius * self.ai.wanderRadius
end

---Pick a random idle duration from AI config bounds.
---@return number
function Soul:getRandomIdleDuration()
	assert(self:isAI(), "getRandomIdleDuration called for non-AI soul")

	local minDuration = self.ai.idleDurationMin
	local maxDuration = self.ai.idleDurationMax or minDuration
	if maxDuration < minDuration then
		minDuration, maxDuration = maxDuration, minDuration
	end

	return love.math.random() * (maxDuration - minDuration) + minDuration
end

---Set AI movement vector and keep facing/animation in sync.
---@param dirX number
---@param dirY number
function Soul:setAIMoveVector(dirX, dirY)
	assert(self:isAI(), "setAIMoveVector called for non-AI soul")

	local length = math.sqrt(dirX * dirX + dirY * dirY)
	if length == 0 then
		self.ai.moveDirX = 0
		self.ai.moveDirY = 0
		self:syncDirectionalAnimation()
		return
	end

	self.ai.moveDirX = dirX / length
	self.ai.moveDirY = dirY / length

	if math.abs(self.ai.moveDirX) > math.abs(self.ai.moveDirY) then
		if self.ai.moveDirX < 0 then
			self.direction = "left"
		else
			self.direction = "right"
		end
	else
		if self.ai.moveDirY < 0 then
			self.direction = "up"
		else
			self.direction = "down"
		end
	end

	self:syncDirectionalAnimation()
end

---Choose a new AI movement vector biased back toward the soul's home.
function Soul:chooseAIWanderDirection()
	assert(self:isAI(), "chooseAIWanderDirection called for non-AI soul")

	local x, y = self.vessel:getPosition()
	local dirX, dirY

	if x < self.ai.homeX and y < self.ai.homeY then
		dirX = 0
		dirY = 1
	elseif x > self.ai.homeX and y < self.ai.homeY then
		dirX = -1
		dirY = 0
	elseif x < self.ai.homeX and y > self.ai.homeY then
		dirX = 1
		dirY = 0
	else
		dirX = 0
		dirY = -1
	end

	local angle = (-math.pi / 2) * love.math.random()
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)
	local rotatedDirX = dirX * cosAngle - dirY * sinAngle
	local rotatedDirY = dirX * sinAngle + dirY * cosAngle

	self:setAIMoveVector(rotatedDirX, rotatedDirY)
end

---Validate AI walking after physics has stepped and positions are synced.
---@param dt number Delta time in seconds
function Soul:postPhysicsUpdate(dt)
	self.stateMachine:postPhysicsUpdate(dt)
end

---Transition this Soul to a new state.
---@param state string State key (e.g. "idle", "walk")
---@param opts? table Optional options forwarded to the state's enterState()
function Soul:changeState(state, opts)
	self.stateMachine:changeState(state, opts)
end

---Sync self.x/self.y from the vessel's physics body position.
---Must be called each frame after the physics world steps.
function Soul:syncPosition()
	self.x, self.y = self.vessel:getPosition()
end

---Record the soul's current position for post-physics movement checks.
function Soul:capturePreviousPosition()
	self.previousX = self.x
	self.previousY = self.y
end

---Switch the active animation to match the Soul's current facing direction.
function Soul:syncDirectionalAnimation()
	self.direction = self.direction or "down"
	self.animations.current = self.animations[self.direction]
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
---@param def {x: number, y: number, width: number, height: number, scale: number, speed: number, spriteSheet: love.Image, physics: physics, direction?: string, ai?: table, tags?: string[]}
---@param subclass? T Metatable for subclass (defaults to Soul)
---@return T
function Soul.new(def, subclass)
	assert(def.physics, "Soul must have a physics instance")
	assert(def.spriteSheet, "Soul must have a spriteSheet")
	local self = setmetatable({}, subclass or Soul)

	self.x = def.x
	self.y = def.y
	self.previousX = def.x
	self.previousY = def.y
	self.width = def.width
	self.height = def.height
	self.scale = def.scale
	self.speed = def.speed
	self.direction = def.direction
	self.spriteSheet = def.spriteSheet

	self.ai = def.ai
	if self.ai then
		self.ai.moveDirX = self.ai.moveDirX or 0
		self.ai.moveDirY = self.ai.moveDirY or 0
		self.ai.wanderBufferDuration = self.ai.wanderBufferDuration or 0.2
	end

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
	self.collider.owner = self

	self.animations = {}
	self:createAnimations()
	self:syncDirectionalAnimation()

	self:createStateMachine()
	self:changeState("idle")

	return self
end

return Soul
