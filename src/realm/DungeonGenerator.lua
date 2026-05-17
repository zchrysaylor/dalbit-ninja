--- Procedural Dungeon Generator for Infinite Dungeon.
--- Generates map data compatible with STI (Simple Tiled Implementation).
local DungeonGenerator = {}

---Generate a procedural dungeon floor.
---@param floorNumber number The current floor depth (1-5)
---@return table mapData STI-compatible map table
---@return number spawnX Player start X in pixels
---@return number spawnY Player start Y in pixels
function DungeonGenerator.generate(floorNumber)
    -- 1. Setup randomization and themes
    math.randomseed(os.time() + floorNumber)
    
    local width = math.random(22, 30)
    local height = math.random(22, 30)
    local tileW, tileH = 16, 16

    -- Define themes for each floor
    local floorSets = {
        [1] = { 178, 179, 180 }, [2] = { 200, 201, 202 },
        [3] = { 222, 223, 224 }, [4] = { 244, 245, 246 },
        [5] = { 266, 267, 268 }
    }
    local currentFloorSet = floorSets[floorNumber] or floorSets[1]
    
    local wallSets = {
        [1] = { 573, 574, 575 }, [2] = { 585, 586, 587 },
        [3] = { 597, 598, 599 }, [4] = { 609, 610, 611 },
        [5] = { 609, 597, 573 }
    }
    local currentWallSet = wallSets[floorNumber] or wallSets[1]
    local wallGid = currentWallSet[1]

    -- 2. Carve Rooms
    local wallData = {}
    for i = 1, width * height do wallData[i] = wallGid end

    local function carveRect(rx, ry, rw, rh)
        for y = ry, ry + rh - 1 do
            for x = rx, rx + rw - 1 do
                if x >= 1 and x < width-1 and y >= 1 and y < height-1 then
                    wallData[y * width + x + 1] = 0
                end
            end
        end
    end

    -- Pick a flow direction: 1:Up, 2:Right, 3:Down, 4:Left
    local flow = math.random(1, 4)
    
    -- Add Start Room
    local startRoom = {}
    if flow == 1 then startRoom = { x = math.random(5, width - 10), y = height - 8, w = 6, h = 6 }
    elseif flow == 2 then startRoom = { x = 2, y = math.random(5, height - 10), w = 6, h = 6 }
    elseif flow == 3 then startRoom = { x = math.random(5, width - 10), y = 2, w = 6, h = 6 }
    else startRoom = { x = width - 8, y = math.random(5, height - 10), w = 6, h = 6 }
    end
    carveRect(startRoom.x, startRoom.y, startRoom.w, startRoom.h)

    -- Add Intermediate Rooms
    local numRooms = math.random(2, 4)
    local rooms = { startRoom }
    for _ = 1, numRooms do
        local r = {
            x = math.random(2, width - 9),
            y = math.random(2, height - 9),
            w = math.random(5, 8),
            h = math.random(5, 8)
        }
        table.insert(rooms, r)
        carveRect(r.x, r.y, r.w, r.h)
    end

    -- Add Exit Room
    local exitRoom = {}
    if flow == 1 then exitRoom = { x = math.random(5, width - 10), y = 2, w = 6, h = 5 }
    elseif flow == 2 then exitRoom = { x = width - 8, y = math.random(5, height - 10), w = 5, h = 6 }
    elseif flow == 3 then exitRoom = { x = math.random(5, width - 10), y = height - 7, w = 6, h = 5 }
    else exitRoom = { x = 2, y = math.random(5, height - 10), w = 5, h = 6 }
    end
    table.insert(rooms, exitRoom)
    carveRect(exitRoom.x, exitRoom.y, exitRoom.w, exitRoom.h)

    -- 3. Connect Rooms with Wide Corridors
    for i = 1, #rooms - 1 do
        local r1 = rooms[i]
        local r2 = rooms[i+1]
        local x1, y1 = math.floor(r1.x + r1.w/2), math.floor(r1.y + r1.h/2)
        local x2, y2 = math.floor(r2.x + r2.w/2), math.floor(r2.y + r2.h/2)
        
        if math.random() > 0.5 then
            carveRect(math.min(x1, x2) - 1, y1 - 1, math.abs(x1 - x2) + 3, 3)
            carveRect(x2 - 1, math.min(y1, y2) - 1, 3, math.abs(y1 - y2) + 3)
        else
            carveRect(x1 - 1, math.min(y1, y2) - 1, 3, math.abs(y1 - y2) + 3)
            carveRect(math.min(x1, x2) - 1, y2 - 1, math.abs(x1 - x2) + 3, 3)
        end
    end

    -- Add random wall variations
    for i = 1, width * height do
        if wallData[i] ~= 0 and math.random() > 0.85 then
            wallData[i] = currentWallSet[math.random(1, #currentWallSet)]
        end
    end

    -- 4. Finalize Map Data Structure
    local mapData = {
        version = "1.10", luaversion = "5.1", tiledversion = "1.11.2",
        orientation = "orthogonal", renderorder = "right-down",
        width = width, height = height, tilewidth = tileW, tileheight = tileH,
        nextlayerid = 6, nextobjectid = 200, properties = {},
        tilesets = {
            {
                name = "ninja-floor", firstgid = 1, tilewidth = 16, tileheight = 16,
                spacing = 0, margin = 0, columns = 22, image = "art/ninja-floor.png",
                imagewidth = 352, imageheight = 417, tilecount = 572, tiles = {}, tileoffset = { x = 0, y = 0 }
            },
            {
                name = "ninja-dungeon", firstgid = 573, tilewidth = 16, tileheight = 16,
                spacing = 0, margin = 0, columns = 12, image = "art/ninja-dungeon.png",
                imagewidth = 192, imageheight = 64, tilecount = 48, tiles = {}, tileoffset = { x = 0, y = 0 }
            }
        },
        layers = {}
    }

    -- Base Floor Layer
    local baseData = {}
    for i = 1, width * height do
        if wallData[i] == 0 then
            baseData[i] = currentFloorSet[1]
            if math.random() > 0.9 then baseData[i] = currentFloorSet[math.random(2, #currentFloorSet)] end
        else
            baseData[i] = currentFloorSet[1] 
        end
    end

    table.insert(mapData.layers, {
        type = "tilelayer", name = "base", id = 1, x = 0, y = 0, width = width, height = height,
        visible = true, opacity = 1, offsetx = 0, offsety = 0, parallaxx = 1, parallaxy = 1, properties = {},
        encoding = "lua", data = baseData
    })

    table.insert(mapData.layers, {
        type = "tilelayer", name = "building", id = 2, x = 0, y = 0, width = width, height = height,
        visible = true, opacity = 1, offsetx = 0, offsety = 0, parallaxx = 1, parallaxy = 1, properties = {},
        encoding = "lua", data = wallData
    })

    -- 5. Create Optimized Collisions
    local wallObjects = {}
    local objId = 1
    for y = 0, height - 1 do
        local startX = nil
        for x = 0, width do
            local isWall = (x < width) and (wallData[y * width + x + 1] ~= 0)
            if isWall and not startX then
                startX = x
            elseif not isWall and startX then
                table.insert(wallObjects, {
                    id = objId, name = "", type = "", shape = "rectangle",
                    x = startX * tileW, y = y * tileH, width = (x - startX) * tileW, height = tileH,
                    rotation = 0, visible = true, properties = {}
                })
                objId = objId + 1
                startX = nil
            end
        end
    end
    table.insert(mapData.layers, {
        type = "objectgroup", name = "wall", id = 3, visible = true, opacity = 1, offsetx = 0, offsety = 0,
        parallaxx = 1, parallaxy = 1, properties = {}, objects = wallObjects
    })

    -- 6. Place Warp (Randomized Exit)
    local warpName = (floorNumber < 5) and "warpToNextFloor" or "warpToMapStart"
    local exitX = exitRoom.x + exitRoom.w/2
    local exitY = exitRoom.y + exitRoom.h/2
    table.insert(mapData.layers, {
        type = "objectgroup", name = "warp", id = 4, visible = true, opacity = 1, offsetx = 0, offsety = 0,
        parallaxx = 1, parallaxy = 1, properties = {},
        objects = {
            {
                id = objId, name = warpName, type = "", shape = "rectangle",
                x = (exitX - 0.5) * tileW, y = (exitY - 0.5) * tileH, width = 16, height = 16,
                rotation = 0, visible = true, properties = { isPortal = true }
            }
        }
    })
    objId = objId + 1

    -- 7. Place Soul Objects (Enemies)
    local soulObjects = {}
    for _ = 1, 5 + floorNumber do
        local sx, sy
        repeat
            sx = math.random(1, width - 2)
            sy = math.random(1, height - 2)
        until wallData[sy * width + sx + 1] == 0
        
        table.insert(soulObjects, {
            id = objId, name = "pointCamoRed", type = "", shape = "point",
            x = sx * tileW + 8, y = sy * tileH + 8, width = 0, height = 0,
            rotation = 0, visible = true, properties = {}
        })
        objId = objId + 1
    end
    table.insert(mapData.layers, {
        type = "objectgroup", name = "soul", id = 5, visible = true, opacity = 1, offsetx = 0, offsety = 0,
        parallaxx = 1, parallaxy = 1, properties = {}, objects = soulObjects
    })

    -- 8. Calculate Spawn Coordinates (Center of Start Room, shifted by half-tile to center on floor)
    local spawnX = math.floor(startRoom.x + startRoom.w/2) * tileW + 8
    local spawnY = math.floor(startRoom.y + startRoom.h/2) * tileH + 8

    return mapData, spawnX, spawnY
end

return DungeonGenerator
