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
			local centerX = obj.x + obj.width / 2
			local centerY = obj.y + obj.height / 2
			local wall = Collision.newRectangle(self.world, centerX, centerY, obj.width, obj.height)
			table.insert(self.walls, wall)
		end
	end

	if self.map.layers["trigger"] then
		for _, obj in pairs(self.map.layers["trigger"].objects) do
			self.warps:spawn(self.world, obj)
		end
	end
end

function Realm:destroyAll()
	for _, wall in ipairs(self.walls) do
		wall.body:destroy()
	end
	self.walls = {}

	self.warps:destroyAll()

	self.entities = {}
	self.map = {}
end

function Realm:update(dt)
	-- TODO: might need to still draw in PlayState outside fading
	-- Maybe this should be a separate util b/c doesn't fit in PlayState or here (because must be called outside fades)
	-- self:CameraLookAtPlayer()
	self:MovePlayer()
	self.world:update(dt)
	self.player.x, self.player.y = self.player.collision:getPosition()
	self.player.animations.current:update(dt)
	self:checkWarps()

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

function Realm:MovePlayer()
	local isMoving = false

	local moveUp = love.keyboard.isDown(KEY_UP)
	local moveLeft = love.keyboard.isDown(KEY_LEFT)
	local moveDown = love.keyboard.isDown(KEY_DOWN)
	local moveRight = love.keyboard.isDown(KEY_RIGHT)

	-- build velocity from input
	local vx, vy = 0, 0
	local speed = self.player.speed * 100 -- velocity is pixels/sec

	if moveUp and not moveDown then
		vy = -speed
		isMoving = true
	elseif moveDown and not moveUp then
		vy = speed
		isMoving = true
	end

	if moveLeft and not moveRight then
		vx = -speed
		isMoving = true
	elseif moveRight and not moveLeft then
		vx = speed
		isMoving = true
	end

	-- move the body with physics and animations
	self.player.collision:setLinearVelocity(vx, vy)
	self:AnimatePlayer(isMoving, moveUp, moveDown, moveLeft, moveRight)
end

function Realm:AnimatePlayer(isMoving, moveUp, moveDown, moveLeft, moveRight)
	local horizontal = (moveLeft or moveRight) and not (moveLeft and moveRight)
	local vertical = (moveUp or moveDown) and not (moveUp and moveDown)

	-- use tracked keystroke order to determine actual direction for animations
	-- prevents weird diagonal movement animations
	if horizontal and vertical then
		-- diagonal: force left/right animation
		if moveLeft then
			self.player.animations.current = self.player.animations.left
		else
			self.player.animations.current = self.player.animations.right
		end
	elseif vertical and not horizontal then
		-- vertical only: find most recent vertical key in order
		for _, key in ipairs(KeyPress.order) do
			if key == KEY_UP then
				self.player.animations.current = self.player.animations.up
				break
			elseif key == KEY_DOWN then
				self.player.animations.current = self.player.animations.down
				break
			end
		end
	elseif horizontal and not vertical then
		-- horizontal only: find most recent horizontal key in order
		for _, key in ipairs(KeyPress.order) do
			if key == KEY_LEFT then
				self.player.animations.current = self.player.animations.left
				break
			elseif key == KEY_RIGHT then
				self.player.animations.current = self.player.animations.right
				break
			end
		end
	end

	if isMoving == false then
		self.player.animations.current:gotoFrame(2)
	end
end

-- Trigger a warp if a player has collided with it
function Realm:checkWarps()
	local warp = self.warps:check(self.player.collision.body)
	if warp then
		self:loadMap(warp.mapName, warp.destX, warp.destY)
	end
end

function Realm.new()
	local self = setmetatable({}, Realm)

	-- create a new physics world
	self.world = love.physics.newWorld(0, 0)

	-- TODO: figure right data type sti returns or instantiate with default map
	self.map = {}
	self.walls = {}
	self.warps = Warp.new()

	self.player = Player.new({
		x = 160,
		y = 200,
		width = 14,
		height = 17,
		speed = 0.8,
		scale = 1, -- can remove if keep 16x16
		spriteSheet = GArt["sprite-player"],
		world = self.world,
	})

	self.entities = {}

	return self
end

return Realm
