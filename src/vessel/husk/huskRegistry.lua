---@alias HuskMapObject {name: string, x: number, y: number}

---@class HuskSpawnContext
---@field physics physics Physics instance used to create Husk colliders.

---@class HuskArchetype
---@field spawn fun(ctx: HuskSpawnContext, obj: HuskMapObject): Husk

---@type table<string, HuskArchetype>
return {
    pointChest = require("src.vessel.husk.archetypes.ArchetypeLittleChest"),
}
