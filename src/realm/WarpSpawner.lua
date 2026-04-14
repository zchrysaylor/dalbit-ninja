--- Factory module that creates warp-trigger colliders and resolves map transitions.
---@class WarpSpawner
local WarpSpawner = {}

---@alias WarpDestination {mapName: string, destX: number, destY: number}

-- TODO: refactor to live in Deps or some global file
-- Map transition lookup: trigger name -> {mapName, destX, destY}
---@type table<string, WarpDestination>
local MAP_TRANSITIONS = {
	["warpToForest"] = { mapName = "map-forest", destX = 176, destY = 300 },
	["warpToHometown"] = { mapName = "map-hometown", destX = 176, destY = 20 },
	["warpToInterior1"] = { mapName = "map-interior-1", destX = 116, destY = 310 },
	["warpToExterior1"] = { mapName = "map-hometown", destX = 72, destY = 192 },
}

---Create a static rectangle collider for a warp zone and tag its body with metadata.
---@param world love.World Box2D world the collider is added to
---@param obj table Tiled map object with `name`, `x`, `y`, `width`, and `height` fields
---@return CollisionData warp The resulting static collision body tagged as a warp
function WarpSpawner.spawn(world, obj)
	local centerX = obj.x + obj.width / 2
	local centerY = obj.y + obj.height / 2
	local warp = Collision.newRectangle(world, centerX, centerY, obj.width, obj.height)

	-- store metadata on love.physics body
	warp.body:setUserData({
		name = obj.name,
		isWarp = true,
	})

	return warp
end

---Check if the player body is touching any warp; if so, return its destination.
---@param playerBody love.Body The player's physics body
---@param warps CollisionData[] Array of warp collision data to test against
---@return WarpDestination|nil destination The map transition data, or nil if no warp is triggered
function WarpSpawner.check(playerBody, warps)
	-- Check all warp bodies for collision with player
	for _, warp in ipairs(warps) do
		if Physics.isColliding(playerBody, warp.body) then
			local data = warp.body:getUserData()
			if data and data.isWarp then
				return MAP_TRANSITIONS[data.name]
			end
		end
	end
	return nil
end

---Destroy all warp physics bodies in the provided array.
---@param warps CollisionData[] Array of warp collision data to destroy
function WarpSpawner.destroyAll(warps)
	for _, warp in ipairs(warps) do
		warp.body:destroy()
	end
end

return WarpSpawner
