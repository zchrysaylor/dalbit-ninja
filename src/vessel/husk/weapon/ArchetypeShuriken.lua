---@class ShurikenSpawnContext
---@field physics physics Physics instance used to create the projectile collider.

---@class ShurikenSpawnOpts
---@field x number Spawn X position.
---@field y number Spawn Y position.
---@field dirX number Launch direction X component.
---@field dirY number Launch direction Y component.
---@field owner? any Entity that fired the shuriken.

-- TODO: add animation so that if lifetime over or collides with wall, looks halfway stuck
-- in wall or ground
local ArchetypeShuriken = {}

ArchetypeShuriken.name = "shuriken"
ArchetypeShuriken.spawnOffset = 12

local SHURIKEN_SPEED = 250
local SHURIKEN_LIFETIME = 2.0
local SHURIKEN_ROTATION_SPEED = 20
local SHURIKEN_SIZE = 4
local SHURIKEN_VISUAL_SCALE = 0.5
local SHURIKEN_HIT_RADIUS = 3
local SHURIKEN_LINEAR_DAMPING = 0.5

---Create a shuriken projectile from generic Projectile behavior.
---@param ctx ShurikenSpawnContext
---@param opts ShurikenSpawnOpts
---@return Projectile
function ArchetypeShuriken.spawn(ctx, opts)
    return Projectile.new({
        name = ArchetypeShuriken.name,
        x = opts.x,
        y = opts.y,
        width = SHURIKEN_SIZE,
        height = SHURIKEN_SIZE,
        spriteSheet = GArt["shuriken"],
        physics = ctx.physics,
        owner = opts.owner,
        dirX = opts.dirX,
        dirY = opts.dirY,
        speed = SHURIKEN_SPEED,
        lifetime = SHURIKEN_LIFETIME,
        rotationSpeed = SHURIKEN_ROTATION_SPEED,
        visualScale = SHURIKEN_VISUAL_SCALE,
        hitRadius = SHURIKEN_HIT_RADIUS,
        linearDamping = SHURIKEN_LINEAR_DAMPING,
        tags = { "projectile", "playerAttack" },
        damageSource = {
            type = Damage.TYPES.PLAYER_ATTACK,
            amount = 1,
            knockbackSpeed = 150,
        },
    })
end

return ArchetypeShuriken
