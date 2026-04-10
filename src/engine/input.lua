---A small module for handling keyboard input
---@module input
local input = {}

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
