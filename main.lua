love.graphics.setDefaultFilter("nearest", "nearest")

require("src.Deps")

function love.load()
	love.window.setTitle("LBA: Lua Boy Advance")

	Camera = HumpCamera()
	Camera:zoomTo(1)
	Map = Tiled("maps/map-hometown-color.lua")
	World = love.physics.newWorld(0, 0)

	-- TODO: refactor to use love.keyboard.keysPressed
	KeyPress = {}
	KeyPress.order = {}

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

function love.resize(w, h)
	Push:resize(w, h)
end

function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true
	if key == KEY_UP or key == KEY_DOWN or key == KEY_LEFT or key == KEY_RIGHT then
		-- Remove if already in stack (prevent duplicates)
		for i, k in ipairs(KeyPress.order) do
			if k == key then
				table.remove(KeyPress.order, i)
				break
			end
		end

		-- Push to stack (most recent)
		table.insert(KeyPress.order, 1, key)
	end

	if key == "escape" then
		love.event.quit()
	end
end

function love.keyreleased(key)
	-- Remove from tracking when released
	for i, k in ipairs(KeyPress.order) do
		if k == key then
			table.remove(KeyPress.order, i)
			break
		end
	end
end

function love.update(dt)
	Timer.update(dt)
	GStateMachine:update(dt)
	love.keyboard.keysPressed = {}
end

function love.draw()
	Push:start()
	GStateMachine:draw()
	Push:finish()
end
