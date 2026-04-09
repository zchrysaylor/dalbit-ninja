local Realm = {}
Realm.__index = Realm

local debug = false

function Realm:loadMap(mapName, destX, destY)
	self:destroyAll()

	if destX and destY then
		-- player x and y are updated based on the collision in update(dt)
		-- Thus, we only need to update the collision here
		self.player.collision:setPosition(destX, destY)
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

	if self.map.layers["entity"] then
		for _, obj in pairs(self.map.layers["entity"].objects) do
			local entity = SoulSpawner.spawn(self.world, obj)
			table.insert(self.entities, entity)
		end
	end
end

function Realm:destroyAll()
	WallSpawner.destroyAll(self.walls)
	self.walls = {}

	WarpSpawner.destroyAll(self.warps)
	self.warps = {}

	SoulSpawner.destroyAll(self.entities)
	self.entities = {}

	self.map = {}
end

function Realm:update(dt)
	-- TODO: might need to still draw in PlayState outside fading
	-- Maybe this should be a separate util b/c doesn't fit in PlayState or here (because must be called outside fades)
	-- self:CameraLookAtPlayer()
	self.world:update(dt)
	self.player.x, self.player.y = self.player.collision:getPosition()
	self.player:update(dt)
	self:checkWarps()

	for _, entity in pairs(self.entities) do
		entity:update(dt)
	end

	if love.keyboard.wasPressed(KEY_DEBUG) then
		debug = not debug
	end
end

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

	for _, entity in pairs(self.entities) do
		entity:draw()
	end

	self.player:draw()

	-- draw collision borders for debugging
	if debug then
		Collision.drawAll(self.world, 0.7)
	end

	Camera:detach()
end

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

-- Trigger a warp if a player has collided with it
function Realm:checkWarps()
	local triggeredWarp = WarpSpawner.check(self.player.collision.body, self.warps)
	if triggeredWarp then
		self:loadMap(triggeredWarp.mapName, triggeredWarp.destX, triggeredWarp.destY)
	end
end

function Realm.new()
	local self = setmetatable({}, Realm)

	-- create a new physics world
	self.world = love.physics.newWorld(0, 0)

	-- TODO: figure right data type sti returns or instantiate with default map
	self.map = {}
	self.walls = {}
	self.warps = {}
	self.entities = {}

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
