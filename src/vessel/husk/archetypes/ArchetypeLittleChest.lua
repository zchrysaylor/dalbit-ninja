---Archetype definition for a little blue interactable chest Husk.
---@class ArchetypeLittleChest : HuskArchetype
local ArchetypeLittleChest = {}

---Spawn a little blue chest Husk from a Tiled object.
---@param ctx HuskSpawnContext Shared spawn dependencies.
---@param obj HuskMapObject Tiled map object.
---@return Husk husk The spawned Husk.
function ArchetypeLittleChest.spawn(ctx, obj)
    local chest = Husk.new({
        x = obj.x,
        y = obj.y,
        width = 16,
        height = 16,
        spriteSheet = GArt["chest-little-blue"],
        animOpts = { frames = "1-2", row = 1, interval = 0.1, paused = true },
        physics = ctx.physics,
        tags = { "husk", "interactable" },
    })
    chest.opened = false

    ---@return nil
    function chest:interact()
        self.opened = not self.opened
        if self.opened then
            self.animations.current:gotoFrame(2)
        else
            self.animations.current:gotoFrame(1)
        end
    end

    return chest
end

return ArchetypeLittleChest
