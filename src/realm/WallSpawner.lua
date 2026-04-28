--- Factory module that creates static wall colliders from Tiled object-layer definitions.
---@class WallSpawner
local WallSpawner = {}

---Create a static rectangle collider centered on the Tiled object's bounding box.
---@param physics physics Physics instance
---@param obj table Tiled map object with `x`, `y`, `width`, and `height` fields
---@return collider wall The resulting static collider
function WallSpawner.spawn(physics, obj)
	local centerX = obj.x + obj.width / 2
	local centerY = obj.y + obj.height / 2
	local wall = physics:collider(centerX, centerY, {
		width = obj.width,
		height = obj.height,
		bodyType = "static",
	})
	return wall
end

---Destroy all wall physics bodies in the provided array.
---@param walls collider[] Array of wall colliders to destroy
---@return nil
function WallSpawner.destroyAll(walls)
	for _, wall in ipairs(walls) do
		wall:destroy()
	end
end

return WallSpawner
