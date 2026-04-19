love.graphics.setDefaultFilter("nearest", "nearest", 1)

require("src.deps")

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

function love.resize(w, h)
	Push:resize(w, h)
end

function love.keypressed(key)
	Input:keyPressed(key)
end

function love.update(dt)
	Flux.update(dt)
	GStateStack:update(dt)
	Input:update(dt)
end

function love.draw()
	Push:start()
	GStateStack:draw()
	Push:finish()

	if Debug.isActive then
		Debug.drawFPS()
	end
end
