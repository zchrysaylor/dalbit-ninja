--- Factory module that creates Soul NPC entities from Tiled object-layer definitions.
---@class SoulSpawner
local SoulSpawner = {}

---Spawn an NPC Soul from a Tiled map object.
---Returns nil for unrecognized object names.
---@param physics physics Physics instance
---@param player Player
---@param obj SoulMapObject Tiled map object with at minimum `name`, `x`, and `y` fields
---@return Soul|nil soul The spawned Soul, or nil if the object type is unrecognized
function SoulSpawner.spawn(physics, player, obj)
	local archetype = SoulRegistry[obj.name]
	if not archetype then
		return nil
	end

	return archetype.spawn({
		physics = physics,
		player = player,
	}, obj)
end

---Destroy the physics bodies of all provided Soul entities.
---Call before clearing the souls table on map transition.
---@param souls Soul[] Array of Soul entities to destroy
---@return nil
function SoulSpawner.destroyAll(souls)
	for _, soul in ipairs(souls) do
		soul:destroy()
	end
end

return SoulSpawner
