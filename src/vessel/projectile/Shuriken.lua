local Vessel = require("src.vessel.Vessel")
local Damage = require("src.vessel.damage")

---@class Shuriken
---@field vessel Vessel Physics-backed vessel wrapper.
---@field collider collider Primary physics collider.
---@field x number Current X position.
---@field y number Current Y position.
---@field width number Sprite width.
---@field height number Sprite height.
---@field speed number Flight speed.
---@field rotation number Current rotation angle.
---@field rotationSpeed number How fast it spins.
---@field lifetime number Remaining life in seconds.
---@field damageSource DamageSource Damage to deal on hit.
---@field spriteSheet love.Image Shuriken sprite image.
---@field destroyed boolean Whether this projectile is marked for removal.
local Shuriken = {}
Shuriken.__index = Shuriken

local SHURIKEN_SPEED = 250
local SHURIKEN_LIFETIME = 2.0
local SHURIKEN_ROTATION_SPEED = 20
local SHURIKEN_SIZE = 4
local SHURIKEN_VISUAL_SCALE = 0.5

---Update the shuriken's position, rotation, and lifetime.
---@param dt number Delta time in seconds.
---@return nil
function Shuriken:update(dt)
    if self.destroyed then return end

    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then
        self:destroy()
        return
    end

    -- Update rotation for visual effect
    self.rotation = self.rotation + SHURIKEN_ROTATION_SPEED * dt

    -- Sync visual position from physics body
    self.x, self.y = self.vessel:getPosition()

    -- Check for collisions with hostiles, souls, husks, or environment (walls)
    local world = self.collider.body:getWorld()
    
    -- ADJUSTED: Slightly increased from 2 to 3 to ensure contact with static bodies
    local queryRadius = 3 
    local queryX, queryY = self.x, self.y
    
    local hits = Collision.queryCircleArea(world, queryX, queryY, queryRadius, function(v)
        -- Identify targets by tags
        local isTargetTag = v:hasTag("hostile") or v:hasTag("soul") or v:hasTag("husk")
        -- Also identify environment (static bodies like walls/trees)
        local isEnvironment = v.body:getType() == "static"
        
        return (isTargetTag or isEnvironment) and v.owner ~= self.owner
    end)

    if #hits > 0 then
        local hitCollider = hits[1]
        local target = hitCollider.owner
        
        -- 1. If it has an owner (entity/husk), handle damage and special destruction
        if target then
            -- Apply damage/knockback
            if target.hurt then
                target:hurt({
                    x = self.x,
                    y = self.y,
                    damage = self.damageSource.amount,
                    knockbackSpeed = self.damageSource.knockbackSpeed,
                    type = self.damageSource.type
                })
            end

            -- Destroy hostile entities immediately
            if hitCollider:hasTag("hostile") and target.destroy then
                target:destroy()
                if Realm.current and Realm.current.souls then
                    for i, soul in ipairs(Realm.current.souls) do
                        if soul == target then
                            table.remove(Realm.current.souls, i)
                            break
                        end
                    end
                end
            end
        end

        -- 2. Destroy shuriken on any hit
        self:destroy()
    end
end

---Draw the shuriken with rotation and scale.
---@return nil
function Shuriken:draw()
    if self.destroyed then return end

    local sw = self.spriteSheet:getWidth()
    local sh = self.spriteSheet:getHeight()

    love.graphics.draw(
        self.spriteSheet,
        self.x,
        self.y,
        self.rotation,
        SHURIKEN_VISUAL_SCALE,
        SHURIKEN_VISUAL_SCALE,
        sw / 2,
        sh / 2
    )
end

---Destroy the shuriken.
---@return nil
function Shuriken:destroy()
    if self.destroyed then return end
    self.destroyed = true
    if self.vessel then
        self.vessel:destroy()
    end
end

---Create a new Shuriken.
---@param opts {x: number, y: number, dirX: number, dirY: number, physics: physics, owner: any}
---@return Shuriken
function Shuriken.new(opts)
    local self = setmetatable({}, Shuriken)

    self.x = opts.x
    self.y = opts.y
    self.width = SHURIKEN_SIZE
    self.height = SHURIKEN_SIZE
    self.speed = SHURIKEN_SPEED
    self.rotation = 0
    self.lifetime = SHURIKEN_LIFETIME
    self.destroyed = false
    self.owner = opts.owner
    
    self.spriteSheet = GArt["shuriken"] or love.graphics.newImage("art/Shuriken.png")

    self.damageSource = Damage.normalizeSource({
        type = Damage.TYPES.PLAYER_ATTACK,
        amount = 1,
        knockbackSpeed = 150
    })

    self.vessel = Vessel.new({
        x = opts.x,
        y = opts.y,
        width = self.width,
        height = self.height,
        physics = opts.physics,
        bodyType = "dynamic",
        tags = { "projectile", "playerAttack" },
        shape = "rectangle"
    })
    self.collider = self.vessel.collider
    self.collider.owner = self
    
    self.collider:setLinearDamping(0.5)

    -- Launch it!
    local vx = opts.dirX * self.speed
    local vy = opts.dirY * self.speed
    self.vessel:setLinearVelocity(vx, vy)

    return self
end

return Shuriken
