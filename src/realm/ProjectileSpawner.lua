---@class ProjectileSpawnDef
---@field weaponName string Ranged weapon registry name to spawn.
---@field x number Origin X position.
---@field y number Origin Y position.
---@field dirX number Launch direction X component. Normalized centrally before spawning.
---@field dirY number Launch direction Y component. Normalized centrally before spawning.
---@field offset? number Distance from origin to spawn the projectile along its launch direction.
---@field owner? any Entity that fired the projectile.

---@class ProjectileSpawner
local ProjectileSpawner = {}

---Return a normalized direction vector, or nil when the vector has no direction.
---@param dirX number Direction X component.
---@param dirY number Direction Y component.
---@return number? normalizedDirX
---@return number? normalizedDirY
local function normalizeDirection(dirX, dirY)
    local magnitude = math.sqrt(dirX * dirX + dirY * dirY)
    if magnitude == 0 then
        return nil, nil
    end

    return dirX / magnitude, dirY / magnitude
end

---Spawn a projectile for a ranged weapon definition.
---@param physics physics Physics instance used to create projectile colliders.
---@param projectileDef ProjectileSpawnDef
---@return Projectile?
function ProjectileSpawner.spawn(physics, projectileDef)
    local weapon = WeaponRegistry.ranged[projectileDef.weaponName]
    if not weapon then
        return nil
    end

    local dirX, dirY = normalizeDirection(projectileDef.dirX, projectileDef.dirY)
    if not dirX or not dirY then
        return nil
    end

    local offset = projectileDef.offset or 0

    return weapon.spawn({ physics = physics }, {
        x = projectileDef.x + dirX * offset,
        y = projectileDef.y + dirY * offset,
        dirX = dirX,
        dirY = dirY,
        owner = projectileDef.owner,
    })
end

---@param projectiles Projectile[]
---@return nil
function ProjectileSpawner.destroyAll(projectiles)
    for _, projectile in pairs(projectiles) do
        projectile:destroy()
    end
end

return ProjectileSpawner
