local Level = {}
Level.__index = Level

function Level:update(dt)
	self.currentLevelMap:update(dt)
end

function Level:draw()
	self.currentLevelMap:draw()
end

function Level.new(player, levelMaps, startX, startY)
	local self = setmetatable({}, Level)
	self.player = player
	self.levelMaps = levelMaps or {}
	self.currentLevelMap = levelMaps[startY][startX]
	return self
end

return Level
