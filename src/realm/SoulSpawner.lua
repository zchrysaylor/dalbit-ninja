--- Factory module that creates Soul NPC entities from Tiled object-layer definitions.
---@class SoulSpawner
local SoulSpawner = {}

---Spawn an NPC Soul from a Tiled map object.
---Returns nil for unrecognized object names.
---@param physics physics Physics instance
---@param obj table Tiled map object with at minimum `name`, `x`, and `y` fields
---@return Soul|nil soul The spawned Soul, or nil if the object type is unrecognized
function SoulSpawner.spawn(physics, obj)
	if obj.name == "pointCamoRed" then
		local camoRedEnemy = Soul.new({
			x = obj.x,
			y = obj.y,
			width = 16,
			height = 16,
			speed = 0.55,
			scale = 1,
			spriteSheet = GArt["sprite-camo-red"],
			physics = physics,
			ai = {
				homeX = obj.x,
				homeY = obj.y,
				type = "wander",
				wanderRadius = 30,
				idleDurationMin = 0.5,
				idleDurationMax = 2.5,
			},
		})
		return camoRedEnemy
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
