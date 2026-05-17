---@alias WarpDestination {mapName: string, destX: number, destY: number}

-- Map transition lookup: trigger name -> map to load with player spawnpoint
---@type table<string, WarpDestination>
local mapTransitions = {
    ["warpToTent"] = { mapName = "map-tent", destX = 128, destY = 192 },
    ["warpToMapStart"] = { mapName = "map-start", destX = 88, destY = 82 },
    ["warpToDungeon"] = { mapName = "map-dungeon", destX = 160, destY = 240 },
    ["warpToNextFloor"] = { mapName = "procedural", destX = 160, destY = 240 }, -- Handled in PlayState
}

return mapTransitions
