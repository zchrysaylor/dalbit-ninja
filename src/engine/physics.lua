-- A util class for common love.physics use cases
local physics = {}

-- Checks if two objects are colliding
function physics.isColliding(body1, body2)
	for _, contact in ipairs(body1:getContacts()) do
		if contact:isTouching() then
			local f1, f2 = contact:getFixtures()
			local b1, b2 = f1:getBody(), f2:getBody()
			if (b1 == body1 and b2 == body2) or (b1 == body2 and b2 == body1) then
				return true
			end
		end
	end
	return false
end

return physics
