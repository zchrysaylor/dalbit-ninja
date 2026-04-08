local PlayerWalkState = require("src.state.vessel.soul.SoulWalkState")

local PlayerWalkState = {}
PlayerWalkState.__index = PlayerWalkState
setmetatable(PlayerWalkState, { __index = SoulWalkState })

-- TODO: implement walk functionality here
function PlayerWalkState:update(dt) end

function PlayerWalkState.new(player)
	local self = SoulWalkState.new(player)
	self.player = player
	return self
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

	if not isMoving then
		self.player.animations.current:gotoFrame(1)
		return
	end

	-- diagonal movement
	if horizontal and vertical then
		if moveUp and moveLeft then
			self.player.animations.current = self.player.animations.upLeft
		elseif moveUp and moveRight then
			self.player.animations.current = self.player.animations.upRight
		elseif moveDown and moveLeft then
			self.player.animations.current = self.player.animations.downLeft
		elseif moveDown and moveRight then
			self.player.animations.current = self.player.animations.downRight
		end
	elseif vertical and not horizontal then
		-- vertical only
		if moveUp then
			self.player.animations.current = self.player.animations.up
		else
			self.player.animations.current = self.player.animations.down
		end
	elseif horizontal and not vertical then
		-- horizontal only
		if moveLeft then
			self.player.animations.current = self.player.animations.left
		else
			self.player.animations.current = self.player.animations.right
		end
	end
end
