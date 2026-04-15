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
---@param physics physics Physics instance
---@param obj table Tiled map object with `name`, `x`, `y`, `width`, and `height` fields
---@return collider warp The resulting static collider tagged as a warp
function WarpSpawner.spawn(physics, obj)
	local centerX = obj.x + obj.width / 2
	local centerY = obj.y + obj.height / 2
	local warp = physics:collider(centerX, centerY, {
		width = obj.width,
		height = obj.height,
		bodyType = "static",
	})

	-- TODO: refactor to use custom tags (can also control bodyType by tag?)
	-- store metadata on love.physics body
	warp:setUserData({
		name = obj.name,
		isWarp = true,
	})

	return warp
end

---Check if the player collider is touching any warp; if so, return its destination.
---@param playerCollider collider The player's collider
---@param warps collider[] Array of warps
---@return WarpDestination|nil destination The map transition data, or nil if no warp is triggered
function WarpSpawner.check(playerCollider, warps)
	-- Check all warp bodies for collision with player
	for _, warp in ipairs(warps) do
		if Collision.isColliding(playerCollider, warp) then
			local data = warp:getUserData()
			if data and data.isWarp then
				return MAP_TRANSITIONS[data.name]
			end
		end
	end
	return nil
end

---Destroy all warps in the provided array.
---@param warps collider[] Array of warps to destroy
function WarpSpawner.destroyAll(warps)
	for _, warp in ipairs(warps) do
		warp:destroy()
	end
end

return WarpSpawner
