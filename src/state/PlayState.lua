local BaseState = require("src.state.BaseState")

local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

local pauseGame = false

function PlayState:enterState(options)
	self.walls = {}
	if Map.layers["wall"] then
		for i, obj in pairs(Map.layers["wall"].objects) do
			local centerX = obj.x + obj.width / 2
			local centerY = obj.y + obj.height / 2
			local wall = Collision.newRectangleCollision(World, centerX, centerY, obj.width, obj.height)
			table.insert(self.walls, wall)
		end
	end

	if options and options.previousState and options.previousState == "start" then
		self.fadeAlpha = 1
		self.isFading = true

		Timer.tween(FADE_RATE, { [self] = { fadeAlpha = 0 } }):finish(function()
			self.isFading = false
		end)
	end
end

function PlayState:exitState()
	-- Optional: cleanup physics bodies if needed
	for _, wall in ipairs(self.walls) do
		wall:destroy()
	end
	self.walls = nil
end

function PlayState:update(dt)
	self:CameraLookAtPlayer()
	-- TODO: player currently looks walking on start, because animation not updated yet due to this early return
	-- Should be fixable when implmenting player idle state
	-- Adding gotoFrame is a workaround
	if self.isFading then
		self.player.animations.current:gotoFrame(2)
		return
	end

	if love.keyboard.wasPressed("p") then
		pauseGame = not pauseGame
	end

	if not pauseGame then
		self:MovePlayer()
		World:update(dt)
		self.player.x, self.player.y = self.player.collision:getPosition()
		self.player.animations.current:update(dt)
	end
end

function PlayState:draw()
	Camera:attach(0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT, true)

	Map:drawLayer(Map.layers["base"])
	Map:drawLayer(Map.layers["ground"])
	-- Map:drawLayer(Map.layers["hill"])
	Map:drawLayer(Map.layers["building"])
	self.player:draw()
	Collision.drawCollisions(World, 0.7)

	Camera:detach()

	if self.isFading then
		love.graphics.setColor(0, 0, 0, self.fadeAlpha)
		love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
	end

	if pauseGame then
		love.graphics.setFont(GFonts["sproutlandsSmall"])
		love.graphics.printf(
			"Game Paused. Press 'p' to resume.",
			0,
			(Push:getHeight() / 2) - 0,
			Push:getWidth(),
			"center"
		)
	end
end

function PlayState:MovePlayer()
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

function PlayState:AnimatePlayer(isMoving, moveUp, moveDown, moveLeft, moveRight)
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

function PlayState:CameraLookAtPlayer()
	local windowWidth = VIRTUAL_WIDTH
	local windowHeight = VIRTUAL_HEIGHT
	local mapWidth = Map.width * Map.tilewidth
	local mapHeight = Map.height * Map.tileheight
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

function PlayState.new()
	local self = setmetatable({}, PlayState)

	self.player = Player.newPlayer({
		x = 180,
		y = 200,
		width = 14,
		height = 17,
		speed = 0.8,
		scale = 1, -- can remove if keep 16x16
		spriteSheet = GArt["sprite-player"],
	})

	self.fadeAlpha = 1
	self.isFading = false

	return self
end

return PlayState
