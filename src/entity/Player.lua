local Entity = require("src.entity.Entity")

local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Entity })

function Player:createCollision(world)
	Entity.createCollision(self, world)
	self.collision.body:setLinearDamping(0) -- no friction slowdown since you control velocity directly
end

function Player.new(def)
	return Entity.new(def)
end

return Player
