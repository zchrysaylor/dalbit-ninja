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

---Draw collider outlines and recorded query outlines in the given world.
---@param world love.World The Box2D world to draw fixtures for
---@param alpha? number Opacity of the outlines (default 1)
---@return nil
function dbg.drawAll(world, alpha)
    Collision.drawColliders(world, alpha)
    Collision.drawQueries(alpha)
end

---Draw the current FPS counter in the top-left corner of the screen.
---@return nil
function dbg.drawFPS()
    local font = GFonts["debug"]
    local text = "FPS: " .. love.timer.getFPS()
    local padding = 8
    local screenMargin = 16

    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    local textX = screenMargin + padding
    local textY = screenMargin + padding

    Util.safeDraw(function()
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle(
            "fill", screenMargin, screenMargin, textWidth + padding * 2, textHeight + padding * 2
        )

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.print(text, textX, textY)
    end)
end

---Draw the debug menu backdrop.
---@return nil
function dbg.drawMenu()
    -- TODO: finish implementing with option to show FPS, spawn enemies, change map, etc
    local screenWidth = View.getWidth()
    local screenHeight = View.getHeight()
    local menuWidth = screenWidth / 2
    local menuHeight = screenHeight / 2
    local menuX = (screenWidth - menuWidth) / 2
    local menuY = (screenHeight - menuHeight) / 2

    Util.safeDraw(function()
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", menuX, menuY, menuWidth, menuHeight)
    end)
end

return dbg
