--- Factory module that creates warp-trigger colliders and resolves map transitions.
---@class WarpSpawner
local WarpSpawner = {}

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

---@alias WarpDestination {mapName: string, destX: number, destY: number}

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
				return MapTransitions[data.name]
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
