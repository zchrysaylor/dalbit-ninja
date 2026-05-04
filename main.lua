love.graphics.setDefaultFilter("nearest", "nearest", 1)

require("src.deps")

---@return nil
function love.load()
	love.window.setTitle("Dalbit Ninja")
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true,
	})
	Lens.setZoom(View.getScale())

	GStateStack = StateStack.new()
	GStateStack:push(StartState.new())
end

---@param w number
---@param h number
---@return nil
function love.resize(w, h)
	Lens.setZoom(View.getScale())
end

---@param key string
---@return nil
function love.keypressed(key)
	Input:keyPressed(key)
end

---@param text string
---@return nil
function love.textinput(text)
	Input:textInput(text)
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
	GStateStack:draw()

	if Debug.showColliders then
		Debug.drawFPS()
	end

	if Debug.showDebugMenu then
		Debug.drawMenu()
	end
end
