---Keyboard input manager.
---@class input
---@field keysPressed table<string, boolean> Keys pressed this frame, cleared each update
---@field commandBuffer string Recently typed text for global command sequences
local input = {}
input.keysPressed = {}
input.commandBuffer = ""

---Record a key press for the current frame and handle global shortcuts.
---@param key string LOVE key constant (e.g. "return", "escape")
---@return nil
function input:keyPressed(key)
    self.keysPressed[key] = true

    -- TODO: refactor so that esc can be used for different cases, like closing a menu
    -- exit the game
    if key == "escape" then
        love.event.quit()
    end

    if key == KEY_DEBUG_COLLIDERS then
        Herald.decree(Events.GAME_DEBUG_COLLIDERS)
        return
    end

    if key == KEY_DEBUG_MENU then
        Herald.decree(Events.GAME_DEBUG_TOGGLED)
        return
    end

    -- Return early if no top state, since rest of input should not be global
    local topState = GStateStack:peek()
    if not topState then
        return
    end

	local stateInputEvent = Events.STATE_INPUT_PREFIX .. topState.stateName
	if key == KEY_INTERACT then
		Herald.decree(stateInputEvent, "interact")
	elseif key == KEY_MENU then
		Herald.decree(stateInputEvent, "toggle_menu")
	elseif key == KEY_PAUSE then
		Herald.decree(stateInputEvent, "toggle_pause")
	elseif key == KEY_SHURIKEN then
		Herald.decree(stateInputEvent, "shuriken")
	end
end

---Record printable text input for global command sequences.
---@param text string
---@return nil
function input:textInput(text)
    self.commandBuffer = (self.commandBuffer .. text):sub(-2)

    if self.commandBuffer == ":q" then
        love.event.quit()
        self.commandBuffer = ""
    end
end

---Return whether the given key was pressed this frame.
---@param key string LOVE key constant (e.g. "return", "space")
---@return boolean
function input:wasPressed(key)
    return self.keysPressed[key] or false
end

---@param dt number Delta time in seconds
---@return nil
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
