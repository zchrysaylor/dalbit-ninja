---@class SoulAIConfig
---@field homeX number
---@field homeY number
---@field type string
---@field wanderRadius number
---@field idleDurationMin number
---@field idleDurationMax number
---@field walkDurationMin number
---@field walkDurationMax number
---@field directionPool string[]
---@field moveDirX number
---@field moveDirY number
---@field lastX? number
---@field lastY? number

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

---Pick a random duration from AI config bounds.
---@param minKey "idleDurationMin"|"walkDurationMin"
---@param maxKey "idleDurationMax"|"walkDurationMax"
---@return number
function Soul:getAIRandomDuration(minKey, maxKey)
	assert(self:isAI(), "getAIRandomDuration called for non-AI soul")

	local minDuration = self.ai[minKey]
	local maxDuration = self.ai[maxKey] or minDuration
	if maxDuration < minDuration then
		minDuration, maxDuration = maxDuration, minDuration
	end

	return love.math.random() * (maxDuration - minDuration) + minDuration
end

---Pick a random idle duration from AI config bounds.
---@return number
function Soul:getRandomIdleDuration()
	return self:getAIRandomDuration("idleDurationMin", "idleDurationMax")
end

---Pick a random walk duration from AI config bounds.
---@return number
function Soul:getRandomWalkDuration()
	return self:getAIRandomDuration("walkDurationMin", "walkDurationMax")
end

---Switch the active animation to match the Soul's current facing direction.
---@param fallbackDirection? string
---@return string
function Soul:syncDirectionalAnimation(fallbackDirection)
	local direction = self.direction or fallbackDirection or "down"
	if self.animations[direction] ~= nil then
		self.direction = direction
		self.animations.current = self.animations[direction]
		return direction
	end

	self.direction = fallbackDirection or "down"
	self.animations.current = self.animations[self.direction] or self.animations.down
	return self.direction
end

---Set AI movement direction and keep facing/animation in sync.
---@param direction string
function Soul:setAIMoveDirection(direction)
	assert(self:isAI(), "setAIMoveDirection called for non-AI soul")

	self.direction = direction
	if direction == "up" then
		self.ai.moveDirX = 0
		self.ai.moveDirY = -1
	elseif direction == "down" then
		self.ai.moveDirX = 0
		self.ai.moveDirY = 1
	elseif direction == "left" then
		self.ai.moveDirX = -1
		self.ai.moveDirY = 0
	elseif direction == "right" then
		self.ai.moveDirX = 1
		self.ai.moveDirY = 0
	else
		self.ai.moveDirX = 0
		self.ai.moveDirY = 0
	end

	self:syncDirectionalAnimation()
end

---Return the squared distance from the Soul to its AI home point.
---@return number
function Soul:getDistanceToAIHomeSq()
	assert(self:isAI(), "getDistanceToAIHomeSq called for non-AI soul")

	local x, y = self.vessel:getPosition()
	local dx = x - self.ai.homeX
	local dy = y - self.ai.homeY
	return dx * dx + dy * dy
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

---Return whether the Soul is near the edge of its wander radius.
---@return boolean
function Soul:isNearAIWanderEdge()
	assert(self:isAI(), "isNearAIWanderEdge called for non-AI soul")

	local threshold = self.ai.wanderRadius * 0.8
	return self:getDistanceToAIHomeSq() >= threshold * threshold
end

---Return whether moving one full walk burst in the given direction would remain within the wander radius.
---@param direction string
---@return boolean
function Soul:isAIWalkDirectionAllowed(direction)
	assert(self:isAI(), "isAIWalkDirectionAllowed called for non-AI soul")

	local x, y = self.vessel:getPosition()
	local maxWalkDuration = self.ai.walkDurationMax or self.ai.walkDurationMin
	local stepDistance = self.speed * 100 * maxWalkDuration
	local dirX, dirY = 0, 0

	if direction == "up" then
		dirY = -1
	elseif direction == "down" then
		dirY = 1
	elseif direction == "left" then
		dirX = -1
	elseif direction == "right" then
		dirX = 1
	else
		return false
	end

	return not self:isOutsideAIWanderRadius(x + dirX * stepDistance, y + dirY * stepDistance)
end

---Choose an AI movement direction that keeps the Soul inside its wander radius.
---@return string
function Soul:chooseAIDirection()
	assert(self:isAI(), "chooseAIDirection called for non-AI soul")

	local allowedDirections = {}
	for _, direction in ipairs(self.ai.directionPool) do
		if self:isAIWalkDirectionAllowed(direction) then
			table.insert(allowedDirections, direction)
		end
	end

	if #allowedDirections > 0 then
		return allowedDirections[love.math.random(#allowedDirections)]
	end

	return self.ai.directionPool[love.math.random(#self.ai.directionPool)]
end

---Record the soul's current position for post-physics movement checks.
function Soul:capturePreviousPosition()
	self.previousX = self.x
	self.previousY = self.y
end

---Validate AI walking after physics has stepped and positions are synced.
---@param dt number Delta time in seconds
function Soul:postPhysicsUpdate(dt)
	if not self:isAI() then
		return
	end

	local currentState = self.stateMachine.current
	if currentState == nil or currentState.stateName ~= "walk" then
		return
	end

	currentState:postPhysicsUpdate(dt)
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
