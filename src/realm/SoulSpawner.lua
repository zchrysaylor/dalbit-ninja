local SoulSpawner = {}

function SoulSpawner.spawn(world, obj)
	if obj.name == "pointFireEnemy" then
		local fireEnemy = Soul.new({
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

function SoulSpawner.destroyAll(entities)
	for _, entity in ipairs(entities) do
		entity.collision.body:destroy()
		-- TODO: call exitState() on cleanup?
		-- entity.stateMachine.currentState:exitState()
	end
end

return SoulSpawner
