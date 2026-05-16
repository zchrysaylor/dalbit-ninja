-- Collision queries and debug rendering for Box2D colliders.
---@class collision
local collision = {}

collision.queryDebugDraw = {}
collision.queryDebugFrames = 10 -- how many frames each shape persists

---Return true when a point lies inside or on a circle.
---@param px number
---@param py number
---@param cx number
---@param cy number
---@param radius number
---@return boolean
local function pointInCircle(px, py, cx, cy, radius)
    return Util.distanceSquared(px, py, cx, cy) <= radius * radius
end

---Return the squared distance from a point to a line segment.
---Used for circle-vs-edge checks without taking square roots.
---@param px number
---@param py number
---@param ax number
---@param ay number
---@param bx number
---@param by number
---@return number
local function distanceSquaredToSegment(px, py, ax, ay, bx, by)
    local abx = bx - ax
    local aby = by - ay
    local apx = px - ax
    local apy = py - ay
    local abLenSq = Util.distanceSquared(ax, ay, bx, by)
    if abLenSq == 0 then
        return Util.distanceSquared(px, py, ax, ay)
    end
    local t = (apx * abx + apy * aby) / abLenSq
    t = math.max(0, math.min(1, t))
    local closestX = ax + abx * t
    local closestY = ay + aby * t
    return Util.distanceSquared(px, py, closestX, closestY)
end

---Return true when a point lies inside a polygon using ray casting.
---@param px number
---@param py number
---@param vertices number[] World-space polygon vertices as `{x1, y1, ...}`
---@return boolean
local function pointInPolygon(px, py, vertices)
    local inside = false
    local count = #vertices
    for i = 1, count, 2 do
        local j = i + 2
        if j > count then
            j = 1
        end
        local xi = vertices[i]
        local yi = vertices[i + 1]
        local xj = vertices[j]
        local yj = vertices[j + 1]
        local intersects = ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi)
        if intersects then
            inside = not inside
        end
    end
    return inside
end

---Return true when a circle overlaps a polygon.
---Checks center containment, vertex inclusion, and edge distance.
---@param cx number
---@param cy number
---@param radius number
---@param vertices number[] World-space polygon vertices as `{x1, y1, ...}`
---@return boolean
local function circleIntersectsPolygon(cx, cy, radius, vertices)
    local radiusSq = radius * radius
    -- If the circle center is inside the polygon, they overlap.
    if pointInPolygon(cx, cy, vertices) then
        return true
    end
    -- If any polygon vertex is inside the circle, they overlap.
    for i = 1, #vertices, 2 do
        if pointInCircle(vertices[i], vertices[i + 1], cx, cy, radius) then
            return true
        end
    end
    -- If the circle reaches any polygon edge, they overlap.
    for i = 1, #vertices, 2 do
        local j = i + 2
        if j > #vertices then
            j = 1
        end
        local ax = vertices[i]
        local ay = vertices[i + 1]
        local bx = vertices[j]
        local by = vertices[j + 1]
        if distanceSquaredToSegment(cx, cy, ax, ay, bx, by) <= radiusSq then
            return true
        end
    end
    return false
end

---Return true when a fixture's shape overlaps the given query circle.
---Only PolygonShape and CircleShape are supported by this helper.
---@param fixture love.Fixture
---@param cx number
---@param cy number
---@param radius number
---@return boolean
local function fixtureIntersectsCircle(fixture, cx, cy, radius)
    local shape = fixture:getShape()
    local shapeType = shape:type()
    local body = fixture:getBody()
    if shapeType == "PolygonShape" then
        local vertices = { body:getWorldPoints(shape:getPoints()) }
        return circleIntersectsPolygon(cx, cy, radius, vertices)
    end
    if shapeType == "CircleShape" then
        local bodyX, bodyY = body:getPosition()
        local offsetX, offsetY = shape:getPoint()
        local fx = bodyX + offsetX
        local fy = bodyY + offsetY
        local totalRadius = radius + shape:getRadius()
        return Util.distanceSquared(cx, cy, fx, fy) <= totalRadius * totalRadius
    end
    return false
end

---Query all colliders overlapping a circle in world space.
---Uses Box2D's AABB query as a broad phase, then performs a precise shape
---intersection test before returning wrapper colliders.
---@param world love.World
---@param x number Circle center X in pixels
---@param y number Circle center Y in pixels
---@param radius number Circle radius in pixels
---@param filter? fun(collider: collider, fixture: love.Fixture): boolean Optional predicate to reject colliders before the narrow-phase test.
---@param debugFrames? number The number of debug frames to print in debug mode
---@return collider[]
function collision.queryCircleArea(world, x, y, radius, filter, debugFrames)
    local results = {}
    local seen = {}

    if Debug.showColliders then
        -- Keep debug query lifetimes bounded even when queries are called repeatedly.
        table.insert(collision.queryDebugDraw, {
            type = "circle",
            x = x,
            y = y,
            r = radius,
            frames = debugFrames or collision.queryDebugFrames,
        })
    end

    world:queryBoundingBox(x - radius, y - radius, x + radius, y + radius, function(fixture)
        local collider = fixture:getUserData()
        if not collider or seen[collider] then
            return true
        end
        if filter and not filter(collider, fixture) then
            return true
        end
        if fixtureIntersectsCircle(fixture, x, y, radius) then
            seen[collider] = true
            table.insert(results, collider)
        end
        return true
    end)
    return results
end

---Check whether two colliders are currently touching.
---Returns false immediately if either collider has been destroyed.
---Iterates active contacts on c1's body and looks for a touching contact with c2's body.
---@param c1 collider First collider
---@param c2 collider Second collider
---@return boolean `true` if the two colliders have an active touching contact
function collision.isColliding(c1, c2)
    if c1:isDestroyed() or c2:isDestroyed() then
        return false
    end

    local b1 = c1.body
    local b2 = c2.body
    for _, contact in ipairs(b1:getContacts()) do
        if contact:isTouching() then
            local f1, f2 = contact:getFixtures()
            local fb1, fb2 = f1:getBody(), f2:getBody()
            if (fb1 == b1 and fb2 == b2) or (fb1 == b2 and fb2 == b1) then
                return true
            end
        end
    end
    return false
end

---Draw collision outlines for all bodies in the world. Debug use only.
---@param world love.World
---@param alpha? number Outline opacity from 0 to 1 (default 1)
---@return nil
function collision.drawColliders(world, alpha)
    Util.safeDraw(function()
        alpha = alpha or 1
        love.graphics.setColor(love.math.colorFromBytes(64, 39, 81, alpha * 255))
        local bodies = world:getBodies()
        for _, body in ipairs(bodies) do
            for _, fixture in ipairs(body:getFixtures()) do
                if fixture:getShape():type() == "PolygonShape" then
                    love.graphics.polygon("line", body:getWorldPoints(fixture:getShape():getPoints()))
                elseif fixture:getShape():type() == "CircleShape" then
                    local bodyX, bodyY = body:getPosition()
                    local offsetX, offsetY = fixture:getShape():getPoint()
                    love.graphics.circle("line", bodyX + offsetX, bodyY + offsetY, fixture:getShape():getRadius())
                end
            end
        end
    end)
end

---Draw outlines for all recorded queries. Debug use only.
---@param alpha? number Outline opacity from 0 to 1 (default 1)
---@return nil
function collision.drawQueries(alpha)
    for _, q in ipairs(collision.queryDebugDraw) do
        q.frames = q.frames - 1
    end

    Util.safeDraw(function()
        alpha = alpha or 1
        love.graphics.setColor(0, 0.8, 0.8, alpha) -- teal, distinct from purple colliders
        for _, q in ipairs(collision.queryDebugDraw) do
            if q.type == "circle" then
                love.graphics.circle("line", q.x, q.y, q.r)
            end
        end
    end)

    -- sweep expired entries in reverse to avoid index-shift bugs
    for i = #collision.queryDebugDraw, 1, -1 do
        if collision.queryDebugDraw[i].frames <= 0 then
            table.remove(collision.queryDebugDraw, i)
        end
    end
end

return collision
