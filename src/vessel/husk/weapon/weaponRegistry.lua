---@class WeaponSpawnContext
---@field physics physics Physics instance used to create weapon colliders.

---@class WeaponSpawnOpts
---@field x number Spawn X position.
---@field y number Spawn Y position.
---@field dirX number Launch direction X component.
---@field dirY number Launch direction Y component.
---@field owner? any Entity that used the weapon.

---@class WeaponArchetype
---@field name string Stable registry/inventory name for this weapon.
---@field spawnOffset number Distance from owner center to spawn fired projectiles.
---@field spawn fun(ctx: WeaponSpawnContext, opts: WeaponSpawnOpts): Projectile

---@class WeaponRegistryCategory : table<string, WeaponArchetype>

---@class WeaponRegistry
---@field ranged WeaponRegistryCategory

local ArchetypeShuriken = require("src.vessel.husk.weapon.ArchetypeShuriken")

---@type WeaponRegistry
return {
    ranged = {
        [ArchetypeShuriken.name] = ArchetypeShuriken,
    },
}
