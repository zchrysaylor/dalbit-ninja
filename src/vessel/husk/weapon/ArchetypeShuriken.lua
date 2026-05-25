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
-- TODO: sprite doesn't appear when player is against a wall, offset too large
local ArchetypeShuriken = {}

ArchetypeShuriken.name = "shuriken"
ArchetypeShuriken.spawnOffset = 12

---Create a shuriken projectile from generic Projectile behavior.
---@param ctx ShurikenSpawnContext
---@param opts ShurikenSpawnOpts
---@return Projectile
function ArchetypeShuriken.spawn(ctx, opts)
    return Projectile.new({
        name = ArchetypeShuriken.name,
        x = opts.x,
        y = opts.y,
        width = 4,
        height = 4,
        spriteSheet = GArt["shuriken"],
        physics = ctx.physics,
        owner = opts.owner,
        dirX = opts.dirX,
        dirY = opts.dirY,
        speed = 250,
        lifetime = 2.0,
        rotationSpeed = 20,
        scale = 0.5,
        hitRadius = 3,
        linearDamping = 0.5,
        tags = { "projectile", "playerAttack" },
        damageSource = {
            type = Damage.TYPES.PLAYER_ATTACK,
            amount = 1,
            knockbackSpeed = 150,
        },
    })
end

return ArchetypeShuriken
