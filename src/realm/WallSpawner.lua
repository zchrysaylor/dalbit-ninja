--- Factory module that creates static wall colliders from Tiled object-layer definitions.
---@module WallSpawner
local WallSpawner = {}

---Create a static rectangle collider centered on the Tiled object's bounding box.
---@param world love.World Box2D world the collider is added to
---@param obj table Tiled map object with `x`, `y`, `width`, and `height` fields
---@return CollisionData wall The resulting static collision body
function WallSpawner.spawn(world, obj)
	local centerX = obj.x + obj.width / 2
	local centerY = obj.y + obj.height / 2
	local wall = Collision.newRectangle(world, centerX, centerY, obj.width, obj.height)
	return wall
end

---Destroy all wall physics bodies in the provided array.
---@param walls CollisionData[] Array of wall collision data to destroy
function WallSpawner.destroyAll(walls)
	for _, wall in ipairs(walls) do
		wall.body:destroy()
	end
end

return WallSpawner
