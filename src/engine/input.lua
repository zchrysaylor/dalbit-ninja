---Keyboard input manager.
---@class input
---@field keysPressed table<string, boolean> Keys pressed this frame, cleared each update
local input = {}
input.keysPressed = {}

---Record a key press for the current frame and handle global shortcuts.
---@param key string LOVE key constant (e.g. "return", "escape")
function input:keyPressed(key)
	self.keysPressed[key] = true

	-- exit the game
	if key == "escape" then
		love.event.quit()
	end

	-- toggle pause mode
	if key == KEY_PAUSE then
		Signal.emit(Events.GAME_PAUSE_TOGGLED)
	end

	-- toggle debug mode
	if key == KEY_DEBUG then
		Signal.emit(Events.GAME_DEBUG_TOGGLED)
	end
end

---Return whether the given key was pressed this frame.
---@param key string LOVE key constant (e.g. "return", "space")
---@return boolean
function input:wasPressed(key)
	return self.keysPressed[key] or false
end

---@param dt number Delta time in seconds
function input:update(dt)
	self.keysPressed = {}
end

---Return the current directional input as a normalized direction vector.
---@return number dirX  -1, 0, or 1
---@return number dirY  -1, 0, or 1
---@return boolean isMoving  true if any directional key is held
function input.getDirection()
	local moveUp = love.keyboard.isDown(KEY_UP)
	local moveDown = love.keyboard.isDown(KEY_DOWN)
	local moveLeft = love.keyboard.isDown(KEY_LEFT)
	local moveRight = love.keyboard.isDown(KEY_RIGHT)

	local dirX = (moveRight and 1 or 0) - (moveLeft and 1 or 0)
	local dirY = (moveDown and 1 or 0) - (moveUp and 1 or 0)
	local isMoving = moveUp or moveDown or moveLeft or moveRight

	return dirX, dirY, isMoving
end

return input
