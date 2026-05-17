---A grab bag of utility functions.
---@class util
local util = {}

---Executes a drawing callback with a fully isolated graphics state.
---Saves all graphics state (color, font, blend mode, transform, etc.) before
---calling `fn`, then restores it afterward using love.graphics push/pop.
---Use this anywhere temporary graphics state changes (setColor, setFont, etc.)
---must not leak into the surrounding draw pipeline.
---@param fn fun() Drawing callback to execute in isolation
---@return nil
function util.safeDraw(fn)
    love.graphics.push("all")
    fn()
    love.graphics.pop()
end

---Return the squared distance between two points.
---Useful for range checks that intentionally avoid taking a square root.
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function util.distanceSquared(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return dx * dx + dy * dy
end

---Return a shallow copy of a table.
---@generic T : table
---@param source T Table to copy.
---@return T copy Copied table with the same first-level keys and values.
function util.shallowCopy(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

return util
