local WallSpawner = {}

function WallSpawner.spawn(world, obj)
	local centerX = obj.x + obj.width / 2
	local centerY = obj.y + obj.height / 2
	local wall = Collision.newRectangle(world, centerX, centerY, obj.width, obj.height)
	return wall
end

function WallSpawner.destroyAll(walls)
	for _, wall in ipairs(walls) do
		wall.body:destroy()
	end
end

return WallSpawner
