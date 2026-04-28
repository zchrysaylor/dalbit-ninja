love.graphics.setDefaultFilter("nearest", "nearest", 1)

require("src.deps")

---@return nil
function love.load()
	love.window.setTitle("LBA: Lua Boy Advance")

	Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true,
	})

	GStateStack = StateStack.new()
	GStateStack:push(StartState.new())
end

---@param w number
---@param h number
---@return nil
function love.resize(w, h)
	Push:resize(w, h)
end

---@param key string
---@return nil
function love.keypressed(key)
	Input:keyPressed(key)
end

---@param dt number
---@return nil
function love.update(dt)
	Flux.update(dt)
	GStateStack:update(dt)
	Input:update(dt)
end

---@return nil
function love.draw()
	Push:start()
	GStateStack:draw()
	Push:finish()

	if Debug.isActive then
		Debug.drawFPS()
	end
end
