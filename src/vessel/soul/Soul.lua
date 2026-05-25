---@class HurtBoxConfig
---@field radius? number Hurt radius in pixels.
---@field offsetX? number Horizontal offset from owner.
---@field offsetY? number Vertical offset from owner.
---@field damageTags? string[] Accepted damage types.

---@class SoulAIConfig
---@field homeX number Home X position.
---@field homeY number Home Y position.
---@field type string AI behavior type.
---@field wanderRadius number Maximum wander distance.
---@field idleDurationMin number Minimum idle seconds.
---@field idleDurationMax? number Maximum idle seconds.
---@field wanderBufferDuration? number Pause before wandering.
---@field moveDirX? number Current X move direction.
---@field moveDirY? number Current Y move direction.
---@field detectionRadius? number Chase detection range.
---@field chaseTarget? Soul Soul to chase.
---@field chaseForce? number Chase movement force.

---@class SoulDef
---@field x number Spawn X position.
---@field y number Spawn Y position.
---@field width number Sprite and body width.
---@field height number Sprite and body height.
---@field speed number Movement speed in pixels/sec.
---@field spriteSheet love.Image Sprite sheet image.
---@field physics physics Physics world wrapper.
---@field direction? string Initial facing direction.
---@field group? number Collision filter group.
---@field ai? SoulAIConfig Optional AI behavior.
---@field linearDamping? number Body drag amount.
---@field hurtbox? HurtBoxConfig Optional damage receiver.
---@field damageSource? DamageSourceConfig Damage dealt by this Soul when overlapping a matching hurtbox.
---@field health? number Initial health points.
---@field tags? string[] Collider tag names.

---@class Soul
---@field vessel Vessel Physics-backed vessel wrapper.
---@field collider collider Primary physics collider.
---@field x number Current X position.
---@field y number Current Y position.
---@field width number Sprite and body width.
---@field height number Sprite and body height.
---@field spriteSheet love.Image Sprite sheet image.
---@field speed number Movement speed in pixels/sec.
---@field animations table Directional animation set.
---@field stateMachine StateMachine Entity behavior machine.
---@field grid any Animation frame grid.
---@field direction? string Current facing direction.
---@field ai? SoulAIConfig Optional AI behavior.
---@field linearDamping? number Body drag amount.
---@field hurtbox? HurtBox Optional damage receiver.
---@field damageSource? DamageSource Damage dealt by this Soul when overlapping a matching hurtbox.
---@field health number Current health points.
---@field previousX number Previous frame X position.
---@field previousY number Previous frame Y position.
---@field isAnimating boolean Whether animation is playing.
---@field pendingRemoval boolean Whether this Soul is hidden and waiting for cleanup.
---@field destroyed boolean Whether this Soul's physics body has been destroyed.
---@field interact? fun(self: Soul) Optional interaction handler.
local Soul = {}
Soul.__index = Soul

local AI_BLOCKED_MOVEMENT_FACTOR = 0.2
local AI_BLOCKED_MIN_EXPECTED_DISTANCE = 0.01
local AI_BLOCKED_FRAME_THRESHOLD = 3

---Build animation grid and directional animations from the sprite sheet.
---@return nil
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
---@return nil
function Soul:createStateMachine()
    self.stateMachine = StateMachine.new({
        [SoulIdleState.STATE_NAME] = function()
            return SoulIdleState.new(self)
        end,
        [SoulWanderState.STATE_NAME] = function()
            return SoulWanderState.new(self)
        end,
        [SoulChaseState.STATE_NAME] = function()
            return SoulChaseState.new(self)
        end,
        [SoulReturnState.STATE_NAME] = function()
            return SoulReturnState.new(self)
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

---Return whether this Soul is no longer participating in gameplay.
---@return boolean
function Soul:isRemoved()
    return self.pendingRemoval or self.destroyed
end

---Return the Soul's current world position.
---@return number, number
function Soul:getPosition()
    return self.vessel:getPosition()
end

---Return whether the given point would be outside the Soul's wander radius.
---@param x number
---@param y number
---@return boolean
function Soul:isOutsideAIWanderRadius(x, y)
    assert(self:isAI(), "isOutsideAIWanderRadius called for non-AI soul")

    return Util.distanceSquared(x, y, self.ai.homeX, self.ai.homeY) > self.ai.wanderRadius * self.ai.wanderRadius
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

---Update this Soul's persisted facing direction from a movement vector.
---@param dirX number
---@param dirY number
---@return nil
function Soul:setFacingFromVector(dirX, dirY)
    if dirX == 0 and dirY == 0 then
        return
    end

    if math.abs(dirX) > math.abs(dirY) then
        if dirX < 0 then
            self.direction = "left"
        else
            self.direction = "right"
        end
    else
        if dirY < 0 then
            self.direction = "up"
        else
            self.direction = "down"
        end
    end
end

---Set AI movement vector and keep facing/animation in sync.
---@param dirX number
---@param dirY number
---@return nil
function Soul:setAIMoveVector(dirX, dirY)
    assert(self:isAI(), "setAIMoveVector called for non-AI soul")

    local length = math.sqrt(dirX * dirX + dirY * dirY)
    if length == 0 then
        self.ai.moveDirX = 0
        self.ai.moveDirY = 0
        self:refreshAnimation()
        return
    end

    self.ai.moveDirX = dirX / length
    self.ai.moveDirY = dirY / length
    self:setFacingFromVector(self.ai.moveDirX, self.ai.moveDirY)

    self:refreshAnimation()
end

---Choose a new AI movement vector biased back toward the soul's home.
---@return nil
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

---Set the active chase target for this AI soul.
---@param target? Soul
---@return nil
function Soul:setAIChaseTarget(target)
    assert(self:isAI(), "setAIChaseTarget called for non-AI soul")
    self.ai.chaseTarget = target
end

---Return whether this Soul can currently detect its chase target.
---@return boolean
function Soul:canDetectAIChaseTarget()
    assert(self:isAI(), "canDetectAIChaseTarget called for non-AI soul")

    local target = self.ai.chaseTarget
    if not target then
        return false
    end

    local soulX, soulY = self:getPosition()
    local targetX, targetY = target:getPosition()
    local detectionRadius = self.ai.detectionRadius or self.ai.wanderRadius

    return Util.distanceSquared(targetX, targetY, soulX, soulY) <= detectionRadius * detectionRadius
end

---Point this Soul toward its chase target and refresh its move vector.
---@return boolean
function Soul:updateAIChaseVector()
    assert(self:isAI(), "updateAIChaseVector called for non-AI soul")

    local target = self.ai.chaseTarget
    if not target then
        self:setAIMoveVector(0, 0)
        return false
    end

    local soulX, soulY = self:getPosition()
    local targetX, targetY = target:getPosition()
    local dirX = targetX - soulX
    local dirY = targetY - soulY

    if dirX == 0 and dirY == 0 then
        self:setAIMoveVector(0, 0)
        return false
    end

    self:setAIMoveVector(dirX, dirY)
    return true
end

---Enter chase state if this AI soul is a chase type and can detect its target.
---@return boolean True when the state changed.
function Soul:tryChangeToAIChaseState()
    if self:isAIType("chase") and self:canDetectAIChaseTarget() then
        self:changeState(SoulChaseState.STATE_NAME)
        return true
    end

    return false
end

---Update blocked-frame count from post-physics movement and report when blocked.
---@param dt number Delta time in seconds
---@param blockedFrames number Current consecutive blocked-frame count
---@return number blockedFrames Updated consecutive blocked-frame count
---@return boolean isBlocked True when blocked long enough to trigger recovery behavior
function Soul:updateAIBlockedFrames(dt, blockedFrames)
    local movedX = self.x - self.previousX
    local movedY = self.y - self.previousY
    local movedDistanceSq = movedX * movedX + movedY * movedY
    local expectedDistance = math.max(self.speed * dt * AI_BLOCKED_MOVEMENT_FACTOR, AI_BLOCKED_MIN_EXPECTED_DISTANCE)
    local expectedDistanceSq = expectedDistance * expectedDistance

    if movedDistanceSq < expectedDistanceSq then
        blockedFrames = blockedFrames + 1
    else
        blockedFrames = 0
    end

    return blockedFrames, blockedFrames >= AI_BLOCKED_FRAME_THRESHOLD
end

---Validate AI walking after physics has stepped and positions are synced.
---@param dt number Delta time in seconds
---@return nil
function Soul:postPhysicsUpdate(dt)
    if self:isRemoved() then
        return
    end

    self.stateMachine:postPhysicsUpdate(dt)
end

---Transition this Soul to a new state.
---@param state string State key (e.g. "idle", "wander")
---@param opts? table Optional options.
---@return nil
function Soul:changeState(state, opts)
    self.stateMachine:changeState(state, opts)
end

---Sync self.x/self.y from the vessel's physics body position.
---Must be called each frame after the physics world steps.
---@return nil
function Soul:syncPosition()
    if self:isRemoved() then
        return
    end

    self.x, self.y = self.vessel:getPosition()
end

---Record the soul's current position for post-physics movement checks.
---@return nil
function Soul:capturePreviousPosition()
    if self:isRemoved() then
        return
    end

    self.previousX = self.x
    self.previousY = self.y
end

---Set whether this Soul's active animation should play or stay paused.
---@param isAnimating boolean
---@return nil
function Soul:setIsAnimating(isAnimating)
    self.isAnimating = isAnimating
end

---Switch the active animation to match the Soul's current facing direction.
---@return nil
function Soul:syncDirectionalAnimation()
    self.direction = self.direction or "down"
    self.animations.current = self.animations[self.direction]
end

---Refresh the current directional animation and apply the active play/pause state.
---@return nil
function Soul:refreshAnimation()
    self:syncDirectionalAnimation()

    if self.isAnimating then
        self.animations.current:resume()
    else
        self.animations.current:pauseAtStart()
    end
end

---Return whether this Soul is currently able to receive damage.
---@return boolean
function Soul:canTakeDamage()
    return not self:isRemoved()
end

---Check whether any damage hit is overlapping this Soul's hurtbox.
---Delegates damage response to `hurt`, which subclasses can override.
---@return nil
function Soul:checkDamage()
    if not self.hurtbox then
        return
    end

    if not self:canTakeDamage() then
        return
    end

    local hits = self.hurtbox:query()
    if #hits == 0 then
        return
    end

    self:hurt(hits[1])
end

---Apply damage and knock this Soul away from the hit source.
---@param hit DamageHit
---@return nil
function Soul:hurt(hit)
    local srcX, srcY = hit.x, hit.y
    local damage = hit.damage
    local knockbackSpeed = hit.knockbackSpeed

    local px, py = self:getPosition()
    local dx, dy = px - srcX, py - srcY
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx, dy = dx / len, dy / len
    else
        dx, dy = 0, -1
    end
    self.vessel:setLinearVelocity(dx * knockbackSpeed, dy * knockbackSpeed)

    self.health = self.health - damage
    if self:isDead() then
        self:markForRemoval()
    end
end

---Return whether this Soul has no health remaining.
---@return boolean
function Soul:isDead()
    return self.health <= 0
end

---Hide this Soul from gameplay and mark it for deferred destruction.
---@return nil
function Soul:markForRemoval()
    if self.pendingRemoval then
        return
    end

    self.pendingRemoval = true

    self.vessel:setLinearVelocity(0, 0)
    self.collider:removeAllTags()
    self.collider.body:setActive(false)
end

---Destroy the underlying Vessel (and its physics body).
---@return nil
function Soul:destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    self.vessel:destroy()
end

---Advance the active animation and delegated entity state.
---@param dt number Delta time in seconds
---@return nil
function Soul:update(dt)
    if self:isRemoved() then
        return
    end

    self.animations.current:update(dt)
    self.stateMachine:update(dt)
end

---Draw the current animation frame centered at (x, y).
---@return nil
function Soul:draw()
    if self:isRemoved() then
        return
    end

    self.animations.current:draw(
        self.spriteSheet,
        self.x,
        self.y, -- body center position
        nil, -- rotation
        nil, -- scaleX
        nil, -- scaleY (defaults to scaleX)
        self.width / 2, -- originX: centered (half of sprite width)
        self.height / 2 -- originY: centered (half of sprite height)
    )
end

---Create a new Soul.
---@generic T : Soul
---@param def SoulDef
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
    self.speed = def.speed
    self.direction = def.direction
    self.spriteSheet = def.spriteSheet
    self.damageSource = Damage.normalizeSource(def.damageSource)
    self.health = def.health or 1

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
        speed = def.speed,
        physics = def.physics,
        group = def.group,
        tags = def.tags or { "soul" }, -- TODO: assert that soul is required when passing custom tag or always append soul to def
    }
    self.vessel = Vessel.new(vesselOpts)
    self.collider = self.vessel.collider
    self.collider.owner = self
    self.linearDamping = def.linearDamping
    if self.linearDamping then
        self.collider:setLinearDamping(self.linearDamping)
    end

    if def.hurtbox then
        self.hurtbox = HurtBox.new(self, def.hurtbox)
    end

    self.destroyed = false
    self.pendingRemoval = false

    self.animations = {}
    self.isAnimating = false
    self:createAnimations()
    self:syncDirectionalAnimation()

    self:createStateMachine()
    self:changeState(SoulIdleState.STATE_NAME)

    return self
end

return Soul
