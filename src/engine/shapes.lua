-- Constructors for collider shapes in body-local coordinates.
---@class shapes
local shapes = {}

---Create a centered rectangle shape.
---@param width number
---@param height number
---@return love.PolygonShape
function shapes.rectangle(width, height)
    return love.physics.newRectangleShape(width, height)
end

---Create a centered rectangle with beveled corners.
---@param width number
---@param height number
---@param bevel number Corner inset in pixels
---@return love.PolygonShape
function shapes.octagon(width, height, bevel)
    return love.physics.newPolygonShape(
        -width / 2,
        -height / 2 + bevel,
        -width / 2 + bevel,
        -height / 2,
        width / 2 - bevel,
        -height / 2,
        width / 2,
        -height / 2 + bevel,
        width / 2,
        height / 2 - bevel,
        width / 2 - bevel,
        height / 2,
        -width / 2 + bevel,
        height / 2,
        -width / 2,
        height / 2 - bevel
    )
end

return shapes
