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
		local chest = Husk.new({
			x = obj.x,
			y = obj.y,
			width = 32,
			height = 49,
			spriteSheet = GArt["chest"],
			animOpts = { frames = "1-2", row = 1, interval = 0.1, paused = true },
			physics = physics,
			tags = { "husk", "interactable" },
		})
		chest.opened = false
		function chest:interact()
			self.opened = not self.opened
			if self.opened then
				self.animations.current:gotoFrame(2)
			else
				self.animations.current:gotoFrame(1)
			end
		end
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
