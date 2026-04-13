local dbg = {}
dbg.isActive = false

Signal.connect(Events.GAME_DEBUG_TOGGLED, function()
	dbg.isActive = not dbg.isActive
end)

function dbg.drawCollisions(world, alpha)
	Collision.drawAll(world, alpha)
end

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

	love.graphics.setColor(0, 0, 0, 0.7)
	love.graphics.rectangle("fill", x, y, textW + padding * 2, textH + padding * 2)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(font)
	love.graphics.print(text, x + padding, y + padding)
end

return dbg
