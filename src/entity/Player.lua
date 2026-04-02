local Entity = require("src.entity.Entity")

local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Entity })

function Player:createCollision()
	Entity.createCollision(self)
	self.collision.body:setLinearDamping(0) -- no friction slowdown since you control velocity directly
end

local function newPlayer(def)
	return Entity.newEntity(def, Player)
end

return { newPlayer = newPlayer }
