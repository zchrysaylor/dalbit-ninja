local EntitySpawner = {}

function EntitySpawner.spawn(world, obj)
	if obj.name == "pointFireEnemy" then
		local fireEnemy = Entity.new({
			x = obj.x,
			y = obj.y,
			width = 16,
			height = 16,
			speed = 0.8,
			scale = 1,
			spriteSheet = GArt["sprite-enemy-fire"],
			world = world,
		})
		return fireEnemy
	end
end

function EntitySpawner.destroyAll(entities)
	for _, entity in ipairs(entities) do
		entity.collision.body:destroy()
	end
end

return EntitySpawner
