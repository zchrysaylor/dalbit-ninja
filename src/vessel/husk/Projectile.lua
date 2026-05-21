local Husk = require("src.vessel.husk.Husk")

---@class ProjectileDef : HuskDef
---@field name string Stable registry/inventory name for this projectile.
---@field owner? any Entity that fired the projectile; ignored by hit queries.
---@field dirX number Launch direction X component.
---@field dirY number Launch direction Y component.
---@field speed number Launch speed in pixels per second.
---@field lifetime? number Lifetime in seconds before self-destruction.
---@field rotation? number Initial draw rotation in radians.
---@field rotationSpeed? number Draw rotation speed in radians per second.
---@field visualScale? number Draw scale for static sprite mode.
---@field hitRadius? number Radius used for hit detection around the projectile center.
---@field hitStaticBodies? boolean Whether static bodies such as walls stop the projectile.
---@field destroyOnHit? boolean Whether this projectile destroys itself after a hit.
---@field linearDamping? number Body drag amount.

---@class Projectile : Husk
---@field name string Stable registry/inventory name for this projectile.
---@field owner? any Entity that fired the projectile.
---@field speed number Launch speed in pixels per second.
---@field lifetime number Lifetime in seconds before self-destruction.
---@field rotation number Current draw rotation in radians.
---@field rotationSpeed number Draw rotation speed in radians per second.
---@field visualScale number Draw scale for static sprite mode.
---@field hitRadius number Radius used for hit detection around the projectile center.
---@field hitStaticBodies boolean Whether static bodies such as walls stop the projectile.
---@field destroyOnHit boolean Whether this projectile destroys itself after a hit.
---@field pendingRemoval boolean Whether this projectile is hidden and waiting for cleanup.
---@field destroyed boolean Whether this projectile's physics body has been destroyed.
local Projectile = {}
Projectile.__index = Projectile
setmetatable(Projectile, { __index = Husk })

-- TODO: check if can refactor Projectile methods

---Return whether this Projectile is no longer participating in gameplay.
---@return boolean
function Projectile:isRemoved()
    return self.pendingRemoval or self.destroyed
end

function Projectile:isStaticHitCollider(collider)
    return self.hitStaticBodies and collider.body:getType() == "static"
end

function Projectile:isDamageHitCollider(collider)
    local target = collider.owner
    if target == self or target == self.owner or not target then
        return false
    end

    if not self.damageSource or not target.hurt or not target.hurtbox then
        return false
    end

    if target.canTakeDamage and not target:canTakeDamage() then
        return false
    end

    return target.hurtbox:acceptsDamageFrom(self)
end

---Return whether a collider is a valid projectile hit.
---@param collider collider
---@return boolean
function Projectile:isHitCollider(collider)
    if self:isRemoved() then
        return false
    end

    return self:isStaticHitCollider(collider) or self:isDamageHitCollider(collider)
end

---Apply this projectile's damage to a hit target when possible.
---@param hitCollider collider
---@return nil
function Projectile:applyDamage(hitCollider)
    local target = hitCollider.owner
    if not target or not target.hurt then
        return
    end

    target:hurt({
        source = self,
        collider = hitCollider,
        x = self.x,
        y = self.y,
        damage = self.damageSource.amount,
        knockbackSpeed = self.damageSource.knockbackSpeed,
        damageType = self.damageSource.type,
    })
end

---Handle the first valid hit in the projectile's hit radius.
---@return nil
function Projectile:checkHits()
    if self:isRemoved() then
        return
    end

    local world = self.collider.body:getWorld()
    local hits = Collision.queryCircleArea(world, self.x, self.y, self.hitRadius, function(collider)
        return self:isHitCollider(collider)
    end, 1)

    if #hits == 0 then
        return
    end

    self:applyDamage(hits[1])

    if self.destroyOnHit then
        self:markForRemoval()
    end
end

---Sync self.x/self.y from the projectile's physics body position.
---@return nil
function Projectile:syncPosition()
    if self:isRemoved() then
        return
    end

    self.x, self.y = self.vessel:getPosition()
end

---@param dt number Delta time in seconds.
---@return nil
function Projectile:update(dt)
    if self:isRemoved() then
        return
    end

    Husk.update(self, dt)

    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then
        self:markForRemoval()
        return
    end

    self.rotation = self.rotation + self.rotationSpeed * dt
    self:syncPosition()
    self:checkHits()
end

---@return nil
function Projectile:draw()
    if self:isRemoved() then
        return
    end

    if self.animations and self.animations.current then
        self.animations.current:draw(
            self.spriteSheet,
            self.x,
            self.y,
            self.rotation,
            self.visualScale,
            self.visualScale,
            self.width / 2,
            self.height / 2
        )
        return
    end

    local originX = self.spriteSheet:getWidth() / 2
    local originY = self.spriteSheet:getHeight() / 2
    love.graphics.draw(
        self.spriteSheet,
        self.x,
        self.y,
        self.rotation,
        self.visualScale,
        self.visualScale,
        originX,
        originY
    )
end

---@return nil
function Projectile:markForRemoval()
    if self:isRemoved() then
        return
    end

    self.pendingRemoval = true
    self.vessel:setLinearVelocity(0, 0)
    self.collider:removeAllTags()
    self.collider.body:setActive(false)
end

---@return nil
function Projectile:destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    Husk.destroy(self)
end

---Create a new projectile.
---@param def ProjectileDef
---@return Projectile
function Projectile.new(def)
    local projectileDef = Util.shallowCopy(def)
    projectileDef.bodyType = "dynamic"
    projectileDef.tags = projectileDef.tags or { "projectile" }

    local self = Husk.new(projectileDef, Projectile)

    self.name = def.name
    self.owner = def.owner
    self.speed = def.speed
    self.lifetime = def.lifetime or 1
    self.rotation = def.rotation or 0
    self.rotationSpeed = def.rotationSpeed or 0
    self.visualScale = def.visualScale or 1
    self.hitRadius = def.hitRadius or math.max(def.width, def.height) / 2
    self.hitStaticBodies = def.hitStaticBodies ~= false
    self.destroyOnHit = def.destroyOnHit ~= false
    self.pendingRemoval = false
    self.destroyed = false

    if def.linearDamping then
        self.collider:setLinearDamping(def.linearDamping)
    end

    self.vessel:setLinearVelocity(def.dirX * self.speed, def.dirY * self.speed)

    return self
end

return Projectile
