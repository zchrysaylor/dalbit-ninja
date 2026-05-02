--- Factory module that creates Soul NPC entities from Tiled object-layer definitions.
---@class SoulSpawner
local SoulSpawner = {}

---Spawn an NPC Soul from a Tiled map object.
---Returns nil for unrecognized object names.
---@param physics physics Physics instance
---@param player Player
---@param obj {name: string, x: number, y: number} Tiled map object with at minimum `name`, `x`, and `y` fields
---@return Soul|nil soul The spawned Soul, or nil if the object type is unrecognized
function SoulSpawner.spawn(physics, player, obj)
	if obj.name == "pointCamoRed" then
		-- TODO: See if can define souls in common place to avoid this function growing huge
		local camoRedEnemy = Soul.new({
			x = obj.x,
			y = obj.y,
			width = 16,
			height = 16,
			speed = 0.5, -- TODO: we do self.soul.speed * 100 in a lot of places, maybe easier to already define as * 100?
			scale = 1,
			spriteSheet = GArt["sprite-camo-red"],
			physics = physics,
			group = COLLISION_GROUP_PASS_THROUGH,
			ai = {
				homeX = obj.x,
				homeY = obj.y,
				type = "chase",
				wanderRadius = 24,
				detectionRadius = 40,
				idleDurationMin = 0.5,
				idleDurationMax = 2.5,
				chaseForce = 80,
				linearDamping = 2,
			},
			tags = { "soul", "hostile" },
		})
		camoRedEnemy:setAIChaseTarget(player)
		return camoRedEnemy
	end
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
