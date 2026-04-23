---@alias WarpDestination {mapName: string, destX: number, destY: number}

-- Map transition lookup: trigger name -> map to load with player spawnpoint
---@type table<string, WarpDestination>
local mapTransitions = {
	["warpToTent"] = { mapName = "map-tent", destX = 128, destY = 192 },
	["warpToMapStart"] = { mapName = "map-start", destX = 88, destY = 82 },
}

return mapTransitions
