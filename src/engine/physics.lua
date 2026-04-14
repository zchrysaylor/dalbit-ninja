--- Utility module for common love.physics queries.
---@class physics
local physics = {}

---Check whether two Box2D bodies are currently touching.
---Iterates all active contacts on body1 and looks for a contact that involves body2.
---@param body1 love.Body First physics body
---@param body2 love.Body Second physics body
---@return boolean `true` if the two bodies have an active touching contact
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

-- TODO: add vector normalization function to account for diagonal speed

return physics
