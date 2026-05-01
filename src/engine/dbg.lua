---Debug overlay module. Toggled via the GAME_DEBUG_TOGGLED event.
---@class dbg
local dbg = {}

---True while the collider outlines are visible.
---@type boolean
dbg.showColliders = false

---True while the debug overlay is visible.
---@type boolean
dbg.showDebugMenu = false

Herald.hearken(Events.GAME_DEBUG_COLLIDERS, function()
	dbg.showColliders = not dbg.showColliders
end)

Herald.hearken(Events.GAME_DEBUG_TOGGLED, function()
	dbg.showDebugMenu = not dbg.showDebugMenu
end)

---Draw outlines for all bodies in the given world.
---@param world love.World The Box2D world to draw fixtures for
---@param alpha? number Opacity of the outlines (default 1)
---@return nil
function dbg.drawAll(world, alpha)
	Collision.drawColliders(world, alpha)
	Collision.drawQueries(alpha)
end

---Draw the current FPS counter in the top-left corner of the virtual screen.
---@return nil
function dbg.drawFPS()
	local font = GFonts["debug"]
	local text = "FPS: " .. love.timer.getFPS()
	-- padding between background border and text
	local padding = 8

	local textW = font:getWidth(text)
	local textH = font:getHeight()

	-- screen margin
	local x = 16
	local y = 16

	Util.safeDraw(function()
		love.graphics.setColor(0, 0, 0, 0.7)
		love.graphics.rectangle("fill", x, y, textW + padding * 2, textH + padding * 2)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(font)
		love.graphics.print(text, x + padding, y + padding)
	end)
end

function dbg.drawMenu()
	-- TODO: finish implementing with option to show FPS, spawn enemies, change map, etc
	-- screen margin
	local x = WINDOW_WIDTH / 2 - WINDOW_WIDTH / 4
	local y = WINDOW_HEIGHT / 2 - WINDOW_HEIGHT / 4

	Util.safeDraw(function()
		love.graphics.setColor(0, 0, 0, 0.4)
		love.graphics.rectangle("fill", x, y, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
	end)
end

return dbg
