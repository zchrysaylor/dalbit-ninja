--- Factory module that creates Husk entities from Tiled object-layer definitions.
---@class HuskSpawner
local HuskSpawner = {}

---Spawn a Husk from a Tiled map object.
---@param physics physics Physics instance
---@param obj HuskMapObject Tiled map object with at minimum `name`, `x`, and `y` fields
---@return Husk|nil husk The spawned Husk, or nil if the object type is unrecognized
function HuskSpawner.spawn(physics, obj)
    local archetype = HuskRegistry[obj.name]
    if not archetype then
        return nil
    end

    return archetype.spawn({
        physics = physics,
    }, obj)
end

---Destroy the physics bodies of all provided Husk entities.
---Call before clearing the husks table on map transition.
---@param husks Husk[] Array of Husk entities to destroy
---@return nil
function HuskSpawner.destroyAll(husks)
    for _, husk in ipairs(husks) do
        husk:destroy()
    end
end

return HuskSpawner
