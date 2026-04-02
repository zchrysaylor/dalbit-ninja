local LevelMap = {}
LevelMap.__index = LevelMap

function LevelMap:update(dt)
	self.player.animations.current:update(dt)
end

function LevelMap:draw()
	self.map:drawLayer(self.map.layers["base"])
	self.map:drawLayer(self.map.layers["ground"])
	self.map:drawLayer(self.map.layers["hill"])
	self.map:drawLayer(self.map.layers["house"])
	self.player:draw()
end

function LevelMap.new(player, x, y)
	local self = setmetatable({}, LevelMap)
	self.map = Tiled("maps/map-start.lua")
	self.player = player
	self.x = x or 1
	self.y = y or 1
	self.width = self.map.width * self.map.tilewidth
	self.height = self.map.height * self.map.tileheight

	self.entities = {}
end

return LevelMap
