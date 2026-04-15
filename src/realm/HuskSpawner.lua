--- Factory module that creates Husk entities from Tiled object-layer definitions.
---@class HuskSpawner
local HuskSpawner = {}

---Spawn a Husk from a Tiled map object.
---Returns nil for unrecognized object names.
---@param physics physics Physics instance
---@param obj table Tiled map object with at minimum `name`, `x`, and `y` fields
---@return Husk|nil husk The spawned Husk, or nil if the object type is unrecognized
function HuskSpawner.spawn(physics, obj)
	if obj.name == "pointChest" then
		-- TODO: there has to be a better way to define anims & props such that a new Husk subclass is not necessary
		-- rather one should be able to create them on the fly
		local anims = {}
		local grid = Anim8.newGrid(32, 49, GArt["chest"]:getWidth(), GArt["chest"]:getHeight())
		local animations = { main = Anim8.newAnimation(grid("1-2", 1), 0.1) }
		anims.animations = animations
		anims.animations.current = animations.main
		anims.grid = grid
		-- TODO: make use of tagging so that husk is by default a static body
		local chest = Husk.new({
			x = obj.x,
			y = obj.y,
			width = 32,
			height = 49,
			spriteSheet = GArt["chest"],
			anims = anims,
			physics = physics,
		})
		return chest
	end
end

---Destroy the physics bodies of all provided Husk entities.
---Call before clearing the husks table on map transition.
---@param husks Husk[] Array of Husk entities to destroy
function HuskSpawner.destroyAll(husks)
	for _, husk in ipairs(husks) do
		husk:destroy()
	end
end

return HuskSpawner
