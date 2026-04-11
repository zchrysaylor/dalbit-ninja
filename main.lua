love.graphics.setDefaultFilter("nearest", "nearest")

require("src.deps")

function love.load()
	love.window.setTitle("LBA: Lua Boy Advance")

	Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		vsync = true,
		fullscreen = false,
		resizable = true,
	})

	GStateMachine = StateMachine.new({
		["start"] = function()
			return StartState.new()
		end,
		["play"] = function()
			return PlayState.new()
		end,
	})
	GStateMachine:changeState("start")

	love.keyboard.keysPressed = {}
end

-- resize the game window using Push's pixel-perfect scaling
function love.resize(w, h)
	Push:resize(w, h)
end

function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true

	if key == "escape" then
		love.event.quit()
	end
end

function love.update(dt)
	Flux.update(dt)
	GStateMachine:update(dt)
	love.keyboard.keysPressed = {}
end

function love.draw()
	Push:start()
	GStateMachine:draw()
	Push:finish()
end
