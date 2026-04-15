--- Factory module that creates Soul NPC entities from Tiled object-layer definitions.
---@class SoulSpawner
local SoulSpawner = {}

---Spawn an NPC Soul from a Tiled map object.
---Returns nil for unrecognized object names.
---@param physics physics Physics instance
---@param obj table Tiled map object with at minimum `name`, `x`, and `y` fields
---@return Soul|nil soul The spawned Soul, or nil if the object type is unrecognized
function SoulSpawner.spawn(physics, obj)
	if obj.name == "pointFireEnemy" then
		local fireEnemy = Soul.new({
			x = obj.x,
			y = obj.y,
			width = 16,
			height = 16,
			speed = 0.8,
			scale = 1,
			spriteSheet = GArt["sprite-enemy-fire"],
			physics = physics,
		})
		return fireEnemy
	end
end

---Destroy the physics bodies of all provided Soul entities.
---Call before clearing the souls table on map transition.
---@param souls Soul[] Array of Soul entities to destroy
function SoulSpawner.destroyAll(souls)
	for _, soul in ipairs(souls) do
		soul:destroy()
	end
end

return SoulSpawner
