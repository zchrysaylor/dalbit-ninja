local WarpSpawner = {}

-- TODO: refactor to live in Deps or some global file
-- Map transition lookup: trigger name -> {mapFile, destX, destY}
local MAP_TRANSITIONS = {
	["warpToForest"] = { mapName = "map-forest", destX = 176, destY = 300 },
	["warpToHometown"] = { mapName = "map-hometown", destX = 176, destY = 20 },
	["warpToInterior1"] = { mapName = "map-interior-1", destX = 116, destY = 310 },
	["warpToExterior1"] = { mapName = "map-hometown", destX = 72, destY = 192 },
}

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

function WarpSpawner.destroyAll(warps)
	for _, warp in ipairs(warps) do
		warp.body:destroy()
	end
end

return WarpSpawner
