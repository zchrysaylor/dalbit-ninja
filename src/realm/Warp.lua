local Warp = {}
Warp.__index = Warp

-- TODO: refactor to live in Deps or some global file
-- Map transition lookup: trigger name -> {mapFile, destX, destY}
local MAP_TRANSITIONS = {
	["toForestTrigger"] = { mapName = "map-forest-color", destX = 176, destY = 300 },
	["toHometownTrigger"] = { mapName = "map-hometown-color", destX = 176, destY = 20 },
}

function Warp:spawn(world, obj)
	local centerX = obj.x + obj.width / 2
	local centerY = obj.y + obj.height / 2
	local warp = Collision.newRectangle(world, centerX, centerY, obj.width, obj.height)

	-- store metadata on love.physics body
	warp.body:setUserData({
		name = obj.name,
		isWarp = true,
	})

	table.insert(self.bodies, warp)
end

function Warp:check(playerBody)
	-- Check all warp bodies for collision with player
	for _, warp in ipairs(self.bodies) do
		if isColliding(playerBody, warp.body) then
			local data = warp.body:getUserData()
			if data and data.isWarp then
				return MAP_TRANSITIONS[data.name]
			end
		end
	end
	return nil
end

function Warp:destroyAll()
	for _, warp in ipairs(self.bodies) do
		warp.body:destroy()
	end
	self.bodies = {}
end

function Warp.new()
	local self = setmetatable({}, Warp)
	self.bodies = {}
	return self
end

return Warp
