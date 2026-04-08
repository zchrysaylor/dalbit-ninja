local BaseState = require("src.state.BaseState")

local SoulIdleState = {}
SoulIdleState.__index = SoulIdleState
setmetatable(SoulIdleState, { __index = BaseState })

-- TODO: implement update function to gotoFrame idle frame

function SoulIdleState.new(entity)
	local self = BaseState.new(SoulIdleState)
	self.entity = entity
	return self
end

return SoulIdleState
