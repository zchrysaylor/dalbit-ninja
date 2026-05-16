--- Factory module that manages projectile lifecycles.
---@class ProjectileSpawner
local ProjectileSpawner = {}

---Destroy all projectile physics bodies in the provided array.
---@param projectiles any[] Array of projectile entities to destroy
---@return nil
function ProjectileSpawner.destroyAll(projectiles)
	for _, p in ipairs(projectiles) do
		if p.destroy then
			p:destroy()
		end
	end
end

return ProjectileSpawner
