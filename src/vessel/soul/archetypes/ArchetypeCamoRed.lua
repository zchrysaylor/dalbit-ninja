---Archetype definition for the red camo chase Soul.
---@class ArchetypeCamoRed : SoulArchetype
local ArchetypeCamoRed = {}

---Spawn a red camo chase Soul from a Tiled object.
---@param ctx SoulSpawnContext Shared spawn dependencies.
---@param obj SoulMapObject Tiled map object.
---@return Soul soul The spawned Soul.
function ArchetypeCamoRed.spawn(ctx, obj)
	local soul = Soul.new({
		x = obj.x,
		y = obj.y,
		width = 16,
		height = 16,
		speed = 50,
		spriteSheet = GArt["sprite-camo-red"],
		physics = ctx.physics,
		group = COLLISION_GROUP_PASS_THROUGH,
		ai = {
			homeX = obj.x,
			homeY = obj.y,
			type = "chase", -- TODO: set chase automaticallly if tag "hostile" is present?
			wanderRadius = 24,
			detectionRadius = 40,
			idleDurationMin = 0.5,
			idleDurationMax = 2.5,
			chaseForce = 80,
		},
		linearDamping = 2,
		tags = { "soul", "hostile" },
	})
	soul:setAIChaseTarget(ctx.player)
	return soul
end

return ArchetypeCamoRed
