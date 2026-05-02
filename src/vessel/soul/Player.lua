---@class PlayerAnimations : table<string, any>
---@field down any
---@field downLeft any
---@field left any
---@field upLeft any
---@field up any
---@field upRight any
---@field right any
---@field downRight any
---@field current any

local Soul = require("src.vessel.soul.Soul")

---@class Player : Soul
---@field dirX number  -1, 0, or 1
---@field dirY number  -1, 0, or 1
---@field direction? "up"|"down"|"left"|"right"|"upLeft"|"upRight"|"downLeft"|"downRight" Persisted facing used for idle animation and interaction queries
---@field animations PlayerAnimations
---@field releaseCoastMultiplier number
---@field health number
---@field damagedTimer number
---@field damagedFlashTimer number
---@field damagedFlashVisible boolean
---@field stunTimer number
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

local ANIMATION_SPEED = 0.1
local INTERACT_RADIUS = 8
local INTERACT_OFFSET = 6
local INTERACT_FACING_OFFSETS = {
	up = { x = 0, y = -1 },
	down = { x = 0, y = 1 },
	left = { x = -1, y = 0 },
	right = { x = 1, y = 0 },
}
local INVINCIBLE_DURATION = 2.0
local FLASH_INTERVAL = 0.05
local STUN_DURATION = 0.1
local KNOCKBACK_SPEED = 200
local PLAYER_LINEAR_DAMPING = 7
local PLAYER_RELEASE_COAST_MULTIPLIER = 0.4
local DAMAGE_QUERY_RADIUS = 5

-- TODO: Fix bug where can't enter idle state on diagonal animation

---Build the 8-directional animation set from the player sprite sheet.
---Overrides Soul:createAnimations() to add diagonal directions.
---@return nil
function Player:createAnimations()
	self.grid = Anim8.newGrid(self.width, self.height, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.animations.down = Anim8.newAnimation(self.grid("1-4", 1), ANIMATION_SPEED)
	self.animations.downLeft = Anim8.newAnimation(self.grid("1-4", 2), ANIMATION_SPEED)
	self.animations.left = Anim8.newAnimation(self.grid("1-4", 3), ANIMATION_SPEED)
	self.animations.upLeft = Anim8.newAnimation(self.grid("1-4", 4), ANIMATION_SPEED)
	self.animations.up = Anim8.newAnimation(self.grid("1-4", 5), ANIMATION_SPEED)
	self.animations.upRight = Anim8.newAnimation(self.grid("1-4", 6), ANIMATION_SPEED)
	self.animations.right = Anim8.newAnimation(self.grid("1-4", 7), ANIMATION_SPEED)
	self.animations.downRight = Anim8.newAnimation(self.grid("1-4", 8), ANIMATION_SPEED)
	self.animations.current = self.animations.down
end

---Build the state machine.
---Overrides Soul:createStateMachine() to wire player-specific states.
---@return nil
function Player:createStateMachine()
	self.stateMachine = StateMachine.new({
		[PlayerIdleState.STATE_NAME] = function()
			return PlayerIdleState.new(self)
		end,
		[PlayerWalkState.STATE_NAME] = function()
			return PlayerWalkState.new(self)
		end,
		[PlayerHurtState.STATE_NAME] = function()
			return PlayerHurtState.new(self)
		end,
	})
end

---Switch the active animation to match the player's current move vector.
---Falls back to persisted facing when the player is idle.
---@return nil
function Player:syncDirectionalAnimation()
	local dirX = self.dirX or 0
	local dirY = self.dirY or 0

	if dirX ~= 0 and dirY ~= 0 then
		if dirY < 0 then
			self.animations.current = dirX < 0 and self.animations.upLeft or self.animations.upRight
		else
			self.animations.current = dirX < 0 and self.animations.downLeft or self.animations.downRight
		end
		return
	end

	if dirY ~= 0 then
		self.animations.current = dirY < 0 and self.animations.up or self.animations.down
		return
	end

	if dirX ~= 0 then
		self.animations.current = dirX < 0 and self.animations.left or self.animations.right
		return
	end

	Soul.syncDirectionalAnimation(self)
end

---Apply current directional input to movement fields and persisted facing.
---@return boolean True when directional input is active.
function Player:applyInputDirection()
	local dirX, dirY, isMoving = Input.getDirection()
	if not isMoving then
		return false
	end

	self.dirX = dirX
	self.dirY = dirY
	self:setFacingFromVector(dirX, dirY)
	return true
end

---Query nearby interactables in front of the player's persisted facing direction.
---@return nil
function Player:interact()
	local world = self.collider.body:getWorld()
	local px, py = self.collider:getPosition()

	-- offset the query circle in the direction the player faces
	local facing = INTERACT_FACING_OFFSETS[self.direction or "down"] or INTERACT_FACING_OFFSETS.down
	local offX = facing.x * INTERACT_OFFSET
	local offY = facing.y * INTERACT_OFFSET

	local x = px + offX
	local y = py + offY
	local interactables = Collision.queryCircleArea(world, x, y, INTERACT_RADIUS, function(vessel)
		return vessel:hasTag("interactable")
	end)

	for _, c in ipairs(interactables) do
		if c.owner and c.owner.interact then
			c.owner:interact()
		end
	end
end

---Check whether any hostile collider is overlapping the player's hurt radius.
---Applies damage and knockback from the first hostile collider found.
---@return nil
function Player:checkDamage()
	-- TODO: investigate if timers can be better managed (i.e. in src/engine, use knife or hump timer as inspo)
	if self.damagedTimer > 0 then
		return
	end

	local world = self.collider.body:getWorld()
	local px, py = self:getPosition()
	local enemies = Collision.queryCircleArea(world, px, py, DAMAGE_QUERY_RADIUS, function(c)
		return c:hasTag("hostile")
	end, 1)

	if #enemies > 0 then
		local ex, ey = enemies[1]:getPosition()
		self:hurt(1, ex, ey)
	end
end

---Apply damage, knock the player away from the source, and enter the hurt state.
---@param damage number
---@param srcX number
---@param srcY number
---@return nil
function Player:hurt(damage, srcX, srcY)
	if self.damagedTimer > 0 then
		return
	end

	local px, py = self:getPosition()
	local dx, dy = px - srcX, py - srcY
	local len = math.sqrt(dx * dx + dy * dy)
	if len > 0 then
		dx, dy = dx / len, dy / len
	else
		dx, dy = 0, -1
	end
	self.vessel:setLinearVelocity(dx * KNOCKBACK_SPEED, dy * KNOCKBACK_SPEED)
	self.stunTimer = STUN_DURATION
	self.damagedTimer = INVINCIBLE_DURATION
	self.health = self.health - damage
	self:changeState(PlayerHurtState.STATE_NAME)
end

---Advance the player's invincibility flash and stun timers.
---@param dt number Delta time in seconds
---@return nil
function Player:updateDamageTimers(dt)
	if self.damagedTimer > 0 then
		self.damagedTimer = self.damagedTimer - dt
		self.damagedFlashTimer = self.damagedFlashTimer - dt
		if self.damagedFlashTimer <= 0 then
			self.damagedFlashTimer = FLASH_INTERVAL
			self.damagedFlashVisible = not self.damagedFlashVisible
		end
		if self.damagedTimer <= 0 then
			self.damagedTimer = 0
			self.damagedFlashVisible = true
		end
	end

	if self.stunTimer > 0 then
		self.stunTimer = self.stunTimer - dt
		if self.stunTimer <= 0 then
			self.stunTimer = 0
		end
	end
end

---Draw the player, flashing while invincible after taking damage.
---@return nil
function Player:draw()
	if self.damagedTimer > 0 then
		local alpha = self.damagedFlashVisible and 0.8 or 0.5
		Util.safeDraw(function()
			love.graphics.setColor(1, 1, 1, alpha)
			Soul.draw(self)
		end)
	else
		Soul.draw(self)
	end
end

---Create a new Player.
---@param def {x: number, y: number, width: number, height: number, scale: number, speed: number, spriteSheet: love.Image, physics: physics, dirX?: number, dirY?: number, group?: number}
---@return Player
function Player.new(def)
	local self = Soul.new(def, Player)

	self.collider:setLinearDamping(PLAYER_LINEAR_DAMPING)
	self.collider.owner = self
	self.releaseCoastMultiplier = PLAYER_RELEASE_COAST_MULTIPLIER

	self.health = 4
	self.damagedTimer = 0
	self.damagedFlashTimer = 0
	self.damagedFlashVisible = true
	self.stunTimer = 0

	self.dirX = def.dirX or 0
	self.dirY = def.dirY or 1
	self:setFacingFromVector(self.dirX, self.dirY)
	self:syncDirectionalAnimation()

	return self
end

return Player
