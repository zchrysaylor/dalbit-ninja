local BaseState = require("src.state.BaseState")

---@class SoulIdleState : BaseState
---@field soul Soul
local SoulIdleState = {}
SoulIdleState.__index = SoulIdleState
setmetatable(SoulIdleState, { __index = BaseState })

function SoulIdleState:enterState(args)
	self.soul.animations.current:pauseAtStart()
end

function SoulIdleState:update(dt) end

---@param soul Soul
---@return SoulIdleState
function SoulIdleState.new(soul)
	local self = BaseState.new(SoulIdleState)
	self.soul = soul
	return self
end

return SoulIdleState
