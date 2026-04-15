-- Collision queries and debug rendering for Box2D colliders.
---@class collision
local collision = {}

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

-- TODO: add a queryCircleArea for interactions (https://www.youtube.com/watch?v=2EPBHHE-ZU0&list=PLqPLyUreLV8D3Ckd_9UFNvEpg4xCvbL1a&index=4)

---Draw collision outlines for all bodies in the world. Debug use only.
---@param world love.World
---@param alpha? number Outline opacity from 0 to 1 (default 1)
function collision.drawAll(world, alpha)
	Util.safeDraw(function()
		alpha = alpha or 1
		love.graphics.setColor(love.math.colorFromBytes(64, 39, 81, alpha * 255))
		local bodies = world:getBodies()
		for _, body in ipairs(bodies) do
			for _, fixture in ipairs(body:getFixtures()) do
				if fixture:getShape():type() == "PolygonShape" then
					love.graphics.polygon("line", body:getWorldPoints(fixture:getShape():getPoints()))
				end
			end
		end
	end)
end

return collision
