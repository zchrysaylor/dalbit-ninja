---Debug overlay module. Toggled via the GAME_DEBUG_TOGGLED event.
---@class dbg
local dbg = {}

---True while the debug overlay is visible.
---@type boolean
dbg.isActive = false

Herald.hearken(Events.GAME_DEBUG_TOGGLED, function()
	dbg.isActive = not dbg.isActive
end)

---Draw outlines for all bodies in the given world.
---@param world love.World The Box2D world to draw fixtures for
---@param alpha? number Opacity of the outlines (default 1)
---@return nil
function dbg.drawAll(world, alpha)
	Collision.drawColliders(world, alpha)
	Collision.drawQueries(alpha)
end

-- TODO: fix FPS to 60 FPS somehow
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

return dbg
