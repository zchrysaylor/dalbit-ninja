---@class Realm
---@field bgColor number[] the background color of all empty tiles
---@field world love.World Box2D physics world (zero gravity, top-down)
---@field physics physics Physics instance wrapping self.world
---@field map table STI map instance (or empty table before first load)
---@field walls collider[] Static wall colliders for the current map
---@field warps collider[] Warp-trigger colliders for the current map
---@field souls Soul[] NPC entities spawned from the current map's entity layer
---@field husks Husk[] NPC entities spawned from the current map's husk layer
---@field projectiles Projectile[] Active projectiles in the current realm
---@field player Player The player entity (persists across map loads)
---@field heraldGroup HeraldMuster Realm-scoped event subscriptions.
local Realm = {}
Realm.__index = Realm

---Load a Tiled map by name, destroying all existing map entities first.
---Spawns walls, warps, and soul entities from the map's object layers.
---If destination coordinates are provided, teleports the player's physics body to that position.
---@param mapName string Filename stem under maps/ (e.g. "map-start")
---@param destX? number Player spawn X in pixels (optional)
---@param destY? number Player spawn Y in pixels (optional)
---@return nil
function Realm:loadMap(mapName, destX, destY)
    self:destroyAll()

    -- TODO: capture loaded map for save state
    -- loadedMap = mapName

    self.map = Tiled("maps/" .. mapName .. ".lua")

    if self.map.layers["wall"] then
        for _, obj in pairs(self.map.layers["wall"].objects) do
            local wall = WallSpawner.spawn(self.physics, obj)
            table.insert(self.walls, wall)
        end
    end

    if self.map.layers["warp"] then
        for _, obj in pairs(self.map.layers["warp"].objects) do
            local warp = WarpSpawner.spawn(self.physics, obj)
            table.insert(self.warps, warp)
        end
    end

    if self.map.layers["soul"] then
        for _, obj in pairs(self.map.layers["soul"].objects) do
            local soul = SoulSpawner.spawn(self.physics, self.player, obj)
            if soul then
                table.insert(self.souls, soul)
            end
        end
    end

    if self.map.layers["husk"] then
        for _, obj in pairs(self.map.layers["husk"].objects) do
            local husk = HuskSpawner.spawn(self.physics, obj)
            if husk then
                table.insert(self.husks, husk)
            end
        end
    end

    -- spawn the player in idle state with zero velocity
    if destX and destY then
        self.player.vessel:setPosition(destX, destY)
        self.player:syncPosition()
        self.player.vessel:setLinearVelocity(0, 0)
        self.player:changeState(PlayerIdleState.STATE_NAME)
    end

    Lens.snapTo(self.player, self.map)
end

---@return nil
function Realm:flushRemovedSouls()
    for i = #self.souls, 1, -1 do
        local soul = self.souls[i]
        if soul.pendingRemoval then
            soul:destroy()
            table.remove(self.souls, i)
        end
    end
end

---@param projectileDef ProjectileSpawnDef
---@return nil
function Realm:fireProjectile(projectileDef)
    local spawnedProjectile = ProjectileSpawner.spawn(self.physics, projectileDef)
    if spawnedProjectile then
        table.insert(self.projectiles, spawnedProjectile)
    end
end

---@return nil
function Realm:flushRemovedProjectiles()
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        if projectile.pendingRemoval then
            projectile:destroy()
            table.remove(self.projectiles, i)
        end
    end
end

---Check all warp colliders and trigger a map transition event when needed.
---@return nil
function Realm:checkWarps()
    local triggeredWarp = WarpSpawner.check(self.player.collider, self.warps)
    if triggeredWarp then
        Herald.decree(Events.REALM_WARP_TRIGGERED, triggeredWarp)
    end
end

---Advance camera follow, entities, physics, and warp handling.
---@param dt number Delta time in seconds
---@return nil
function Realm:update(dt)
    self.player:update(dt)
    self.player:updateDamageTimers(dt)

    for _, soul in pairs(self.souls) do
        soul:capturePreviousPosition()
        soul:update(dt)
    end

    for _, husk in pairs(self.husks) do
        husk:update(dt)
    end

    for _, projectile in pairs(self.projectiles) do
        projectile:update(dt)
    end

    self.world:update(dt)

    self.player:syncPosition()
    for _, soul in pairs(self.souls) do
        soul:syncPosition()
        soul:postPhysicsUpdate(dt)
    end

    Lens.follow(self.player, self.map)
    Lens.update(dt)

    -- Damage should be checked after player and soul positions are synced.
    self.player:checkDamage()
    for _, soul in pairs(self.souls) do
        soul:checkDamage()
    end

    self:checkWarps()

    self:flushRemovedSouls()
    self:flushRemovedProjectiles()
end

---Render the current map layers, all soul entities, the player, and optionally collision shapes.
---Wrapped inside Lens:attach/detach to clip to the virtual viewport.
---@return nil
function Realm:draw()
    love.graphics.clear(self.bgColor)
    Lens.attach(0, 0, View.getWidth(), View.getHeight(), true)

    -- draw map layers conditionally (not all maps have all layers)
    if self.map.layers["base"] then
        self.map:drawLayer(self.map.layers["base"])
    end
    if self.map.layers["ground"] then
        self.map:drawLayer(self.map.layers["ground"])
    end
    if self.map.layers["building"] then
        self.map:drawLayer(self.map.layers["building"])
    end

    for _, husk in pairs(self.husks) do
        husk:draw()
    end

    self.player:draw()

    for _, soul in pairs(self.souls) do
        soul:draw()
    end

    for _, projectile in pairs(self.projectiles) do
        projectile:draw()
    end

    -- draw collision borders for debugging
    if Debug.showColliders then
        Debug.drawAll(self.world, 0.7)
    end

    Lens.detach()
end

---Destroy all map-scoped entities (walls, warps, souls) and reset the map table.
---@return nil
function Realm:destroyAll()
    WallSpawner.destroyAll(self.walls)
    self.walls = {}

    WarpSpawner.destroyAll(self.warps)
    self.warps = {}

    SoulSpawner.destroyAll(self.souls)
    self.souls = {}

    HuskSpawner.destroyAll(self.husks)
    self.husks = {}

    ProjectileSpawner.destroyAll(self.projectiles)
    self.projectiles = {}

    self.map = {}
end

---Destroy realm-owned entities and event subscriptions.
---@return nil
function Realm:destroy()
    self:destroyAll()

    if self.heraldGroup then
        self.heraldGroup:unhearkenAll()
        self.heraldGroup = nil
    end

    self.player:destroy()
end

---Create a new Realm
---@return Realm
function Realm.new()
    local self = setmetatable({}, Realm)
    self.bgColor = { 0, 0, 0, 1 }

    self.world = love.physics.newWorld(0, 0)
    self.physics = Physics.new(self.world)

    self.map = {}
    self.walls = {}
    self.warps = {}
    self.souls = {}
    self.husks = {}
    self.projectiles = {}

    self.heraldGroup = Herald.muster()
    self.heraldGroup:hearken(Events.REALM_FIRE_PROJECTILE, function(projectileDef)
        self:fireProjectile(projectileDef)
    end)

    self.player = Player.new({
        x = 152,
        y = 136,
        width = 16,
        height = 17,
        speed = 80,
        spriteSheet = GArt["sprite-player"],
        physics = self.physics,
        group = COLLISION_GROUP_PASS_THROUGH,
        hurtbox = {
            radius = 5,
            damageTags = { Damage.TYPES.ENEMY_ATTACK, Damage.TYPES.ENVIRONMENT },
        },
    })

    return self
end

return Realm
