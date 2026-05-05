---@alias SoulMapObject {name: string, x: number, y: number}

---@class SoulSpawnContext
---@field physics physics Physics instance used to create Soul colliders.
---@field player Player Player target available to hostile Soul archetypes.

---@class SoulArchetype
---@field spawn fun(ctx: SoulSpawnContext, obj: SoulMapObject): Soul

---@type table<string, SoulArchetype>
return {
	pointCamoRed = require("src.vessel.soul.archetypes.ArchetypeCamoRed"),
}
