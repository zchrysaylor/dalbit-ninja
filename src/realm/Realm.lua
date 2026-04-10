---@class Realm
---@field world love.World Box2D physics world (zero gravity, top-down)
---@field map table STI map instance (or empty table before first load)
---@field walls CollisionData[] Static wall colliders for the current map
---@field warps CollisionData[] Warp-trigger colliders for the current map
---@field souls Soul[] NPC entities spawned from the current map's entity layer
---@field player Player The player entity (persists across map loads)
local Realm = {}
Realm.__index = Realm

-- Module-level debug toggle; flipped by KEY_DEBUG each frame
local debug = false

---Load a Tiled map by name, destroying all existing map entities first.
---Spawns walls, warps, and soul entities from the map's object layers.
---If destination coordinates are provided, teleports the player's physics body to that position.
---@param mapName string Filename stem under maps/ (e.g. "map-hometown")
---@param destX? number Player spawn X in pixels (optional)
---@param destY? number Player spawn Y in pixels (optional)
function Realm:loadMap(mapName, destX, destY)
	self:destroyAll()

	if destX and destY then
		-- player x and y are updated based on the collision in update(dt)
		-- Thus, we only need to update the collision here
		self.player:setPosition(destX, destY)
	end

	-- TODO: capture loaded map for save state
	-- loadedMap = mapName

	self.map = Tiled("maps/" .. mapName .. ".lua")

	if self.map.layers["wall"] then
		for _, obj in pairs(self.map.layers["wall"].objects) do
			local wall = WallSpawner.spawn(self.world, obj)
			table.insert(self.walls, wall)
		end
	end

	if self.map.layers["warp"] then
		for _, obj in pairs(self.map.layers["warp"].objects) do
			local warp = WarpSpawner.spawn(self.world, obj)
			table.insert(self.warps, warp)
		end
	end

	-- TODO: refactor map layer to be "soul"
	if self.map.layers["entity"] then
		for _, obj in pairs(self.map.layers["entity"].objects) do
			local soul = SoulSpawner.spawn(self.world, obj)
			table.insert(self.souls, soul)
		end
	end
end

---Destroy all map-scoped entities (walls, warps, souls) and reset the map table.
---Called automatically at the start of loadMap(); also called from PlayState:exitState().
function Realm:destroyAll()
	WallSpawner.destroyAll(self.walls)
	self.walls = {}

	WarpSpawner.destroyAll(self.warps)
	self.warps = {}

	SoulSpawner.destroyAll(self.souls)
	self.souls = {}

	self.map = {}
end

---Step the physics world, sync entity positions from their collision bodies,
---update all entities, check warp triggers, and handle debug toggle.
---@param dt number Delta time in seconds
function Realm:update(dt)
	-- TODO: might need to still draw in PlayState outside fading
	-- Maybe this should be a separate util b/c doesn't fit in PlayState or here (because must be called outside fades)
	-- self:CameraLookAtPlayer()
	self.world:update(dt)
	self.player.x, self.player.y = self.player:getPosition()
	self.player:update(dt)
	self:checkWarps()

	for _, soul in pairs(self.souls) do
		soul.x, soul.y = soul:getPosition()
		soul:update(dt)
	end

	if love.keyboard.wasPressed(KEY_DEBUG) then
		debug = not debug
	end
end

---Render the current map layers, all soul entities, the player, and optionally collision shapes.
---Wrapped inside Camera:attach/detach to clip to the virtual 240x160 viewport.
function Realm:draw()
	Camera:attach(0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, true)

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

	for _, soul in pairs(self.souls) do
		soul:draw()
	end

	self.player:draw()

	-- draw collision borders for debugging
	if debug then
		Collision.drawAll(self.world, 0.7)
	end

	Camera:detach()
end

---Point the camera at the player and clamp so it never shows area outside the map bounds.
---Must be called every frame (even during fades) so the viewport stays correct.
function Realm:CameraLookAtPlayer()
	local windowWidth = VIRTUAL_WIDTH
	local windowHeight = VIRTUAL_HEIGHT
	local mapWidth = self.map.width * self.map.tilewidth
	local mapHeight = self.map.height * self.map.tileheight
	local zoom = Camera.scale

	Camera:lookAt(self.player.x, self.player.y)

	local halfViewW = windowWidth / (2 * zoom)
	local halfViewH = windowHeight / (2 * zoom)

	if Camera.x < halfViewW then
		Camera.x = halfViewW
	end
	if Camera.y < halfViewH then
		Camera.y = halfViewH
	end
	if Camera.x > mapWidth - halfViewW then
		Camera.x = mapWidth - halfViewW
	end
	if Camera.y > mapHeight - halfViewH then
		Camera.y = mapHeight - halfViewH
	end
end

---Check all warp colliders; if the player is touching one, load its destination map.
function Realm:checkWarps()
	local triggeredWarp = WarpSpawner.check(self.player.collision.body, self.warps)
	if triggeredWarp then
		self:loadMap(triggeredWarp.mapName, triggeredWarp.destX, triggeredWarp.destY)
	end
end

---Create a new Realm with a zero-gravity Box2D world and a default Player.
---Call loadMap() after construction to populate the first map.
---@return Realm
function Realm.new()
	local self = setmetatable({}, Realm)

	-- create a new physics world
	self.world = love.physics.newWorld(0, 0)

	self.map = {}
	self.walls = {}
	self.warps = {}
	self.souls = {}

	self.player = Player.new({
		x = 160,
		y = 200,
		width = 16,
		height = 16,
		speed = 0.8,
		scale = 1, -- can remove if keep 16x16
		spriteSheet = GArt["sprite-player"],
		world = self.world,
	})

	return self
end

return Realm
